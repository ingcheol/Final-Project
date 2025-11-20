<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%-- DateTimeFormatter 정의 --%>
<%
  DateTimeFormatter dateInputFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
%>

<style>
  .edit-container {
    max-width: 900px;
    margin: 20px auto;
    padding: 20px;
  }

  .edit-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 10px;
    margin-bottom: 30px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  }

  .edit-header h2 {
    margin: 0 0 10px 0;
    font-size: 28px;
  }

  .edit-header p {
    margin: 0;
    opacity: 0.9;
  }

  /* 폼 카드 */
  .form-card {
    background: white;
    padding: 30px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .form-section {
    margin-bottom: 30px;
  }

  .form-section:last-child {
    margin-bottom: 0;
  }

  .form-section h3 {
    margin: 0 0 20px 0;
    font-size: 18px;
    color: #1f2937;
    border-bottom: 2px solid #e5e7eb;
    padding-bottom: 10px;
  }

  .form-group {
    margin-bottom: 20px;
  }

  .form-group label {
    display: block;
    margin-bottom: 8px;
    font-weight: 600;
    color: #374151;
    font-size: 14px;
  }

  .form-group label .required {
    color: #ef4444;
  }

  .form-control {
    width: 100%;
    padding: 12px 15px;
    border: 2px solid #e5e7eb;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.3s;
    box-sizing: border-box;
  }

  .form-control:focus {
    outline: none;
    border-color: #667eea;
  }

  .form-control:disabled {
    background: #f3f4f6;
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

  @media (max-width: 768px) {
    .form-row {
      grid-template-columns: 1fr;
    }
  }

  /* 버튼 */
  .button-group {
    display: flex;
    gap: 10px;
    justify-content: flex-end;
    margin-top: 30px;
    padding-top: 20px;
    border-top: 2px solid #e5e7eb;
  }

  .btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
  }

  .btn-primary {
    background: #667eea;
    color: white;
  }

  .btn-primary:hover {
    background: #5568d3;
    transform: translateY(-2px);
  }

  .btn-secondary {
    background: #6b7280;
    color: white;
  }

  .btn-secondary:hover {
    background: #4b5563;
  }

  /* 도움말 텍스트 */
  .help-text {
    font-size: 12px;
    color: #6b7280;
    margin-top: 5px;
  }

  /* 메시지 */
  .alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .alert-error {
    background: #fee2e2;
    color: #991b1b;
    border-left: 4px solid #ef4444;
  }
</style>

<div class="edit-container">
  <!-- 헤더 -->
  <div class="edit-header">
    <h2>✏️ 환자 정보 수정</h2>
    <p>${patient.patientName} 님의 정보를 수정합니다</p>
  </div>

  <!-- 에러 메시지 -->
  <c:if test="${not empty error}">
    <div class="alert alert-error">
      ✗ ${error}
    </div>
  </c:if>

  <!-- 수정 폼 -->
  <div class="form-card">
    <form method="post" action="<c:url value='/manage/edit'/>" onsubmit="return validateForm()">
      <input type="hidden" name="patientId" value="${patient.patientId}">

      <!-- 기본 정보 -->
      <div class="form-section">
        <h3>📋 기본 정보</h3>

        <div class="form-group">
          <label for="patientName">
            이름 <span class="required">*</span>
          </label>
          <input type="text" id="patientName" name="patientName"
                 class="form-control" value="${patient.patientName}" required>
        </div>

        <div class="form-row">
          <div class="form-group">
            <label for="patientGender">성별</label>
            <select id="patientGender" name="patientGender" class="form-control">
              <option value="M" ${patient.patientGender == 'M' ? 'selected' : ''}>남성</option>
              <option value="F" ${patient.patientGender == 'F' ? 'selected' : ''}>여성</option>
            </select>
          </div>

          <div class="form-group">
            <label for="patientDob">생년월일</label>
            <input type="date" id="patientDob" name="patientDob"
                   class="form-control"
                   value="<%
                     if (((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientDob() != null) {
                       out.print(((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientDob().format(dateInputFormatter));
                     }
                   %>">
          </div>
        </div>
      </div>

      <!-- 연락처 정보 -->
      <div class="form-section">
        <h3>📞 연락처 정보</h3>

        <div class="form-group">
          <label for="patientEmail">
            이메일 <span class="required">*</span>
          </label>
          <input type="email" id="patientEmail" name="patientEmail"
                 class="form-control" value="${patient.patientEmail}" required>
          <div class="help-text">로그인에 사용되는 이메일입니다</div>
        </div>

        <div class="form-group">
          <label for="patientPhone">전화번호</label>
          <input type="tel" id="patientPhone" name="patientPhone"
                 class="form-control" value="${patient.patientPhone}"
                 placeholder="010-0000-0000">
        </div>

        <div class="form-group">
          <label for="patientAddr">주소</label>
          <input type="text" id="patientAddr" name="patientAddr"
                 class="form-control" value="${patient.patientAddr}">
        </div>
      </div>

      <!-- 의료 정보 -->
      <div class="form-section">
        <h3>🏥 의료 정보</h3>

        <div class="form-group">
          <label for="patientMedicalHistory">병력</label>
          <textarea id="patientMedicalHistory" name="patientMedicalHistory"
                    class="form-control"
                    placeholder="과거 병력이나 현재 진료중인 질환을 입력하세요">${patient.patientMedicalHistory}</textarea>
        </div>

        <div class="form-group">
          <label for="patientLifestyleHabits">생활 습관</label>
          <textarea id="patientLifestyleHabits" name="patientLifestyleHabits"
                    class="form-control"
                    placeholder="흡연, 음주, 운동 습관 등을 입력하세요">${patient.patientLifestyleHabits}</textarea>
        </div>
      </div>

      <!-- 계정 설정 -->
      <div class="form-section">
        <h3>⚙️ 계정 설정</h3>

        <div class="form-row">
          <div class="form-group">
            <label for="patientAccountStatus">계정 상태</label>
            <select id="patientAccountStatus" name="patientAccountStatus" class="form-control">
              <option value="active" ${patient.patientAccountStatus == 'active' ? 'selected' : ''}>활성</option>
              <option value="inactive" ${patient.patientAccountStatus == 'inactive' ? 'selected' : ''}>비활성</option>
              <option value="withdrawn" ${patient.patientAccountStatus == 'withdrawn' ? 'selected' : ''}>탈퇴</option>
            </select>
          </div>

          <div class="form-group">
            <label for="languagePreference">언어 설정</label>
            <select id="languagePreference" name="languagePreference" class="form-control">
              <option value="ko" ${patient.languagePreference == 'ko' ? 'selected' : ''}>한국어</option>
              <option value="en" ${patient.languagePreference == 'en' ? 'selected' : ''}>English</option>
            </select>
          </div>
        </div>
      </div>

      <!-- 비밀번호 변경 (선택) -->
      <div class="form-section">
        <h3>🔐 비밀번호 변경 (선택사항)</h3>

        <div class="form-group">
          <label for="patientPwd">새 비밀번호</label>
          <input type="password" id="patientPwd" name="patientPwd"
                 class="form-control"
                 placeholder="변경하지 않으려면 비워두세요">
          <div class="help-text">비밀번호는 8자 이상, 영문, 숫자, 특수문자를 포함해야 합니다</div>
        </div>

        <div class="form-group">
          <label for="patientPwdConfirm">비밀번호 확인</label>
          <input type="password" id="patientPwdConfirm" name="patientPwdConfirm"
                 class="form-control"
                 placeholder="새 비밀번호를 다시 입력하세요">
        </div>
      </div>

      <!-- 버튼 -->
      <div class="button-group">
        <button type="button" class="btn btn-secondary"
                onclick="location.href='<c:url value="/manage/${patient.patientId}"/>'">
          취소
        </button>
        <button type="submit" class="btn btn-primary">
          💾 저장하기
        </button>
      </div>
    </form>
  </div>
</div>

<script>
  function validateForm() {
    const name = document.getElementById('patientName').value.trim();
    const email = document.getElementById('patientEmail').value.trim();
    const pwd = document.getElementById('patientPwd').value;
    const pwdConfirm = document.getElementById('patientPwdConfirm').value;

    // 이름 검증
    if (name === '') {
      alert('이름을 입력해주세요.');
      document.getElementById('patientName').focus();
      return false;
    }

    // 이메일 검증
    if (email === '') {
      alert('이메일을 입력해주세요.');
      document.getElementById('patientEmail').focus();
      return false;
    }

    const emailPattern = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailPattern.test(email)) {
      alert('올바른 이메일 형식이 아닙니다.');
      document.getElementById('patientEmail').focus();
      return false;
    }

    // 비밀번호 변경 시 검증
    if (pwd !== '' || pwdConfirm !== '') {
      if (pwd !== pwdConfirm) {
        alert('비밀번호가 일치하지 않습니다.');
        document.getElementById('patientPwdConfirm').focus();
        return false;
      }

      if (pwd.length < 8) {
        alert('비밀번호는 8자 이상이어야 합니다.');
        document.getElementById('patientPwd').focus();
        return false;
      }

      // 비밀번호 강도 검증
      const hasLetter = /[a-zA-Z]/.test(pwd);
      const hasNumber = /[0-9]/.test(pwd);
      const hasSpecial = /[!@#$%^&*]/.test(pwd);

      if (!hasLetter || !hasNumber || !hasSpecial) {
        alert('비밀번호는 영문, 숫자, 특수문자를 모두 포함해야 합니다.');
        document.getElementById('patientPwd').focus();
        return false;
      }
    }

    return confirm('환자 정보를 수정하시겠습니까?');
  }

  // 전화번호 자동 포맷팅
  document.getElementById('patientPhone').addEventListener('input', function(e) {
    let value = e.target.value.replace(/\D/g, '');
    if (value.length > 3 && value.length <= 7) {
      value = value.slice(0, 3) + '-' + value.slice(3);
    } else if (value.length > 7) {
      value = value.slice(0, 3) + '-' + value.slice(3, 7) + '-' + value.slice(7, 11);
    }
    e.target.value = value;
  });
</script>