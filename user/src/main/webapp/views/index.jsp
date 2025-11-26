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
    /* 기본 CSS */
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Noto Sans KR', sans-serif; color: #333; line-height: 1.6; }

    /* 헤더 고정 및 스타일 */
    header {
        background: white;
        box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
        position: fixed;
        width: 100%;
        top: 0;
        z-index: 1000;
    }

    /* === 헤더 레이아웃 최적화 === */
    nav {
        max-width: 1200px;
        margin: 0 auto;
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 15px 15px;
    }
    .logo {
        font-size: 20px;
        font-weight: bold;
        color: #5B6FB5;
        white-space: nowrap;
        margin-right: 20px;
    }
    .nav-menu {
        display: flex;
        gap: 15px;
        list-style: none;
        align-items: center;
        flex-wrap: nowrap;
        margin-left: auto;
    }
    .nav-menu li { white-space: nowrap; }
    .nav-menu a {
        text-decoration: none;
        color: #333;
        font-weight: 500;
        transition: color 0.3s;
        font-size: 14px;
    }
    .nav-menu a:hover { color: #5B6FB5; }

    /* 언어 선택 드롭다운 */
    #language-select {
        padding: 5px 8px;
        border: 1px solid #ccc;
        border-radius: 4px;
        font-size: 13px;
        cursor: pointer;
    }

    /* 메인 컨텐츠 래퍼 (헤더 높이만큼 여백 확보) */
    .main-content-wrapper {
        margin-top: 80px; /* 헤더 높이 */
        min-height: 800px;
    }

    /* 메인 히어로 섹션 */
    .hero {
        /* margin-top은 wrapper에서 처리하므로 제거하거나 조정 */
        height: 600px;
        background: linear-gradient(rgba(91, 111, 181, 0.1), rgba(91, 111, 181, 0.2)), url('data:image/svg+xml,<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 1200 600"><rect fill="%23f0f4f8" width="1200" height="600"/></svg>');
        background-size: cover;
        background-position: center;
        display: flex;
        align-items: center;
        position: relative;
    }
    .hero-content { max-width: 1200px; margin: 0 auto; padding: 0 40px; width: 100%; display: flex; justify-content: space-between; align-items: center; }
    .hero-text { flex: 1; }
    .hero-text h1 { font-size: 48px; color: #333; margin-bottom: 20px; line-height: 1.3; }
    .hero-text .highlight { color: #5B6FB5; font-weight: bold; }
    .hero-text p { font-size: 20px; color: #666; margin-bottom: 30px; }

    .quick-menu { background: #5B6FB5; padding: 40px; border-radius: 10px; display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; width: 400px; }
    .quick-item { background: rgba(255, 255, 255, 0.2); padding: 30px 20px; text-align: center; border-radius: 8px; color: white; cursor: pointer; transition: all 0.3s; }
    .quick-item:hover { background: rgba(255, 255, 255, 0.3); transform: translateY(-5px); }
    .quick-item svg { width: 50px; height: 50px; margin-bottom: 10px; }

    /* 공지사항, 진료 안내 등 기타 섹션 */
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

    /* Footer */
    footer { background: #2c3e50; color: white; padding: 60px 40px 30px; }
    .footer-content { max-width: 1200px; margin: 0 auto; display: grid; grid-template-columns: 2fr 1fr; gap: 60px; margin-bottom: 30px; }
    .footer-bottom { text-align: center; padding-top: 30px; border-top: 1px solid #34495e; color: #95a5a6; }

    /* 반응형 */
    @media (max-width: 768px) {
      .hero-content { flex-direction: column; text-align: center; }
      .quick-menu { width: 100%; margin-top: 30px; }
      .notice-section, .guide-cards, .about-section, .footer-content { grid-template-columns: 1fr; }
      .hero-text h1 { font-size: 32px; }
      nav { flex-direction: column; gap: 10px; }
      .nav-menu { width: 100%; justify-content: center; flex-wrap: wrap; }
    }
  </style>
</head>
<body>

<header>
  <nav>
    <div class="logo">🏥 AI 의료 매칭 시스템</div>
    <ul class="nav-menu">
      <li><a href="<c:url value='/'/>">홈</a></li>
      <li><a href="<c:url value="/dia/dia1"/>">자가진단</a></li>
      <li><a href="<c:url value="/map/map1"/>">병원찾기</a></li>
      <li><a href="<c:url value='/statview'/>">통계 확인</a></li>
      <li><a href="<c:url value='/consul'/>">상담하기</a></li>
      <c:choose>
        <c:when test="${loginuser != null}">
          <li><a href="<c:url value='/info?userId=${loginuser.patientId}'/>">${loginuser.patientName}님</a></li>
          <li><a href="<c:url value='/logout'/>">로그아웃</a></li>
        </c:when>
        <c:otherwise>
          <li><a href="<c:url value='/login'/>">로그인</a></li>
        </c:otherwise>
      </c:choose>

      <li>
        <select id="language-select">
            <option value="ko">🇰🇷 한국어</option>
            <option value="en">🇺🇸 English</option>
            <option value="ja">🇯🇵 Japanese</option>
            <option value="zh">🇨🇳 Chinese</option>
        </select>
      </li>
    </ul>
  </nav>
</header>

<div class="main-content-wrapper">
    <c:choose>
      <%-- 1. center 변수가 있으면 해당 페이지를 여기에 끼워넣음 (statview 등) --%>
      <c:when test="${center != null}">
        <jsp:include page="${center}.jsp"/>
      </c:when>

      <%-- 2. center 변수가 없으면 메인 홈페이지 내용을 표시 --%>
      <c:otherwise>
        <section class="hero" id="home">
          <div class="hero-content">
            <div class="hero-text">
              <h1>
                <span class="highlight">행복한 삶을 위한 치료</span><br>
              </h1>
              <p>AI 기반 스마트 병원 매칭으로<br>의료 취약계층의 건강을 지킵니다</p>
            </div>
            <div class="quick-menu">
              <c:choose>
                <c:when test="${loginuser != null}">
                  <div class="quick-item" onclick="location.href='logout'">
                    <svg fill="white" viewBox="0 0 24 24">
                      <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
                    </svg>
                    <div>로그아웃</div>
                    </div>
                </c:when>
                <c:otherwise>
                  <div class="quick-item" onclick="location.href='login'">
                    <svg fill="white" viewBox="0 0 24 24">
                      <path d="M19 3H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-5 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
                    </svg>
                    <div>로그인</div>
                  </div>
                </c:otherwise>
              </c:choose>
              <div class="quick-item" onclick="location.href='consul'">
                <svg fill="white" viewBox="0 0 24 24">
                  <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
                </svg>
                <div>상담 하기</div>
              </div>
              <div class="quick-item" onclick="document.getElementById('services').scrollIntoView({ behavior: 'smooth' })">
                <svg fill="white" viewBox="0 0 24 24">
                  <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"/>
                </svg>
                <div>서비스 소개</div>
              </div>
              <div class="quick-item" onclick="document.getElementById('contact').scrollIntoView({ behavior: 'smooth' })">
                <svg fill="white" viewBox="0 0 24 24">
                  <path d="M11.99 2C6.47 2 2 6.48 2 12s4.47 10 9.99 10C17.52 22 22 17.52 22 12S17.52 2 11.99 2zM12 20c-4.42 0-8-3.58-8-8s3.58-8 8-8 8 3.58 8 8-3.58 8-8 8zm.5-13H11v6l5.25 3.15.75-1.23-4.5-2.67z"/>
                </svg>
                <div>문의 하기</div>
              </div>
            </div>
          </div>
        </section>
        <div id="calendar-section">
          <%@ include file="schedule.jsp" %>
        </div>
        <section class="treatment-guide" id="services">
          <h2>진료 안내</h2>
          <p class="subtitle">AI 기반 스마트 매칭으로 최적의 매칭 및 헬스케어 서비스를 제공합니다</p>
          <div class="guide-cards">
          <div class="guide-card featured" onclick="const el = document.getElementById('language-select'); el.focus();">
          <svg fill="#5B6FB5" viewBox="0 0 24 24">
                <path d="M12 2L4 5v6.09c0 5.05 3.41 9.76 8 10.91 4.59-1.15 8-5.86 8-10.91V5l-8-3zm-1 16h2v-2h-2v2zm0-4h2V7h-2v7z"/>
              </svg>
              <h4>노약자, 시니어 맞춤 제공</h4>
              <p>노약자를 위한 음성 시스템과 외국인을 위한 언어 변경 시스템을 제공합니다</p>
            </div>
            <div class="guide-card" onclick="location.href='statview'">
              <svg fill="#666" viewBox="0 0 24 24">
                <path d="M19 3h-4.18C14.4 1.84 13.3 1 12 1c-1.3 0-2.4.84-2.82 2H5c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm-7 0c.55 0 1 .45 1 1s-.45 1-1 1-1-.45-1-1 .45-1 1-1zm2 14H7v-2h7v2zm3-4H7v-2h10v2zm0-4H7V7h10v2z"/>
              </svg>
              <h4>차트제공</h4>
              <p>원하는 질병 발병률을 차트화하여 시각적으로 도출합니다</p>
            </div>
            <div class="guide-card" onclick="document.getElementById('calendar-section').scrollIntoView({ behavior: 'smooth' })">
            <svg fill="#666" viewBox="0 0 24 24">
                <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm4.59-12.42L10 14.17l-2.59-2.58L6 13l4 4 8-8z"/>
                </svg>
              <h4>캘린더 제공</h4>
              <p>매칭된 병원의 진료 날짜를 시각화해주고 사용자가 직접 약 복용날짜 기입과 같은 일정 추가가 가능합니다</p>
            </div>
            <div class="guide-card" onclick="toggleChatbot()">
              <svg fill="#666" viewBox="0 0 24 24">
                <path d="M12 12c2.21 0 4-1.79 4-4s-1.79-4-4-4-4 1.79-4 4 1.79 4 4 4zm0 2c-2.67 0-8 1.34-8 4v2h16v-2c0-2.66-5.33-4-8-4z"/>
              </svg>
              <h4>챗봇서비스</h4>
              <p>AI챗봇을 통해 사이트에서 찾기 어려운 부분이나 궁금한 사항을 텍스트, 음성, 버튼으로 검색합니다</p>
            </div>
          </div>
        </section>

        <section class="about-section">
          <div class="about-image">
            여기엔 화면사진 붙여 넣읍시다
          </div>
          <div class="about-content">
            <h2>🤖 SPRING AI 기술을 이용한 자가진단 진행</h2>
            <h3>높은 적중률과 근거를 제시한 진단</h3>
            <p>
              SPRING AI 기술을 활용하여 의료 취약계층을 위한<br>
              최적의 병원을 매칭해드립니다.<br><br>
              자가진단을 통해 증상을 분석하고,<br>
              보건소의 검증을 거쳐 가장 적합한 공공기관 병원을<br>
              추천받으세요.
            </p>
            <a href="<c:url value='/dia/dia1'/>" class="btn-primary">자가 진단하기</a>
            </div>
        </section>

        <section class="about-section">
          <div class="about-content">
            <h2>🏥 MAP API를 이용한 병원 찾기 시스템</h2>
            <h3>공공기관이 배정한 병원</h3>
            <p>
              의료 사각지대 해소를 위해<br>
              보건소에서 배정해주는 병원 네트워크를 구축했습니다.<br><br>
              IoT 기기 연동으로 실시간 건강 데이터를 수집하고,<br>
              부서와 맞는 정확한 병원 추천을 제공합니다.
            </p>
            <a href="<c:url value='/map/map1'/>" class="btn-primary">병원 찾아보기</a>
          </div>
          <div class="about-image">
            여기엔 화면사진 붙여 넣읍시다2
          </div>
        </section>
      </c:otherwise>
    </c:choose>
</div>

<jsp:include page="chatbot.jsp" />

<footer id="contact">
  <div class="footer-content">
    <div class="footer-info">
      <h3>AI 기반 의료 매칭 시스템</h3>
      <p>주소: 주소: 충청남도 아산시 탕정면 선문로221번길 70, 대한민국 우편번호 31460</p>
      <p>이메일: project@final.com</p>
      <p>대표자: 몰입형</p>
    </div>
    <div class="footer-contact">
      <h3>문의사항</h3>
      <div class="contact-number">010-1234-5678</div>
      <p>평일: AM 9:00 - PM 9:00</p>
      <p>토요일: 휴식</p>
      <p>일요일: 휴식</p>
    </div>
  </div>
  <div class="footer-bottom">
    <p>© 2025 FINAL-PROJECT AI 의료 매칭 시스템</p>
  </div>
</footer>
<%--<script>--%>
<%--  const translationManager = {--%>
<%--    currentLang: 'ko',--%>
<%--    cache: {}, // { 'en': Promise object, ... }--%>

<%--    // 텍스트 추출 (기존과 동일)--%>
<%--    extractTextNodes: function() {--%>
<%--      const textNodes = [];--%>
<%--      const nodeRefs = [];--%>
<%--      const walker = document.createTreeWalker(--%>
<%--              document.body, NodeFilter.SHOW_TEXT,--%>
<%--              { acceptNode: node => {--%>
<%--                  const t = node.nodeValue.trim();--%>
<%--                  if(!t || ['SCRIPT', 'STYLE', 'NOSCRIPT'].includes(node.parentElement.tagName)) return NodeFilter.FILTER_REJECT;--%>
<%--                  return NodeFilter.FILTER_ACCEPT;--%>
<%--                }}, false--%>
<%--      );--%>
<%--      while(node = walker.nextNode()) {--%>
<%--        textNodes.push(node.nodeValue.trim());--%>
<%--        nodeRefs.push({ type: 'text', node: node });--%>
<%--      }--%>
<%--      document.querySelectorAll('[placeholder], input[type="button"], input[type="submit"]').forEach(el => {--%>
<%--        if (el.placeholder && el.placeholder.trim()) {--%>
<%--          textNodes.push(el.placeholder);--%>
<%--          nodeRefs.push({ type: 'attr', node: el, attr: 'placeholder' });--%>
<%--        }--%>
<%--        if (el.value && (el.type === 'button' || el.type === 'submit')) {--%>
<%--          textNodes.push(el.value);--%>
<%--          nodeRefs.push({ type: 'attr', node: el, attr: 'value' });--%>
<%--        }--%>
<%--      });--%>
<%--      return { textNodes, nodeRefs };--%>
<%--    },--%>

<%--    // 공통 요청 함수 (캐싱 로직 통합)--%>
<%--    fetchTranslation: function(targetLangCode) {--%>
<%--      // 이미 요청 중이거나 완료된 캐시가 있으면 그것을 반환 (중복 요청 방지)--%>
<%--      if (this.cache[targetLangCode]) {--%>
<%--        return this.cache[targetLangCode];--%>
<%--      }--%>

<%--      const { textNodes } = this.extractTextNodes();--%>
<%--      if (textNodes.length === 0) return Promise.resolve([]);--%>

<%--      // [수정됨] 요청 자체(Promise)를 캐시에 넣어버림 -> 이후 같은 요청은 이 Promise 결과를 씀--%>
<%--      const requestPromise = fetch('/api/translate', {--%>
<%--        method: 'POST',--%>
<%--        headers: { 'Content-Type': 'application/json' },--%>
<%--        body: JSON.stringify({--%>
<%--          targetLang: this.getLangName(targetLangCode),--%>
<%--          texts: textNodes--%>
<%--        })--%>
<%--      })--%>
<%--              .then(res => res.json())--%>
<%--              .then(data => data.translatedTexts)--%>
<%--              .catch(err => {--%>
<%--                console.error(err);--%>
<%--                delete this.cache[targetLangCode]; // 에러나면 캐시 삭제해서 다시 시도하게 함--%>
<%--                return null;--%>
<%--              });--%>

<%--      this.cache[targetLangCode] = requestPromise; // 캐시 저장--%>
<%--      return requestPromise;--%>
<%--    },--%>

<%--    getLangName: function(code) {--%>
<%--      const map = { 'en': 'English', 'ja': 'Japanese', 'zh': 'Chinese', 'ko': 'Korean' };--%>
<%--      return map[code] || code;--%>
<%--    },--%>

<%--    // 접속 시 자동 실행 (백그라운드)--%>
<%--    preloadTranslations: function() {--%>
<%--      console.log("🚀 백그라운드 번역 시작...");--%>
<%--      ['en', 'ja', 'zh'].forEach(lang => this.fetchTranslation(lang));--%>
<%--    },--%>

<%--    // 언어 변경 클릭 시--%>
<%--    translatePage: async function(targetLangCode) {--%>
<%--      if (targetLangCode === 'ko') {--%>
<%--        location.reload();--%>
<%--        return;--%>
<%--      }--%>

<%--      this.currentLang = targetLangCode;--%>
<%--      document.body.style.cursor = 'wait';--%>
<%--      document.body.style.opacity = '0.6';--%>

<%--      try {--%>
<%--        // fetchTranslation이 캐시가 있으면 캐시를, 없으면 새 요청을 리턴함--%>
<%--        const translatedTexts = await this.fetchTranslation(targetLangCode);--%>

<%--        if (translatedTexts) {--%>
<%--          const { nodeRefs } = this.extractTextNodes();--%>
<%--          if (translatedTexts.length === nodeRefs.length) {--%>
<%--            nodeRefs.forEach((ref, index) => {--%>
<%--              if (ref.type === 'text') ref.node.nodeValue = translatedTexts[index];--%>
<%--              else ref.node[ref.attr] = translatedTexts[index];--%>
<%--            });--%>

<%--            // 캘린더 언어 설정--%>
<%--            if (window.calendarManager && window.calendarManager.calendar) {--%>
<%--              let calLang = 'en';--%>
<%--              if (targetLangCode === 'ja') calLang = 'ja';--%>
<%--              if (targetLangCode === 'zh') calLang = 'zh-cn';--%>
<%--              window.calendarManager.calendar.setOption('locale', calLang);--%>
<%--            }--%>
<%--          }--%>
<%--        }--%>
<%--      } catch (e) {--%>
<%--        console.error(e);--%>
<%--        alert("번역 적용 실패");--%>
<%--      } finally {--%>
<%--        document.body.style.cursor = 'default';--%>
<%--        document.body.style.opacity = '1';--%>
<%--      }--%>
<%--    }--%>
<%--  };--%>

<%--  document.addEventListener('DOMContentLoaded', function() {--%>
<%--    if (typeof window.calendarManager !== 'undefined') window.calendarManager.init();--%>

<%--    // 1초 뒤 백그라운드 번역 시작--%>
<%--    setTimeout(() => translationManager.preloadTranslations(), 1000);--%>

<%--    const langSelect = document.getElementById('language-select');--%>
<%--    if (langSelect) {--%>
<%--      langSelect.addEventListener('change', function() {--%>
<%--        translationManager.translatePage(this.value);--%>
<%--      });--%>
<%--    }--%>
<%--  });--%>
<%--</script>--%>
</body>
</html>