<%--
  Created by IntelliJ IDEA.
  User: 건
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .register-container {
        max-width: 500px;
        margin: 50px auto;
        padding: 40px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        border-radius: 10px;
        background: white;
    }

    .register-container h2 {
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
        transition: border-color 0.2s;
    }

    .form-control:focus {
        outline: none;
        border-color: #667eea;
    }

    .form-control.is-valid {
        border-color: #28a745;
    }

    .form-control.is-invalid {
        border-color: #dc3545;
    }

    .feedback {
        font-size: 12px;
        margin-top: 5px;
        display: none;
    }

    .feedback.valid {
        color: #28a745;
        display: block;
    }

    .feedback.invalid {
        color: #dc3545;
        display: block;
    }

    .btn-register {
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
        margin-top: 10px;
    }

    .btn-register:hover:not(:disabled) {
        transform: translateY(-2px);
    }

    .btn-register:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .login-link {
        text-align: center;
        margin-top: 20px;
        padding-top: 20px;
        border-top: 1px solid #eee;
        color: #666;
    }

    .login-link a {
        color: #667eea;
        text-decoration: none;
        font-weight: 600;
    }

    .login-link a:hover {
        text-decoration: underline;
    }

    .password-strength {
        height: 4px;
        margin-top: 5px;
        border-radius: 2px;
        background: #eee;
        overflow: hidden;
    }

    .password-strength-bar {
        height: 100%;
        transition: width 0.3s, background-color 0.3s;
        width: 0;
    }

    .password-strength-bar.weak {
        width: 33%;
        background-color: #dc3545;
    }

    .password-strength-bar.medium {
        width: 66%;
        background-color: #ffc107;
    }

    .password-strength-bar.strong {
        width: 100%;
        background-color: #28a745;
    }
</style>

<script>
    const register = {
        isEmailValid: false,
        isEmailChecked: false,
        isPwdValid: false,
        isPwdConfirmValid: false,
        isNameValid: false,
        isPhoneValid: false,

        init: function() {
            this.setupValidation();
            this.setupSubmit();
        },

        setupValidation: function() {
            // 이메일 입력 시 중복 확인 초기화
            $('#email').on('input', () => {
                this.isEmailChecked = false;
                this.isEmailValid = false;
                $('#email').removeClass('is-valid is-invalid');
                $('#email').siblings('.feedback').removeClass('valid invalid').hide();
            });

            // 이메일 중복 확인 버튼
            $('#check_email_btn').click(() => {
                this.checkEmailDuplicate();
            });

            // 이메일 유효성 검사 (blur 시)
            $('#email').on('blur', () => {
                const email = $('#email').val().trim();
                const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

                if (!email) {
                    this.showFeedback('#email', '이메일을 입력해주세요.', false);
                    this.isEmailValid = false;
                    this.isEmailChecked = false;
                } else if (!emailPattern.test(email)) {
                    this.showFeedback('#email', '올바른 이메일 형식이 아닙니다.', false);
                    this.isEmailValid = false;
                    this.isEmailChecked = false;
                }
            });

            // 비밀번호 유효성 검사 및 강도 체크
            $('#pwd').on('input', () => {
                const pwd = $('#pwd').val();
                this.checkPasswordStrength(pwd);

                if (pwd.length < 6) {
                    this.showFeedback('#pwd', '비밀번호는 최소 6자 이상이어야 합니다.', false);
                    this.isPwdValid = false;
                } else {
                    this.showFeedback('#pwd', '사용 가능한 비밀번호입니다.', true);
                    this.isPwdValid = true;
                }

                // 비밀번호 확인 재검증
                if ($('#pwd_confirm').val()) {
                    $('#pwd_confirm').trigger('blur');
                }
            });

            // 비밀번호 확인
            $('#pwd_confirm').on('blur', () => {
                const pwd = $('#pwd').val();
                const pwdConfirm = $('#pwd_confirm').val();

                if (!pwdConfirm) {
                    this.showFeedback('#pwd_confirm', '비밀번호 확인을 입력해주세요.', false);
                    this.isPwdConfirmValid = false;
                } else if (pwd !== pwdConfirm) {
                    this.showFeedback('#pwd_confirm', '비밀번호가 일치하지 않습니다.', false);
                    this.isPwdConfirmValid = false;
                } else {
                    this.showFeedback('#pwd_confirm', '비밀번호가 일치합니다.', true);
                    this.isPwdConfirmValid = true;
                }
            });

            // 이름 유효성 검사
            $('#name').on('blur', () => {
                const name = $('#name').val().trim();

                if (!name) {
                    this.showFeedback('#name', '이름을 입력해주세요.', false);
                    this.isNameValid = false;
                } else if (name.length < 2) {
                    this.showFeedback('#name', '이름은 최소 2자 이상이어야 합니다.', false);
                    this.isNameValid = false;
                } else {
                    this.showFeedback('#name', '올바른 이름입니다.', true);
                    this.isNameValid = true;
                }
            });

            // 전화번호 입력 시 숫자만 허용
            $('#phone').on('input', function() {
                const value = $(this).val();
                $(this).val(value.replace(/\D/g, ''));
            });

            // 전화번호 유효성 검사
            $('#phone').on('blur', () => {
                const phone = $('#phone').val().trim();
                const phonePattern = /^01[0-9]{8,9}$/;

                if (!phone) {
                    this.showFeedback('#phone', '전화번호를 입력해주세요.', false);
                    this.isPhoneValid = false;
                } else if (!phonePattern.test(phone)) {
                    this.showFeedback('#phone', '올바른 전화번호 형식이 아닙니다. (예: 01012345678)', false);
                    this.isPhoneValid = false;
                } else {
                    this.showFeedback('#phone', '올바른 전화번호입니다.', true);
                    this.isPhoneValid = true;
                }
            });

        },

        // 이메일 중복 확인 AJAX
        checkEmailDuplicate: function() {
            const email = $('#email').val().trim();
            const emailPattern = /^[a-zA-Z0-9._-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,6}$/;

            if (!email) {
                alert('이메일을 입력해주세요.');
                $('#email').focus();
                return;
            }

            if (!emailPattern.test(email)) {
                alert('올바른 이메일 형식이 아닙니다.');
                $('#email').focus();
                return;
            }

            // AJAX로 중복 확인
            $.ajax({
                url: '<c:url value="/checkemail"/>',
                type: 'POST',
                data: { email: email },
                success: (response) => {
                    if (response.available) {
                        this.showFeedback('#email', '✓ 사용 가능한 이메일입니다.', true);
                        this.isEmailValid = true;
                        this.isEmailChecked = true;
                    } else {
                        this.showFeedback('#email', '✗ 이미 사용 중인 이메일입니다.', false);
                        this.isEmailValid = false;
                        this.isEmailChecked = false;
                    }
                },
                error: () => {
                    alert('이메일 중복 확인 중 오류가 발생했습니다.');
                }
            });
        },

        checkPasswordStrength: function(pwd) {
            let strength = 0;
            const strengthBar = $('.password-strength-bar');

            if (pwd.length >= 6) strength++;
            if (pwd.length >= 10) strength++;
            if (/[a-z]/.test(pwd) && /[A-Z]/.test(pwd)) strength++;
            if (/[0-9]/.test(pwd)) strength++;
            if (/[^a-zA-Z0-9]/.test(pwd)) strength++;

            strengthBar.removeClass('weak medium strong');
            if (strength <= 2) {
                strengthBar.addClass('weak');
            } else if (strength <= 3) {
                strengthBar.addClass('medium');
            } else {
                strengthBar.addClass('strong');
            }
        },

        showFeedback: function(selector, message, isValid) {
            const input = $(selector);
            const feedback = input.siblings('.feedback');

            input.removeClass('is-valid is-invalid');
            feedback.removeClass('valid invalid');

            if (isValid) {
                input.addClass('is-valid');
                feedback.addClass('valid');
            } else {
                input.addClass('is-invalid');
                feedback.addClass('invalid');
            }

            feedback.text(message);
        },

        setupSubmit: function() {
            $('#register_btn').click((e) => {
                e.preventDefault();
                this.validateAndSubmit();
            });
        },

        validateAndSubmit: function() {
            // 이메일 중복 확인 필수
            if (!this.isEmailChecked) {
                alert('이메일 중복 확인을 해주세요.');
                $('#email').focus();
                return;
            }
            // 모든 필드 재검증
            $('#email, #pwd, #pwd_confirm, #name, #phone').trigger('blur');

            const isFormValid = this.isEmailValid && this.isPwdValid &&
                this.isPwdConfirmValid && this.isNameValid &&
                this.isPhoneValid;

            if (!isFormValid) {
                alert('모든 필드를 올바르게 입력해주세요.');
                return;
            }

            // 생년월일 검증
            const dob = $('#dob').val();
            if (!dob) {
                alert('생년월일을 입력해주세요.');
                $('#dob').focus();
                return;
            }
            // 성별 검증
            const gender = $('input[name="patientGender"]:checked').val();
            if (!gender) {
                alert('성별을 선택해주세요.');
                return;
            }

            this.send();
        },

        send: function() {
            $('#register_form').attr('method', 'post');
            $('#register_form').attr('action', '<c:url value="/registerimpl"/>');
            $('#register_form').submit();
        }
    }

    $(function(){
        register.init();
    });
</script>

<div class="register-container">
  <h2>회원가입</h2>

  <form id="register_form">
    <div class="form-group">
      <div style="display: flex; gap: 10px;">
        <input type="email"
               class="form-control"
               placeholder="example@email.com"
               id="email"
               name="patientEmail"
               style="flex: 1;"
               required>
        <button type="button"
                id="check_email_btn"
                style="padding: 12px 20px; background: #667eea; color: white; border: none; border-radius: 5px; cursor: pointer; white-space: nowrap;">
          중복확인
        </button>
      </div>
      <div class="feedback"></div>
    </div>

    <div class="form-group">
      <label for="pwd">비밀번호 <span style="color: red;">*</span></label>
      <input type="password"
             class="form-control"
             placeholder="비밀번호 (최소 6자)"
             id="pwd"
             name="patientPwd"
             required>
      <div class="password-strength">
        <div class="password-strength-bar"></div>
      </div>
      <div class="feedback"></div>
    </div>

    <div class="form-group">
      <label for="pwd_confirm">비밀번호 확인 <span style="color: red;">*</span></label>
      <input type="password"
             class="form-control"
             placeholder="비밀번호 재입력"
             id="pwd_confirm"
             required>
      <div class="feedback"></div>
    </div>

    <div class="form-group">
      <label for="name">이름 <span style="color: red;">*</span></label>
      <input type="text"
             class="form-control"
             placeholder="홍길동"
             id="name"
             name="patientName"
             required>
      <div class="feedback"></div>
    </div>

    <div class="form-group">
      <label for="phone">전화번호 <span style="color: red;">*</span></label>
      <input type="tel"
             class="form-control"
             placeholder="01012345678"
             id="phone"
             name="patientPhone"
             required>
      <div class="feedback"></div>
    </div>

    <div class="form-group">
      <label for="dob">생년월일 <span style="color: red;">*</span></label>
      <input type="date"
             class="form-control"
             id="dob"
             name="patientDob"
             required>
    </div>

    <div class="form-group">
      <label>성별 <span style="color: red;">*</span></label>
      <div style="display: flex; gap: 20px; margin-top: 8px;">
        <label style="font-weight: normal; display: flex; align-items: center;">
          <input type="radio" name="patientGender" value="M" style="margin-right: 5px;" required> 남성
        </label>
        <label style="font-weight: normal; display: flex; align-items: center;">
          <input type="radio" name="patientGender" value="F" style="margin-right: 5px;" required> 여성
        </label>
      </div>
    </div>

    <div class="form-group">
      <label for="addr">주소</label>
      <input type="text"
             class="form-control"
             placeholder="서울시 강남구..."
             id="addr"
             name="patientAddr">
    </div>

    <button type="button" id="register_btn" class="btn-register">회원가입</button>
  </form>

  <div class="login-link">
    이미 계정이 있으신가요? <a href="<c:url value='/login'/>">로그인</a>
  </div>
</div>


