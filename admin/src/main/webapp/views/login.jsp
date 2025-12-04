<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>로그인 | Osen</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
    }

    body {
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 20px;
    }

    .login-container {
      background: #fff;
      border-radius: 20px;
      padding: 50px 40px;
      width: 100%;
      max-width: 450px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
    }

    .logo {
      text-align: center;
      margin-bottom: 40px;
    }

    .logo h1 {
      font-size: 32px;
      color: #1e293b;
      margin-bottom: 8px;
    }

    .logo p {
      color: #64748b;
      font-size: 14px;
    }

    .error-message {
      background: #fee2e2;
      color: #dc2626;
      padding: 12px;
      border-radius: 8px;
      margin-bottom: 20px;
      font-size: 14px;
      display: none;
    }

    .error-message.show {
      display: block;
    }

    .form-group {
      margin-bottom: 20px;
    }

    .form-group label {
      display: block;
      margin-bottom: 8px;
      color: #475569;
      font-size: 14px;
      font-weight: 500;
    }

    .form-group input {
      width: 100%;
      padding: 14px 16px;
      border: 2px solid #e2e8f0;
      border-radius: 10px;
      font-size: 15px;
      transition: all 0.3s;
    }

    .form-group input:focus {
      outline: none;
      border-color: #6366f1;
      box-shadow: 0 0 0 4px rgba(99, 102, 241, 0.1);
    }

    .remember-forgot {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 25px;
      font-size: 14px;
    }

    .remember-me {
      display: flex;
      align-items: center;
      gap: 8px;
    }

    .remember-me input[type="checkbox"] {
      width: 18px;
      height: 18px;
      cursor: pointer;
    }

    .forgot-password {
      color: #6366f1;
      text-decoration: none;
    }

    .forgot-password:hover {
      text-decoration: underline;
    }

    .login-btn {
      width: 100%;
      padding: 16px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: #fff;
      border: none;
      border-radius: 10px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s;
    }

    .login-btn:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(102, 126, 234, 0.4);
    }

    .divider {
      text-align: center;
      margin: 30px 0;
      position: relative;
    }

    .divider::before {
      content: "";
      position: absolute;
      left: 0;
      right: 0;
      top: 50%;
      height: 1px;
      background: #e2e8f0;
    }

    .divider span {
      background: #fff;
      padding: 0 15px;
      position: relative;
      color: #94a3b8;
      font-size: 13px;
    }

    .social-login {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 12px;
    }

    .social-btn {
      padding: 12px;
      border: 2px solid #e2e8f0;
      border-radius: 10px;
      background: #fff;
      cursor: pointer;
      font-size: 14px;
      font-weight: 500;
      transition: all 0.3s;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
    }

    .social-btn:hover {
      border-color: #cbd5e1;
      background: #f8fafc;
      transform: translateY(-2px);
    }

    .signup-link {
      text-align: center;
      margin-top: 30px;
      font-size: 14px;
      color: #64748b;
    }

    .signup-link a {
      color: #6366f1;
      text-decoration: none;
      font-weight: 600;
    }

    .signup-link a:hover {
      text-decoration: underline;
    }

    @media (max-width: 480px) {
      .login-container {
        padding: 40px 25px;
      }
    }
  </style>
</head>
<body>
<div class="login-container">
  <div class="logo">
    <h1>탱구</h1>
    <p>관리자 로그인</p>

    <a href="${pageContext.request.contextPath}/"
       style="text-decoration: none; color: #6366f1; font-size: 14px; margin-top: 10px; display: inline-block;">
      HOME
    </a>
  </div>

  <% if (request.getAttribute("error") != null) { %>
  <div class="error-message show">
    <%= request.getAttribute("error") %>
  </div>
  <% } %>

  <form action="${pageContext.request.contextPath}/login" method="post">
    <div class="form-group">
      <label for="email">이메일</label>
      <input type="email" id="email" name="email" placeholder="example@email.com" required>
    </div>

    <div class="form-group">
      <label for="password">비밀번호</label>
      <input type="password" id="password" name="password" placeholder="••••••••" required>
    </div>

    <div class="remember-forgot">
      <label class="remember-me">
        <input type="checkbox" name="rememberMe" value="on">
        <span>로그인 상태 유지</span>
      </label>
      <a href="#" class="forgot-password">비밀번호 찾기</a>
    </div>

    <button type="submit" class="login-btn">로그인</button>
  </form>

  <div class="divider">
    <span>또는</span>
  </div>

  <div class="signup-link">
    계정이 없으신가요? <a href="#">회원가입</a>
  </div>
</div>
</body>
</html>
