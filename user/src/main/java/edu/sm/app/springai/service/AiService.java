package edu.sm.app.springai.service;

import edu.sm.app.dto.NewsDto;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.stereotype.Service;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Autowired;
import reactor.core.publisher.Flux;



@Service
@Slf4j
public class AiService {
    @Autowired
    private ChatModel chatModel;
    private final ChatClient chatClient;
    private final ObjectMapper objectMapper; // JSON 파싱용

    public AiService(ChatClient.Builder builder, ObjectMapper objectMapper) {
        this.chatClient = builder.build();
        this.objectMapper = objectMapper;
    }

    /**
     * 네이버 검색 결과를 AI가 분석하여 3개를 선정해주는 메서드
     */
    public List<NewsDto> curateNews(String rawJsonItems, String diseaseName) {
        // 프롬프트 엔지니어링
        String prompt = String.format("""
            다음은 '%s'와 관련된 뉴스 검색 결과(JSON)입니다.
            
            [데이터]: %s
            
            [지시사항]:
            1. 이 중에서 환자에게 가장 유용하고 신뢰할 수 있는 최신 의료 정보 3개만 선정하세요.
            2. 단순 병원 광고, 홍보성 기사, 중복된 내용은 반드시 제외하세요.
            3. 제목(title)의 HTML 태그(<b> 등)는 모두 제거하세요.
            4. 설명(description)은 환자가 이해하기 쉽게 2문장 내외로 요약하세요.
            5. 결과는 반드시 아래 JSON 배열 포맷으로만 출력하세요 (마크다운 코드 블록 제외).
            
            [{"title": "...", "originLink": "...", "description": "...", "pubDate": "..."}]
            """, diseaseName, rawJsonItems);

        try {
            // AI 호출
            String response = chatClient.prompt().user(prompt).call().content();

            // AI 응답이 가끔 ```json ... ``` 으로 감싸져 올 때가 있어서 처리
            if (response.startsWith("```json")) {
                response = response.substring(7, response.lastIndexOf("```"));
            } else if (response.startsWith("```")) {
                response = response.substring(3, response.lastIndexOf("```"));
            }

            // JSON 문자열을 Java 리스트로 변환
            return objectMapper.readValue(response, new TypeReference<List<NewsDto>>() {});

        } catch (Exception e) {
            // AI 호출 실패 시 빈 리스트 반환 (화면 에러 방지)
            e.printStackTrace();
            return new ArrayList<>();
        }
    }
    public String generateText(String question){
        SystemMessage systemMessage = SystemMessage.builder()
                .text("사용자 질문에 대해서 한국어로 친절하게 답변해야 합니다. ").build();
        UserMessage userMessage = UserMessage.builder().text(question).build();
        ChatOptions chatOptions = ChatOptions.builder().build();
        Prompt prompt = Prompt.builder()
                .messages(systemMessage,userMessage)
                .chatOptions(chatOptions).build();

        ChatResponse chatResponse = chatModel.call(prompt);
        AssistantMessage assistantMessage = chatResponse.getResult().getOutput();
        return assistantMessage.getText();

    }
    public Flux<String> geneateStreamText(String question){
        SystemMessage systemMessage = SystemMessage.builder()
                .text("사용자 질문에 대해서 한국어로 친절하게 답변해야 합니다. ").build();
        UserMessage userMessage = UserMessage.builder().text(question).build();
        ChatOptions chatOptions = ChatOptions.builder().build();
        Prompt prompt = Prompt.builder()
                .messages(systemMessage,userMessage)
                .chatOptions(chatOptions).build();



        Flux<ChatResponse> fluxResponse = chatModel.stream(prompt);
        Flux<String> fluxString = fluxResponse.map(chatResponse -> {
            AssistantMessage assistantMessage = chatResponse.getResult().getOutput();
            String chunk = assistantMessage.getText();
            if (chunk == null) chunk = "";
            return chunk;
        });
        log.info(fluxString.toString());
        return fluxString;
    }

  public String translate(String text, String targetLang) {
    // consul에 쓸거, AiChatController
    String templateMsg = """
                Translate the following text into {targetLang}.
                Only return the translated text. Do not add explanations.
                Text: {text}
                """;
    try {
      PromptTemplate template = new PromptTemplate(templateMsg);
      Prompt prompt = template.create(Map.of("targetLang", targetLang, "text", text));
      return chatClient.prompt(prompt).call().content();
    } catch (Exception e) {
      e.printStackTrace();
      return text; // 에러나면 원문 그대로 반환
    }
  }
}
