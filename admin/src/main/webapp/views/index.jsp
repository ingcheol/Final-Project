<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="edu.sm.app.dto.Admin" %>
<%@ page import="edu.sm.app.dto.Adviser" %>
<%
    // 세션에서 로그인 정보 가져오기
    Admin loggedInAdmin = (Admin) session.getAttribute("admin");
    Adviser loggedInAdviser = (Adviser) session.getAttribute("adviser");
    String userRole = (String) session.getAttribute("role"); // ADMIN 또는 ADVISER

    // 로그인 상태 확인
    boolean isLoggedIn = (loggedInAdmin != null || loggedInAdviser != null);
    String userName = "";

    if (loggedInAdmin != null) {
        userName = loggedInAdmin.getName() + " (관리자)";
    } else if (loggedInAdviser != null) {
        userName = loggedInAdviser.getName() + " (상담사)";
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OSEN Admin</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            font-size: 1.175em;
            background-color: #f5f6fa;
            color: #333;
        }

        .container {
            display: flex;
            min-height: 100vh;
        }

        /* Sidebar Styles */
        .sidebar {
            width: 260px;
            background: linear-gradient(180deg, #1e293b 0%, #0f172a 100%);
            color: #fff;
            padding: 20px 0;
            position: fixed;
            height: 100vh;
            overflow-y: auto;
        }

        .logo {
            padding: 0 20px 30px;
            font-size: 24px;
            font-weight: bold;
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .logo::before {
            content: "●";
            color: #6366f1;
            font-size: 30px;
        }

        .nav-section {
            margin-bottom: 30px;
        }

        .nav-title {
            padding: 10px 20px;
            font-size: 14px; /* 기존 11px에서 14px로 증가 */
            text-transform: uppercase;
            color: #94a3b8;
            letter-spacing: 1px;
        }

        .nav-item {
            padding: 12px 20px;
            display: flex;
            align-items: center;
            gap: 12px;
            color: #cbd5e1;
            cursor: pointer;
            transition: all 0.3s;
            position: relative;
            text-decoration: none;
        }

        .nav-item:hover {
            background: rgba(99, 102, 241, 0.1);
            color: #fff;
        }

        .nav-item.active {
            background: rgba(99, 102, 241, 0.2);
            color: #fff;
            border-left: 3px solid #6366f1;
        }

        .nav-item.active::before {
            content: "●";
            position: absolute;
            right: 20px;
            color: #22c55e;
            font-size: 12px;
        }

        .nav-item .icon {
            width: 20px;
            height: 20px;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        /* Main Content Styles */
        .main-content {
            margin-left: 260px;
            flex: 1;
            padding: 20px 30px;
        }

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
            background: #fff;
            padding: 15px 25px;
            border-radius: 12px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.05);
        }

        .search-bar {
            display: flex;
            align-items: center;
            background: #f1f5f9;
            padding: 10px 15px;
            border-radius: 8px;
            width: 300px;
        }

        .search-bar input {
            border: none;
            background: none;
            outline: none;
            margin-left: 10px;
            width: 100%;
        }

        .header-actions {
            display: flex;
            gap: 15px;
            align-items: center;
        }

        .icon-btn {
            width: 40px;
            height: 40px;
            border-radius: 8px;
            border: none;
            background: #f1f5f9;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            transition: all 0.3s;
        }

        .icon-btn:hover {
            background: #e2e8f0;
        }

        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: #fff;
            border: none;
            padding: 10px 20px;
            border-radius: 8px;
            cursor: pointer;
            font-weight: 500;
            transition: all 0.3s;
        }

        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 20px rgba(102, 126, 234, 0.3);
        }

        /* --- 로그인 모달 스타일 추가 --- */
        .modal {
            display: none; /* 기본 숨김 */
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0,0,0,0.4); /* 배경 흐림 */
        }

        .modal-content {
            background-color: #fefefe;
            margin: 15% auto; /* 상단에서 15% 위치, 가운데 정렬 */
            padding: 30px;
            border-radius: 12px;
            box-shadow: 0 5px 15px rgba(0,0,0,0.3);
            width: 350px; /* 모달 너비 */
            text-align: center;
        }

        .modal-content h2 {
            margin-bottom: 20px;
            color: #1e293b;
        }

        .modal-content input[type="text"],
        .modal-content input[type="password"] {
            width: 100%;
            padding: 12px;
            margin: 8px 0 15px 0;
            display: inline-block;
            border: 1px solid #ccc;
            border-radius: 8px;
            box-sizing: border-box;
        }

        .modal-content .btn-primary {
            width: 100%;
            padding: 12px;
            margin-top: 10px;
        }

        .close {
            color: #aaa;
            float: right;
            font-size: 28px;
            font-weight: bold;
        }

        .close:hover,
        .close:focus {
            color: #000;
            text-decoration: none;
            cursor: pointer;
        }

        /* Welcome Screen */
        .welcome-screen {
            text-align: center;
            padding: 100px;
            color: #64748b;
        }

        .welcome-screen h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }

        .welcome-screen p {
            font-size: 18px;
        }

        /* Responsive */
        @media (max-width: 1200px) {
            .cards-grid {
                grid-template-columns: 1fr;
            }
        }

        @media (max-width: 768px) {
            .sidebar {
                transform: translateX(-100%);
            }

            .main-content {
                margin-left: 0;
            }
        }

        /* --- 알림 모달 스타일 (기존 모달 스타일 활용 및 확장) --- */
        #alertModal .modal-content {
            border-top: 5px solid #6366f1; /* 기본 색상 */
        }
        #alertModal.warning .modal-content {
            border-top-color: #ffc107; /* 경고: 노랑 */
        }
        #alertModal.emergency .modal-content {
            border-top-color: #e74c3c; /* 위험: 빨강 */
        }
        .alert-time {
            font-size: 12px;
            color: #666;
            margin-bottom: 10px;
        }
        .alert-message {
            font-size: 16px;
            font-weight: bold;
            margin: 20px 0;
            white-space: pre-line;
        }

    </style>
</head>
<body>
<div class="container">
    <aside class="sidebar">
        <div class="logo">선문 보건소</div>

        <div class="nav-section">
            <div class="nav-title">DASH</div>
            <a href="<c:url value='/'/>" class="nav-item">
                <span class="icon">📊</span>
                <span>Sales</span>
            </a>
            <a href="<c:url value='/manage'/>" class="nav-item">
                <span class="icon">🏥</span>
                <span>환자 관리</span>
            </a>
            <a href="<c:url value='/anage'/>" class="nav-item">
                <span class="icon">👨‍⚕️</span>
                <span>상담사 관리</span>
            </a>
            <a href="<c:url value='/consultation'/>" class="nav-item">
                <span class="icon">📱</span>
                <span>상담 페이지</span>
            </a>
            <a href="<c:url value='/admin/appointments'/>" class="nav-item">
                <span class="icon">📱</span>
                <span>예약 관리</span>
            </a>
          <a href="<c:url value='/admin/signlanguage'/>" class="nav-item">
            <span class="icon">👌</span>
            <span>수어 번역</span>
          </a>
        </div>

        <div class="nav-section">
            <div class="nav-title">APPS & PAGES</div>
            <div class="nav-item">
                <span class="icon">💬</span>
                <span>Chat</span>
            </div>
            <div class="nav-item">
                <span class="icon">📅</span>
                <span>Calendar</span>
            </div>
            <div class="nav-item">
                <span class="icon">✉️</span>
                <span>Email</span>
            </div>
            <div class="nav-item">
                <span class="icon">📁</span>
                <span>File Manager</span>
            </div>
        </div>

        <div class="nav-section">
            <div class="nav-title">COMPONENTS</div>
            <div class="nav-item">
                <span class="icon">🧩</span>
                <span>Base UI</span>
            </div>
            <div class="nav-item">
                <span class="icon">📋</span>
                <span>Forms</span>
            </div>
            <div class="nav-item">
                <span class="icon">📊</span>
                <span>Charts</span>
            </div>
        </div>
    </aside>

    <main class="main-content">
        <header class="header">
            <div class="search-bar">
                <span>🔍</span>
                <input type="text" placeholder="Search something...">
            </div>
            <div class="header-actions">
                <button class="icon-btn">🌙</button>
                <button class="icon-btn">🔔</button>
                <button class="icon-btn">⚙️</button>

                <% if (isLoggedIn) { %>
                <button class="btn-primary" onclick="location.href='logoutimpl'">
                    <%= userName %> | 로그아웃
                </button>
                <% } else { %>
                <button class="icon-btn" id="loginBtn">👤</button>
                <% } %>
            </div>
        </header>

        <%-- 로그인 실패 메시지 출력 (LoginController에서 넘어옴) --%>
        <% if (request.getAttribute("loginfail") != null) { %>
        <script>
            alert("<%= request.getAttribute("msg") %>");
        </script>
        <% } %>

        <%-- 동적 콘텐츠 영역 --%>
        <c:choose>
            <%-- 1. 환자 관리 페이지 --%>
            <c:when test="${center == 'manage'}">
                <jsp:include page="patient/manage.jsp" />
            </c:when>

            <%-- 2. 환자 상세 페이지 --%>
            <c:when test="${center == 'manage_detail'}">
                <jsp:include page="patient/detail.jsp" />
            </c:when>

            <%-- 3. 환자 수정 페이지 --%>
            <c:when test="${center == 'manage_edit'}">
                <jsp:include page="patient/edit.jsp" />
            </c:when>

            <%-- 4. 상담사 관리 페이지 --%>
            <c:when test="${center == 'anage'}">
                <jsp:include page="adviser/anage.jsp" />
            </c:when>

            <%-- 5. 상담사 상세 페이지 --%>
            <c:when test="${center == 'anage_detail'}">
                <jsp:include page="adviser/detail.jsp" />
            </c:when>

            <%-- 6. 상담사 수정 페이지 --%>
            <c:when test="${center == 'anage_edit'}">
                <jsp:include page="adviser/edit.jsp" />
            </c:when>

            <%-- 7. 화상 상담 페이지 --%>
            <c:when test="${center == 'consultation'}">
                <jsp:include page="consultation.jsp" />
            </c:when>

<%--          수어 번역--%>
          <c:when test="${center == 'signlanguage'}">
            <jsp:include page="signlanguage.jsp" />
          </c:when>

            <%-- 예약 관리 목록 페이지 --%>
            <c:when test="${center == 'appointments/list'}">
                <jsp:include page="appointments/list.jsp" />
            </c:when>

            <%-- 예약 관리 상세 페이지 --%>
            <c:when test="${center == 'appointments/detail'}">
                <jsp:include page="appointments/detail.jsp" />
            </c:when>

            <%-- 예약 관리 수정 페이지 --%>
            <c:when test="${center == 'appointments/edit'}">
                <jsp:include page="appointments/edit.jsp" />
            </c:when>

            <%-- 8. 에러 페이지 --%>
            <c:when test="${center == 'error'}">
                <div class="welcome-screen">
                    <h1 style="color: #ef4444;">오류 발생</h1>
                    <p>${error}</p>
                </div>
            </c:when>

          <%-- 9. 그 외의 경우 (초기 접속 등) --%>
            <c:otherwise>
                <div class="welcome-screen">
                    <h1>선문 보건소</h1>
                    <p>좌측 메뉴를 선택하여 작업을 시작하세요.</p>
                </div>
            </c:otherwise>
        </c:choose>
    </main>
</div>

<div id="loginModal" class="modal">
    <div class="modal-content">
        <span class="close" id="closeModalBtn">&times;</span>
        <h2>로그인</h2>
        <form action="loginimpl" method="post">
            <input type="text" id="id" name="id" placeholder="아이디 (관리자/상담사)" required>
            <input type="password" id="pwd" name="pwd" placeholder="비밀번호" required>
            <button type="submit" class="btn-primary">로그인</button>
        </form>
    </div>
</div>

<!-- 비정상 알림 모달 -->
<div id="alertModal" class="modal">
  <div class="modal-content">
    <span class="close" id="closeAlertBtn">&times;</span>
    <h2 id="alertTitle">알림</h2>
    <div id="alertTime" class="alert-time"></div>
    <div id="alertMessage" class="alert-message"></div>
    <button class="btn-primary" onclick="closeAlertModal()">확인</button>
  </div>
</div>
<script>
    // 로그인 모달 관련 JavaScript
    var modal = document.getElementById("loginModal");
    var btn = document.getElementById("loginBtn");
    var span = document.getElementById("closeModalBtn");

    // --- 알림 모달 및 SSE 관련 스크립트 ---
    var alertModal = document.getElementById("alertModal");
    var closeAlertBtn = document.getElementById("closeAlertBtn");
    var alertTitle = document.getElementById("alertTitle");
    var alertTime = document.getElementById("alertTime");
    var alertMessage = document.getElementById("alertMessage");

    // 알림 모달 닫기 함수
    function closeAlertModal() {
        alertModal.style.display = "none";
        // 모달 닫을 때 클래스 초기화
        alertModal.classList.remove('warning', 'emergency');
    }

    // X 버튼 클릭 시 닫기
    closeAlertBtn.onclick = closeAlertModal;

    // 모달 외부 클릭 시 닫기 (로그인 모달과 통합 처리)
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
        if (event.target == alertModal) {
            closeAlertModal();
        }
    }

    // --- SSE 연결 및 알림 처리 ---
    let eventSource = null;

    function connect() {
        // 실제 운영 서버 주소로 변경 필요할 수 있음
        eventSource = new EventSource('https://127.0.0.1:8444/iot/admin/subscribe');

        eventSource.addEventListener('connect', function(event) {
            console.log('알림 서버 연결 성공');
        });

        eventSource.addEventListener('warning', function(event) {
            showAlert(event.data, 'warning');
        });

        eventSource.addEventListener('emergency', function(event) {
            showAlert(event.data, 'emergency');
            playAlertSound(); // 소리 재생
        });

        eventSource.onerror = function(error) {
            console.log('알림 서버 연결 끊김, 재연결 시도...');
            // EventSource는 기본적으로 자동 재연결을 시도하므로 추가 로직 불필요
        };
    }

    function showAlert(message, type) {
        const now = new Date();
        const timeStr = now.getHours() + ':' +
            String(now.getMinutes()).padStart(2, '0') + ':' +
            String(now.getSeconds()).padStart(2, '0');

        // 내용 채우기
        alertTime.innerText = timeStr;
        alertMessage.innerText = message;

        // 타입에 따른 스타일/제목 설정
        alertModal.className = 'modal'; // 초기화
        alertModal.classList.add(type); // warning 또는 emergency 클래스 추가
        alertModal.style.display = "block";

        if (type === 'emergency') {
            alertTitle.innerText = "🚨 긴급 알림";
            alertTitle.style.color = "#e74c3c";
        } else if (type === 'warning') {
            alertTitle.innerText = "⚠️ 경고 알림";
            alertTitle.style.color = "#ffc107";
        }
    }

    function playAlertSound() {
        const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuAyvLZimwQHTfE7efHdCUFM4fN8t2WQAoTXbPp7KlXFApFoN/yvnsgBSyAy/LaiXwQHDnE7efHdCUFM4fO8t2XQAsUX7To66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvg==');
        audio.play().catch(function(e) { console.log('Audio play failed', e); });
    }

    window.addEventListener('beforeunload', function() {
        if (eventSource) {
            eventSource.close();
        }
    });

    // 👤 버튼 클릭 시 모달 열기 (로그아웃 상태일 때만 존재)
    if (btn) {
        btn.onclick = function() {
            modal.style.display = "block";
        }
    }

    // X 버튼 클릭 시 모달 닫기
    span.onclick = function() {
        modal.style.display = "none";
    }

    // 모달 외부 클릭 시 모달 닫기
    window.onclick = function(event) {
        if (event.target == modal) {
            modal.style.display = "none";
        }
    }

    connect();
</script>
</body>
</html>