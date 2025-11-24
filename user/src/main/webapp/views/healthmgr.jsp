<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-11-17
  Time: 오후 1:40:10
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 건강 상담</title>
  <style>
      * {
          margin: 0;
          padding: 0;
          box-sizing: border-box;
      }

      body {
          font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Noto Sans KR', sans-serif;
          background: #f5f7fa;
          height: 100vh;
          overflow: hidden;
      }

      .main-container {
          max-width: 1400px;
          margin: 0 auto;
          height: 100vh;
          display: flex;
          flex-direction: column;
      }

      .header {
          background: white;
          padding: 20px;
          border-bottom: 1px solid #e2e8f0;
          display: flex;
          justify-content: space-between;
          align-items: center;
          z-index: 10;
      }

      .header h1 {
          font-size: 20px;
          color: #1a202c;
      }

      .header-actions {
          display: flex;
          gap: 10px;
      }

      .btn-secondary, .btn-primary {
          padding: 8px 16px;
          border: 1px solid #e2e8f0;
          background: white;
          border-radius: 6px;
          font-size: 14px;
          cursor: pointer;
          transition: all 0.2s;
      }

      .btn-secondary:hover {
          background: #f7fafc;
      }

      .btn-primary {
          background: #4299e1;
          color: white;
          border-color: #4299e1;
      }

      .btn-primary:hover {
          background: #3182ce;
      }

      /* 2단 레이아웃 */
      .content-wrapper {
          display: flex;
          flex: 1;
          overflow: hidden;
      }

      /* 왼쪽: 문서 업로드 및 미리보기 */
      .left-panel {
          width: 400px;
          background: white;
          border-right: 1px solid #e2e8f0;
          display: flex;
          flex-direction: column;
          overflow: hidden;
      }

      .upload-section {
          padding: 16px;
          border-bottom: 1px solid #e2e8f0;
          background: #f7fafc;
      }

      .upload-controls {
          display: flex;
          flex-direction: column;
          gap: 10px;
      }

      .file-input-wrapper {
          position: relative;
      }

      .file-input-wrapper input[type="file"] {
          display: none;
      }

      .file-label {
          padding: 10px;
          background: #48bb78;
          color: white;
          border-radius: 6px;
          cursor: pointer;
          font-size: 14px;
          text-align: center;
          display: block;
          transition: background 0.2s;
      }

      .file-label:hover {
          background: #38a169;
      }

      .file-info {
          display: none;
          padding: 8px;
          background: #edf2f7;
          border-radius: 4px;
          font-size: 13px;
          color: #4a5568;
      }

      .file-info.active {
          display: block;
      }

      .document-type-select {
          padding: 10px;
          border: 1px solid #cbd5e0;
          border-radius: 6px;
          font-size: 14px;
      }

      .upload-btn {
          padding: 10px;
          background: #4299e1;
          color: white;
          border: none;
          border-radius: 6px;
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
      }

      .upload-btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
      }

      .upload-btn:hover:not(:disabled) {
          background: #3182ce;
      }

      .upload-status {
          padding: 8px;
          border-radius: 4px;
          font-size: 13px;
          text-align: center;
          display: none;
      }

      .upload-status.success {
          background: #c6f6d5;
          color: #22543d;
          display: block;
      }

      .upload-status.error {
          background: #fed7d7;
          color: #742a2a;
          display: block;
      }

      /* 업로드된 이미지 목록 */
      .images-preview {
          flex: 1;
          overflow-y: auto;
          padding: 16px;
      }

      .images-preview h3 {
          font-size: 14px;
          color: #2d3748;
          margin-bottom: 12px;
      }

      .image-item {
          margin-bottom: 16px;
          border: 1px solid #e2e8f0;
          border-radius: 8px;
          overflow: hidden;
          background: white;
      }

      .image-item img {
          width: 100%;
          height: auto;
          display: block;
          cursor: pointer;
          transition: transform 0.2s;
      }

      .image-item img:hover {
          transform: scale(1.02);
      }

      .image-item-info {
          padding: 8px;
          background: #f7fafc;
          font-size: 12px;
          color: #718096;
      }

      .empty-images {
          text-align: center;
          padding: 40px 20px;
          color: #a0aec0;
      }

      /* 오른쪽: 채팅 영역 */
      .right-panel {
          flex: 1;
          display: flex;
          flex-direction: column;
          background: white;
      }

      .chat-container {
          display: flex;
          flex-direction: column;
          height: 100%;
      }

      .chat-messages {
          flex: 1;
          overflow-y: auto;
          padding: 20px;
          background: #f7fafc;
      }

      .message {
          margin-bottom: 16px;
          display: flex;
          animation: fadeIn 0.3s;
      }

      @keyframes fadeIn {
          from { opacity: 0; transform: translateY(10px); }
          to { opacity: 1; transform: translateY(0); }
      }

      .message.ai {
          justify-content: flex-start;
      }

      .message.user {
          justify-content: flex-end;
      }

      .message-content {
          max-width: 70%;
          padding: 12px 16px;
          border-radius: 12px;
          line-height: 1.6;
          font-size: 14px;
          white-space: pre-wrap;
      }

      .message.ai .message-content {
          background: white;
          border: 1px solid #e2e8f0;
          border-radius: 12px 12px 12px 4px;
      }

      .message.user .message-content {
          background: #4299e1;
          color: white;
          border-radius: 12px 12px 4px 12px;
      }

      .typing-indicator {
          display: none;
          padding: 12px 16px;
          background: white;
          border: 1px solid #e2e8f0;
          border-radius: 12px;
          width: 60px;
      }

      .typing-indicator span {
          height: 8px;
          width: 8px;
          background: #cbd5e0;
          border-radius: 50%;
          display: inline-block;
          margin-right: 4px;
          animation: bounce 1.4s infinite;
      }

      .typing-indicator span:nth-child(2) {
          animation-delay: 0.2s;
      }

      .typing-indicator span:nth-child(3) {
          animation-delay: 0.4s;
      }

      @keyframes bounce {
          0%, 60%, 100% { transform: translateY(0); }
          30% { transform: translateY(-10px); }
      }

      .chat-input-area {
          padding: 16px 20px;
          background: white;
          border-top: 1px solid #e2e8f0;
      }

      .quick-replies {
          display: flex;
          gap: 8px;
          margin-bottom: 12px;
          overflow-x: auto;
          padding-bottom: 8px;
      }

      .quick-reply-btn {
          padding: 8px 16px;
          border: 1px solid #e2e8f0;
          background: white;
          border-radius: 20px;
          font-size: 13px;
          white-space: nowrap;
          cursor: pointer;
          transition: all 0.2s;
      }

      .quick-reply-btn:hover {
          background: #4299e1;
          color: white;
          border-color: #4299e1;
      }

      .input-wrapper {
          display: flex;
          gap: 8px;
          align-items: flex-end;
      }

      textarea {
          flex: 1;
          border: 1px solid #cbd5e0;
          border-radius: 12px;
          padding: 12px;
          font-size: 14px;
          resize: none;
          min-height: 48px;
          max-height: 120px;
          font-family: inherit;
      }

      textarea:focus {
          outline: none;
          border-color: #4299e1;
      }

      .btn-send {
          padding: 12px 24px;
          background: #4299e1;
          color: white;
          border: none;
          border-radius: 12px;
          font-size: 14px;
          font-weight: 600;
          cursor: pointer;
          transition: background 0.2s;
      }

      .btn-send:hover:not(:disabled) {
          background: #3182ce;
      }

      .btn-send:disabled {
          opacity: 0.6;
          cursor: not-allowed;
      }

      .btn-voice {
          padding: 12px;
          background: #48bb78;
          color: white;
          border: none;
          border-radius: 12px;
          font-size: 18px;
          cursor: pointer;
          transition: background 0.2s;
      }

      .btn-voice:hover {
          background: #38a169;
      }

      .btn-voice.recording {
          background: #f56565;
          animation: pulse 1.5s infinite;
      }

      @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.7; }
      }

      .empty-state {
          text-align: center;
          padding: 60px 20px;
          color: #718096;
      }

      .empty-state h3 {
          margin-bottom: 16px;
          color: #2d3748;
      }

      /* 이미지 모달 */
      .image-modal {
          display: none;
          position: fixed;
          z-index: 1000;
          left: 0;
          top: 0;
          width: 100%;
          height: 100%;
          background: rgba(0, 0, 0, 0.9);
          align-items: center;
          justify-content: center;
      }

      .image-modal.active {
          display: flex;
      }

      .image-modal img {
          max-width: 90%;
          max-height: 90%;
          object-fit: contain;
      }

      .image-modal-close {
          position: absolute;
          top: 20px;
          right: 40px;
          color: white;
          font-size: 40px;
          cursor: pointer;
      }

      @media (max-width: 768px) {
          .content-wrapper {
              flex-direction: column;
          }

          .left-panel {
              width: 100%;
              height: 40%;
          }

          .right-panel {
              height: 60%;
          }

          .message-content {
              max-width: 85%;
          }
      }
  </style>
</head>
<body>
<div class="main-container">
  <!-- 헤더 -->
  <div class="header">
    <h1>AI 건강 상담</h1>
    <div class="header-actions">
      <button class="btn-primary" onclick="predictDisease()">질환 예측</button>
      <button class="btn-secondary" onclick="clearChat()">대화 초기화</button>
      <a href="<c:url value='/'/>" class="btn-secondary" style="text-decoration: none;">홈</a>
    </div>
  </div>

  <!-- 2단 레이아웃 -->
  <div class="content-wrapper">
    <!-- 왼쪽: 문서 업로드 -->
    <div class="left-panel">
      <div class="upload-section">
        <div class="upload-controls">
          <div class="file-input-wrapper">
            <input type="file" id="documentFile" accept=".pdf,.txt,.doc,.docx,.png,.jpg,.jpeg" onchange="handleFileSelect(event)">
            <label for="documentFile" class="file-label">진단서/처방전 업로드</label>
          </div>
          <div class="file-info" id="fileInfo"></div>
          <select id="documentType" class="document-type-select">
            <option value="diagnosis">진단서</option>
            <option value="prescription">처방전</option>
          </select>
          <button class="upload-btn" onclick="uploadDocument()" id="uploadBtn" disabled>업로드</button>
          <div class="upload-status" id="uploadStatus"></div>
        </div>
      </div>

      <!-- 업로드된 이미지 미리보기 -->
      <div class="images-preview" id="imagesPreview">
        <h3>업로드된 문서</h3>
        <div id="imagesList">
          <div class="empty-images">
            아직 업로드된 문서가 없습니다
          </div>
        </div>
      </div>
    </div>

    <!-- 오른쪽: 채팅 -->
    <div class="right-panel">
      <div class="chat-container">
        <div class="chat-messages" id="chatMessages">
          <div class="empty-state" id="emptyState">
            <h3>AI 건강 상담을 시작하세요</h3>
            <p>증상이나 건강 고민을 자유롭게 말씀해주세요</p>
            <p style="font-size: 13px; margin-top: 10px;">
              왼쪽에 진단서나 처방전 이미지를 업로드하면<br>더 정확한 분석이 가능합니다
            </p>
          </div>

          <div id="messagesContainer"></div>

          <div class="message ai">
            <div class="typing-indicator" id="typingIndicator">
              <span></span>
              <span></span>
              <span></span>
            </div>
          </div>
        </div>

        <div class="chat-input-area">
          <div class="quick-replies">
            <button class="quick-reply-btn" onclick="quickReply('전체 건강 상태 분석해줘')">건강 분석</button>
            <button class="quick-reply-btn" onclick="quickReply('추천 운동 알려줘')">운동 추천</button>
            <button class="quick-reply-btn" onclick="quickReply('식단 추천해줘')">식단 추천</button>
            <button class="quick-reply-btn" onclick="quickReply('최근 바이탈 데이터 설명해줘')">바이탈 확인</button>
          </div>

          <div class="input-wrapper">
            <textarea id="userInput" placeholder="메시지를 입력하세요..." rows="1"></textarea>
            <button class="btn-voice" id="voiceBtn" onclick="toggleVoice()" title="음성 입력">🎤</button>
            <button class="btn-send" id="sendBtn" onclick="sendMessage()">전송</button>
          </div>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- 이미지 확대 모달 -->
<div class="image-modal" id="imageModal" onclick="closeModal()">
  <span class="image-modal-close">&times;</span>
  <img id="modalImage" src="" alt="확대 이미지">
</div>

<script>
    let isRecognizing = false;
    let recognition;
    let selectedFile = null;

    // 음성 인식 초기화
    if ('webkitSpeechRecognition' in window) {
        recognition = new webkitSpeechRecognition();
        recognition.lang = 'ko-KR';
        recognition.continuous = false;
        recognition.interimResults = false;

        recognition.onresult = function(event) {
            const transcript = event.results[0][0].transcript;
            document.getElementById('userInput').value = transcript;
            stopVoice();
        };

        recognition.onerror = function(event) {
            console.error('음성 인식 오류:', event.error);
            stopVoice();
        };

        recognition.onend = function() {
            stopVoice();
        };
    }

    // 파일 선택 핸들러
    function handleFileSelect(event) {
        selectedFile = event.target.files[0];
        const fileInfo = document.getElementById('fileInfo');
        const uploadBtn = document.getElementById('uploadBtn');

        if (selectedFile) {
            const fileSize = (selectedFile.size / 1024 / 1024).toFixed(2);
            fileInfo.textContent = `${selectedFile.name} (${fileSize} MB)`;
            fileInfo.classList.add('active');
            uploadBtn.disabled = false;
        } else {
            fileInfo.classList.remove('active');
            uploadBtn.disabled = true;
        }
    }

    // 문서 업로드
    async function uploadDocument() {
        if (!selectedFile) {
            alert('파일을 선택해주세요.');
            return;
        }

        const documentType = document.getElementById('documentType').value;
        const uploadBtn = document.getElementById('uploadBtn');
        const uploadStatus = document.getElementById('uploadStatus');

        uploadBtn.disabled = true;
        uploadBtn.textContent = '업로드 중...';
        uploadStatus.className = 'upload-status';
        uploadStatus.style.display = 'none';

        const formData = new FormData();
        formData.append('file', selectedFile);
        formData.append('documentType', documentType);

        try {
            const response = await fetch('/healthmgr/upload-document', {
                method: 'POST',
                body: formData
            });

            const data = await response.json();

            if (data.success) {
                uploadStatus.textContent = '✓ 업로드 완료';
                uploadStatus.className = 'upload-status success';

                // 파일 입력 초기화
                document.getElementById('documentFile').value = '';
                document.getElementById('fileInfo').classList.remove('active');
                selectedFile = null;

                // 이미지 목록 새로고침
                loadUploadedImages();

                setTimeout(() => {
                    uploadStatus.style.display = 'none';
                }, 3000);
            } else {
                uploadStatus.textContent = '✗ ' + data.message;
                uploadStatus.className = 'upload-status error';
            }
        } catch (error) {
            console.error('업로드 오류:', error);
            uploadStatus.textContent = '✗ 업로드 실패';
            uploadStatus.className = 'upload-status error';
        } finally {
            uploadBtn.disabled = true;
            uploadBtn.textContent = '업로드';
        }
    }
    async function deleteImage(fileName) {
        if (!confirm('이 문서를 삭제하시겠습니까?')) {
            return;
        }

        try {
            const response = await fetch('/healthmgr/delete-document', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'fileName=' + encodeURIComponent(fileName)
            });

            const data = await response.json();

            if (data.success) {
                loadUploadedImages();  // 목록 새로고침
            } else {
                alert(data.message);
            }
        } catch (error) {
            console.error('삭제 오류:', error);
            alert('삭제 중 오류가 발생했습니다.');
        }
    }
    // 업로드된 이미지 목록 불러오기
    async function loadUploadedImages() {
        try {
            const response = await fetch('/healthmgr/uploaded-images');
            const data = await response.json();

            const imagesList = document.getElementById('imagesList');

            if (data.success && data.images.length > 0) {
                imagesList.innerHTML = '';
                data.images.forEach(image => {
                    const imageItem = document.createElement('div');
                    imageItem.className = 'image-item';

                    // 삼항 연산자 제거 - 일반 문자열 연결 사용
                    let documentTypeText = '문서';
                    if (image.documentType === 'diagnosis') {
                        documentTypeText = '진단서';
                    } else if (image.documentType === 'prescription') {
                        documentTypeText = '처방전';
                    }

                    imageItem.innerHTML =
                        '<img src="' + image.url + '" alt="' + image.documentType + '" onclick="openModal(\'' + image.url + '\')">' +
                        '<div class="image-item-info">' +
                        '<span>' + documentTypeText + ' - ' + image.fileName + '</span>' +
                        '<button onclick="event.stopPropagation(); deleteImage(\'' + image.fileName + '\')" ' +
                        'style="float:right; background:#f56565; color:white; border:none; border-radius:4px; padding:4px 8px; cursor:pointer;">' +
                        '삭제' +
                        '</button>' +
                        '</div>';


                    imagesList.appendChild(imageItem);
                });
            } else {
                imagesList.innerHTML = '<div class="empty-images">아직 업로드된 문서가 없습니다</div>';
            }
        } catch (error) {
            console.error('이미지 목록 로드 오류:', error);
        }
    }
    // 이미지 모달 열기
    function openModal(imageUrl) {
        document.getElementById('modalImage').src = imageUrl;
        document.getElementById('imageModal').classList.add('active');
    }

    // 이미지 모달 닫기
    function closeModal() {
        document.getElementById('imageModal').classList.remove('active');
    }

    // 질환 예측
    async function predictDisease() {
        if (!confirm('현재 건강 데이터를 기반으로 질환 발생 가능성을 예측하시겠습니까?')) {
            return;
        }

        document.getElementById('emptyState').style.display = 'none';
        addMessage('질환 발생 가능성 분석 요청', 'user');

        document.getElementById('typingIndicator').style.display = 'block';
        scrollToBottom();

        try {
            const response = await fetch('/healthmgr/predict-disease', {
                method: 'POST'
            });

            const data = await response.json();

            document.getElementById('typingIndicator').style.display = 'none';

            if (data.success) {
                addMessage(data.prediction, 'ai');
            } else {
                addMessage('예측 중 오류가 발생했습니다: ' + data.message, 'ai');
            }
        } catch (error) {
            console.error('예측 오류:', error);
            document.getElementById('typingIndicator').style.display = 'none';
            addMessage('네트워크 오류가 발생했습니다.', 'ai');
        }
    }

    function toggleVoice() {
        if (isRecognizing) {
            stopVoice();
        } else {
            startVoice();
        }
    }

    function startVoice() {
        if (!recognition) {
            alert('이 브라우저는 음성 인식을 지원하지 않습니다.');
            return;
        }

        recognition.start();
        isRecognizing = true;
        document.getElementById('voiceBtn').classList.add('recording');
        document.getElementById('voiceBtn').textContent = '⏹️';
    }

    function stopVoice() {
        if (recognition && isRecognizing) {
            recognition.stop();
        }
        isRecognizing = false;
        document.getElementById('voiceBtn').classList.remove('recording');
        document.getElementById('voiceBtn').textContent = '🎤';
    }

    function quickReply(text) {
        document.getElementById('userInput').value = text;
        sendMessage();
    }

    async function sendMessage() {
        const input = document.getElementById('userInput');
        const message = input.value.trim();

        if (!message) return;

        document.getElementById('emptyState').style.display = 'none';
        addMessage(message, 'user');
        input.value = '';

        const sendBtn = document.getElementById('sendBtn');
        sendBtn.disabled = true;
        sendBtn.textContent = '전송 중...';

        document.getElementById('typingIndicator').style.display = 'block';
        scrollToBottom();

        try {
            const response = await fetch('/healthmgr/chat', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ message: message })
            });

            const data = await response.json();

            document.getElementById('typingIndicator').style.display = 'none';

            if (data.success) {
                addMessage(data.message, 'ai');
            } else {
                addMessage('오류가 발생했습니다.', 'ai');
            }

        } catch (error) {
            console.error('채팅 오류:', error);
            document.getElementById('typingIndicator').style.display = 'none';
            addMessage('네트워크 오류가 발생했습니다.', 'ai');
        } finally {
            sendBtn.disabled = false;
            sendBtn.textContent = '전송';
        }
    }

    function addMessage(text, type) {
        const container = document.getElementById('messagesContainer');

        const messageDiv = document.createElement('div');
        messageDiv.className = `message ${type}`;

        const contentDiv = document.createElement('div');
        contentDiv.className = 'message-content';
        contentDiv.textContent = text;

        messageDiv.appendChild(contentDiv);
        container.appendChild(messageDiv);

        scrollToBottom();
    }

    function scrollToBottom() {
        const messages = document.getElementById('chatMessages');
        messages.scrollTop = messages.scrollHeight;
    }

    async function clearChat() {
        if (!confirm('대화 내역을 모두 삭제하시겠습니까?')) {
            return;
        }

        try {
            const response = await fetch('/healthmgr/chat/clear', {
                method: 'POST'
            });

            const data = await response.json();

            if (data.success) {
                document.getElementById('messagesContainer').innerHTML = '';
                document.getElementById('emptyState').style.display = 'block';
            }
        } catch (error) {
            console.error('초기화 오류:', error);
        }
    }

    // Enter 키로 전송
    document.getElementById('userInput').addEventListener('keydown', function(e) {
        if (e.key === 'Enter' && !e.shiftKey) {
            e.preventDefault();
            sendMessage();
        }
    });

    // 텍스트 영역 자동 높이 조절
    document.getElementById('userInput').addEventListener('input', function() {
        this.style.height = 'auto';
        this.style.height = (this.scrollHeight) + 'px';
    });

    // 페이지 로드 시
    window.addEventListener('DOMContentLoaded', async function() {
        // 이전 대화 내역 불러오기
        try {
            const response = await fetch('/healthmgr/chat/history');
            const data = await response.json();

            if (data.success && data.history.length > 0) {
                document.getElementById('emptyState').style.display = 'none';

                data.history.forEach(msg => {
                    const type = msg.role === 'user' ? 'user' : 'ai';
                    addMessage(msg.content, type);
                });
            }
        } catch (error) {
            console.error('대화 내역 로드 실패:', error);
        }

        // 업로드된 이미지 불러오기
        loadUploadedImages();
    });
</script>
</body>
</html>



