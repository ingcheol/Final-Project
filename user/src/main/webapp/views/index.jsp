<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib uri="http://www.springframework.org/tags" prefix="spring" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title data-lang-key="pageTitle">AI 기반 의료 매칭 시스템</title>
  <style>
    /* 기본 CSS 유지 */
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Noto Sans KR', sans-serif; color: #333; line-height: 1.6; }
    header { background: white; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1); position: fixed; width: 100%; top: 0; z-index: 1000; }

    /* === 헤더 레이아웃 안정화 수정 시작 === */
    nav {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 15px; /* 좌우 패딩을 더 줄임 */
    }
    .logo {
        font-size: 24px; /* 로고 폰트 크기 미세 조정 */
        font-weight: bold;
        color: #5B6FB5;
        white-space: nowrap;
    }
    .nav-menu {
        display: flex;
        gap: 12px; /* 메뉴 항목 간격을 최소화 */
        list-style: none;
        align-items: center;
        flex-wrap: nowrap; /* 줄 바꿈 절대 방지 */
        margin-left: auto; /* 로고와 메뉴 간격을 벌림 */
    }
    .nav-menu li {
        white-space: nowrap;
        padding: 0 5px; /* 리스트 항목의 좌우 패딩을 최소화 */
    }
    .nav-menu a {
        text-decoration: none;
        color: #333;
        font-weight: 500;
        transition: color 0.3s;
        font-size: 15px; /* 메뉴 텍스트 크기 축소 */
    }
    .nav-menu a:hover { color: #5B6FB5; }

    /* 언어 선택 드롭다운 스타일 */
    #language-select {
        padding: 4px 6px; /* 드롭다운 패딩 축소 */
        border: 1px solid #ccc;
        border-radius: 4px;
        font-size: 13px;
        cursor: pointer;
    }
    /* === 헤더 레이아웃 안정화 수정 끝 === */


    /* 나머지 CSS는 기존 유지 */
    .hero { margin-top: 80px; height: 600px; background: linear-gradient(rgba(91, 111, 181, 0.1), rgba(91, 111, 181, 0.2)), url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600"><rect fill="%23f0f4f8" width="1200" height="600"/></svg>'); background-size: cover; background-position: center; display: flex; align-items: center; position: relative; }
    .hero-content { max-width: 1200px; margin: 0 auto; padding: 0 40px; width: 100%; display: flex; justify-content: space-between; align-items: center; }
    .hero-text { flex: 1; }
    .hero-text h1 { font-size: 48px; color: #333; margin-bottom: 20px; line-height: 1.3; }
    .hero-text .highlight { color: #5B6FB5; font-weight: bold; }
    .hero-text p { font-size: 20px; color: #666; margin-bottom: 30px; }
    .quick-menu { background: #5B6FB5; padding: 40px; border-radius: 10px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; width: 350px; }
    .quick-item { background: rgba(255, 255, 255, 0.2); padding: 30px 20px; text-align: center; border-radius: 8px; color: white; cursor: pointer; transition: all 0.3s; }
    .quick-item:hover { background: rgba(255, 255, 255, 0.3); transform: translateY(-5px); }
    .quick-item svg { width: 50px; height: 50px; margin-bottom: 10px; }
    .notice-section { max-width: 1200px; margin: 80px auto; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 40px; }
    .notice-box { background: white; border: 1px solid #e0e0e0; border-radius: 10px; padding: 30px; }
    .notice-box h3 { font-size: 22px; margin-bottom: 20px; color: #333; border-bottom: 2px solid #5B6FB5; padding-bottom: 10px; }
    .notice-item { padding: 15px 0; border-bottom: 1px solid #f0f0f0; cursor: pointer; transition: background 0.3s; }
    .treatment-guide { background: #f8f9fa; padding: 80px 40px; text-align: center; }
    .treatment-guide h2 { font-size: 36px; margin-bottom: 20px; color: #333; }
    .guide-cards { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: repeat(4, 1fr); gap: 30px; }
    .guide-card { background: white; padding: 40px 20px; border-radius: 10px; box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1); transition: all 0.3s; cursor: pointer; }
    .about-section { max-width: 1200px; margin: 80px auto; padding: 0 40px; display: grid; grid-template-columns: 1fr 1fr; gap: 60px; align-items: center; }
    .about-image { width: 100%; height: 400px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 10px; display: flex; align-items: center; justify-content: center; color: white; font-size: 24px; }
    .btn-primary { display: inline-block; background: #5B6FB5; color: white; padding: 15px 40px; border-radius: 5px; text-decoration: none; font-weight: 500; transition: all 0.3s; }
    footer { background: #2c3e50; color: white; padding: 60px 40px 30px; }
    .footer-content { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 2fr 1fr; gap: 60px; margin-bottom: 30px; }
    .footer-bottom { text-align: center; padding-top: 30px; border-top: 1px solid #34495e; color: #95a5a6; }
    .chatbot-button { position: fixed; bottom: 30px; right: 30px; width: 70px; height: 70px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 50%; box-shadow: 0 4px 12px rgba(0, 0, 0, 0.3); cursor: pointer; display: flex; align-items: center; justify-content: center; transition: all 0.3s ease; z-index: 999; border: none; }
    .chatbot-button:hover { transform: scale(1.1); box-shadow: 0 6px 20px rgba(0, 0, 0, 0.4); }
    .chatbot-button svg { width: 35px; height: 35px; fill: white; }
    .chatbot-modal { display: none; position: fixed; bottom: 120px; right: 30px; width: 400px; height: 600px; background: white; border-radius: 20px; box-shadow: 0 8px 32px rgba(0, 0, 0, 0.2); z-index: 998; flex-direction: column; overflow: hidden; }
    .chatbot-modal.active { display: flex; }
    .chatbot-header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 20px; display: flex; justify-content: space-between; align-items: center; }
    .chatbot-close { background: none; border: none; color: white; font-size: 24px; cursor: pointer; }
    .chatbot-body { flex: 1; padding: 20px; overflow-y: auto; background: #f5f5f5; }
    .chat-message { margin-bottom: 15px; display: flex; gap: 10px; animation: slideIn 0.3s ease-out; }
    .chat-message.user { justify-content: flex-end; }
    .chat-message.bot { justify-content: flex-start; }
    .message-bubble { max-width: 70%; padding: 12px 16px; word-wrap: break-word; line-height: 1.5; font-size: 15px; position: relative; }
    .chat-message.user .message-bubble { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; border-radius: 18px 18px 4px 18px; box-shadow: 0 2px 4px rgba(102, 126, 234, 0.3); }
    .chat-message.bot .message-bubble { background: white; color: #333; border-radius: 18px 18px 18px 4px; box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1); }
    @keyframes slideIn { from { opacity: 0; transform: translateY(10px); } to { opacity: 1; transform: translateY(0); } }
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
        <div class="logo" data-lang-key="logoTitle">🏥 AI 의료 매칭 시스템</div>
        <ul class="nav-menu">
          <li><a href="#home" data-lang-key="navHome">홈</a></li>
          <li><a href="#services" data-lang-key="navServices">서비스 소개</a></li>
          <li><a href="#diagnosis" data-lang-key="navDiagnosis">자가진단</a></li>
          <li><a href="#hospitals" data-lang-key="navHospitals">병원찾기</a></li>
          <li><a href="#contact" data-lang-key="navContact">문의하기</a></li>
          <c:choose>
            <c:when test="${loginuser != null}">
              <li><a href="<c:url value='/info?userId=${loginuser.userId}'/>">${loginuser.userName}님</a></li>
              <li><a href="<c:url value='/logout'/>" data-lang-key="navLogout">로그아웃</a></li>
            </c:when>
            <c:otherwise>
              <li><a href="<c:url value='/login'/>" data-lang-key="navLogin">로그인</a></li>
            </c:otherwise>
          </c:choose>
          <li>
            <select id="language-select" onchange="languageManager.applyLanguage(this.value)">
                <option value="ko">🇰🇷 한국어</option>
                <option value="en">🇺🇸 English</option>
                <option value="ja">🇯🇵 日本語</option>
                <option value="zh">🇨🇳 简体中文</option>
            </select>
          </li>
        </ul>
      </nav>
    </header>

    <section class="hero" id="home">
      <div class="hero-content">
        <div class="hero-text">
          <h1 data-lang-key="heroTitle">
            <span class="highlight" data-lang-key="heroHighlight">행복한 삶을 위한 치료</span><br>
          </h1>
          <p data-lang-key="heroSubtitle">AI 기반 스마트 병원 매칭으로<br>의료 취약계층의 건강을 지킵니다</p>
        </div>
        <div class="quick-menu">
          <div class="quick-item" onclick="location.href='#services'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
            </svg>
            <div data-lang-key="quickRecommend">병원 추천</div>
          </div>
          <div class="quick-item" onclick="location.href='#diagnosis'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            <div data-lang-key="quickDiagnosis">자가 진단</div>
          </div>
          <div class="quick-item" onclick="location.href='#contact'">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
            </svg>
            <div data-lang-key="quickContact">문의 하기</div>
          </div>
          <div class="quick-item" onclick="alert(languageManager.getString('alertPrepare'))">
            <svg fill="white" viewBox="0 0 24 24">
              <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
            </svg>
            <div data-lang-key="quickEmergency">응급의료</div>
          </div>
        </div>
      </div>
    </section>

    <%@ include file="schedule.jsp" %>

    <section class="treatment-guide" id="services">
      <h2 data-lang-key="guideTitle">진료 안내</h2>
      <p class="subtitle" data-lang-key="guideSubtitle">AI 기반 스마트 매칭으로 최적의 매칭 및 헬스케어 서비스를 제공합니다</p>
      <div class="guide-cards">
        <div class="guide-card featured">
          <svg fill="#5B6FB5" viewBox="0 0 24 24">
            <path d="M12 2L4 5v6.09c0 5.05 3.41 9.76 8 10.91 4.59-1.15 8-5.86 8-10.91V5l-8-3zm-1 16h2v-2h-2v2zm0-4h2V7h-2v7z"/>
          </svg>
          <h4 data-lang-key="cardSeniorTitle">노약자, 시니어 맞춤 제공</h4>
          <p data-lang-key="cardSeniorDesc">노약자를 위한 음성 시스템과 외국인을 위한 언어 변경 시스템을 제공합니다</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
          </svg>
          <h4 data-lang-key="cardChartTitle">차트제공</h4>
          <p data-lang-key="cardChartDesc">원하는 질병 발병률을 차트화하여 시각적으로 도출합니다</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm4.59-12.42L10 14.17l-2.59-2.58L6 13l4 4 8-8z"/>
          </svg>
          <h4 data-lang-key="cardCalendarTitle">캘린더 제공</h4>
          <p data-lang-key="cardCalendarDesc">매칭된 병원의 진료 날짜를 시각화해주고 사용자가 직접 약 복용날짜 기입과 같은 일정 추가가 가능합니다</p>
        </div>
        <div class="guide-card">
          <svg fill="#666" viewBox="0 0 24 24">
            <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
          </svg>
          <h4 data-lang-key="cardChatbotTitle">챗봇서비스</h4>
          <p data-lang-key="cardChatbotDesc">AI챗봇을 통해 사이트에서 찾기 어려운 부분이나 궁금한 사항을 텍스트, 음성, 버튼으로 검색합니다</p>
        </div>
      </div>
    </section>

    <section class="about-section">
      <div class="about-image" data-lang-key="aboutImage1">
        여기엔 화면사진 붙여 넣읍시다
      </div>
      <div class="about-content">
        <h2 data-lang-key="aboutTitle1">🤖 SPRING AI 기술을 이용한 자가진단 진행</h2>
        <h3 data-lang-key="aboutSubtitle1">높은 적중률과 근거를 제시한 진단</h3>
        <p data-lang-key="aboutDesc1">
          SPRING AI 기술을 활용하여 의료 취약계층을 위한<br>
          최적의 병원을 매칭해드립니다.<br><br>
          자가진단을 통해 증상을 분석하고,<br>
          보건소의 검증을 거쳐 가장 적합한 공공기관 병원을<br>
          추천받으세요.
        </p>
        <a href="#diagnosis" class="btn-primary" data-lang-key="aboutBtn1">자가 진단하기</a>
      </div>
    </section>

    <section class="about-section">
      <div class="about-content">
        <h2 data-lang-key="aboutTitle2">🏥 MAP API를 이용한 병원 찾기 시스템</h2>
        <h3 data-lang-key="aboutSubtitle2">공공기관이 배정한 병원</h3>
        <p data-lang-key="aboutDesc2">
          의료 사각지대 해소를 위해<br>
          보건소에서 배정해주는 병원 네트워크를 구축했습니다.<br><br>
          IoT 기기 연동으로 실시간 건강 데이터를 수집하고,<br>
          부서와 맞는 정확한 병원 추천을 제공합니다.
        </p>
        <a href="#hospitals" class="btn-primary" data-lang-key="aboutBtn2">병원 찾아보기</a>
      </div>
      <div class="about-image" data-lang-key="aboutImage2">
        여기엔 화면사진 붙여 넣읍시다2
      </div>
    </section>

    <button class="chatbot-button" onclick="toggleChatbot()">
      <svg viewBox="0 0 24 24">
        <path d="M20 2H4c-1.1 0-2 .9-2 2v18l4-4h14c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-3 12H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1zm0-3H7c-.55 0-1-.45-1-1s.45-1 1-1h10c.55 0 1 .45 1 1s-.45 1-1 1z"/>
      </svg>
    </button>

    <div class="chatbot-modal" id="chatbotModal">
      <div class="chatbot-header">
        <h3 data-lang-key="chatHeader">🏥 AI 의료 상담</h3>
        <button class="chatbot-close" onclick="toggleChatbot()">×</button>
      </div>
      <div class="chatbot-body" id="chatBody">
        <div class="chat-message bot">
          <div class="message-bubble" data-lang-key="chatWelcome">
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
          <h3 data-lang-key="footerTitle">AI 기반 의료 매칭 시스템</h3>
          <p data-lang-key="footerAddress">주소: 서울특별시 강남구, 대한민국 우편번호 06234</p>
          <p data-lang-key="footerEmail">이메일: contact@medical-ai.kr</p>
          <p data-lang-key="footerCEO">대표자: 홍길동</p>
        </div>
        <div class="footer-contact">
          <h3 data-lang-key="footerContactTitle">전문 의료상담</h3>
          <div class="contact-number">1234-5678</div>
          <p data-lang-key="footerWeekday">평일: AM 9:00 - PM 6:00</p>
          <p data-lang-key="footerSaturday">토요일: AM 9:00 - PM 1:00</p>
          <p data-lang-key="footerSunday">일요일: PM 1:00 - PM 6:00</p>
        </div>
      </div>
      <div class="footer-bottom">
        <p data-lang-key="footerCopyright">Copyright © 2025 AI 의료 매칭 시스템. All Rights Reserved.</p>
      </div>
    </footer>

    <script>
      // --- 1. 다국어 텍스트 정의 ---
      const LANGUAGES = {
        'ko': {
          pageTitle: 'AI 기반 의료 매칭 시스템', logoTitle: '🏥 AI 의료 매칭 시스템', navHome: '홈', navServices: '서비스 소개', navDiagnosis: '자가진단', navHospitals: '병원찾기', navContact: '문의하기', navLogout: '로그아웃', navLogin: '로그인',
          heroTitle: '행복한 삶을 위한 치료', heroHighlight: '행복한 삶을 위한 치료', heroSubtitle: 'AI 기반 스마트 병원 매칭으로\n의료 취약계층의 건강을 지킵니다',
          quickRecommend: '병원 추천', quickDiagnosis: '자가 진단', quickContact: '문의 하기', quickEmergency: '응급의료', alertPrepare: '준비 중입니다.',
          guideTitle: '진료 안내', guideSubtitle: 'AI 기반 스마트 매칭으로 최적의 매칭 및 헬스케어 서비스를 제공합니다',
          cardSeniorTitle: '노약자, 시니어 맞춤 제공', cardSeniorDesc: '노약자를 위한 음성 시스템과 외국인을 위한 언어 변경 시스템을 제공합니다',
          cardChartTitle: '차트제공', cardChartDesc: '원하는 질병 발병률을 차트화하여 시각적으로 도출합니다',
          cardCalendarTitle: '캘린더 제공', cardCalendarDesc: '매칭된 병원의 진료 날짜를 시각화해주고 사용자가 직접 약 복용날짜 기입과 같은 일정 추가가 가능합니다',
          cardChatbotTitle: '챗봇서비스', cardChatbotDesc: 'AI챗봇을 통해 사이트에서 찾기 어려운 부분이나 궁금한 사항을 텍스트, 음성, 버튼으로 검색합니다',
          aboutTitle1: '🤖 SPRING AI 기술을 이용한 자가진단 진행', aboutSubtitle1: '높은 적중률과 근거를 제시한 진단', aboutDesc1: 'SPRING AI 기술을 활용하여 의료 취약계층을 위한\n최적의 병원을 매칭해드립니다.\n\n자가진단을 통해 증상을 분석하고,\n보건소의 검증을 거쳐 가장 적합한 공공기관 병원을\n추천받으세요.', aboutBtn1: '자가 진단하기', aboutImage1: '여기엔 화면사진 붙여 넣읍시다',
          aboutTitle2: '🏥 MAP API를 이용한 병원 찾기 시스템', aboutSubtitle2: '공공기관이 배정한 병원', aboutDesc2: '의료 사각지대 해소를 위해\n보건소에서 배정해주는 병원 네트워크를 구축했습니다.\n\nIoT 기기 연동으로 실시간 건강 데이터를 수집하고,\n부서와 맞는 정확한 병원 추천을 제공합니다.', aboutBtn2: '병원 찾아보기', aboutImage2: '여기엔 화면사진 붙여 넣읍시다2',
          chatHeader: '🏥 AI 의료 상담', chatWelcome: '안녕하세요! AI 의료 상담 챗봇입니다.<br>궁금하신 내용을 자유롭게 물어보세요.',
          footerTitle: 'AI 기반 의료 매칭 시스템', footerAddress: '주소: 서울특별시 강남구, 대한민국 우편번호 06234', footerEmail: '이메일: contact@medical-ai.kr', footerCEO: '대표자: 홍길동', footerContactTitle: '전문 의료상담', footerWeekday: '평일: AM 9:00 - PM 6:00', footerSaturday: '토요일: AM 9:00 - PM 1:00', footerSunday: '일요일: PM 1:00 - PM 6:00', footerCopyright: 'Copyright © 2025 AI 의료 매칭 시스템. All Rights Reserved.',
          chatPlaceholder: '메시지를 입력하세요...'
        },
        'en': {
          pageTitle: 'AI Healthcare Matching System', logoTitle: '🏥 AI Healthcare Matching System', navHome: 'Home', navServices: 'Services', navDiagnosis: 'Self-Diagnosis', navHospitals: 'Find Hospitals', navContact: 'Contact Us', navLogout: 'Logout', navLogin: 'Login',
          heroTitle: 'Treatment for a Happy Life', heroHighlight: 'Treatment for a Happy Life', heroSubtitle: 'AI-based smart hospital matching protects the health of the medically vulnerable.',
          quickRecommend: 'Recommend Hospitals', quickDiagnosis: 'Self-Diagnosis', quickContact: 'Contact Us', quickEmergency: 'Emergency Care', alertPrepare: 'Coming Soon.',
          guideTitle: 'Treatment Guide', guideSubtitle: 'Provides optimal matching and healthcare services through AI-based smart matching.',
          cardSeniorTitle: 'Elderly & Senior Customization', cardSeniorDesc: 'Provides voice systems for the elderly and language change systems for foreigners.',
          cardChartTitle: 'Chart Provision', cardChartDesc: 'Visually derives desired disease incidence rates in chart form.',
          cardCalendarTitle: 'Calendar Provision', cardCalendarDesc: 'Visualizes matched hospital appointment dates and allows users to add schedules like medication dates.',
          cardChatbotTitle: 'Chatbot Service', cardChatbotDesc: 'AI chatbot allows searching for hard-to-find information or questions via text, voice, or buttons.',
          aboutTitle1: '🤖 Self-Diagnosis using SPRING AI Technology', aboutSubtitle1: 'High Accuracy and Evidence-Based Diagnosis', aboutDesc1: 'Utilizing SPRING AI technology, we match the best hospitals for the medically vulnerable.\n\nAnalyze symptoms through self-diagnosis and receive recommendations for the most suitable public hospital, verified by the public health center.', aboutBtn1: 'Start Self-Diagnosis', aboutImage1: 'Paste screen image here',
          aboutTitle2: '🏥 Hospital Finder System using MAP API', aboutSubtitle2: 'Hospitals Assigned by Public Institutions', aboutDesc2: 'To resolve blind spots in healthcare,\nwe have built a network of hospitals assigned by public health centers.\n\nWe collect real-time health data through IoT devices and provide accurate hospital recommendations matching specific departments.', aboutBtn2: 'Find Hospitals', aboutImage2: 'Paste screen image here 2',
          chatHeader: '🏥 AI Medical Consultation', chatWelcome: 'Hello! I am the AI Medical Consultation Chatbot.<br>Feel free to ask any questions.',
          footerTitle: 'AI Healthcare Matching System', footerAddress: 'Address: Gangnam-gu, Seoul, Republic of Korea, Postal Code 06234', footerEmail: 'Email: contact@medical-ai.kr', footerCEO: 'CEO: Gildong Hong', footerContactTitle: 'Professional Medical Consultation', footerWeekday: 'Weekday: AM 9:00 - PM 6:00', footerSaturday: 'Saturday: AM 9:00 - PM 1:00', footerSunday: 'Sunday: PM 1:00 - PM 6:00', footerCopyright: 'Copyright © 2025 AI Healthcare Matching System. All Rights Reserved.',
          chatPlaceholder: 'Enter your message...'
        },
        'ja': {
          pageTitle: 'AI医療マッチングシステム', logoTitle: '🏥 AI医療マッチングシステム', navHome: 'ホーム', navServices: 'サービス紹介', navDiagnosis: '自己診断', navHospitals: '病院検索', navContact: 'お問い合わせ', navLogout: 'ログアウト', navLogin: 'ログイン',
          heroTitle: '幸せな生活のための治療', heroHighlight: '幸せな生活のための治療', heroSubtitle: 'AIベースのスマート病院マッチングは、医療弱者の健康を守ります。',
          quickRecommend: '病院推薦', quickDiagnosis: '自己診断', quickContact: 'お問い合わせ', quickEmergency: '緊急医療', alertPrepare: '準備中です。',
          guideTitle: '診療案内', guideSubtitle: 'AIベースのスマートマッチングにより、最適なマッチングとヘルスケアサービスを提供します。',
          cardSeniorTitle: '高齢者、シニア向け提供', cardSeniorDesc: '高齢者向けの音声システムと外国人向けの言語変更システムを提供します。',
          cardChartTitle: 'チャート提供', cardChartDesc: '希望する疾病発症率をチャート化し、視覚的に導出します。',
          cardCalendarTitle: 'カレンダー提供', cardCalendarDesc: 'マッチングされた病院の診療日を視覚化し、ユーザーが薬の服用日などのスケジュールを追加できます。',
          cardChatbotTitle: 'チャットボットサービス', cardChatbotDesc: 'AIチャットボットを通じて、サイトで見つけにくい情報や疑問をテキスト、音声、ボタンで検索します。',
          aboutTitle1: '🤖 SPRING AI技術を利用した自己診断の実施', aboutSubtitle1: '高い的中率と根拠を提示した診断', aboutDesc1: 'SPRING AI技術を活用し、医療弱者のための\n最適な病院をマッチングします。\n\n自己診断を通じて症状を分析し、\n保健所の検証を経て最も適切な公共機関病院を\n推薦します。', aboutBtn1: '自己診断を始める', aboutImage1: 'ここに画面写真を貼り付けます',
          aboutTitle2: '🏥 MAP APIを利用した病院検索システム', aboutSubtitle2: '公的機関が割り当てた病院', aboutDesc2: '医療の死角地帯解消のため、\n保健所が割り当てる病院ネットワークを構築しました。\n\nIoT機器連携でリアルタイムの健康データを収集し、\n部署に合った正確な病院推薦を提供します。', aboutBtn2: '病院を探す', aboutImage2: 'ここに画面写真を貼り付けます2',
          chatHeader: '🏥 AI医療相談', chatWelcome: 'こんにちは！AI医療相談チャットボットです。<br>気になる点を自由にお尋ねください。',
          footerTitle: 'AI医療マッチングシステム', footerAddress: '住所：大韓民国ソウル特別市江南区、郵便番号06234', footerEmail: 'メール：contact@medical-ai.kr', footerCEO: '代表者：洪吉童', footerContactTitle: '専門医療相談', footerWeekday: '平日：AM 9:00 - PM 6:00', footerSaturday: '土曜日：AM 9:00 - PM 1:00', footerSunday: '日曜日：PM 1:00 - PM 6:00', footerCopyright: 'Copyright © 2025 AI医療マッチングシステム. All Rights Reserved.',
          chatPlaceholder: 'メッセージを入力してください...'
        },
        'zh': {
          pageTitle: 'AI医疗匹配系统', logoTitle: '🏥 AI医疗匹配系统', navHome: '首页', navServices: '服务介绍', navDiagnosis: '自我诊断', navHospitals: '查找医院', navContact: '联系我们', navLogout: '退出登录', navLogin: '登录',
          heroTitle: '为幸福生活而治疗', heroHighlight: '为幸福生活而治疗', heroSubtitle: '基于AI的智能医院匹配，保障医疗弱势群体的健康。',
          quickRecommend: '医院推荐', quickDiagnosis: '自我诊断', quickContact: '联系我们', quickEmergency: '紧急医疗', alertPrepare: '准备中。',
          guideTitle: '就诊指南', guideSubtitle: '通过AI智能匹配，提供最佳匹配和医疗保健服务。',
          cardSeniorTitle: '老年人、长者定制服务', cardSeniorDesc: '为老年人提供语音系统，为外国人提供语言切换系统。',
          cardChartTitle: '图表提供', cardChartDesc: '将所需疾病的发病率图表化，进行可视化展示。',
          cardCalendarTitle: '日历提供', cardCalendarDesc: '可视化匹配医院的就诊日期，并允许用户添加服药日期等日程。',
          cardChatbotTitle: '聊天机器人服务', cardChatbotDesc: '通过AI聊天机器人，可以通过文本、语音、按钮搜索网站中难以查找的部分或疑问事项。',
          aboutTitle1: '🤖 使用SPRING AI技术进行自我诊断', aboutSubtitle1: '高准确率和提供依据的诊断', aboutDesc1: '利用SPRING AI技术，为医疗弱势群体匹配最合适的医院。\n\n通过自我诊断分析症状，并经过保健所验证，推荐最合适的公共机构医院。', aboutBtn1: '开始自我诊断', aboutImage1: '在此处粘贴屏幕截图',
          aboutTitle2: '🏥 使用MAP API的医院查找系统', aboutSubtitle2: '公共机构分配的医院', aboutDesc2: '为解决医疗死角问题，\n我们构建了由保健所分配的医院网络。\n\n通过物联网设备实时收集健康数据，并提供与科室匹配的准确医院推荐。', aboutBtn2: '查找医院', aboutImage2: '在此处粘贴屏幕截图2',
          chatHeader: '🏥 AI医疗咨询', chatWelcome: '您好！我是AI医疗咨询聊天机器人。<br>请自由提问您想知道的内容。',
          footerTitle: 'AI医疗匹配系统', footerAddress: '地址：大韩民国首尔市江南区，邮政编码06234', footerEmail: '邮箱：contact@medical-ai.kr', footerCEO: '代表：洪吉童', footerContactTitle: '专业医疗咨询', footerWeekday: '平日：AM 9:00 - PM 6:00', footerSaturday: '周六：AM 9:00 - PM 1:00', footerSunday: '周日：PM 1:00 - PM 6:00', footerCopyright: 'Copyright © 2025 AI医疗匹配系统. All Rights Reserved.',
          chatPlaceholder: '请输入消息...'
        }
      };

      // --- 2. 언어 관리 객체 ---
      const languageManager = {
        currentLang: 'ko',

        // 현재 선택된 언어로 UI 텍스트를 변경합니다.
        applyLanguage: function(lang) {
          if (!LANGUAGES[lang]) return;
          this.currentLang = lang;

          // 1. 모든 data-lang-key 속성을 가진 요소 찾기
          const elements = document.querySelectorAll('[data-lang-key]');
          elements.forEach(el => {
            const key = el.getAttribute('data-lang-key');
            const text = LANGUAGES[lang][key];

            if (text !== undefined) {
              // h1, p 태그 등에 <br>이 포함될 수 있으므로 innerHTML을 사용
              if (el.tagName === 'H1' || el.tagName === 'P' || el.tagName === 'DIV' || el.tagName === 'SPAN' || el.classList.contains('highlight')) { // highlight 클래스 추가
                el.innerHTML = text;
              } else {
                el.textContent = text;
              }
            }
          });

          // 2. 챗봇 입력 필드 placeholder 변경
          const chatInput = document.getElementById('chatInput');
          if (chatInput) {
             chatInput.placeholder = LANGUAGES[lang].chatPlaceholder;
          }

          // 3. HTML 언어 속성 변경
          document.documentElement.lang = lang;

          // 4. (선택 사항) 로컬 스토리지에 언어 저장 (페이지 새로고침 시 유지)
          localStorage.setItem('preferredLang', lang);

          // 5. schedule.jsp의 FullCalendar locale 변경
          if (typeof window.calendarManager !== 'undefined' && typeof window.calendarManager.applyLanguage === 'function') {
            window.calendarManager.applyLanguage(lang);
        }

          // 6. 챗봇 시작 메시지 업데이트 (선택된 언어로)
          this.updateChatbotWelcomeMessage(lang);
        },

        getString: function(key) {
          return LANGUAGES[this.currentLang][key] || key;
        },

        updateChatbotWelcomeMessage: function(lang) {
          const chatBody = document.getElementById('chatBody');
          const welcomeBubble = chatBody.querySelector('.chat-message.bot .message-bubble');

          // 챗봇 환영 메시지가 첫 번째 메시지라고 가정하고 업데이트
          if (welcomeBubble && welcomeBubble.getAttribute('data-lang-key') === 'chatWelcome') {
             welcomeBubble.innerHTML = LANGUAGES[lang].chatWelcome;
          }
        },

        // 페이지 로드 시 마지막으로 저장된 언어를 로드합니다.
        loadLanguage: function() {
          const savedLang = localStorage.getItem('preferredLang') || 'ko';
          const langSelect = document.getElementById('language-select');
          if (langSelect) {
            langSelect.value = savedLang;
          }
          this.applyLanguage(savedLang);
        }
      };

      // --- 3. 챗봇 및 기타 기능 (기존 코드 유지) ---
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
          // Spring AI API 호출 (실제 백엔드 API 경로 사용)
          const response = await fetch('/api/chat', {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
            },
            body: JSON.stringify({
                question: message,
                language: languageManager.currentLang // AI에게 현재 언어 전달
            })
          });

          const data = await response.json();

          // 타이핑 인디케이터 숨김
          typingIndicator.classList.remove('active');

          // AI 응답 표시
          addMessage(data.answer || languageManager.getString('chatError') || 'Error response.', 'bot');

        } catch (error) {
          console.error('Error:', error);
          typingIndicator.classList.remove('active');
          addMessage(languageManager.getString('chatError') || 'Sorry, an error occurred. Please try again.', 'bot');
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
        bubbleDiv.innerHTML = text.replace(/\n/g, '<br>'); // 줄바꿈 처리

        messageDiv.appendChild(bubbleDiv);

        const typingIndicator = document.getElementById('typingIndicator');
        chatBody.insertBefore(messageDiv, typingIndicator);

        chatBody.scrollTop = chatBody.scrollHeight;
      }

      // --- 4. 초기화 ---
      document.addEventListener('DOMContentLoaded', function() {
        // 페이지 로드 시 언어 설정 적용
        languageManager.loadLanguage();
      });

      // 부드러운 스크롤 (기존 코드 유지)
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