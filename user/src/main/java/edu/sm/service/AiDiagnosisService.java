package edu.sm.service;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import com.google.gson.reflect.TypeToken;
import edu.sm.dto.Question;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.model.ChatResponse;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.List;

@Service
public class AiDiagnosisService {

    @Autowired
    private ChatClient.Builder chatClientBuilder;

    private final Gson gson = new Gson();

    /**
     * 증상을 기반으로 맞춤 설문조사 생성 (OpenAI)
     */
    public List<Question> generateSurvey(String symptomText) {
        String prompt = String.format("""
            당신은 의료 전문 AI입니다.
            다음 증상에 대한 추가 질문 5개를 생성해주세요.
            
            증상: %s
            
            요구사항:
            1. 각 질문은 객관식이어야 합니다
            2. 각 질문마다 4개의 선택지를 제공해주세요
            3. 질문은 진단에 도움이 되는 구체적인 내용이어야 합니다
            4. 반드시 아래 JSON 형식으로만 응답해주세요 (다른 설명 없이):
            
            {
              "questions": [
                {
                  "id": 1,
                  "question": "질문 내용",
                  "type": "choice",
                  "options": ["선택지1", "선택지2", "선택지3", "선택지4"]
                }
              ]
            }
            """, symptomText);

        try {
            ChatClient chatClient = chatClientBuilder.build();

            String response = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();

            System.out.println("=== OpenAI 설문 생성 응답 ===");
            System.out.println(response);

            // JSON 파싱
            return parseQuestionsFromJson(response);

        } catch (Exception e) {
            System.err.println("AI 설문 생성 실패: " + e.getMessage());
            e.printStackTrace();

            // 실패 시 기본 설문 반환
            return getDefaultQuestions();
        }
    }

    /**
     * JSON 응답을 Question 리스트로 파싱
     */
    private List<Question> parseQuestionsFromJson(String jsonResponse) {
        try {
            // JSON 정제 (```json 제거)
            String cleanJson = jsonResponse
                    .replaceAll("```json", "")
                    .replaceAll("```", "")
                    .trim();

            JsonObject jsonObject = gson.fromJson(cleanJson, JsonObject.class);

            Type listType = new TypeToken<List<Question>>(){}.getType();
            List<Question> questions = gson.fromJson(
                    jsonObject.get("questions"),
                    listType
            );

            if (questions == null || questions.isEmpty()) {
                return getDefaultQuestions();
            }

            return questions;

        } catch (Exception e) {
            System.err.println("JSON 파싱 실패: " + e.getMessage());
            e.printStackTrace();
            return getDefaultQuestions();
        }
    }

    /**
     * AI 실패 시 기본 설문
     */
    private List<Question> getDefaultQuestions() {
        List<Question> defaultQuestions = new ArrayList<>();

        defaultQuestions.add(new Question(
                1,
                "증상이 시작된 지 얼마나 되었나요?",
                "choice",
                List.of("1일 이내", "2-3일", "4-7일", "1주일 이상")
        ));

        defaultQuestions.add(new Question(
                2,
                "증상의 강도는 어느 정도인가요?",
                "choice",
                List.of("경미함", "보통", "심함", "매우 심함")
        ));

        defaultQuestions.add(new Question(
                3,
                "증상이 일상생활에 지장을 주나요?",
                "choice",
                List.of("전혀 없음", "약간 있음", "상당히 있음", "매우 많음")
        ));

        defaultQuestions.add(new Question(
                4,
                "비슷한 증상을 이전에 경험한 적이 있나요?",
                "choice",
                List.of("없음", "1-2번", "3-5번", "자주 있음")
        ));

        defaultQuestions.add(new Question(
                5,
                "현재 복용 중인 약이 있나요?",
                "choice",
                List.of("없음", "일반의약품", "처방약", "여러 약물")
        ));

        return defaultQuestions;
    }

    /**
     * 설문 응답을 기반으로 AI 진단 (OpenAI)
     */
    public String analyzeDiagnosis(String symptomText, String[] surveyAnswers) {
        StringBuilder answersText = new StringBuilder();
        for (int i = 0; i < surveyAnswers.length; i++) {
            answersText.append(String.format("질문 %d: %s\n", i + 1, surveyAnswers[i]));
        }

        String prompt = String.format("""
            당신은 의료 전문 AI입니다.
            다음 정보를 바탕으로 가능성 있는 질환과 권장 진료과를 분석해주세요.
            
            증상: %s
            
            추가 정보:
            %s
            
            다음 형식으로 응답해주세요:
            
            ## 1. 가능성 있는 질환
            - 질환1: 설명
            - 질환2: 설명
            - 질환3: 설명
            
            ## 2. 권장 진료과
            
            ## 3. 주의사항
            
            ## 4. 응급도
            (낮음/보통/높음/매우높음)
            """, symptomText, answersText.toString());

        try {
            ChatClient chatClient = chatClientBuilder.build();

            String response = chatClient.prompt()
                    .user(prompt)
                    .call()
                    .content();

            System.out.println("=== OpenAI 진단 분석 응답 ===");
            System.out.println(response);

            return response;

        } catch (Exception e) {
            System.err.println("AI 분석 실패: " + e.getMessage());
            e.printStackTrace();
            return "AI 분석 중 오류가 발생했습니다. 의료 전문가와 상담하시기 바랍니다.";
        }
    }
}