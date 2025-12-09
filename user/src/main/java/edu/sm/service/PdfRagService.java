package edu.sm.service;

import edu.sm.entity.MedicalDocument;
import edu.sm.repository.MedicalDocumentRepository;
import org.apache.pdfbox.pdmodel.PDDocument;
import org.apache.pdfbox.text.PDFTextStripper;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.core.io.ClassPathResource;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.io.File;
import java.io.InputStream;
import java.util.*;

@Service
public class PdfRagService {

    @Autowired
    private MedicalDocumentRepository medicalDocumentRepository;

    @Autowired
    private JdbcTemplate jdbcTemplate;

    @Autowired
    private ChatClient chatClient;

    /**
     * 서버 시작 시 PDF 인덱싱 실행
     */
    @PostConstruct
    public void init() {
        System.out.println("==============================================");
        System.out.println("  PDF 문서 인덱싱 시작");
        System.out.println("==============================================");
        indexAllPdfDocuments();
        System.out.println("==============================================");
        System.out.println("  ✅ PDF 인덱싱 완료!");
        System.out.println("==============================================");
    }

    /**
     * 모든 PDF 문서를 읽고 벡터 DB에 인덱싱
     */
    public void indexAllPdfDocuments() {
        System.out.println("=== PDF 문서 인덱싱 시작 ===");

        List<MedicalDocument> documents = medicalDocumentRepository.findAll();
        int totalChunks = 0;

        for (MedicalDocument doc : documents) {
            try {
                String text = extractTextFromPdf(doc.getFilePath());
                List<String> chunks = splitIntoChunks(text, 500);

                for (int i = 0; i < chunks.size(); i++) {
                    String chunk = chunks.get(i);
                    saveChunkToVectorDb(doc.getDocId(), doc.getFileName(), chunk, i);
                }

                totalChunks += chunks.size();
                System.out.println("✅ 인덱싱 완료: " + doc.getFileName() + " (" + chunks.size() + " chunks)");

            } catch (Exception e) {
                System.err.println("❌ 인덱싱 실패: " + doc.getFileName() + " - " + e.getMessage());
            }
        }

        System.out.println("=== 총 " + totalChunks + "개 청크 인덱싱 완료 ===");
    }

    /**
     * PDF 파일에서 텍스트 추출 (ClassPath 리소스 사용)
     */
    private String extractTextFromPdf(String filePath) throws Exception {
        System.out.println("📁 원본 경로: " + filePath);

        String fileName = new File(filePath).getName();
        PDDocument document = null;

        try {
            // 1. ClassPath에서 시도
            String resourcePath = "medical-data/" + fileName;
            ClassPathResource resource = new ClassPathResource(resourcePath);

            if (resource.exists()) {
                System.out.println("  ✅ ClassPath에서 발견: " + resourcePath);
                InputStream is = resource.getInputStream();
                byte[] bytes = is.readAllBytes();
                is.close();
                document = org.apache.pdfbox.Loader.loadPDF(bytes);
            } else {
                // 2. 파일 시스템에서 시도
                String[] possiblePaths = {
                        filePath,
                        "src/main/resources/medical-data/" + fileName,
                        System.getProperty("user.dir") + "/" + filePath
                };

                for (String path : possiblePaths) {
                    File file = new File(path);
                    if (file.exists()) {
                        System.out.println("  ✅ 파일 시스템에서 발견: " + file.getAbsolutePath());
                        document = org.apache.pdfbox.Loader.loadPDF(file);
                        break;
                    }
                }
            }

            if (document == null) {
                throw new Exception("파일을 찾을 수 없습니다: " + filePath);
            }

            PDFTextStripper stripper = new PDFTextStripper();
            String text = stripper.getText(document);
            document.close();

            System.out.println("✅ PDF 텍스트 추출 성공: " + text.length() + " 글자");
            return text;

        } catch (Exception e) {
            if (document != null) document.close();
            throw e;
        }
    }

    /**
     * 텍스트를 청크로 분할
     */
    private List<String> splitIntoChunks(String text, int chunkSize) {
        List<String> chunks = new ArrayList<>();
        String[] sentences = text.split("(?<=[.!?])\\s+");

        StringBuilder currentChunk = new StringBuilder();

        for (String sentence : sentences) {
            if (currentChunk.length() + sentence.length() > chunkSize && currentChunk.length() > 0) {
                chunks.add(currentChunk.toString().trim());
                currentChunk = new StringBuilder();
            }
            currentChunk.append(sentence).append(" ");
        }

        if (currentChunk.length() > 0) {
            chunks.add(currentChunk.toString().trim());
        }

        return chunks;
    }

    /**
     * 청크를 벡터 DB에 저장
     */
    private void saveChunkToVectorDb(Long docId, String fileName, String content, int chunkIndex) {
        try {
            // NULL 문자(0x00) 및 기타 특수문자 제거
            String cleanContent = content
                    .replace("\u0000", "")  // NULL 문자 제거
                    .replace("\r", " ")      // 캐리지 리턴 제거
                    .replaceAll("\\p{C}", "") // 모든 제어 문자 제거
                    .trim();

            // 빈 내용은 저장하지 않음
            if (cleanContent.isEmpty()) {
                return;
            }

            String sql = "INSERT INTO pdf_chunks (doc_id, file_name, content, chunk_index) VALUES (?, ?, ?, ?)";
            jdbcTemplate.update(sql, docId, fileName, cleanContent, chunkIndex);
        } catch (Exception e) {
            System.err.println("❌ 청크 저장 실패: " + e.getMessage());
        }
    }

    /**
     * 증상 기반 PDF RAG 분석 - 메인 메서드!
     */
    public String analyzeSymptoms(String symptomText) {
        System.out.println("🤖 PDF RAG 분석 시작: " + symptomText);

        try {
            // 1. 키워드 추출
            List<String> keywords = extractKeywords(symptomText);
            System.out.println("🔍 추출된 키워드: " + keywords);

            // 2. 관련 PDF 청크 검색
            List<String> relevantChunks = searchRelevantChunks(keywords);
            System.out.println("📚 관련 청크 " + relevantChunks.size() + "개 발견");

            if (relevantChunks.isEmpty()) {
                System.out.println("⚠️ 관련 PDF 내용 없음 - 일반 AI 분석 실행");
                return analyzeWithoutRag(symptomText);
            }

            // 3. RAG 프롬프트 생성
            String context = String.join("\n\n", relevantChunks);
            String prompt = buildRagPrompt(symptomText, context);

            // 4. AI 분석 요청
            System.out.println("🤖 AI 분석 요청 중...");
            String result = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();

            System.out.println("=== RAG 분석 완료 ===");
            return result;

        } catch (Exception e) {
            System.err.println("❌ RAG 분석 실패: " + e.getMessage());
            e.printStackTrace();
            return analyzeWithoutRag(symptomText);
        }
    }

    /**
     * 증상에서 키워드 추출
     */
    private List<String> extractKeywords(String symptomText) {
        String[] keywords = {"열", "기침", "두통", "복통", "설사", "구토", "호흡곤란",
                "가슴통증", "피부발진", "관절통", "근육통", "피로", "어지러움",
                "발열", "오한", "인후통", "콧물", "코막힘", "감염", "염증"};

        List<String> found = new ArrayList<>();
        for (String keyword : keywords) {
            if (symptomText.contains(keyword)) {
                found.add(keyword);
            }
        }

        if (found.isEmpty()) {
            found.add(symptomText.substring(0, Math.min(20, symptomText.length())));
        }

        return found;
    }

    /**
     * 키워드로 관련 PDF 청크 검색
     */
    private List<String> searchRelevantChunks(List<String> keywords) {
        List<String> chunks = new ArrayList<>();

        try {
            StringBuilder sql = new StringBuilder(
                    "SELECT DISTINCT content FROM pdf_chunks WHERE "
            );

            List<String> conditions = new ArrayList<>();
            for (String keyword : keywords) {
                conditions.add("content LIKE ?");
            }
            sql.append(String.join(" OR ", conditions));
            sql.append(" LIMIT 15");

            List<Object> params = new ArrayList<>();
            for (String keyword : keywords) {
                params.add("%" + keyword + "%");
            }

            chunks = jdbcTemplate.query(
                    sql.toString(),
                    params.toArray(),
                    (rs, rowNum) -> rs.getString("content")
            );

        } catch (Exception e) {
            System.err.println("❌ 청크 검색 실패: " + e.getMessage());
        }

        return chunks;
    }

    /**
     * RAG 프롬프트 생성 (간결한 형식)
     */
    private String buildRagPrompt(String symptomText, String context) {
        return String.format(
                """
                당신은 전문 의료 AI 어시스턴트입니다.
                
                다음은 의료 가이드라인 문서에서 추출한 관련 정보입니다:
                
                === 의료 가이드라인 ===
                %s
                ========================
                
                환자가 입력한 증상:
                "%s"
                
                위 의료 가이드라인을 참고하여 다음 형식으로 간결하게 분석해주세요:
                
                **예상 진단:**
                - 가장 가능성 높은 질환 1-2가지만 간단히 (각 1-2줄)
                
                **주요 증상 분석:**
                - 핵심 증상 2-3가지만 요약 (각 1줄)
                
                **권장 진료과:**
                - 진료과 이름과 간단한 이유 (1줄)
                
                **시급성:**
                - 즉시/24시간내/일주일내 중 하나와 간단한 이유 (1-2줄)
                
                **응급 상황:**
                - 즉시 병원 가야 하는 증상 2-3가지만 (각 1줄)
                
                **자가 관리:**
                - 실천 가능한 조치 3가지만 간단히 (각 1줄)
                
                전문적이지만 일반인이 이해하기 쉽게, 각 항목은 3줄 이내로 간결하게 작성해주세요.
                불필요한 서론이나 반복 설명은 제외하고 핵심만 전달해주세요.
                """,
                context,
                symptomText
        );
    }

    /**
     * RAG 없이 일반 AI 분석 (간결한 형식)
     */
    private String analyzeWithoutRag(String symptomText) {
        try {
            System.out.println("🤖 일반 AI 분석 실행");

            String prompt = String.format(
                    """
                    당신은 전문 의료 AI 어시스턴트입니다.
                    
                    환자가 입력한 증상:
                    "%s"
                    
                    다음 형식으로 간결하게 분석해주세요:
                    
                    **예상 진단:**
                    - 가장 가능성 높은 질환 1-2가지만 간단히 (각 1-2줄)
                    
                    **주요 증상 분석:**
                    - 핵심 증상 2-3가지만 요약 (각 1줄)
                    
                    **권장 진료과:**
                    - 진료과 이름과 간단한 이유 (1줄)
                    
                    **시급성:**
                    - 즉시/24시간내/일주일내 중 하나와 간단한 이유 (1-2줄)
                    
                    **응급 상황:**
                    - 즉시 병원 가야 하는 증상 2-3가지만 (각 1줄)
                    
                    **자가 관리:**
                    - 실천 가능한 조치 3가지만 간단히 (각 1줄)
                    
                    전문적이지만 일반인이 이해하기 쉽게, 각 항목은 3줄 이내로 간결하게 작성해주세요.
                    불필요한 서론이나 반복 설명은 제외하고 핵심만 전달해주세요.
                    """,
                    symptomText
            );

            String result = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();

            System.out.println("✅ 일반 AI 분석 완료");
            return result;

        } catch (Exception e) {
            System.err.println("❌ 일반 AI 분석 실패: " + e.getMessage());
            return getDefaultAnalysis(symptomText);
        }
    }

    /**
     * 기본 분석 결과 (모든 AI 호출 실패 시)
     */
    private String getDefaultAnalysis(String symptomText) {
        return String.format(
                """
                입력하신 증상: %s
                
                현재 AI 분석 서비스에 일시적인 문제가 발생했습니다.
                
                일반적인 권장사항:
                - 증상이 심각하거나 악화되는 경우 즉시 병원을 방문하세요
                - 고열(38.5도 이상)이 지속되면 응급실을 방문하세요
                - 호흡곤란, 심한 통증이 있으면 119에 연락하세요
                
                가까운 병원의 일반내과 또는 가정의학과를 방문하시기 바랍니다.
                """,
                symptomText
        );
    }
}