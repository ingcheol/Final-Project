<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%-- DateTimeFormatter 정의 --%>
<%
  DateTimeFormatter dateFormatter = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일");
  DateTimeFormatter dateTimeFormatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
%>

<style>
  .detail-container {
    max-width: 1200px;
    margin: 20px auto;
    padding: 20px;
  }

  .detail-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 10px;
    margin-bottom: 30px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  }

  .detail-header h2 {
    margin: 0 0 10px 0;
    font-size: 28px;
  }

  .detail-header .patient-id {
    opacity: 0.9;
    font-size: 14px;
  }

  /* 액션 버튼 영역 */
  .action-bar {
    display: flex;
    gap: 10px;
    margin-bottom: 30px;
    flex-wrap: wrap;
  }

  .btn {
    padding: 12px 24px;
    border: none;
    border-radius: 8px;
    font-size: 14px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    text-decoration: none;
    display: inline-block;
  }

  .btn-back {
    background: #6b7280;
    color: white;
  }

  .btn-edit {
    background: #f59e0b;
    color: white;
  }

  .btn-delete {
    background: #ef4444;
    color: white;
  }

  .btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 8px rgba(0,0,0,0.2);
  }

  /* 정보 카드 */
  .info-cards {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
  }

  .info-card {
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .info-card h3 {
    margin: 0 0 20px 0;
    font-size: 18px;
    color: #1f2937;
    border-bottom: 2px solid #e5e7eb;
    padding-bottom: 10px;
  }

  .info-row {
    display: flex;
    justify-content: space-between;
    padding: 12px 0;
    border-bottom: 1px solid #f3f4f6;
  }

  .info-row:last-child {
    border-bottom: none;
  }

  .info-label {
    font-weight: 600;
    color: #6b7280;
    font-size: 14px;
  }

  .info-value {
    color: #1f2937;
    font-size: 14px;
    text-align: right;
  }

  /* 상태 배지 */
  .status-badge {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
    font-weight: 600;
  }

  .status-active {
    background: #d1fae5;
    color: #065f46;
  }

  .status-inactive {
    background: #fef3c7;
    color: #92400e;
  }

  .status-withdrawn {
    background: #fee2e2;
    color: #991b1b;
  }

  /* 계정 상태 변경 섹션 */
  .status-change-card {
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .status-change-card h3 {
    margin: 0 0 20px 0;
    font-size: 18px;
    color: #1f2937;
  }

  .status-buttons {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }

  .status-btn {
    flex: 1;
    min-width: 150px;
    padding: 15px;
    border: 2px solid;
    border-radius: 8px;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s;
    text-align: center;
  }

  .status-btn-active {
    border-color: #10b981;
    color: #10b981;
    background: white;
  }

  .status-btn-active:hover {
    background: #10b981;
    color: white;
  }

  .status-btn-inactive {
    border-color: #f59e0b;
    color: #f59e0b;
    background: white;
  }

  .status-btn-inactive:hover {
    background: #f59e0b;
    color: white;
  }

  .status-btn-withdrawn {
    border-color: #ef4444;
    color: #ef4444;
    background: white;
  }

  .status-btn-withdrawn:hover {
    background: #ef4444;
    color: white;
  }

  /* 메시지 */
  .alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
  }

  .alert-success {
    background: #d1fae5;
    color: #065f46;
    border-left: 4px solid #10b981;
  }

  .alert-error {
    background: #fee2e2;
    color: #991b1b;
    border-left: 4px solid #ef4444;
  }
</style>

<div class="detail-container">
  <!-- 헤더 -->
  <div class="detail-header">
    <h2>👤 ${patient.patientName} 님의 정보</h2>
    <div class="patient-id">환자 ID: ${patient.patientId}</div>
  </div>

  <!-- 메시지 표시 -->
  <c:if test="${not empty message}">
    <div class="alert alert-success">
      ✓ ${message}
    </div>
  </c:if>
  <c:if test="${not empty error}">
    <div class="alert alert-error">
      ✗ ${error}
    </div>
  </c:if>

  <!-- 액션 버튼 -->
  <div class="action-bar">
    <a href="<c:url value='/manage'/>" class="btn btn-back">
      ← 목록으로
    </a>
    <a href="<c:url value='/manage/edit/${patient.patientId}'/>" class="btn btn-edit">
      ✏️ 정보 수정
    </a>
    <button class="btn btn-delete" onclick="confirmDelete()">
      🗑️ 환자 삭제
    </button>
  </div>

  <!-- 계정 상태 변경 -->
  <div class="status-change-card">
    <h3>🔄 계정 상태 변경</h3>
    <div class="status-buttons">
      <form method="post" action="<c:url value='/manage/status'/>" style="flex: 1; min-width: 150px;">
        <input type="hidden" name="patientId" value="${patient.patientId}">
        <input type="hidden" name="status" value="active">
        <button type="submit" class="status-btn status-btn-active">
          ✅ 활성화
        </button>
      </form>
      <form method="post" action="<c:url value='/manage/status'/>" style="flex: 1; min-width: 150px;">
        <input type="hidden" name="patientId" value="${patient.patientId}">
        <input type="hidden" name="status" value="inactive">
        <button type="submit" class="status-btn status-btn-inactive">
          ⏸️ 비활성화
        </button>
      </form>
      <form method="post" action="<c:url value='/manage/status'/>" style="flex: 1; min-width: 150px;">
        <input type="hidden" name="patientId" value="${patient.patientId}">
        <input type="hidden" name="status" value="withdrawn">
        <button type="submit" class="status-btn status-btn-withdrawn"
                onclick="return confirm('정말 탈퇴 상태로 변경하시겠습니까?')">
          ❌ 탈퇴 처리
        </button>
      </form>
    </div>
  </div>

  <!-- 정보 카드 -->
  <div class="info-cards">
    <!-- 기본 정보 -->
    <div class="info-card">
      <h3>📋 기본 정보</h3>
      <div class="info-row">
        <span class="info-label">환자 ID</span>
        <span class="info-value">${patient.patientId}</span>
      </div>
      <div class="info-row">
        <span class="info-label">이름</span>
        <span class="info-value"><strong>${patient.patientName}</strong></span>
      </div>
      <div class="info-row">
        <span class="info-label">성별</span>
        <span class="info-value">${patient.genderKr}</span>
      </div>
      <div class="info-row">
        <span class="info-label">생년월일</span>
        <span class="info-value">
          <%
            if (((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientDob() != null) {
              out.print(((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientDob().format(dateFormatter));
            } else {
              out.print("-");
            }
          %>
        </span>
      </div>
      <div class="info-row">
        <span class="info-label">나이</span>
        <span class="info-value">${patient.age}세</span>
      </div>
    </div>

    <!-- 연락처 정보 -->
    <div class="info-card">
      <h3>📞 연락처 정보</h3>
      <div class="info-row">
        <span class="info-label">이메일</span>
        <span class="info-value">${patient.patientEmail}</span>
      </div>
      <div class="info-row">
        <span class="info-label">전화번호</span>
        <span class="info-value">${patient.patientPhone}</span>
      </div>
      <div class="info-row">
        <span class="info-label">주소</span>
        <span class="info-value">${patient.patientAddr}</span>
      </div>
    </div>

    <!-- 계정 정보 -->
    <div class="info-card">
      <h3>🔐 계정 정보</h3>
      <div class="info-row">
        <span class="info-label">계정 상태</span>
        <span class="info-value">
          <c:choose>
            <c:when test="${patient.patientAccountStatus == 'active'}">
              <span class="status-badge status-active">활성</span>
            </c:when>
            <c:when test="${patient.patientAccountStatus == 'inactive'}">
              <span class="status-badge status-inactive">비활성</span>
            </c:when>
            <c:when test="${patient.patientAccountStatus == 'withdrawn'}">
              <span class="status-badge status-withdrawn">탈퇴</span>
            </c:when>
          </c:choose>
        </span>
      </div>
      <div class="info-row">
        <span class="info-label">가입일</span>
        <span class="info-value">
          <%
            if (((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientRegdate() != null) {
              out.print(((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientRegdate().format(dateTimeFormatter));
            } else {
              out.print("-");
            }
          %>
        </span>
      </div>
      <div class="info-row">
        <span class="info-label">최종 수정일</span>
        <span class="info-value">
          <%
            if (((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientUpdate() != null) {
              out.print(((edu.sm.app.dto.Patient)request.getAttribute("patient")).getPatientUpdate().format(dateTimeFormatter));
            } else {
              out.print("-");
            }
          %>
        </span>
      </div>
      <div class="info-row">
        <span class="info-label">언어 설정</span>
        <span class="info-value">${patient.languagePreference}</span>
      </div>
    </div>

    <!-- 의료 정보 -->
    <div class="info-card">
      <h3>🏥 의료 정보</h3>
      <div class="info-row">
        <span class="info-label">병력</span>
        <span class="info-value">
          <c:choose>
            <c:when test="${empty patient.patientMedicalHistory}">
              없음
            </c:when>
            <c:otherwise>
              ${patient.patientMedicalHistory}
            </c:otherwise>
          </c:choose>
        </span>
      </div>
    </div>

    <!-- 생활 습관 -->
    <div class="info-card">
      <h3>🏃 생활 습관</h3>
      <div class="info-row">
        <span class="info-label">생활 습관</span>
        <span class="info-value">
          <c:choose>
            <c:when test="${empty patient.patientLifestyleHabits}">
              없음
            </c:when>
            <c:otherwise>
              ${patient.patientLifestyleHabits}
            </c:otherwise>
          </c:choose>
        </span>
      </div>
    </div>

    <!-- OAuth 정보 (있는 경우) -->
    <c:if test="${not empty patient.provider}">
      <div class="info-card">
        <h3>🔗 OAuth 정보</h3>
        <div class="info-row">
          <span class="info-label">로그인 제공자</span>
          <span class="info-value">${patient.provider}</span>
        </div>
        <div class="info-row">
          <span class="info-label">Provider ID</span>
          <span class="info-value">${patient.providerId}</span>
        </div>
      </div>
    </c:if>
  </div>
</div>

<script>
  function confirmDelete() {
    if (confirm('정말로 이 환자의 정보를 삭제하시겠습니까?\n이 작업은 되돌릴 수 없습니다.')) {
      const form = document.createElement('form');
      form.method = 'POST';
      form.action = '<c:url value="/manage/delete/${patient.patientId}"/>';
      document.body.appendChild(form);
      form.submit();
    }
  }

  // 메시지 자동 숨김
  setTimeout(function() {
    const alerts = document.querySelectorAll('.alert');
    alerts.forEach(alert => {
      alert.style.transition = 'opacity 0.5s';
      alert.style.opacity = '0';
      setTimeout(() => alert.remove(), 500);
    });
  }, 3000);
</script>