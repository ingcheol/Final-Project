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

        .main-container {
            margin-top: 100px;
            padding: 40px 30px;
            max-width: 1000px;
            margin-left: auto;
            margin-right: auto;
        }

        /* Progress Bar */
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

        .progress-step.completed .circle {
            background: #28a745;
            color: white;
            border-color: #28a745;
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

        /* Card */
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

        /* Input Section */
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

        /* Image Upload */
        .image-upload-area {
            margin-top: 30px;
            border: 3px dashed #e0e0e0;
            border-radius: 12px;
            padding: 40px;
            text-align: center;
            cursor: pointer;
            transition: all 0.3s;
            background: #fafafa;
        }

        .image-upload-area:hover {
            border-color: #5B6FB5;
            background: #f0f4ff;
        }

        .image-upload-area.dragover {
            border-color: #5B6FB5;
            background: #e8f0fe;
            transform: scale(1.02);
        }

        .upload-icon {
            font-size: 48px;
            margin-bottom: 15px;
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

        /* Action Buttons */
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

        /* Info Box */
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
        <a href="<c:url value="/"/>" class="logo">🏥 AI 의료 매칭 시스템</a>
        <ul class="nav-menu">
            <li><a href="<c:url value="/"/>">홈</a></li>
            <li><a href="<c:url value="/#services"/>">서비스 소개</a></li>
            <li><a href="<c:url value="/#diagnosis"/>">자가진단</a></li>
            <li><a href="<c:url value="/map/map1"/>" style="color: #5B6FB5;">병원찾기</a></li>
            <li><a href="<c:url value="/#contact"/>">문의하기</a></li>
        </ul>
    </nav>
</header>

<div class="main-container">
    <!-- Progress Bar -->
    <div class="progress-bar">
        <div class="progress-step active">
            <div class="circle">1</div>
            <span>증상 입력</span>
        </div>
        <div class="progress-step">
            <div class="circle">2</div>
            <span>설문조사</span>
        </div>
        <div class="progress-step">
            <div class="circle">3</div>
            <span>AI 분석</span>
        </div>
        <div class="progress-step">
            <div class="circle">4</div>
            <span>결과 확인</span>
        </div>
    </div>

    <!-- Diagnosis Card -->
    <div class="diagnosis-card">
        <div class="card-header">
            <h2>증상을 입력해주세요</h2>
            <p>현재 불편하신 증상을 자세히 설명해주시면 AI가 분석해드립니다</p>
        </div>

        <form id="diagnosisForm" action="<c:url value="/dia/dia2"/>" method="post" enctype="multipart/form-data">
            <!-- 텍스트 입력 -->
            <div class="input-section">
                <label for="symptomText">증상 설명 *</label>
                <textarea
                        id="symptomText"
                        name="symptomText"
                        placeholder="예: 3일 전부터 머리가 지끈지끈 아프고 열이 38도 정도 나요. 목도 따끔거리고 기침도 조금 나옵니다."
                        required
                ></textarea>
                <div class="input-buttons">
                    <button type="button" class="btn-voice" id="voiceBtn">
                         음성으로 입력
                    </button>
                    <button type="button" class="btn-camera" onclick="document.getElementById('imageInput').click()">
                         사진 추가 (선택)
                    </button>
                </div>
            </div>

            <!-- 이미지 업로드 -->
            <div class="image-upload-area" id="uploadArea">
                <div class="upload-icon">📸</div>
                <h4 style="margin: 10px 0;">증상 사진 업로드 (선택사항)</h4>
                <p style="color: #7f8c8d; font-size: 14px; margin-top: 8px;">
                    피부 발진, 상처 등의 사진을 업로드하면 더 정확한 분석이 가능합니다
                </p>
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
                <h4>💡 입력 팁</h4>
                <ul>
                    <li>증상이 시작된 시기를 알려주세요 (예: 3일 전부터)</li>
                    <li>통증의 정도나 빈도를 구체적으로 설명해주세요</li>
                    <li>동반되는 다른 증상도 함께 말씀해주세요</li>
                    <li>사진은 최대 5장까지 업로드 가능합니다</li>
                    <li>약 복용 중이라면 함께 알려주세요</li>
                </ul>
            </div>

            <!-- 액션 버튼 -->
            <div class="action-buttons">
                <button type="button" class="btn btn-secondary" onclick="history.back()">
                    ← 이전으로
                </button>
                <button type="submit" class="btn btn-primary" id="submitBtn">
                    다음 단계 (설문조사) →
                </button>
            </div>
        </form>
    </div>
</div>

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
            recognition.lang = 'ko-KR';
            recognition.continuous = true;
            recognition.interimResults = true;

            recognition.onstart = function() {
                isRecording = true;
                document.getElementById('voiceBtn').classList.add('recording');
                document.getElementById('voiceBtn').innerHTML = '⏹️ 녹음 중지';
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
                alert('음성 인식 중 오류가 발생했습니다: ' + event.error);
                stopVoiceRecording();
            };

            recognition.start();
        } else {
            alert('이 브라우저는 음성 인식을 지원하지 않습니다.\n크롬 브라우저를 사용해주세요.');
        }
    }

    function stopVoiceRecording() {
        if (recognition) {
            recognition.stop();
            isRecording = false;
            document.getElementById('voiceBtn').classList.remove('recording');
            document.getElementById('voiceBtn').innerHTML = '🎤 음성으로 입력';
        }
    }

    // 이미지 업로드 기능
    const uploadArea = document.getElementById('uploadArea');
    const imageInput = document.getElementById('imageInput');
    const imagePreview = document.getElementById('imagePreview');
    let uploadedFiles = [];

    uploadArea.addEventListener('click', () => imageInput.click());

    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });

    uploadArea.addEventListener('dragleave', () => {
        uploadArea.classList.remove('dragover');
    });

    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');
        handleFiles(e.dataTransfer.files);
    });

    imageInput.addEventListener('change', (e) => {
        handleFiles(e.target.files);
    });

    function handleFiles(files) {
        if (uploadedFiles.length + files.length > 5) {
            alert('이미지는 최대 5장까지 업로드 가능합니다.');
            return;
        }

        Array.from(files).forEach(file => {
            if (file.type.startsWith('image/')) {
                uploadedFiles.push(file);
                displayImage(file);
            }
        });
    }

    function displayImage(file) {
        const reader = new FileReader();
        reader.onload = (e) => {
            const div = document.createElement('div');
            div.className = 'preview-item';
            div.innerHTML = `
                <img src="${e.target.result}" alt="preview">
                <button type="button" class="remove-btn" onclick="removeImage(this, '${file.name}')">×</button>
            `;
            imagePreview.appendChild(div);
            imagePreview.classList.add('show');
        };
        reader.readAsDataURL(file);
    }

    function removeImage(btn, fileName) {
        uploadedFiles = uploadedFiles.filter(f => f.name !== fileName);
        btn.parentElement.remove();

        if (uploadedFiles.length === 0) {
            imagePreview.classList.remove('show');
        }
    }

    // 폼 제출 검증
    document.getElementById('diagnosisForm').addEventListener('submit', function(e) {
        const symptomText = document.getElementById('symptomText').value.trim();

        if (!symptomText) {
            e.preventDefault();
            alert('증상을 입력해주세요.');
            return;
        }

        if (symptomText.length < 10) {
            e.preventDefault();
            alert('증상을 좀 더 자세히 입력해주세요. (최소 10자 이상)');
            return;
        }

        // 제출 버튼 비활성화
        document.getElementById('submitBtn').disabled = true;
        document.getElementById('submitBtn').innerHTML = '처리 중...';
    });
</script>
</body>
</html>