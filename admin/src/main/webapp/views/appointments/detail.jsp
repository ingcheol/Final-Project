<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .detail-container {
    max-width: 900px;
    margin: 40px auto;
    padding: 30px;
  }

  .detail-header {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .detail-header-top {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 20px;
  }

  .appointment-id {
    font-size: 24px;
    font-weight: bold;
    color: #333;
  }

  .status-badge {
    padding: 8px 16px;
    border-radius: 20px;
    font-size: 14px;
    font-weight: 600;
  }

  .badge-pending {
    background: #fff3cd;
    color: #856404;
  }

  .badge-confirmed {
    background: #d4edda;
    color: #155724;
  }

  .badge-cancelled {
    background: #f8d7da;
    color: #721c24;
  }

  .badge-completed {
    background: #d1ecf1;
    color: #0c5460;
  }

  .detail-section {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .section-title {
    font-size: 18px;
    font-weight: 600;
    color: #333;
    margin-bottom: 16px;
    padding-bottom: 12px;
    border-bottom: 2px solid #e9ecef;
  }

  .info-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 20px;
  }

  .info-item {
    display: flex;
    flex-direction: column;
    gap: 6px;
  }

  .info-label {
    font-size: 13px;
    font-weight: 600;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .info-value {
    font-size: 15px;
    color: #333;
  }

  .info-value.large {
    font-size: 18px;
    font-weight: 600;
  }

  .notes-box {
    background: #f8f9fa;
    padding: 16px;
    border-radius: 8px;
    border-left: 4px solid #5B6FB5;
    margin-top: 12px;
  }

  .notes-box p {
    margin: 0;
    color: #495057;
    line-height: 1.6;
  }

  .action-section {
    background: white;
    border-radius: 12px;
    padding: 24px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .action-buttons {
    display: flex;
    gap: 12px;
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
  }

  .btn-primary {
    background: #5B6FB5;
    color: white;
  }

  .btn-primary:hover {
    background: #4a5d9d;
  }

  .btn-success {
    background: #28a745;
    color: white;
  }

  .btn-success:hover {
    background: #218838;
  }

  .btn-danger {
    background: #dc3545;
    color: white;
  }

  .btn-danger:hover {
    background: #c82333;
  }

  .btn-secondary {
    background: #6c757d;
    color: white;
  }

  .btn-secondary:hover {
    background: #5a6268;
  }

  .btn-outline {
    background: white;
    color: #5B6FB5;
    border: 2px solid #5B6FB5;
  }

  .btn-outline:hover {
    background: #5B6FB5;
    color: white;
  }

  .back-link {
    display: inline-flex;
    align-items: center;
    gap: 8px;
    color: #5B6FB5;
    text-decoration: none;
    font-weight: 500;
    margin-bottom: 20px;
    transition: all 0.3s;
  }

  .back-link:hover {
    color: #4a5d9d;
  }

  .alert {
    padding: 15px 20px;
    border-radius: 8px;
    margin-bottom: 20px;
    font-size: 14px;
  }

  .alert-success {
    background: #d4edda;
    border: 1px solid #c3e6cb;
    color: #155724;
  }

  .alert-error {
    background: #f8d7da;
    border: 1px solid #f5c6cb;
    color: #721c24;
  }

  @media (max-width: 768px) {
    .info-grid {
      grid-template-columns: 1fr;
    }

    .detail-header-top {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;
    }

    .action-buttons {
      flex-direction: column;
    }

    .btn {
      width: 100%;
    }
  }
</style>

<div class="detail-container">
  <a href="<c:url value='/admin/appointments'/>" class="back-link">
    ← 목록으로 돌아가기
  </a>

  <c:if test="${not empty message}">
    <div class="alert alert-success">${message}</div>
  </c:if>

  <c:if test="${not empty error}">
    <div class="alert alert-error">${error}</div>
  </c:if>

  <!-- 헤더 -->
  <div class="detail-header">
    <div class="detail-header-top">
      <div class="appointment-id">예약 #${appointment.appointmentId}</div>
      <span class="status-badge badge-${appointment.status}">
        ${appointment.statusKr}
      </span>
    </div>
  </div>

  <!-- 환자 정보 -->
  <div class="detail-section">
    <h3 class="section-title">👤 환자 정보</h3>
    <div class="info-grid">
      <div class="info-item">
        <div class="info-label">환자 ID</div>
        <div class="info-value">#${appointment.patientId}</div>
      </div>

      <div class="info-item">
        <div class="info-label">환자명</div>
        <div class="info-value">${appointment.name != null ? appointment.name : '정보 없음'}</div>
      </div>

      <div class="info-item">
        <div class="info-label">연락처</div>
        <div class="info-value">${appointment.phone != null ? appointment.phone : '정보 없음'}</div>
      </div>

      <div class="info-item">
        <div class="info-label">이메일</div>
        <div class="info-value">${appointment.email != null ? appointment.email : '정보 없음'}</div>
      </div>
    </div>
  </div>

  <!-- 예약 정보 -->
  <div class="detail-section">
    <h3 class="section-title">📅 예약 정보</h3>
    <div class="info-grid">
      <div class="info-item">
        <div class="info-label">예약 일시</div>
        <div class="info-value large">
          ${appointment.formattedDateTimeWithDay}
        </div>
      </div>

      <div class="info-item">
        <div class="info-label">상담 유형</div>
        <div class="info-value large">${appointment.appointmentTypeKr}</div>
      </div>
    </div>

    <c:if test="${not empty appointment.notes}">
      <div class="notes-box">
        <strong>📝 환자 메모:</strong>
        <p>${appointment.notes}</p>
      </div>
    </c:if>
  </div>

  <!-- 액션 버튼 -->
  <div class="action-section">
    <h3 class="section-title">⚙️ 관리 작업</h3>
    <div class="action-buttons">

      <!-- 승인 대기 상태일 때 -->
      <c:if test="${appointment.status == 'pending'}">
        <form method="post" action="<c:url value='/admin/appointments/${appointment.appointmentId}/confirm'/>" style="display:inline;">
          <button type="submit" class="btn btn-success" onclick="return confirm('이 예약을 승인하시겠습니까?');">
            ✅ 예약 승인
          </button>
        </form>

        <button type="button" class="btn btn-danger" onclick="handleReject()">
          ❌ 예약 거절
        </button>
      </c:if>

      <!-- 예약 확정 상태일 때 -->
      <c:if test="${appointment.status == 'confirmed'}">
        <a href="<c:url value='/consultation?appointmentId=${appointment.appointmentId}'/>" class="btn btn-primary">
          🎥 상담 시작
        </a>

        <form method="post" action="<c:url value='/admin/appointments/${appointment.appointmentId}/complete'/>" style="display:inline;">
          <button type="submit" class="btn btn-success" onclick="return confirm('상담을 완료 처리하시겠습니까?');">
            ✔️ 상담 완료
          </button>
        </form>
      </c:if>

      <!-- 공통 버튼 -->
      <a href="<c:url value='/admin/appointments/${appointment.appointmentId}/edit'/>" class="btn btn-outline">
        ✏️ 정보 수정
      </a>

      <c:if test="${sessionScope.admin != null}">
        <form method="post"
              action="<c:url value='/admin/appointments/${appointment.appointmentId}/delete'/>"
              style="display:inline;"
              onsubmit="return confirm('정말 이 예약을 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.');">
          <button type="submit" class="btn btn-secondary">
            🗑️ 예약 삭제
          </button>
        </form>
      </c:if>
    </div>
  </div>
</div>

<!-- 거절 폼 (숨김) -->
<form id="rejectForm" method="post" action="<c:url value='/admin/appointments/${appointment.appointmentId}/reject'/>" style="display:none;">
  <input type="hidden" name="reason" id="rejectReason">
</form>

<script>
  function handleReject() {
    const reason = prompt('거절 사유를 입력해주세요 (선택사항):');

    if (reason === null) {
      return; // 취소 클릭
    }

    document.getElementById('rejectReason').value = reason || '관리자 거절';
    document.getElementById('rejectForm').submit();
  }
</script>