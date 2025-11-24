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
            font-size: 11px;
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
    </style>
</head>
<body>
<div class="container">
    <aside class="sidebar">
        <div class="logo">OSEN</div>

        <div class="nav-section">
            <div class="nav-title">DASH</div>
            <a href="<c:url value='/'/>" class="nav-item">
                <span class="icon">📊</span>
                <span>Sales</span>
            </a>
            <a href="<c:url value='/manage'/>" class="nav-item">
                <span class="icon">🏥</span>
                <span>Patient Manage</span>
            </a>
            <a href="<c:url value='/anage'/>" class="nav-item">
                <span class="icon">👨‍⚕️</span>
                <span>Adviser Manage</span>
            </a>
            <a href="<c:url value='/consultation'/>" class="nav-item">
                <span class="icon">📱</span>
                <span>Consultation</span>
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
                    <h1>OSEN</h1>
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

<script>
    // 모달 관련 JavaScript
    var modal = document.getElementById("loginModal");
    var btn = document.getElementById("loginBtn");
    var span = document.getElementById("closeModalBtn");

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
</script>
</body>
</html>