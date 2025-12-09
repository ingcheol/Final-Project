package edu.sm.app.springai.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.SimpleLoggerAdvisor;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.content.Media;
import org.springframework.ai.document.Document;
import org.springframework.ai.document.DocumentReader;
import org.springframework.ai.reader.TextReader;
import org.springframework.ai.reader.pdf.PagePdfDocumentReader;
import org.springframework.ai.reader.tika.TikaDocumentReader;
import org.springframework.ai.transformer.splitter.TokenTextSplitter;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.Ordered;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.Resource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;
import org.springframework.util.MimeTypeUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.multipart.MultipartFile;
import reactor.core.publisher.Flux;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
@Slf4j
public class ETLService {
  // ##### 필드 #####
  private ChatClient chatClient;
  @Autowired
  private VectorStore vectorStore;
  @Autowired private JdbcTemplate jdbcTemplate;


  // ##### 생성자 #####
  public ETLService(ChatClient.Builder chatClientBuilder) {
    this.chatClient = chatClientBuilder
            .defaultAdvisors(
                    new SimpleLoggerAdvisor(Ordered.LOWEST_PRECEDENCE - 1)
            )
            .build();
  }

  // ##### 벡터 저장소의 데이터를 모두 삭제하는 메소드 #####
  public void clearVectorStore() {
    jdbcTemplate.update("TRUNCATE TABLE vector_store");
  }


  // ##### 업로드된 파일을 가지고 ETL 과정을 처리하는 메소드 #####
  public String etlFromFile(String type, MultipartFile attach) throws IOException {

    // 추출하기
    List<Document> documents = extractFromFile(attach);
    if (documents == null) {
      return ".txt, .pdf, .doc, .docx 파일 중에 하나를 올려주세요.";
    }
    log.info("추출된 Document 수: {} 개", documents.size());
    for (Document doc : documents) {
      doc.getMetadata().put("type", type);
    }
    // 메타데이터에 공통 정보 추가하기
//    for (Document doc : documents) {
//      Map<String, Object> metadata = doc.getMetadata();
//      metadata.putAll(Map.of(
//          "type", type,
//          "source", attach.getOriginalFilename()));
//    }

    // 변환하기
    documents = transform(documents);
    log.info("변환된 Document 수: {} 개", documents.size());

    // 적재하기
    vectorStore.add(documents);

    return "올린 문서를 추출-변환-적재 완료 했습니다.";
  }

  // ##### 업로드된 파일로부터 텍스트를 추출하는 메소드 #####
  private List<Document> extractFromFile(MultipartFile attach) throws IOException {
    // 바이트 배열을 Resource로 생성
    Resource resource = new ByteArrayResource(attach.getBytes());

    List<Document> documents = null;
    if (attach.getContentType().equals("text/plain")) {
      // Text(.txt) 파일일 경우
      DocumentReader reader = new TextReader(resource);
      documents = reader.read();
    } else if (attach.getContentType().equals("application/pdf")) {
      // PDF(.pdf) 파일일 경우
      DocumentReader reader = new PagePdfDocumentReader(resource);
      documents = reader.read();
    } else if (attach.getContentType().contains("wordprocessingml")) {
      // Word(.doc, .docx) 파일일 경우
      DocumentReader reader = new TikaDocumentReader(resource);
      documents = reader.read();
    }else if (attach.getContentType().startsWith("image/")) {
      // 이미지 파일일 경우 (JPG, JPEG, PNG)
      log.info("이미지 파일 감지 - ContentType: {}", attach.getContentType());

      // GIF 차단
      if (attach.getContentType().equals("image/gif")) {
        log.warn("GIF 파일은 지원하지 않습니다.");
        return null;
      }

      // GPT-4 Vision으로 OCR 수행
      String extractedText = extractTextFromImage(attach);

      // Document 생성
      Map<String, Object> metadata = new HashMap<>();
      metadata.put("source", attach.getOriginalFilename());
      metadata.put("content_type", attach.getContentType());
      metadata.put("extraction_method", "gpt4_vision_ocr");

      Document document = new Document(extractedText, metadata);
      documents = new ArrayList<>();
      documents.add(document);

      log.info("이미지에서 추출된 텍스트 길이: {} 글자", extractedText.length());
    }

    return documents;
  }

  // ##### GPT-4 Vision으로 이미지에서 텍스트 추출 (OCR) #####
  private String extractTextFromImage(MultipartFile imageFile) throws IOException {
    log.info("GPT-4 Vision OCR 시작 - 파일: {}", imageFile.getOriginalFilename());

    try {
      byte[] imageBytes = imageFile.getBytes();
      Resource imageResource = new ByteArrayResource(imageBytes);

      // MIME 타입 결정
      String mimeType = imageFile.getContentType();
      if (mimeType == null) {
        mimeType = "image/jpeg";
      }

      // Vision API 호출용 프롬프트
      String prompt = """
          이 이미지는 병원 진단서 또는 처방전입니다.
          이미지에서 다음 정보를 정확하게 추출해주세요:
          
          1. 환자 정보 (이름, 나이, 성별 등)
          2. 진단명 또는 질병명
          3. 처방된 약물 및 용량
          4. 의사 소견 및 검사 결과
          5. 진료 날짜 및 병원 정보
          6. 기타 중요 의료 정보
          
          한국어로 정확하게 추출하고, 읽을 수 없는 부분은 "확인 불가"로 표시해주세요.
          추출한 정보를 구조화된 형식으로 제공해주세요.
          """;

      // final 변수로 선언 (람다 캡처용)
      final String finalMimeType = mimeType;

      // Chatlient로 Vision API 호출
      String extractedText = chatClient.prompt()
          .user(u -> u
              .text(prompt)
              .media(new Media(MimeTypeUtils.parseMimeType(finalMimeType), imageResource)))
          .call()
          .content();

      return extractedText;

    } catch (Exception e) {
      throw new IOException("이미지 분석 중 오류가 발생했습니다: " + e.getMessage());
    }
  }

  // ##### 작은 크기로 분할하고 키워드 메타데이터를 추가하는 메소드 #####
  private List<Document> transform(List<Document> documents) {
    List<Document> transformedDocuments = null;

    // 작게 분할하기
    TokenTextSplitter tokenTextSplitter = new TokenTextSplitter();
    transformedDocuments = tokenTextSplitter.apply(documents);

    return transformedDocuments;
  }

  // ##### LLM과 대화하는 메소드 #####
  public Flux<String> ragChat(String question, String type) {
    // 벡터 저장소 검색 조건 생성
    SearchRequest.Builder searchRequestBuilder = SearchRequest.builder()
            .similarityThreshold(0.0)
            .topK(3);
    if (StringUtils.hasText(type)) {
      searchRequestBuilder.filterExpression("type == '%s'".formatted(type));
    }
    SearchRequest searchRequest = searchRequestBuilder.build();


    // QuestionAnswerAdvisor 생성
    QuestionAnswerAdvisor questionAnswerAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
            .searchRequest(searchRequest)
            .build();

    // 프롬프트를 LLM으로 전송하고 응답을 받는 코드
//    String answer = this.chatClient.prompt()
//            .user(question)
//            .advisors(questionAnswerAdvisor)
//            .call()
//            .content();
    Flux<String> answer = this.chatClient.prompt()
            .user(question)
            .advisors(questionAnswerAdvisor)
            .stream()
            .content();
    return answer;
  }

}
