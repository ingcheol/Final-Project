package edu.sm.app.springai.service;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

import java.util.Map;

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
