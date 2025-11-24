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

      .container {
          max-width: 1000px;
          margin: 0 auto;
          height: 100vh;
          display: flex;
          flex-direction: column;
          background: white;
          box-shadow: 0 0 20px rgba(0,0,0,0.1);
      }

      .header {
          background: #4299e1;
          padding: 20px;
          border-bottom: 1px solid #e2e8f0;
          display: flex;
          justify-content: space-between;
          align-items: center;
      }

      .header h1 {
          font-size: 20px;
          color: #1a202c;
      }

      .header-actions {
          display: flex;
          gap: 10px;
      }

      .btn-secondary {
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
          background: bisque;
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

      .message-label {
          font-size: 12px;
          color: #718096;
          margin-bottom: 4px;
          padding: 0 4px;
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

      @media (max-width: 768px) {
          .container {
              max-width: 100%;
          }

          .message-content {
              max-width: 85%;
          }

          .quick-replies {
              flex-wrap: nowrap;
          }
      }
  </style>

  <script>
      let isRecognizing = false;
      let recognition;

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
              alert('음성 인식 오류가 발생했습니다.');
          };

          recognition.onend = function() {
              stopVoice();
          };
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

          // 빈 상태 숨기기
          document.getElementById('emptyState').style.display = 'none';

          // 사용자 메시지 추가
          addMessage(message, 'user');
          input.value = '';

          // 전송 버튼 비활성화
          const sendBtn = document.getElementById('sendBtn');
          sendBtn.disabled = true;
          sendBtn.textContent = '전송 중...';

          // 타이핑 인디케이터 표시
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

              // 타이핑 인디케이터 숨기기
              document.getElementById('typingIndicator').style.display = 'none';

              if (data.success) {
                  addMessage(data.message, 'ai');
              } else {
                  if (data.redirect) {
                      alert(data.message);
                      window.location.href = data.redirect;
                  } else {
                      addMessage(data.message || '오류가 발생했습니다.', '건강상담');
                  }
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
              alert('초기화에 실패했습니다.');
          }
      }

      window.addEventListener('DOMContentLoaded', function() {
          const userInput = document.getElementById('userInput');

          if (userInput) {
              // Enter 키로 전송 (Shift+Enter는 줄바꿈)
              userInput.addEventListener('keydown', function(e) {
                  if (e.key === 'Enter' && !e.shiftKey) {
                      e.preventDefault();
                      sendMessage();
                  }
              });

              // 텍스트 영역 자동 높이 조절
              userInput.addEventListener('input', function() {
                  this.style.height = 'auto';
                  this.style.height = (this.scrollHeight) + 'px';
              });
          }
      });

      // // 페이지 로드 시 이전 대화 내역 불러오기
      // window.addEventListener('DOMContentLoaded', async function() {
      //     try {
      //         const response = await fetch('/healthmgr/chat/history');
      //         const data = await response.json();
      //
      //         if (data.success && data.history.length > 0) {
      //             document.getElementById('emptyState').style.display = 'none';
      //
      //             data.history.forEach(msg => {
      //                 const type = msg.role === 'user' ? 'user' : 'ai';
      //                 addMessage(msg.content, type);
      //             });
      //         }
      //     } catch (error) {
      //         console.error('대화 내역 로드 실패:', error);
      //     }
      // });
  </script>

</head>
<body>

<div class="container">
  <!-- 헤더 -->
  <div class="header">
    <h1>AI 건강 상담</h1>
    <div class="header-actions">
      <button class="btn-secondary" onclick="clearChat()">대화 초기화</button>
      <a href="<c:url value='/'/>" class="btn-secondary" style="text-decoration: none; display: inline-block;">홈</a>
    </div>
  </div>

  <!-- 채팅 메시지 영역 -->
  <div class="chat-messages" id="chatMessages">
    <div class="empty-state" id="emptyState">
      <h3>AI 건강 상담을 시작하세요</h3>
      <p>증상이나 건강 고민을 자유롭게 말씀해주세요</p>
    </div>

    <div id="messagesContainer"></div>

    <!-- 타이핑 인디케이터 -->
    <div class="message ai">
      <div class="typing-indicator" id="typingIndicator">
        <span></span>
        <span></span>
        <span></span>
      </div>
    </div>
  </div>

  <!-- 입력 영역 -->
  <div class="chat-input-area">
    <!-- 빠른 답변 버튼 -->
    <div class="quick-replies">
      <button class="quick-reply-btn" onclick="quickReply('전체 건강 상태 분석해줘')">건강 분석</button>
      <button class="quick-reply-btn" onclick="quickReply('추천 운동 알려줘')">운동 추천</button>
      <button class="quick-reply-btn" onclick="quickReply('식단 추천해줘')">식단 추천</button>
      <button class="quick-reply-btn" onclick="quickReply('최근 바이탈 데이터 설명해줘')">바이탈 확인</button>
    </div>

    <!-- 입력 필드 -->
    <div class="input-wrapper">
            <textarea id="userInput"
                      placeholder="메시지를 입력하세요..."
                      rows="1"></textarea>
      <button class="btn-voice" id="voiceBtn" onclick="toggleVoice()" title="음성 입력">🎤</button>
      <button class="btn-send" id="sendBtn" onclick="sendMessage()">전송</button>
    </div>
  </div>
</div>

</body>
</html>


