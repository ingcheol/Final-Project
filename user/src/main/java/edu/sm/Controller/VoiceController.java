package edu.sm.controller;

import edu.sm.app.dto.Patient;
import edu.sm.app.springai.service.AiSttService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDate;
import java.util.Map;

@Slf4j
@RestController
@RequiredArgsConstructor
public class VoiceController {

  private final AiSttService aiSttService;
  private final ChatClient chatClient;

  @PostMapping("/voice/navigate")
  public Map<String, String> handleVoiceCommand(@RequestParam("audio") MultipartFile audioFile, HttpSession session) {
    try {
      // 1. STT: 음성을 텍스트로 변환
      String userCommand = aiSttService.stt(audioFile);
      log.info("음성 명령: {}", userCommand);

      if (userCommand == null || userCommand.trim().isEmpty()) {
        return Map.of("status", "error", "message", "음성을 인식하지 못했습니다.");
      }

      // 2. 로그인 사용자 정보 확인 (URL 파라미터 바인딩용)
      Patient loginUser = (Patient) session.getAttribute("loginuser");
      Long patientId = (loginUser != null) ? loginUser.getPatientId() : 0L;
      int currentYear = LocalDate.now().getYear() - 3; // 통계용 연도

      // 3. AI에게 라우팅 판단 요청
      String aiResponse = determineRouteWithAI(userCommand, patientId, currentYear);

      // 4. JSON 파싱 및 반환
      // AI가 ```json ... ``` 형태로 줄 수 있으므로 정제
      String cleanJson = aiResponse.replace("```json", "").replace("```", "").trim();
      JSONObject json = new JSONObject(cleanJson);

      return Map.of(
          "status", "success",
          "text", userCommand,
          "url", json.getString("url"),
          "message", json.getString("message") // AI가 생성한 안내 멘트
      );

    } catch (Exception e) {
      log.error("음성 제어 실패", e);
      return Map.of("status", "error", "message", "처리 중 오류가 발생했습니다.");
    }
  }

  // AI 라우팅 핵심 로직
  private String determineRouteWithAI(String command, Long patientId, int year) {
    // 사이트 맵 정의 (AI가 판단할 기준)
    String siteMap = """
            1. [메인 홈]: / (키워드: 홈, 메인, 처음)
            2. [IoT 모니터링]: /monitor?patientId=%d (키워드: 내 차트, 혈압, 혈당, 모니터링, 건강 상태)
            3. [예약 신청]: /appointment/new (키워드: 예약 하기, 진료 예약, 병원 가고 싶어)
            4. [내 예약 확인]: /appointment/my (키워드: 내 예약, 언제 예약했지, 예약 조회)
            5. [병원 지도]: /map/map1 (키워드: 병원 위치, 지도, 찾아가는 길)
            6. [화상 진료]: /consul (키워드: 화상 상담, 비대면 진료, 의사 선생님 보기)
            7. [수어 번역]: /signlanguage (키워드: 수어, 수화, 번역)
            8. [건강 매니저]: /healthmgr (키워드: 건강 관리, 식단, 챗봇, 문서 업로드)
            9. [진료 기록(EMR)]: /emr (키워드: 진료 기록, 처방전, 기록 보기)
            10. [AI 자가 진단]: /dia/dia1 (키워드: 아파, 증상, 진단, 무슨 병이지)
            11. [질병 통계]: /statview?year=%d&sickCd=J20 (키워드: 감기 통계, 질병 정보) -> '감기'면 J20, '당뇨'면 E11 등 질병명에 맞춰 코드 변경 필요.
            12. [로그인]: /login (키워드: 로그인)
            13. [로그아웃]: /logout (키워드: 로그아웃)
            """.formatted(patientId, year);

    String prompt = String.format("""
            당신은 스마트 헬스케어 웹사이트의 'AI 네비게이션 시스템'입니다.
            사용자의 자연어 명령을 해석하여 가장 적절한 페이지 URL을 반환하세요.
            
            ### 사이트 맵 (Site Map)
            %s
            
            ### 사용자 명령
            "%s"
            
            ### 규칙
            1. 사용자의 의도와 가장 잘 맞는 URL을 선택하세요.
            2. **질병 통계(/statview)** 요청 시, 사용자가 언급한 질병에 맞는 상병코드(sickCd)를 추론해서 URL을 완성하세요. (기본값: 감기=J00, 당뇨=E11, 고혈압=I10)
            3. 결과는 반드시 **JSON 형식**으로만 반환하세요.
            4. `message` 필드에는 사용자에게 보여줄 이동 안내 멘트를 20자 이내로 다정하게 작성하세요.
            5. 매칭되는 페이지가 없다면 `url`을 "unknown"으로 설정하세요.
            
            ### 반환 예시
            {
                "url": "/appointment/new",
                "message": "진료 예약 페이지로 이동합니다."
            }
            """, siteMap, command);

    return chatClient.prompt().user(prompt).call().content();
  }
}