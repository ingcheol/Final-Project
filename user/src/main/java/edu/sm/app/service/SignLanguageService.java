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

  /**
   * 이미지 1장 + 랜드마크 JSON + 수어 종류(KSL/ASL)
   */
  public SignLanguageMessage translateSignLanguage(
      MultipartFile videoFrame,
      String landmarksJson,
      String signLanguage) throws Exception {

    log.info("수어 번역 시작 - 언어: {}", signLanguage);

    ChatClient chatClient = chatClientBuilder.build();
    String systemPrompt = buildSystemPrompt(signLanguage);

    String userPrompt = """
        아래는 수어 손동작 한 장의 이미지와 MediaPipe Hands가 추출한 21개 손 랜드마크 데이터입니다.

        [랜드마크 데이터 형식]
        - landmarks: 21개의 포인트 배열
        - 각 포인트는 {x: 0~1, y: 0~1, z: 깊이 값} 형태 (이미지 크기에 정규화됨)
        - 인덱스 순서는 MediaPipe Hands의 표준 인덱스(손목→손가락 관절 순)와 동일함.

        [입력 랜드마크 JSON]
        %s

        [분류 대상]
        - 한국 수어 지문자: 자음(ㄱ, ㄴ, ㄷ, ... , ㅎ)

        [지시사항]
        1. 이미지를 먼저 보고 손 모양을 이해하세요.
        2. 랜드마크 JSON은 손가락의 상대적 위치와 각도를 보정하는 참고 정보로 사용하세요.
        3. 가장 가능성이 높은 "하나의" 문자 또는 숫자만 선택하세요.
           - 예시 출력: ㄱ, ㅎ
        4. 확신이 없으면 "인식 불가"라고만 출력하세요.
        5. 추가 설명, 문장, 따옴표는 출력하지 마세요. 오직 최종 결과만 출력합니다.
        """.formatted(
        (landmarksJson != null && !landmarksJson.isBlank()) ? landmarksJson : "[]"
    );

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
    if ("ksl".equalsIgnoreCase(signLanguage)) {
      return """
             당신은 한국수어(KSL) 지문자 인식 전문가입니다.

             [역할]
             - 손가락 모양과 방향을 보고 한국어 지문자(자음)를 판별합니다.
             - 입력으로는 카메라 이미지 1장과 MediaPipe Hands 랜드마크 좌표가 함께 제공됩니다.
             - 랜드마크는 손가락 관절의 상대 위치를 더 정확히 파악하기 위한 보조 정보입니다.

             [출력 규칙]
             - 가능한 값:
               - 자음: ㄱ, ㄴ, ㄷ, ㄹ, ㅁ, ㅂ, ㅅ, ㅇ, ㅈ, ㅊ, ㅋ, ㅌ, ㅍ, ㅎ
             - 위 목록 중 하나만 정확히 선택해서 출력하세요.
             - 확신이 없으면 "인식 불가"라고만 출력하세요.
             - 설명이나 부연 문장은 절대 쓰지 마세요.
             """;
    } else {
      return """
             You are an expert in American Sign Language (ASL) numbers and fingerspelling.
             You receive a hand gesture image and 21 MediaPipe hand landmarks.
             Your task is to output ONLY one recognized label:
             - Or 'UNKNOWN' if you are not confident.
             Do not output explanations.
             """;
    }
  }
}
