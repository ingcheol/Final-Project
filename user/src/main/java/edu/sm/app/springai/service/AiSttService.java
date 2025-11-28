package edu.sm.app.springai.service;

import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.audio.transcription.AudioTranscriptionPrompt;
import org.springframework.ai.audio.transcription.AudioTranscriptionResponse;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.openai.OpenAiAudioSpeechModel;
import org.springframework.ai.openai.OpenAiAudioSpeechOptions;
import org.springframework.ai.openai.OpenAiAudioTranscriptionModel;
import org.springframework.ai.openai.OpenAiAudioTranscriptionOptions;
import org.springframework.ai.openai.api.OpenAiAudioApi.SpeechRequest;
import org.springframework.ai.openai.api.OpenAiAudioApi.SpeechRequest.AudioResponseFormat;
import org.springframework.ai.openai.audio.speech.SpeechPrompt;
import org.springframework.ai.openai.audio.speech.SpeechResponse;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.core.io.FileSystemResource;
import org.springframework.core.io.Resource;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.Base64;
import java.util.HashMap;
import java.util.Map;

@Service
@Slf4j
public class AiSttService {
  // ##### 필드 #####
  private ChatClient chatClient;
  private OpenAiAudioTranscriptionModel openAiAudioTranscriptionModel;
  private OpenAiAudioSpeechModel openAiAudioSpeechModel;

  // ##### 생성자 #####
  public AiSttService(ChatClient.Builder chatClientBuilder,
                      OpenAiAudioTranscriptionModel openAiAudioTranscriptionModel,
                      OpenAiAudioSpeechModel openAiAudioSpeechModel) {
    chatClient = chatClientBuilder.build();
    this.openAiAudioTranscriptionModel = openAiAudioTranscriptionModel;
    this.openAiAudioSpeechModel = openAiAudioSpeechModel;
  }

  // ##### 메소드 #####
  public String stt(MultipartFile multipartFile) throws IOException {

    Path tempFile = Files.createTempFile("multipart-", multipartFile.getOriginalFilename());
    multipartFile.transferTo(tempFile);
    Resource audioResource = new FileSystemResource(tempFile);

    // 모델 옵션 설정
    OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
            .model("whisper-1")
            .language("ko") // 입력 음성 언어의 종류 설정, 출력 언어에도 영향을 미침
            .build();

    // 프롬프트 생성
    AudioTranscriptionPrompt prompt = new AudioTranscriptionPrompt(audioResource, options);

    // 모델을 호출하고 응답받기
    AudioTranscriptionResponse response = openAiAudioTranscriptionModel.call(prompt);
    String text = response.getResult().getOutput();
    log.info(text);

    return text;
  }

  public byte[] tts(String text) {
    // 모델 옵션 설정
    OpenAiAudioSpeechOptions options = OpenAiAudioSpeechOptions.builder()
        .model("gpt-4o-mini-tts")
        .voice(SpeechRequest.Voice.NOVA)
        .responseFormat(AudioResponseFormat.MP3)
        .speed(1.0f)
        .build();

    // 프롬프트 생성
    SpeechPrompt prompt = new SpeechPrompt(text, options);

    // 모델을 호출하고 응답받기
    SpeechResponse response = openAiAudioSpeechModel.call(prompt);
    byte[] bytes = response.getResult().getOutput();

    return bytes;
  }
    public Map<String, String> tts2(String text) {
        // 모델 옵션 설정
        OpenAiAudioSpeechOptions options = OpenAiAudioSpeechOptions.builder()
                .model("gpt-4o-mini-tts")
                .voice(SpeechRequest.Voice.ALLOY)
                .responseFormat(AudioResponseFormat.MP3)
                .speed(1.0f)
                .build();

        // 프롬프트 생성
        SpeechPrompt prompt = new SpeechPrompt(text, options);

        // 모델을 호출하고 응답받기
        SpeechResponse response = openAiAudioSpeechModel.call(prompt);
        byte[] bytes = response.getResult().getOutput();
        String base64Audio = Base64.getEncoder().encodeToString(bytes);

        Map<String, String> result = new HashMap<>();
        result.put("audio", base64Audio);

        return result;
    }

  public Map<String, String> chatText(String question) {
    // LLM로 요청하고, 텍스트 응답 얻기
    String textAnswer = chatClient.prompt()
        .system("한국어로 답변해주세요.")
        .user(question)
        .call()
        .content();

    // TTS 모델로 요청하고 응답으로 받은 음성 데이터를 base64 문자열로 변환
    byte[] audio = tts(textAnswer);
    String base64Audio = Base64.getEncoder().encodeToString(audio);

    // 텍스트 답변과 음성 답변을 Map에 저장
    Map<String, String> response = new HashMap<>();
    response.put("text", textAnswer);
    response.put("audio", base64Audio);

    return response;
  }

//  voice컨트롤러에서 확장자 고정
  public String sttWithExtension(MultipartFile multipartFile, String extension) throws IOException {
    Resource audioResource = new ByteArrayResource(multipartFile.getBytes()) {
      @Override
      public String getFilename() {
        // 전달받은 확장자를 붙여서 리턴 (예: "audio.webm")
        return "audio." + extension;
      }
    };

    OpenAiAudioTranscriptionOptions options = OpenAiAudioTranscriptionOptions.builder()
        .model("whisper-1")
        .language("ko")
        .build();

    AudioTranscriptionPrompt prompt = new AudioTranscriptionPrompt(audioResource, options);
    AudioTranscriptionResponse response = openAiAudioTranscriptionModel.call(prompt);

    String text = response.getResult().getOutput();
    log.info("STT Result (Extension: {}): {}", extension, text);
    return text;
  }

}
