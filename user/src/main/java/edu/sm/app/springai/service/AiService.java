package edu.sm.app.springai.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.messages.AssistantMessage;
import org.springframework.ai.chat.messages.SystemMessage;
import org.springframework.ai.chat.messages.UserMessage;
import org.springframework.ai.chat.model.ChatModel;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.ChatOptions;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import reactor.core.publisher.Flux;

@Service
@Slf4j
public class AiService {
    @Autowired
    private ChatModel chatModel;

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
}
