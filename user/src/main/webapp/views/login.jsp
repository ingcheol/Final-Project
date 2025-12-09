<%--
  Created by IntelliJ IDEA.
  User: 건
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .nav-buttons {
        position: absolute;
        top: 20px;
        right: 20px;
        display: flex;
        gap: 10px;
    }

    .nav-btn {
        width: 40px;
        height: 40px;
        border: 2px solid #e0e0e0;
        border-radius: 50%;
        background: white;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        transition: all 0.2s;
        color: #666;
        font-size: 18px;
    }

    .nav-btn:hover {
        border-color: #667eea;
        color: #667eea;
        transform: translateY(-2px);
    }

    .login-container {
        max-width: 500px;
        margin: 100px auto;
        padding: 40px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        border-radius: 10px;
        background: white;
    }

    .login-container h2 {
        text-align: center;
        color: #5B6FB5;
        margin-bottom: 30px;
    }

    .form-group {
        margin-bottom: 20px;
    }

    .form-group label {
        font-weight: 600;
        color: #333;
        display: block;
        margin-bottom: 8px;
    }

    .form-control {
        width: 100%;
        border-radius: 5px;
        border: 1px solid #ddd;
        padding: 12px;
        font-size: 14px;
    }

    .btn-login {
        width: 100%;
        padding: 12px;
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        border: none;
        border-radius: 5px;
        color: white;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: transform 0.2s;
    }

    .btn-login:hover {
        transform: translateY(-2px);
    }

    .divider {
        text-align: center;
        margin: 30px 0;
        position: relative;
    }

    .divider::before {
        content: '';
        position: absolute;
        left: 0;
        top: 50%;
        width: 100%;
        height: 1px;
        background: #ddd;
    }

    .divider span {
        background: white;
        padding: 0 15px;
        position: relative;
        color: #999;
    }

    .btn-kakao {
        width: 100%;
        padding: 12px;
        background-color: #FEE500;
        border: none;
        border-radius: 5px;
        color: #000000;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: background-color 0.2s;
        text-decoration: none;
        display: block;
        text-align: center;
    }

    .btn-kakao:hover {
        background-color: #FDD835;
    }

    .login-error {
        color: #dc3545;
        text-align: center;
        margin-bottom: 20px;
        padding: 10px;
        background: #f8d7da;
        border-radius: 5px;
    }

    .signup-section {
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid #eee;
    }

    .signup-section p {
        color: #666;
        margin-bottom: 10px;
    }

    .btn-signup {
        width: 100%;
        padding: 12px;
        background: white;
        border: 2px solid #667eea;
        border-radius: 5px;
        color: #667eea;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.2s;
        text-decoration: none;
        display: block;
        text-align: center;
    }

    .btn-signup:hover {
        background: #667eea;
        color: white;
    }
</style>

<script>
    const login = {
        init:function(){
            $('#login_btn').click(()=>{
                this.send();
            });

            $('#email, #pwd').keypress(function(e) {
                if(e.which === 13) {
                    login.send();
                }
            });

            // 뒤로가기 버튼
            $('#back_btn').click(function() {
                window.history.back();
            });
        },
        send:function(){
            let email = $('#email').val().trim();
            let pwd = $('#pwd').val().trim();

            if(!email) {
                alert('이메일을 입력해주세요.');
                $('#email').focus();
                return;
            }

            if(!pwd) {
                alert('비밀번호를 입력해주세요.');
                $('#pwd').focus();
                return;
            }

            $('#login_form').submit();
        }
    }

    $(function(){
        login.init();
    });
</script>

<div class="login-container">
  <button type="button" id="back_btn" class="nav-btn" title="뒤로가기">
    🔙
  </button>
  <h2>로그인</h2>

  <c:if test="${loginstate == 'fail'}">
    <div class="login-error">
      이메일 또는 비밀번호가 일치하지 않습니다.
    </div>
  </c:if>

  <form id="login_form" action="<c:url value='/loginimpl'/>?redirect=${param.redirect}" method="post">
    <div class="form-group">
      <label for="email">이메일</label>
      <input type="email"
             class="form-control"
             id="email"
             name="email"
             value="qwe123@gmail.com"
             required>
    </div>

    <div class="form-group">
      <label for="pwd">비밀번호</label>
      <input type="password"
             class="form-control"
             id="pwd"
             name="pwd"
             placeholder="비밀번호를 입력하세요"
             value="111111"
             required>
    </div>

    <button type="button" id="login_btn" class="btn-login">로그인</button>
  </form>

  <div class="divider">
    <span>또는</span>
  </div>

  <a href="/oauth2/authorization/kakao" class="btn-kakao">
    카카오로 로그인
  </a>

  <div class="signup-section">
    <p>아직 계정이 없으신가요?</p>
    <a href="<c:url value='/register'/>" class="btn-signup">이메일로 회원가입</a>
  </div>
</div>
