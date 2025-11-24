<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>추가 질문 - AI 병원 찾기</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            max-width: 800px;
            width: 100%;
            padding: 40px;
            animation: slideUp 0.5s ease;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .header {
            text-align: center;
            margin-bottom: 30px;
        }

        .header h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }

        .header p {
            color: #666;
            font-size: 16px;
        }


        .progress-bar {
            width: 100%;
            height: 8px;
            background: #e9ecef;
            border-radius: 10px;
            margin-bottom: 30px;
            overflow: hidden;
        }

        .progress-fill {
            width: 50%;
            height: 100%;
            background: linear-gradient(90deg, #667eea, #764ba2);
            border-radius: 10px;
            animation: progressAnimation 0.5s ease;
        }

        @keyframes progressAnimation {
            from { width: 0; }
            to { width: 50%; }
        }

        .symptom-box {
            background: #f8f9ff;
            border-left: 4px solid #667eea;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 30px;
        }

        .symptom-box h3 {
            color: #667eea;
            font-size: 18px;
            margin-bottom: 10px;
        }

        .symptom-box p {
            color: #333;
            line-height: 1.6;
        }

        .survey-form {
            margin-top: 30px;
        }

        .question-item {
            background: #f8f9fa;
            padding: 25px;
            border-radius: 15px;
            margin-bottom: 25px;
            border: 2px solid #e9ecef;
            transition: all 0.3s ease;
        }

        .question-item:hover {
            border-color: #667eea;
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.1);
        }

        .question-item h4 {
            color: #333;
            font-size: 18px;
            margin-bottom: 15px;
            font-weight: 600;
        }

        .options-group {
            display: flex;
            flex-direction: column;
            gap: 12px;
        }

        .option-label {
            display: flex;
            align-items: center;
            padding: 15px 20px;
            background: white;
            border: 2px solid #e9ecef;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .option-label:hover {
            border-color: #667eea;
            background: #f8f9ff;
            transform: translateX(5px);
        }

        .option-label input[type="radio"] {
            width: 20px;
            height: 20px;
            margin-right: 15px;
            cursor: pointer;
            accent-color: #667eea;
        }

        .option-label input[type="radio"]:checked ~ span {
            color: #667eea;
            font-weight: 600;
        }

        .option-label span {
            color: #333;
            font-size: 16px;
        }

        .button-group {
            display: flex;
            gap: 15px;
            margin-top: 30px;
            justify-content: space-between;
        }

        .btn {
            flex: 1;
            padding: 15px 30px;
            font-size: 16px;
            font-weight: 600;
            border: none;
            border-radius: 10px;
            cursor: pointer;
            transition: all 0.3s ease;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }

        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
        }

        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .btn-secondary {
            background: #e9ecef;
            color: #333;
        }

        .btn-secondary:hover {
            background: #dee2e6;
            transform: translateY(-2px);
        }

        .loading-message {
            display: none;
            text-align: center;
            margin-top: 20px;
            color: #667eea;
            font-size: 16px;
        }

        .error-message {
            background: #fff3cd;
            border: 1px solid #ffc107;
            color: #856404;
            padding: 15px;
            border-radius: 10px;
            margin-bottom: 20px;
        }

        @media (max-width: 768px) {
            .container {
                padding: 25px;
            }

            .header h1 {
                font-size: 24px;
            }

            .question-item h4 {
                font-size: 16px;
            }

            .button-group {
                flex-direction: column;
            }

        }
    </style>
</head>
<body>
<div class="container">
    <!-- 진행률 표시 -->
    <div class="progress-bar">
        <div class="progress-fill"></div>
    </div>

    <!-- 헤더 -->
    <div class="header">
        <h1>🩺 추가 질문</h1>
        <p>증상에 대한 추가 질문에 답변해주세요</p>
    </div>

    <!-- 입력한 증상 표시 -->
    <div class="symptom-box">
        <h3>📝 입력하신 증상</h3>
        <p>${symptomText}</p>
    </div>

    <!-- 설문조사 폼 -->
    <form id="surveyForm" action="${pageContext.request.contextPath}/dia/dia3" method="post" class="survey-form">

        <!-- 임시 고정 질문 (나중에 AI 생성으로 교체) -->
        <div class="question-item">
            <h4>1. 증상이 시작된 지 얼마나 되었나요?</h4>
            <div class="options-group">
                <label class="option-label">
                    <input type="radio" name="answer0" value="1일 이내" required>
                    <span>1일 이내</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer0" value="2-3일">
                    <span>2-3일</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer0" value="4-7일">
                    <span>4-7일</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer0" value="1주일 이상">
                    <span>1주일 이상</span>
                </label>
            </div>
        </div>

        <div class="question-item">
            <h4>2. 증상의 강도는 어느 정도인가요?</h4>
            <div class="options-group">
                <label class="option-label">
                    <input type="radio" name="answer1" value="경미함" required>
                    <span>경미함</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer1" value="보통">
                    <span>보통</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer1" value="심함">
                    <span>심함</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer1" value="매우 심함">
                    <span>매우 심함</span>
                </label>
            </div>
        </div>

        <div class="question-item">
            <h4>3. 증상이 일상생활에 지장을 주나요?</h4>
            <div class="options-group">
                <label class="option-label">
                    <input type="radio" name="answer2" value="전혀 없음" required>
                    <span>전혀 없음</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer2" value="약간 있음">
                    <span>약간 있음</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer2" value="상당히 있음">
                    <span>상당히 있음</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer2" value="매우 많음">
                    <span>매우 많음</span>
                </label>
            </div>
        </div>

        <div class="question-item">
            <h4>4. 비슷한 증상을 이전에 경험한 적이 있나요?</h4>
            <div class="options-group">
                <label class="option-label">
                    <input type="radio" name="answer3" value="없음" required>
                    <span>없음</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer3" value="1-2번">
                    <span>1-2번</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer3" value="3-5번">
                    <span>3-5번</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer3" value="자주 있음">
                    <span>자주 있음</span>
                </label>
            </div>
        </div>

        <div class="question-item">
            <h4>5. 현재 복용 중인 약이 있나요?</h4>
            <div class="options-group">
                <label class="option-label">
                    <input type="radio" name="answer4" value="없음" required>
                    <span>없음</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer4" value="일반의약품">
                    <span>일반의약품</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer4" value="처방약">
                    <span>처방약</span>
                </label>
                <label class="option-label">
                    <input type="radio" name="answer4" value="여러 약물">
                    <span>여러 약물</span>
                </label>
            </div>
        </div>

        <!-- 버튼 그룹 -->
        <div class="button-group">
            <button type="button" class="btn btn-secondary" onclick="history.back()">
                ← 이전
            </button>
            <button type="submit" class="btn btn-primary" id="submitBtn">
                다음 단계 →
            </button>
        </div>

        <div class="loading-message" id="loadingMessage">
            답변을 전송하는 중입니다...
        </div>
    </form>
</div>

<script>
    // 폼 제출 시 로딩 표시
    document.getElementById('surveyForm').addEventListener('submit', function(e) {
        const submitBtn = document.getElementById('submitBtn');
        const loadingMessage = document.getElementById('loadingMessage');

        submitBtn.disabled = true;
        submitBtn.textContent = '전송 중...';
        loadingMessage.style.display = 'block';
    });

    // 라디오 버튼 선택 시 애니메이션
    document.querySelectorAll('.option-label input[type="radio"]').forEach(radio => {
        radio.addEventListener('change', function() {
            // 같은 그룹의 다른 라벨 스타일 초기화
            this.closest('.options-group').querySelectorAll('.option-label').forEach(label => {
                label.style.borderColor = '#e9ecef';
                label.style.background = 'white';
            });

            // 선택된 라벨 하이라이트
            const label = this.closest('.option-label');
            label.style.borderColor = '#667eea';
            label.style.background = '#f8f9ff';
        });
    });
</script>
</body>
</html>