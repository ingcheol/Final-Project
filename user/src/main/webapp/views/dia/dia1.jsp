<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>증상 입력 - AI 의료 매칭 시스템</title>
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;700&display=swap" rel="stylesheet">
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Noto Sans KR', -apple-system, BlinkMacSystemFont, sans-serif;
            color: #333;
            background: linear-gradient(135deg, #f5f7fa 0%, #e8f0fe 100%);
            min-height: 100vh;
        }

        header {
            background: white;
            box-shadow: 0 2px 5px rgba(0,0,0,0.1);
            position: fixed;
            width: 100%;
            top: 0;
            z-index: 1000;
        }

        nav {
            max-width: 1400px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 20px 40px;
        }

        .logo {
            font-size: 24px;
            font-weight: bold;
            color: #5B6FB5;
            text-decoration: none;
        }

        .nav-right {
            display: flex;
            align-items: center;
            gap: 30px;
        }

        .nav-menu {
            display: flex;
            gap: 40px;
            list-style: none;
        }

        .nav-menu a {
            text-decoration: none;
            color: #333;
            font-weight: 500;
            transition: color 0.3s;
        }

        .nav-menu a:hover {
            color: #5B6FB5;
        }

        /* 언어 선택 버튼 스타일 */
        .language-selector {
            display: flex;
            gap: 8px;
            background: #f0f0f0;
            padding: 5px;
            border-radius: 20px;
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
            background: rgba(91, 111, 181, 0.1);
            color: #5B6FB5;
        }

        .lang-btn.active {
            background: #5B6FB5;
            color: white;
        }

        .main-container {
            margin-top: 100px;
            padding: 40px 30px;
            max-width: 1000px;
            margin-left: auto;
            margin-right: auto;
        }

        .progress-bar {
            display: flex;
            justify-content: space-between;
            margin-bottom: 50px;
            position: relative;
        }

        .progress-bar::before {
            content: '';
            position: absolute;
            top: 20px;
            left: 0;
            right: 0;
            height: 3px;
            background: #e0e0e0;
            z-index: 0;
        }

        .progress-step {
            display: flex;
            flex-direction: column;
            align-items: center;
            position: relative;
            z-index: 1;
            flex: 1;
        }

        .progress-step .circle {
            width: 40px;
            height: 40px;
            border-radius: 50%;
            background: white;
            border: 3px solid #e0e0e0;
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: bold;
            margin-bottom: 10px;
            transition: all 0.3s;
        }

        .progress-step.active .circle {
            background: #5B6FB5;
            color: white;
            border-color: #5B6FB5;
            transform: scale(1.1);
        }

        .progress-step span {
            font-size: 13px;
            color: #666;
            font-weight: 500;
        }

        .progress-step.active span {
            color: #5B6FB5;
            font-weight: 700;
        }

        .diagnosis-card {
            background: white;
            border-radius: 20px;
            padding: 40px;
            box-shadow: 0 4px 30px rgba(0,0,0,0.1);
            margin-bottom: 30px;
        }

        .card-header {
            text-align: center;
            margin-bottom: 40px;
        }

        .card-header h2 {
            font-size: 28px;
            color: #2c3e50;
            margin-bottom: 12px;
        }

        .card-header p {
            font-size: 16px;
            color: #7f8c8d;
        }

        .input-section {
            margin-bottom: 30px;
        }

        .input-section label {
            display: block;
            font-weight: 600;
            color: #2c3e50;
            margin-bottom: 12px;
            font-size: 16px;
        }

        .input-section textarea {
            width: 100%;
            min-height: 150px;
            padding: 15px;
            border: 2px solid #e0e0e0;
            border-radius: 12px;
            font-size: 15px;
            font-family: inherit;
            resize: vertical;
            transition: border-color 0.3s;
        }

        .input-section textarea:focus {
            outline: none;
            border-color: #5B6FB5;
        }

        .input-buttons {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px;
            margin-top: 15px;
        }

        .btn-voice, .btn-camera {
            padding: 12px 20px;
            border: 2px solid #e0e0e0;
            border-radius: 10px;
            background: white;
            cursor: pointer;
            font-size: 14px;
            font-weight: 600;
            transition: all 0.3s;
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 8px;
        }

        .btn-voice:hover, .btn-camera:hover {
            border-color: #5B6FB5;
            color: #5B6FB5;
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(91, 111, 181, 0.2);
        }

        .btn-voice.recording {
            background: #dc3545;
            color: white;
            border-color: #dc3545;
            animation: pulse 1.5s infinite;
        }

        @keyframes pulse {
            0%, 100% { opacity: 1; }
            50% { opacity: 0.7; }
        }

        .image-preview {
            display: none;
            margin-top: 20px;
            gap: 10px;
            flex-wrap: wrap;
        }

        .image-preview.show {
            display: flex;
        }

        .preview-item {
            position: relative;
            width: 120px;
            height: 120px;
            border-radius: 10px;
            overflow: hidden;
            border: 2px solid #e0e0e0;
        }

        .preview-item img {
            width: 100%;
            height: 100%;
            object-fit: cover;
        }

        .preview-item .remove-btn {
            position: absolute;
            top: 5px;
            right: 5px;
            background: rgba(220, 53, 69, 0.9);
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }

        .preview-item .remove-btn:hover {
            background: #dc3545;
            transform: scale(1.1);
        }

        .action-buttons {
            display: flex;
            gap: 15px;
            margin-top: 40px;
        }

        .btn {
            flex: 1;
            padding: 16px 32px;
            border: none;
            border-radius: 12px;
            font-size: 16px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }

        .btn-primary {
            background: linear-gradient(135deg, #5B6FB5 0%, #4a5a9e 100%);
            color: white;
        }

        .btn-primary:hover:not(:disabled) {
            transform: translateY(-2px);
            box-shadow: 0 6px 20px rgba(91, 111, 181, 0.4);
        }

        .btn-primary:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }

        .btn-secondary {
            background: white;
            color: #666;
            border: 2px solid #e0e0e0;
        }

        .btn-secondary:hover {
            border-color: #5B6FB5;
            color: #5B6FB5;
        }

        .info-box {
            background: linear-gradient(135deg, #EEF2FF 0%, #E0E7FF 100%);
            border: 2px solid #C7D2FE;
            border-radius: 12px;
            padding: 20px;
            margin-top: 30px;
        }

        .info-box h4 {
            font-size: 16px;
            color: #2c3e50;
            margin-bottom: 12px;
            display: flex;
            align-items: center;
            gap: 8px;
        }

        .info-box ul {
            list-style: none;
            padding-left: 0;
        }

        .info-box li {
            font-size: 14px;
            color: #4B5563;
            margin-bottom: 8px;
            padding-left: 20px;
            position: relative;
        }

        .info-box li:before {
            content: "•";
            position: absolute;
            left: 6px;
            color: #5B6FB5;
            font-weight: bold;
        }

        @media (max-width: 768px) {
            .main-container {
                padding: 20px 15px;
            }

            .diagnosis-card {
                padding: 25px 20px;
            }

            .action-buttons {
                flex-direction: column;
            }

            .input-buttons {
                grid-template-columns: 1fr;
            }

            .nav-menu {
                display: none;
            }
        }
    </style>
</head>
<body>
<header>
    <nav>
        <a href="<c:url value="/"/>" class="logo" data-i18n="logo">🏥 AI 의료 매칭 시스템</a>
        <div class="nav-right">
            <ul class="nav-menu">
                <li><a href="<c:url value="/"/>" data-i18n="navHome">홈</a></li>
                <li><a href="<c:url value="/#services"/>" data-i18n="navServices">서비스 소개</a></li>
                <li><a href="<c:url value="/#diagnosis"/>" data-i18n="navDiagnosis">자가진단</a></li>
                <li><a href="<c:url value="/map/map1"/>" data-i18n="navHospital" style="color: #5B6FB5;">병원찾기</a></li>
                <li><a href="<c:url value="/#contact"/>" data-i18n="navContact">문의하기</a></li>
            </ul>
            <div class="language-selector">
                <button class="lang-btn active" data-lang="ko">한국어</button>
                <button class="lang-btn" data-lang="en">English</button>
                <button class="lang-btn" data-lang="ja">日本語</button>
                <button class="lang-btn" data-lang="zh">中文</button>
            </div>
        </div>
    </nav>
</header>

<div class="main-container">
    <!-- Progress Bar -->
    <div class="progress-bar">
        <div class="progress-step active">
            <div class="circle">1</div>
            <span data-i18n="step1">증상 입력</span>
        </div>
        <div class="progress-step">
            <div class="circle">2</div>
            <span data-i18n="step2">설문조사</span>
        </div>
        <div class="progress-step">
            <div class="circle">3</div>
            <span data-i18n="step3">AI 분석</span>
        </div>
        <div class="progress-step">
            <div class="circle">4</div>
            <span data-i18n="step4">결과 확인</span>
        </div>
    </div>

    <!-- Diagnosis Card -->
    <div class="diagnosis-card">
        <div class="card-header">
            <h2 data-i18n="pageTitle">증상을 입력해주세요</h2>
            <p data-i18n="pageSubtitle">현재 불편하신 증상을 자세히 설명해주시면 AI가 분석해드립니다</p>
        </div>

        <div style="background: linear-gradient(135deg, #f0f4ff 0%, #e8f0fe 100%); border-radius: 15px; padding: 30px; margin-top: 25px; border-left: 5px solid #5B6FB5; box-shadow: 0 2px 10px rgba(91, 111, 181, 0.1);">
            <h4 style="color: #2c3e50; font-size: 18px; margin-bottom: 20px; display: flex; align-items: center; gap: 10px;">
                <span data-i18n="howItWorks">AI 진단 시스템이 이렇게 작동합니다</span>
            </h4>

            <div style="display: grid; gap: 15px;">
                <!-- 1단계 -->
                <div style="background: white; padding: 20px; border-radius: 10px; border-left: 3px solid #667eea;">
                    <div style="display: flex; align-items: start; gap: 15px;">
                        <div style="background: #667eea; color: white; min-width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px;">1</div>
                        <div style="flex: 1;">
                            <h5 style="color: #667eea; font-size: 15px; margin-bottom: 8px; font-weight: 600;" data-i18n="step1DetailTitle">증상 입력 및 수집</h5>
                            <p style="color: #666; font-size: 14px; line-height: 1.7; margin: 0;" data-i18n="step1DetailDesc">
                                텍스트, 음성, 이미지 등 다양한 방법으로 증상을 입력하시면 AI가 모든 정보를 수집합니다.
                                "3일 전부터 두통과 발열" 같은 자연스러운 문장으로 작성하셔도 됩니다.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- 2단계 -->
                <div style="background: white; padding: 20px; border-radius: 10px; border-left: 3px solid #764ba2;">
                    <div style="display: flex; align-items: start; gap: 15px;">
                        <div style="background: #764ba2; color: white; min-width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px;">2</div>
                        <div style="flex: 1;">
                            <h5 style="color: #764ba2; font-size: 15px; margin-bottom: 8px; font-weight: 600;" data-i18n="step2DetailTitle">맞춤형 설문 생성</h5>
                            <p style="color: #666; font-size: 14px; line-height: 1.7; margin: 0;" data-i18n="step2DetailDesc">
                                입력하신 증상을 기반으로 AI가 추가로 필요한 정보를 파악하여 맞춤형 설문을 자동 생성합니다.
                                예: 두통이라면 "통증 부위", "지속 시간", "강도" 등을 물어봅니다.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- 3단계 -->
                <div style="background: white; padding: 20px; border-radius: 10px; border-left: 3px solid #5B6FB5;">
                    <div style="display: flex; align-items: start; gap: 15px;">
                        <div style="background: #5B6FB5; color: white; min-width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px;">3</div>
                        <div style="flex: 1;">
                            <h5 style="color: #5B6FB5; font-size: 15px; margin-bottom: 8px; font-weight: 600;" data-i18n="step3DetailTitle">키워드 추출 및 RAG 검색</h5>
                            <p style="color: #666; font-size: 14px; line-height: 1.7; margin: 0;" data-i18n="step3DetailDesc">
                                AI가 증상에서 핵심 키워드("두통", "발열", "구토" 등)를 추출하고,
                                이를 바탕으로 RAG(Retrieval-Augmented Generation)를 통해 방대한 의료 PDF 문서와 데이터베이스를 실시간 검색하여
                                관련 질병, 증상 패턴, 치료법 정보를 수집합니다.
                            </p>
                        </div>
                    </div>
                </div>

                <!-- 4단계 -->
                <div style="background: white; padding: 20px; border-radius: 10px; border-left: 3px solid #28a745;">
                    <div style="display: flex; align-items: start; gap: 15px;">
                        <div style="background: #28a745; color: white; min-width: 32px; height: 32px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-weight: bold; font-size: 16px;">4</div>
                        <div style="flex: 1;">
                            <h5 style="color: #28a745; font-size: 15px; margin-bottom: 8px; font-weight: 600;" data-i18n="step4DetailTitle">AI 종합 분석 및 병원 추천</h5>
                            <p style="color: #666; font-size: 14px; line-height: 1.7; margin: 0;" data-i18n="step4DetailDesc">
                                수집된 의료 정보와 설문 답변을 종합하여 AI가 증상을 분석하고,
                                가장 적합한 진료과를 추천합니다. 동시에 위치 정보를 활용하여 근처의 적절한 병원(1차/2차/3차)을 찾아드립니다.
                            </p>
                        </div>
                    </div>
                </div>
            </div>

        <form id="diagnosisForm" action="<c:url value='/dia/dia2'/>" method="post" enctype="multipart/form-data">
            <!-- 언어 정보 전송 -->
            <input type="hidden" id="languageInput" name="language" value="ko">

            <!-- 텍스트 입력 -->
            <div class="input-section">
                <label for="symptomText" data-i18n="symptomLabel">증상 설명</label>
                <textarea
                        id="symptomText"
                        name="symptomText"
                        data-i18n="symptomPlaceholder"
                        placeholder="예: 3일 전부터 머리가 지끈지끈 아프고 열이 38도 정도 나요. 목도 따끔거리고 기침도 조금 나옵니다."
                        required
                ></textarea>

                <!-- 음성 입력 & 사진 추가 버튼 -->
                <div class="input-buttons">
                    <button type="button" class="btn-voice" id="voiceBtn" data-i18n="voiceBtn">
                        🎤 음성으로 입력
                    </button>
                    <button type="button" class="btn-camera" data-i18n="cameraBtn" onclick="document.getElementById('imageInput').click()">
                        📷 사진 추가 (선택)
                    </button>
                </div>

                <!-- 숨겨진 파일 입력 -->
                <input
                        type="file"
                        id="imageInput"
                        name="symptomImages"
                        accept="image/*"
                        multiple
                        style="display: none;"
                >
            </div>

            <!-- 이미지 미리보기 -->
            <div class="image-preview" id="imagePreview"></div>

            <!-- 안내사항 -->
            <div class="info-box">
                <h4 data-i18n="infoTitle">💡 입력 팁</h4>
                <ul>
                    <li data-i18n="infoTip1">증상이 시작된 시기를 알려주세요 (예: 3일 전부터)</li>
                    <li data-i18n="infoTip2">통증의 정도나 빈도를 구체적으로 설명해주세요</li>
                    <li data-i18n="infoTip3">동반되는 다른 증상도 함께 말씀해주세요</li>
                    <li data-i18n="infoTip4">사진은 최대 5장까지 업로드 가능합니다</li>
                    <li data-i18n="infoTip5">약 복용 중이라면 함께 알려주세요</li>
                </ul>
            </div>

            <!-- 액션 버튼 -->
            <div class="action-buttons">
                <button type="button" class="btn btn-secondary" data-i18n="btnPrev" onclick="history.back()">
                    ← 이전으로
                </button>
                <button type="submit" class="btn btn-primary" id="submitBtn" data-i18n="btnNext">
                    다음 단계 (설문조사) →
                </button>
            </div>
        </form>
    </div>
</div>

<!-- multilang.js 추가 -->
<script src="<c:url value='/js/multilang.js'/>"></script>

<script>
    // 음성 입력 기능
    let recognition;
    let isRecording = false;

    document.getElementById('voiceBtn').addEventListener('click', function() {
        if (!isRecording) {
            startVoiceRecording();
        } else {
            stopVoiceRecording();
        }
    });

    function startVoiceRecording() {
        if ('webkitSpeechRecognition' in window || 'SpeechRecognition' in window) {
            const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition;
            recognition = new SpeechRecognition();

            // 언어에 따라 음성 인식 언어 설정
            const langCode = {
                'ko': 'ko-KR',
                'en': 'en-US',
                'ja': 'ja-JP',
                'zh': 'zh-CN'
            };
            recognition.lang = langCode[currentLang] || 'ko-KR';
            recognition.continuous = true;
            recognition.interimResults = true;

            recognition.onstart = function() {
                isRecording = true;
                document.getElementById('voiceBtn').classList.add('recording');
                document.getElementById('voiceBtn').textContent = t('voiceStopBtn');
            };

            recognition.onresult = function(event) {
                let transcript = '';
                for (let i = event.resultIndex; i < event.results.length; i++) {
                    transcript += event.results[i][0].transcript;
                }
                document.getElementById('symptomText').value = transcript;
            };

            recognition.onerror = function(event) {
                console.error('음성 인식 오류:', event.error);
                alert(t('alertVoiceNotSupported'));
                stopVoiceRecording();
            };

            recognition.start();
        } else {
            alert(t('alertVoiceNotSupported'));
        }
    }

    function stopVoiceRecording() {
        if (recognition) {
            recognition.stop();
            isRecording = false;
            document.getElementById('voiceBtn').classList.remove('recording');
            document.getElementById('voiceBtn').textContent = t('voiceBtn');
        }
    }

    // 이미지 업로드 및 미리보기
    const imageInput = document.getElementById('imageInput');
    const imagePreview = document.getElementById('imagePreview');
    let uploadedFiles = [];
    const dataTransfer = new DataTransfer();

    imageInput.addEventListener('change', (e) => {
        const files = Array.from(e.target.files);
        console.log('📸 선택된 파일:', files.length + '개');
        handleFiles(files);
    });

    function handleFiles(files) {
        if (uploadedFiles.length + files.length > 5) {
            alert(t('alertMaxImages'));
            return;
        }

        files.forEach(file => {
            if (file.type.startsWith('image/')) {
                console.log('✅ 이미지 추가:', file.name, file.type, file.size + ' bytes');
                uploadedFiles.push(file);
                dataTransfer.items.add(file);
                displayImage(file);
            } else {
                console.warn('⚠️ 이미지 파일이 아님:', file.type);
            }
        });

        imageInput.files = dataTransfer.files;
        console.log('📦 현재 업로드된 파일 수:', uploadedFiles.length);
    }

    function displayImage(file) {
        const reader = new FileReader();

        reader.onload = (e) => {
            console.log('🖼️ 이미지 로드 완료:', file.name);

            const div = document.createElement('div');
            div.className = 'preview-item';
            div.setAttribute('data-filename', file.name);

            const img = document.createElement('img');
            img.src = e.target.result;
            img.alt = 'preview';

            const removeBtn = document.createElement('button');
            removeBtn.type = 'button';
            removeBtn.className = 'remove-btn';
            removeBtn.textContent = '×';
            removeBtn.onclick = function() {
                removeImage(div, file.name);
            };

            div.appendChild(img);
            div.appendChild(removeBtn);
            imagePreview.appendChild(div);
            imagePreview.classList.add('show');

            console.log('✅ 미리보기 표시 완료:', file.name);
        };

        reader.onerror = (error) => {
            console.error('❌ 이미지 로드 실패:', error);
            alert(t('alertImageLoadError') + file.name);
        };

        reader.readAsDataURL(file);
    }

    function removeImage(previewDiv, fileName) {
        console.log('🗑️ 이미지 삭제:', fileName);

        uploadedFiles = uploadedFiles.filter(f => f.name !== fileName);

        const newDataTransfer = new DataTransfer();
        uploadedFiles.forEach(file => newDataTransfer.items.add(file));
        imageInput.files = newDataTransfer.files;

        previewDiv.remove();

        if (uploadedFiles.length === 0) {
            imagePreview.classList.remove('show');
        }

        console.log('📦 남은 파일 수:', uploadedFiles.length);
    }

    // 폼 제출 검증
    document.getElementById('diagnosisForm').addEventListener('submit', function(e) {
        const symptomText = document.getElementById('symptomText').value.trim();

        if (!symptomText) {
            e.preventDefault();
            alert(t('alertNoSymptom'));
            return;
        }

        if (symptomText.length < 10) {
            e.preventDefault();
            alert(t('alertShortSymptom'));
            return;
        }

        // 현재 언어 전송
        document.getElementById('languageInput').value = currentLang;

        const fileInput = document.getElementById('imageInput');
        console.log('=== 폼 제출 직전 확인 ===');
        console.log('📤 제출할 파일 수:', fileInput.files.length);

        if (fileInput.files.length > 0) {
            for (let i = 0; i < fileInput.files.length; i++) {
                console.log('파일 ' + (i+1) + ':', fileInput.files[i].name, fileInput.files[i].size + ' bytes');
            }
        } else {
            console.warn('⚠️ 제출할 이미지 파일이 없습니다');
        }

        document.getElementById('submitBtn').disabled = true;
        document.getElementById('submitBtn').textContent = t('processing');
    });
</script>
</body>
</html>