<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-11-20
  Time: 오후 3:53:38
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>

<style>
    .info-container {
        max-width: 800px;
        margin: 50px auto;
        padding: 40px;
        box-shadow: 0 4px 20px rgba(0,0,0,0.1);
        border-radius: 10px;
        background: white;
    }

    .info-header {
        text-align: center;
        margin-bottom: 40px;
        padding-bottom: 20px;
        border-bottom: 2px solid #5B6FB5;
    }

    .info-header h2 {
        color: #5B6FB5;
        margin-bottom: 10px;
    }

    .info-header .user-email {
        color: #666;
        font-size: 14px;
    }

    .form-section {
        margin-bottom: 30px;
    }

    .form-section h3 {
        color: #333;
        font-size: 18px;
        margin-bottom: 15px;
        padding-bottom: 10px;
        border-bottom: 1px solid #e0e0e0;
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

    .form-control:disabled {
        background-color: #f5f5f5;
        cursor: not-allowed;
    }

    textarea.form-control {
        min-height: 100px;
        resize: vertical;
    }

    .form-row {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .button-group {
        display: flex;
        gap: 10px;
        margin-top: 30px;
    }

    .btn {
        flex: 1;
        padding: 12px;
        border: none;
        border-radius: 5px;
        font-weight: 600;
        font-size: 16px;
        cursor: pointer;
        transition: all 0.2s;
    }

    .btn-primary {
        background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
        color: white;
    }

    .btn-primary:hover {
        transform: translateY(-2px);
    }

    .btn-secondary {
        background: white;
        color: #666;
        border: 2px solid #ddd;
    }

    .btn-secondary:hover {
        border-color: #999;
        color: #333;
    }

    .btn-danger {
        background: #dc3545;
        color: white;
    }

    .btn-danger:hover {
        background: #c82333;
    }

    .delete-section {
        margin-top: 40px;
        padding-top: 30px;
        border-top: 2px solid #f0f0f0;
        text-align: center;
    }

    .delete-section h3 {
        color: #dc3545;
        margin-bottom: 15px;
    }

    .delete-section p {
        color: #666;
        margin-bottom: 20px;
    }

    .error-message {
        color: #dc3545;
        background: #f8d7da;
        padding: 12px;
        border-radius: 5px;
        margin-bottom: 20px;
        text-align: center;
    }

    .success-message {
        color: #155724;
        background: #d4edda;
        padding: 12px;
        border-radius: 5px;
        margin-bottom: 20px;
        text-align: center;
    }

    .gender-options {
        display: flex;
        gap: 20px;
        margin-top: 8px;
    }

    .gender-options label {
        font-weight: normal;
        display: flex;
        align-items: center;
    }

    .gender-options input[type="radio"] {
        margin-right: 5px;
    }

    .info-badge {
        display: inline-block;
        padding: 4px 12px;
        background: #e7f3ff;
        color: #1976d2;
        border-radius: 15px;
        font-size: 12px;
        margin-left: 10px;
    }

    @media (max-width: 768px) {
        .form-row {
            grid-template-columns: 1fr;
        }

        .button-group {
            flex-direction: column;
        }
    }
</style>

<script>
    const patientInfo = {
        init: function() {
            this.setupEventHandlers();
        },

        setupEventHandlers: function() {
            // 정보 수정 버튼
            $('#update_btn').click(() => {
                this.validateAndUpdate();
            });

            // 취소 버튼
            $('#cancel_btn').click(() => {
                window.location.href = '<c:url value="/"/>';
            });

            // 회원 탈퇴 버튼
            $('#delete_btn').click(() => {
                this.confirmDelete();
            });

            // 전화번호 입력 시 숫자만 허용
            $('#phone').on('input', function() {
                const value = $(this).val();
                $(this).val(value.replace(/\D/g, ''));
            });
        },

        validateAndUpdate: function() {
            const name = $('#name').val().trim();
            const phone = $('#phone').val().trim();
            const addr = $('#addr').val().trim();

            if (!name || name.length < 2) {
                alert('이름은 최소 2자 이상이어야 합니다.');
                $('#name').focus();
                return;
            }

            if (phone && !/^01[0-9]{8,9}$/.test(phone)) {
                alert('올바른 전화번호 형식이 아닙니다. (예: 01012345678)');
                $('#phone').focus();
                return;
            }

            if (confirm('개인정보를 수정하시겠습니까?')) {
                $('#update_form').submit();
            }
        },

        confirmDelete: function() {
            const currentPwd = prompt('회원 탈퇴를 위해 현재 비밀번호를 입력해주세요:');

            if (currentPwd === null) {
                return;
            }

            if (!currentPwd.trim()) {
                alert('비밀번호를 입력해주세요.');
                return;
            }

            if (confirm('정말로 탈퇴하시겠습니까? 이 작업은 되돌릴 수 없습니다.')) {
                $('#currentPwd').val(currentPwd);
                $('#delete_form').submit();
            }
        }
    }

    $(function(){
        patientInfo.init();
    });
</script>

<div class="info-container">
  <div class="info-header">
    <h2>개인정보 관리</h2>
    <p class="user-email">${patient.patientEmail}</p>
  </div>

  <c:if test="${error != null}">
    <div class="error-message">${error}</div>
  </c:if>

  <c:if test="${param.update == 'success'}">
    <div class="success-message">개인정보가 성공적으로 수정되었습니다.</div>
  </c:if>

  <form id="update_form" action="<c:url value='/updateinfo'/>" method="post">
    <input type="hidden" name="patientId" value="${patient.patientId}">
    <input type="hidden" name="patientEmail" value="${patient.patientEmail}">

    <!-- 기본 정보 섹션 -->
    <div class="form-section">
      <h3>기본 정보</h3>

      <div class="form-group">
        <label for="email">이메일 <span class="info-badge">변경불가</span></label>
        <input type="email"
               class="form-control"
               id="email"
               value="${patient.patientEmail}"
               disabled>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label for="name">이름 <span style="color: red;">*</span></label>
          <input type="text"
                 class="form-control"
                 id="name"
                 name="patientName"
                 value="${patient.patientName}"
                 required>
        </div>

        <div class="form-group">
          <label for="phone">전화번호</label>
          <input type="tel"
                 class="form-control"
                 id="phone"
                 name="patientPhone"
                 value="${patient.patientPhone}"
                 placeholder="01012345678">
        </div>
      </div>

      <div class="form-group">
        <label for="addr">주소</label>
        <input type="text"
               class="form-control"
               id="addr"
               name="patientAddr"
               value="${patient.patientAddr}"
               placeholder="서울시 강남구...">
      </div>
    </div>

    <!-- 의료 정보 섹션 -->
    <div class="form-section">
      <h3>의료 정보</h3>

      <div class="form-group">
        <label for="medical_history">과거 병력</label>
        <textarea class="form-control"
                  id="medical_history"
                  name="patientMedicalHistory"
                  placeholder="예: 고혈압, 당뇨, 천식 등 과거 진단받은 질병이나 수술 이력을 입력해주세요.">${patient.patientMedicalHistory}</textarea>
      </div>

      <div class="form-group">
        <label for="lifestyle_habits">생활습관</label>
        <textarea class="form-control"
                  id="lifestyle_habits"
                  name="patientLifestyleHabits"
                  placeholder="예: 흡연 여부, 음주 빈도, 운동 습관, 식습관 등을 입력해주세요.">${patient.patientLifestyleHabits}</textarea>
      </div>
    </div>

    <!-- 시스템 설정 섹션 -->
    <div class="form-section">
      <div class="form-group">
        <label for="language_preference">선호 언어</label>
        <select class="form-control"
                id="language_preference"
                name="languagePreference">
          <option value="ko" ${patient.languagePreference == 'ko' ? 'selected' : ''}>한국어</option>
          <option value="en" ${patient.languagePreference == 'en' ? 'selected' : ''}>English</option>
          <option value="ja" ${patient.languagePreference == 'ja' ? 'selected' : ''}>日本語</option>
          <option value="zh" ${patient.languagePreference == 'zh' ? 'selected' : ''}>简体中文</option>
        </select>
      </div>
    </div>

    <div class="button-group">
      <button type="button" id="cancel_btn" class="btn btn-secondary">취소</button>
      <button type="button" id="update_btn" class="btn btn-primary">정보 수정</button>
    </div>
  </form>

  <!-- 회원 탈퇴 섹션 -->
  <div class="delete-section">
    <h3>⚠️ 회원 탈퇴</h3>
    <p>계정을 삭제하면 모든 개인정보와 이용 기록이 영구적으로 삭제됩니다.</p>
    <form id="delete_form" action="<c:url value='/deleteimpl'/>" method="post">
      <input type="hidden" id="currentPwd" name="currentPwd">
      <button type="button" id="delete_btn" class="btn btn-danger" style="max-width: 200px;">
        회원 탈퇴
      </button>
    </form>
  </div>
</div>

