package edu.sm.app.service;

import edu.sm.app.dto.SignLanguageMessage;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.util.MimeTypeUtils;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;

@Service
@Slf4j
@RequiredArgsConstructor
public class SignLanguageService {

  private final ChatClient.Builder chatClientBuilder;

  // 이미지 1장 + 랜드마크 JSON + 수어 종류(KSL/ASL)
  public SignLanguageMessage translateSignLanguage(
      MultipartFile videoFrame,
      String landmarksJson,
      String signLanguage) throws Exception {

    log.info("수어 번역 시작 - 언어: {}", signLanguage);

    ChatClient chatClient = chatClientBuilder.build();
    String systemPrompt = buildSystemPrompt(signLanguage);

    String userPrompt = """
         첨부된 이미지와 아래 랜드마크 데이터를 바탕으로, 다음 [동작 목록] 중 하나를 선택해 단어만 출력하세요.
        
                    [동작 목록 및 매칭 조건]
                    1. 검지 손가락 끝이 머리/관자놀이 근처에 있음 -> "머리"
                    2. 손이 목을 잡거나 가리킴 -> "목"
                    3.**모양 B (모아 쥔 모양 - "아파요"):**
                                        - **핵심:** 모든 손가락(엄지~새끼)이 펴지지 않고, 공을 쥐듯 안쪽으로 구부러져 모여있는 형태.
                                        - **좌표 특징:** 모든 손가락의 Tip(끝)이 서로 가깝게 모여 있으며, 손바닥이 완전히 펴진 상태(보자기)가 아님.
        
                    [랜드마크 데이터]
                    %s
        
                    [제약 사항]
                    - "" 같은 특수문자는 출력하지 마세요.
                    - 확신이 없으면 "인식 불가"라고만 출력하세요.
                    - 문장 외에 그 어떤 말도 덧붙이지 마세요.
                    - "죄송합니다", "분석 결과" 등의 서두를 금지합니다.
                    
        """.formatted((landmarksJson != null && !landmarksJson.isBlank()) ? landmarksJson : "{}");

    String response = chatClient.prompt()
        .system(systemPrompt)
        .user(u -> {
          try {
            u.text(userPrompt)
                .media(MimeTypeUtils.IMAGE_JPEG,
                    new ByteArrayResource(videoFrame.getBytes()));
          } catch (Exception e) {
            throw new RuntimeException("이미지 처리 실패", e);
          }
        })
        .call()
        .content();

    log.info("번역 결과: {}", response);

    return SignLanguageMessage.builder()
        .signLanguage(signLanguage)
        .translatedText(response == null ? null : response.trim())
        .confidence(0.90)
        .timestamp(LocalDateTime.now())
        .build();
  }

  private String buildSystemPrompt(String signLanguage) {
    // KSL에 초점을 맞춰 프롬프트를 작성합니다.
    if ("ksl".equalsIgnoreCase(signLanguage)) {
      return """
          당신은 병원에서 환자의 **한 손 수어**를 보고 증상을 해석하는 번역 AI입니다.
          정적인 이미지 한 장과 손의 랜드마크 좌표를 기반으로, 가장 가능성이 높은 증상 문장을 만드세요.
          
          [중요 규칙]
          1. **한 손만 사용**합니다. 양손 수어는 고려하지 않습니다.
          2. **'손의 위치'**와 **'손의 모양'**을 조합하여 증상을 추론합니다.
          3. 최종 결과는 자연스러운 한국어 **문장 하나**여야 합니다. (예: "아파요.")
          4. 규칙에 없는 애매한 동작은 **"인식 불가"**라고만 응답하세요.
          5. 절대 부연 설명을 하지 마세요.
          
          ---
          [핵심 증상 해석 규칙 (RAG)]
          
          **1. '머리' 위치 인식:**
             - 손(특히 검지 손가락 끝)이 머리나 관자놀이 근처에 있을 때.
          
          **2. '목' 위치 인식:**
             - 손이 목 앞부분이나 옆부분을 가리키거나 감싸고 있을 때.
          
          **3. '아픔' 손 모양 인식:**
             - (규칙 A) 검지를 제외한 나머지 손가락을 접고, 편 검지를 살짝 비트는 모양.
             - (규칙 B) 모든 손가락을 살짝 구부려 모은 뒤 손바닥이 몸을 향한 상태.
          
          **4. 최종 문장 조합:**
             - **IF** (손 모양이 검지 하나로 '머리' 위치를 가리킴) **THEN** 응답: "머리가 아파요."
             - **IF** ('머리' 위치) **AND** ('아픔' 손 모양 규칙 A 또는 B 충족) **THEN** 응답: "머리가 아파요."
             - **IF** (손 모양이 검지나 여러 손가락으로 '목' 위치를 가리키거나 쥐는 모양) **THEN** 응답: "목이 아파요."
             - **IF** ('목' 위치) **AND** ('아픔' 손 모양 규칙 A 또는 B 충족) **THEN** 응답: "목감기가 있어요."
          ---
          [모드] 한국수어(KSL). 위의 규칙에 따라 한국어 문장으로 응답하세요.
          """;
    } else {
      // ASL에 대한 프롬프트 (요구사항에 따라 확장 가능)
      return """
          You are an expert in American Sign Language (ASL) for medical symptoms.
          Analyze the single hand gesture from the image and landmarks.
          Combine hand shape and location (head, neck) to determine the symptom.
          - Pointing at head means "headache".
          - Pointing at or grabbing neck means "sore throat".
          Respond with a short descriptive sentence in English.
          If unsure, respond with "Symptom not clear".
          """;
    }
  }
}
