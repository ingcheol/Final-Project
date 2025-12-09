<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>추가 질문</title>
    <style>
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        }

        /* 언어 선택 버튼 */
        .language-selector {
            position: fixed;
            top: 20px;
            right: 20px;
            display: flex;
            gap: 8px;
            background: white;
            padding: 5px;
            border-radius: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
            z-index: 1000;
        }

        .lang-btn {
            padding: 6px 12px;
            border: none;
            background: transparent;
            border-radius: 15px;
            cursor: pointer;
            font-size: 13px;
            font-weight: 600;
            color: #666;
            transition: all 0.3s;
        }

        .lang-btn:hover {
            background: rgba(102, 126, 234, 0.1);
            color: #667eea;
        }

        .lang-btn.active {
            background: #667eea;
            color: white;
        }

        .container {
            max-width: 900px;
            margin: 50px auto;
            background: white;
            padding: 40px;
            border-radius: 15px;
        }
        .question {
            margin-bottom: 25px;
            padding: 20px;
            background: #f8f9fa;
            border-radius: 10px;
        }
        .question h4 {
            color: #667eea;
            margin-bottom: 15px;
        }
        .answers {
            display: flex;
            flex-wrap: wrap;
            gap: 10px;
        }
        .answer-btn {
            padding: 10px 20px;
            border: 2px solid #667eea;
            background: white;
            border-radius: 25px;
            cursor: pointer;
            transition: all 0.3s;
        }
        .answer-btn:hover, .answer-btn.selected {
            background: #667eea;
            color: white;
        }
        .btn-container {
            text-align: center;
            margin-top: 30px;
        }
        .submit-btn {
            padding: 15px 50px;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            border: none;
            border-radius: 30px;
            font-size: 18px;
            cursor: pointer;
        }
    </style>
</head>
<body>
<!-- 언어 선택 버튼 -->
<div class="language-selector">
    <button class="lang-btn active" data-lang="ko">한국어</button>
    <button class="lang-btn" data-lang="en">English</button>
    <button class="lang-btn" data-lang="ja">日本語</button>
    <button class="lang-btn" data-lang="zh">中文</button>
</div>

<div class="container">
    <h2 data-i18n="surveyTitle">🩺 추가 질문</h2>
    <p data-i18n="surveySubtitle">증상에 대한 추가 질문에 답변해주세요</p>

    <form id="surveyForm" action="/dia/dia3" method="post">
        <div id="customSurvey"></div>
        <div class="btn-container">
            <button type="button" onclick="history.back()" class="submit-btn" style="background: #ccc;">
                <span data-i18n="btnPrev">← 이전</span>
            </button>
            <button type="submit" class="submit-btn">
                <span data-i18n="surveySubmit">다음 단계 →</span>
            </button>
        </div>
    </form>
</div>

<!-- multilang.js 추가 -->
<script src="<c:url value='/js/multilang.js'/>"></script>

<script>
    // JSP에서 customSurvey 가져오기
    const customSurveyData = `<c:out value="${customSurvey}" escapeXml="false"/>`;

    console.log("=== 맞춤 설문 데이터 ===");
    console.log(customSurveyData);

    function renderCustomSurvey() {
        const container = document.getElementById('customSurvey');

        if (!customSurveyData || customSurveyData.trim() === '' || customSurveyData === 'null') {
            console.log("❌ 맞춤 설문 없음, 기본 설문 사용");
            renderDefaultSurvey();
            return;
        }

        console.log("✅ 맞춤 설문 렌더링 시작");

        const lines = customSurveyData.trim().split('\n');
        let html = '';
        let currentQ = null;
        let questionIndex = 0;

        lines.forEach(line => {
            line = line.trim();
            if (line.startsWith('Q')) {
                if (currentQ) {
                    html += '</div></div>';
                }
                currentQ = line.substring(line.indexOf(':') + 1).trim();
                html += '<div class="question">';
                html += '<h4>' + currentQ + '</h4>';
                html += '<div class="answers" data-question="' + questionIndex + '">';
                questionIndex++;
            } else if (line.startsWith('A') && currentQ) {
                const answers = line.substring(line.indexOf(':') + 1).trim().split('|');
                answers.forEach((answer, idx) => {
                    const trimmedAnswer = answer.trim();
                    const isRequired = questionIndex === 1 ? ' required' : '';
                    html += '<button type="button" class="answer-btn" data-value="' + trimmedAnswer + '" data-index="' + idx + '"' + isRequired + '>' + trimmedAnswer + '</button>';
                });
            }
        });

        if (currentQ) {
            html += '</div></div>';
        }

        container.innerHTML = html;
        setupAnswerButtons();
    }

    function renderDefaultSurvey() {
        const container = document.getElementById('customSurvey');
        container.innerHTML = `
                <div class="question">
                    <h4>증상이 시작된 지 얼마나 되었나요?</h4>
                    <div class="answers">
                        <button type="button" class="answer-btn" data-value="오늘">오늘</button>
                        <button type="button" class="answer-btn" data-value="1-2일">1-2일</button>
                        <button type="button" class="answer-btn" data-value="3-7일">3-7일</button>
                        <button type="button" class="answer-btn" data-value="1주일 이상">1주일 이상</button>
                    </div>
                </div>
                <div class="question">
                    <h4>통증의 정도는 어떤가요?</h4>
                    <div class="answers">
                        <button type="button" class="answer-btn" data-value="경미함">경미함</button>
                        <button type="button" class="answer-btn" data-value="보통">보통</button>
                        <button type="button" class="answer-btn" data-value="심함">심함</button>
                        <button type="button" class="answer-btn" data-value="매우 심함">매우 심함</button>
                    </div>
                </div>
                <div class="question">
                    <h4>증상이 점점 심해지고 있나요?</h4>
                    <div class="answers">
                        <button type="button" class="answer-btn" data-value="호전됨">호전됨</button>
                        <button type="button" class="answer-btn" data-value="변화 없음">변화 없음</button>
                        <button type="button" class="answer-btn" data-value="악화됨">악화됨</button>
                    </div>
                </div>
            `;
        setupAnswerButtons();
    }

    function setupAnswerButtons() {
        const answerContainers = document.querySelectorAll('.answers');

        answerContainers.forEach((container, qIndex) => {
            const buttons = container.querySelectorAll('.answer-btn');

            buttons.forEach(btn => {
                btn.addEventListener('click', function() {
                    // 같은 질문의 다른 버튼 선택 해제
                    buttons.forEach(b => b.classList.remove('selected'));
                    this.classList.add('selected');

                    // hidden input 생성/업데이트
                    let input = document.getElementById('answer' + qIndex);
                    if (!input) {
                        input = document.createElement('input');
                        input.type = 'hidden';
                        input.id = 'answer' + qIndex;
                        input.name = 'answer' + qIndex;
                        document.getElementById('surveyForm').appendChild(input);
                    }
                    input.value = this.dataset.value;
                });
            });
        });
    }

    // 폼 제출 전 검증
    document.getElementById('surveyForm').addEventListener('submit', function(e) {
        const answerCount = document.querySelectorAll('.answers').length;
        let allAnswered = true;

        for (let i = 0; i < answerCount; i++) {
            if (!document.getElementById('answer' + i)) {
                allAnswered = false;
                break;
            }
        }

        if (!allAnswered) {
            e.preventDefault();
            alert(t('alertAnswerAll'));
            return false;
        }
    });

    // 페이지 로드 시 설문 렌더링
    renderCustomSurvey();
</script>
</body>
</html>