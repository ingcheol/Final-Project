<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>AI 기반 의료 매칭 시스템</title>
  <style>
    /* 기본 스타일 재설정 */
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Noto Sans KR', sans-serif; color: #333; line-height: 1.6; }

    /* 헤더 */
    header { background: white; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }
    nav { max-width: 1200px; margin: 0 auto; display: flex; justify-content: space-between; align-items: center; padding: 20px 40px; }
    .logo { font-size: 24px; font-weight: bold; color: #5B6FB5; }
    .nav-menu { display: flex; gap: 40px; list-style: none; }
    .nav-menu a { text-decoration: none; color: #333; font-weight: 500; transition: color 0.3s; }
    .nav-menu a:hover { color: #5B6FB5; }

    /* 메인 히어로 섹션 */
    .hero { margin-top: 80px; height: 600px; background: linear-gradient(rgba(91, 111, 181, 0.1), rgba(91, 111, 181, 0.2)), url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600"><rect fill="%23f0f4f8" width="1200" height="600"/></svg>'); background-size: cover; background-position: center; display: flex; align-items: center; position: relative; }
    .hero-content { max-width: 1200px; margin: 0 auto; padding: 0 40px; width: 100%; display: flex; justify-content: space-between; align-items: center; }
    .hero-text { flex: 1; }
    .hero-text h1 { font-size: 48px; color: #333; margin-bottom: 20px; line-height: 1.3; }
    .hero-text .highlight { color: #5B6FB5; font-weight: bold; }
    .hero-text p { font-size: 20px; color: #666; margin-bottom: 30px; }
    .quick-menu { background: #5B6FB5; padding: 40px; border-radius: 10px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; width: 300px; }
    .quick-item { background: rgba(255, 255, 255, 0.2); padding: 30px 20px; text-align: center; border-radius: 8px; color: white; cursor: pointer; transition: all 0.3s; }
    .quick-item:hover { background: rgba(255, 255, 255, 0.3); transform: translateY(-5px); }
    .quick-item svg { width: 50px; height: 50px; margin-bottom: 10px; }

    /* 공지사항 */
    .notice-section { max-width: 1200px; margin: 80px auto; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
    .notice-box { background: white; border: 1px solid #e0e0e0; border-radius: 10px; padding: 30px; }
    .notice-box h3 { font-size: 22px; margin-bottom: 20px; color: #333; border-bottom: 2px solid #5B6FB5; padding-bottom: 10px; }
    .notice-item { padding: 15px 0; border-bottom: 1px solid #f0f0f0; cursor: pointer; transition: background 0.3s; }

    /* 진료 안내 */
    .treatment-guide { background: #f8f9fa; padding: 80px 40px; text-align: center; }
    .treatment-guide h2 { font-size: 36px; margin-bottom: 20px; color: #333; }
    .guide-cards { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; }
    .guide-card { background: white; padding: 40px 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); transition: all 0.3s; cursor: pointer; }

    /* About 섹션 */
    .about-section { max-width: 1200px; margin: 80px auto; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center; }
    .about-image { width: 100%; height: 400px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; }
    .btn-primary { display: inline-block; background: #5B6FB5; color: white; padding: 15px 40px; border-radius: 5px; text-decoration: none; font-weight: 500; transition: all 0.3s; }

    /* Footer */
    footer { background: #2c3e50; color: white; padding: 60px 40px 30px; }
    .footer-content { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 2fr 1fr; gap: 60px; margin-bottom: 30px; }
    .footer-bottom { text-align: center; padding-top: 30px; border-top: 1px solid #34495e; color: #95a5a6; }

    /* 챗봇 버튼 */
    .chatbot-button {
      position: fixed; bottom: 30px; right: 30px; width: 70px; height: 70px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      border-radius: 50%; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3);
      cursor: pointer; display: flex; align-items: center; justify-content: center;
      transition: all 0.3s ease; z-index: 999; border: none;
    }
    .chatbot-button:hover { transform: scale(1.1); box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4); }
    .chatbot-button svg { width: 35px; height: 35px; fill: white; }

    /* 챗봇 모달 */
    .chatbot-modal {
      display: none; position: fixed; bottom: 120px; right: 30px;
      width: 400px; height: 600px; background: white; border-radius: 20px;
      box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2); z-index: 998;
      flex-direction: column; overflow: hidden;
    }
    .chatbot-modal.active { display: flex; }
    .chatbot-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; display: flex; justify-content: space-between; align-items: center; }
    .chatbot-close { background: none; border: none; color: white; font-size: 24px; cursor: pointer; }
    .chatbot-body { flex: 1; padding: 20px; overflow-y: auto; background: #f5f5f5; }

    /* 대화 메시지 스타일 (카카오톡 스타일) */
    .chat-message {
      margin-bottom: 15px;
      display: flex;
      gap: 10px;
      animation: slideIn 0.3s ease-out;
    }

    .chat-message.user {
      justify-content: flex-end;
    }

    .chat-message.bot {
      justify-content: flex-start;
    }

    .message-bubble {
      max-width: 70%;
      padding: 12px 16px;
      word-wrap: break-word;
      line-height: 1.5;
      font-size: 15px;
      position: relative;
    }

    /* 사용자 메시지 (오른쪽, 파란색 말풍선) */
    .chat-message.user .message-bubble {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border-radius: 18px 18px 4px 18px;
      box-shadow: 0 2px 4px rgba(102, 126, 234, 0.3);
    }

    /* 봇 메시지 (왼쪽, 흰색 말풍선) */
    .chat-message.bot .message-bubble {
      background: white;
      color: #333;
      border-radius: 18px 18px 18px 4px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    @keyframes slideIn {
      from {
        opacity: 0;
        transform: translateY(10px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .chatbot-footer { padding: 15px; background: white; border-top: 1px solid #e0e0e0; display: flex; gap: 10px; }
    .chatbot-input { flex: 1; padding: 12px 16px; border: 1px solid #e0e0e0; border-radius: 25px; outline: none; font-size: 14px; }
    .chatbot-send { width: 45px; height: 45px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border: none; border-radius: 50%; color: white; cursor: pointer; display: flex; align-items: center; justify-content: center; }
    .chatbot-send:disabled { opacity: 0.5; cursor: not-allowed; }
    .typing-indicator { display: none; padding: 12px 16px; background: white; border-radius: 18px; width: fit-content; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
    .typing-indicator.active { display: block; }
    .typing-indicator span { display: inline-block; width: 8px; height: 8px; background: #999; border-radius: 50%; margin: 0 2px; animation: typing 1.4s infinite; }
    .typing-indicator span:nth-child(2) { animation-delay: 0.2s; }
    .typing-indicator span:nth-child(3) { animation-delay: 0.4s; }
    @keyframes typing { 0%, 60%, 100% { transform: translateY(0); } 30% { transform: translateY(-10px); } }

    /* 반응형 */
    @media (max-width: 768px) {
      .hero-content { flex-direction: column; text-align: center; }
      .quick-menu { width: 100%; margin-top: 30px; }
      .notice-section, .guide-cards, .about-section, .footer-content { grid-template-columns: 1fr; }
      .hero-text h1 { font-size: 32px; }
      .chatbot-modal { width: 90%; height: 70%; right: 5%; bottom: 80px; }
      .chatbot-button { width: 60px; height: 60px; bottom: 20px; right: 20px; }
      .chatbot-button svg { width: 30px; height: 30px; }
    }
  </style>
</head>
<body>
<c:choose>
  <c:when test="${center != null}">
    <jsp:include page="${center}.jsp"/>
  </c:when>
  <c:otherwise>
    <header>
      <nav>
        <div class="logo">🏥 AI 의료 매칭 시스템</div>
        <ul class="nav-menu">
          <li><a href="#home">홈</a></li>
          <li><a href="#services">서비스 소개</a></li>
          <li><a href="#diagnosis">자가진단</a></li>
          <li><a href="#hospitals">병원찾기</a></li>
          <li><a href="#contact">문의하기</a></li>
          <li><a href="<c:url value='/statview'/>">통계 확인</a></li>
          <li><a href="<c:url value='/consul'/>">상담하기</a></li>
          <c:choose>
            <c:when test="${loginuser != null}">
              <li><a href="<c:url value='/info?patientId=${loginuser.patientId}'/>">${loginuser.patientName}님</a></li>
              <li><a href="<c:url value='/logout'/>">로그아웃</a></li>
            </c:when>
            <c:otherwise>
              <li><a href="<c:url value='/login'/>">로그인</a></li>
            </c:otherwise>
          </c:choose>
        </ul>
      </nav>
    </header>

    <section class="hero" id="home">
      <div class="hero-content">
        <div class="hero-text">
          <h1>
            <span class="highlight">행복한 삶을 위한 치료</span><br>
            셀플 전향의과와 함께하세요
          </h1>
          <p>AI 기반 스마트 병원 매칭으로<br>의료 취약계층의 건강을 지킵니다</p>
        </div>
        <div class="quick-menu">
          <div class="quick-item" onclick="location.href='#services'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
            </svg>
            <div>병원 추천</div>
          </div>
          <div class="quick-item" onclick="location.href='#diagnosis'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <div>자가 진단</div>
          </div>
          <div class="quick-item" onclick="location.href='#contact'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
            </svg>
            <div>문의 하기</div>
          </div>
          <div class="quick-item" onclick="alert('준비 중입니다.')">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
            </svg>
            <div>응급의료</div>
          </div>
        </div>
      </div>
    </section>

    <section class="notice-section">
      <div class="notice-box">
        <h3>📢 공지사항</h3>
        <div class="notice-item">
          <div class="title">AI 의료 매칭 서비스 정식 오픈</div>
          <div class="date">2025.11.10</div>
        </div>
        <div class="notice-item">
          <div class="title">의료 취약계층 지원 프로그램 안내</div>
          <div class="date">2025.11.05</div>
        </div>
        <div class="notice-item">
          <div class="title">자가진단 시스템 업데이트 완료</div>
          <div class="date">2025.11.01</div>
        </div>
      </div>
      <div class="notice-box">
        <h3>📰 보도자료</h3>
        <div class="notice-item">
          <div class="title">SPRING AI 기반 병원 매칭 시스템 도입</div>
          <div class="date">2025.11.08</div>
        </div>
        <div class="notice-item">
          <div class="title">의료 사각지대 해소를 위한 혁신 서비스</div>
          <div class="date">2025.10.28</div>
        </div>
        <div class="notice-item">
          <div class="title">공공기관 협력 병원 네트워크 확대</div>
          <div class="date">2025.10.20</div>
        </div>
      </div>
    </section>

    <section class="treatment-guide" id="services">
      <h2>진료 안내</h2>
      <p class="subtitle">AI 기반 스마트 매칭으로 최적의 의료 서비스를 제공합니다</p>
      <div class="guide-cards">
        <div class="guide-card featured">
          <svg fill="#5B6FB5" viewBox="0 0 24 24">
            <path d="M12 2L4 5v6.09c0 5.05 3.41 9.76 8 10.91 4.59-1.15 8-5.86 8-10.91V5l-8-3zm-1 16h2v-2h-2v2zm0-4h2V7h-2v7z"/>
          </svg>
          <h4>초음파 검사</h4>
          <p>최신 장비를 이용한 정밀 초음파 검사로 질병을 조기에 발견합니다</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
          </svg>
          <h4>주사치료</h4>
          <p>숙련된 의료진의 안전하고 효과적인 주사 치료를 제공합니다</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm4.59-12.42L10 14.17l-2.59-2.58L6 13l4 4 8-8z"/>
          </svg>
          <h4>물리치료</h4>
          <p>재활 및 통증 완화를 위한 전문 물리치료 프로그램</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          <h4>건강검진</h4>
          <p>정기적인 건강검진으로 질병을 예방하고 건강을 관리합니다</p>
        </div>
      </div>
    </section>

    <section class="about-section">
      <div class="about-image">
        🏥 AI 의료 매칭 시스템
      </div>
      <div class="about-content">
        <h2>숙련된 경험과 전확한 진단,</h2>
        <h3>디나건의 의상치료정형</h3>
        <p>
          SPRING AI 기술을 활용하여 의료 취약계층을 위한<br>
          최적의 병원을 매칭해드립니다.<br><br>
          자가진단을 통해 증상을 분석하고,<br>
          보건소의 검증을 거쳐 가장 적합한 공공기관 병원을<br>
          추천받으세요.
        </p>
        <a href="#diagnosis" class="btn-primary">자가 진단하기</a>
      </div>
    </section>

    <section class="about-section">
      <div class="about-content">
        <h2>최고의 전문 의료진이</h2>
        <h3>건강 주치의가 되겠습니다.</h3>
        <p>
          의료 사각지대 해소를 위해<br>
          전국 공공기관 병원 네트워크를 구축했습니다.<br><br>
          IoT 기기 연동으로 실시간 건강 데이터를 수집하고,<br>
          AI가 분석하여 정확한 병원 추천을 제공합니다.
        </p>
        <a href="#hospitals" class="btn-primary">병원 찾아보기</a>
      </div>
      <div class="about-image">
        🤖 SPRING AI 기술
      </div>
    </section>

    <button class="chatbot-button" onclick="toggleChatbot()">
      <svg viewBox="0 0 24 24">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-3 12H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1z"/>
      </svg>
    </button>

    <div class="chatbot-modal" id="chatbotModal">
      <div class="chatbot-header">
        <h3>🏥 AI 의료 상담</h3>
        <button class="chatbot-close" onclick="toggleChatbot()">×</button>
      </div>
      <div class="chatbot-body" id="chatBody">
        <div class="chat-message bot">
          <div class="message-bubble">
            안녕하세요! AI 의료 상담 챗봇입니다.<br>
            궁금하신 내용을 자유롭게 물어보세요.
          </div>
        </div>
        <div class="typing-indicator" id="typingIndicator">
          <span></span><span></span><span></span>
        </div>
      </div>
      <div class="chatbot-footer">
        <input type="text" class="chatbot-input" id="chatInput" placeholder="메시지를 입력하세요..." onkeypress="handleKeyPress(event)">
        <button class="chatbot-send" onclick="sendMessage()" id="sendBtn">
          <svg width="20" height="20" viewBox="0 0 24 24" fill="white">
            <path d="M2.01 21L23 12 2.01 3 2 10l15 2-15 2z"/>
          </svg>
        </button>
      </div>
    </div>

    <footer id="contact">
      <div class="footer-content">
        <div class="footer-info">
          <h3>AI 기반 의료 매칭 시스템</h3>
          <p>주소: 서울특별시 강남구, 대한민국 우편번호 06234</p>
          <p>이메일: contact@medical-ai.kr</p>
          <p>대표자: 홍길동</p>
        </div>
        <div class="footer-contact">
          <h3>전문 의료상담</h3>
          <div class="contact-number">1234-5678</div>
          <p>평일: AM 9:00 - PM 6:00</p>
          <p>토요일: AM 9:00 - PM 1:00</p>
          <p>일요일: PM 1:00 - PM 6:00</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p>Copyright © 2025 AI 의료 매칭 시스템. All Rights Reserved.</p>
      </div>
    </footer>

    <script>
      function toggleChatbot() {
        const modal = document.getElementById('chatbotModal');
        modal.classList.toggle('active');
      }

      function handleKeyPress(event) {
        if (event.key === 'Enter') {
          sendMessage();
        }
      }

      async function sendMessage() {
        const input = document.getElementById('chatInput');
        const message = input.value.trim();

        if (!message) return;

        // 사용자 메시지 표시
        addMessage(message, 'user');
        input.value = '';

        // 전송 버튼 비활성화
        const sendBtn = document.getElementById('sendBtn');
        sendBtn.disabled = true;

        // 타이핑 인디케이터 표시
        const typingIndicator = document.getElementById('typingIndicator');
        typingIndicator.classList.add('active');

        try {
          // Spring AI API 호출
          const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({ question: message })
          });

          const data = await response.json();

          // 타이핑 인디케이터 숨김
          typingIndicator.classList.remove('active');

          // AI 응답 표시
          addMessage(data.answer || '죄송합니다. 응답을 생성할 수 없습니다.', 'bot');

        } catch (error) {
          console.error('Error:', error);
          typingIndicator.classList.remove('active');
          addMessage('죄송합니다. 오류가 발생했습니다. 다시 시도해주세요.', 'bot');
        } finally {
          sendBtn.disabled = false;
        }
      }

      function addMessage(text, sender) {
        const chatBody = document.getElementById('chatBody');
        const messageDiv = document.createElement('div');
        messageDiv.className = `chat-message ${sender}`;

        const bubbleDiv = document.createElement('div');
        bubbleDiv.className = 'message-bubble';
        bubbleDiv.textContent = text;

        messageDiv.appendChild(bubbleDiv);

        // 타이핑 인디케이터 전에 삽입
        const typingIndicator = document.getElementById('typingIndicator');
        chatBody.insertBefore(messageDiv, typingIndicator);

        // 스크롤을 최하단으로
        chatBody.scrollTop = chatBody.scrollHeight;
      }

      // 부드러운 스크롤
      document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
          e.preventDefault();
          const target = document.querySelector(this.getAttribute('href'));
          if (target) {
            target.scrollIntoView({
              behavior: 'smooth',
              block: 'start'
            });
          }
        });
      });
    </script>
  </c:otherwise>
</c:choose>
</body>
</html>