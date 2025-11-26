<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .my-appointments-container {
    max-width: 1200px;
    margin: 40px auto;
    padding: 30px;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
  }

  .page-header h2 {
    font-size: 28px;
    color: #333;
  }

  .btn-new-appointment {
    padding: 12px 24px;
    background: #5B6FB5;
    color: white;
    text-decoration: none;
    border-radius: 8px;
    font-weight: 600;
    transition: all 0.3s;
  }

  .btn-new-appointment:hover {
    background: #4a5d9d;
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(91, 111, 181, 0.3);
  }

  .status-tabs {
    display: flex;
    gap: 10px;
    margin-bottom: 20px;
    border-bottom: 2px solid #e0e0e0;
  }

  .status-tab {
    padding: 12px 24px;
    background: none;
    border: none;
    border-bottom: 3px solid transparent;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    color: #666;
    transition: all 0.3s;
  }

  .status-tab.active {
    color: #5B6FB5;
    border-bottom-color: #5B6FB5;
  }

  .appointment-card {
    background: white;
    border-radius: 12px;
    padding: 24px;
    margin-bottom: 20px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: all 0.3s;
  }

  .appointment-card:hover {
    box-shadow: 0 4px 16px rgba(0,0,0,0.15);
    transform: translateY(-2px);
  }

  .appointment-header-row {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
  }

  .appointment-time {
    display: flex;
    align-items: center;
    gap: 8px;
    font-size: 18px;
    font-weight: 600;
    color: #333;
  }

  .status-badge {
    padding: 6px 16px;
    border-radius: 20px;
    font-size: 13px;
    font-weight: 600;
  }

  .status-pending {
    background: #fff3cd;
    color: #856404;
  }

  .status-confirmed {
    background: #d4edda;
    color: #155724;
  }

  .status-cancelled {
    background: #f8d7da;
    color: #721c24;
  }

  .status-completed {
    background: #d1ecf1;
    color: #0c5460;
  }

  .appointment-info {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 15px;
    margin-bottom: 15px;
  }

  .info-item {
    display: flex;
    align-items: center;
    gap: 8px;
    color: #666;
    font-size: 14px;
  }

  .appointment-notes {
    background: #f8f9fa;
    padding: 12px;
    border-radius: 6px;
    color: #666;
    font-size: 14px;
    line-height: 1.6;
    margin-bottom: 15px;
  }

  .appointment-actions {
    display: flex;
    gap: 10px;
  }

  .btn-action {
    padding: 8px 16px;
    border: none;
    border-radius: 6px;
    font-size: 13px;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.3s;
  }

  .btn-detail {
    background: #e9ecef;
    color: #495057;
  }

  .btn-detail:hover {
    background: #dee2e6;
  }

  .btn-cancel {
    background: #dc3545;
    color: white;
  }

  .btn-cancel:hover {
    background: #c82333;
  }

  .btn-join {
    background: #5B6FB5;
    color: white;
  }

  .btn-join:hover {
    background: #4a5d9d;
  }

  .empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #999;
  }

  .empty-state-icon {
    font-size: 64px;
    margin-bottom: 20px;
  }

  .empty-state h3 {
    font-size: 20px;
    color: #666;
    margin-bottom: 10px;
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
    .appointment-info {
      grid-template-columns: 1fr;
    }

    .page-header {
      flex-direction: column;
      align-items: flex-start;
      gap: 15px;
    }

    .status-tabs {
      overflow-x: auto;
      white-space: nowrap;
    }
  }
</style>

<div class="my-appointments-container">
  <div class="page-header">
    <h2>📅 내 예약 관리</h2>
    <a href="<c:url value='/appointment/new'/>" class="btn-new-appointment">+ 새 예약 신청</a>
  </div>

  <c:if test="${not empty message}">
    <div class="alert alert-success">${message}</div>
  </c:if>

  <c:if test="${not empty error}">
    <div class="alert alert-error">${error}</div>
  </c:if>

  <!-- 상태별 필터 탭 -->
  <div class="status-tabs">
    <button class="status-tab active" onclick="filterAppointments('all')">전체</button>
    <button class="status-tab" onclick="filterAppointments('pending')">승인 대기</button>
    <button class="status-tab" onclick="filterAppointments('confirmed')">예약 확정</button>
    <button class="status-tab" onclick="filterAppointments('completed')">완료</button>
    <button class="status-tab" onclick="filterAppointments('cancelled')">취소</button>
  </div>

  <!-- 예약 목록 -->
  <div id="appointmentList">
    <c:choose>
      <c:when test="${empty appointments}">
        <div class="empty-state">
          <div class="empty-state-icon">📭</div>
          <h3>예약 내역이 없습니다</h3>
          <p>새로운 상담 예약을 신청해보세요!</p>
        </div>
      </c:when>
      <c:otherwise>
        <c:forEach var="apt" items="${appointments}">
          <div class="appointment-card" data-status="${apt.status}">
            <div class="appointment-header-row">
              <div class="appointment-time">
                🕐 ${apt.formattedDateTime}
              </div>
              <span class="status-badge status-${apt.status}">${apt.statusKr}</span>
            </div>

            <div class="appointment-info">
              <div class="info-item">
                <span>📋</span>
                <span>상담 유형: ${apt.appointmentTypeKr}</span>
              </div>
              <div class="info-item">
                <span>🆔</span>
                <span>예약 번호: #${apt.appointmentId}</span>
              </div>
            </div>

            <c:if test="${not empty apt.notes}">
              <div class="appointment-notes">
                <strong>메모:</strong> ${apt.notes}
              </div>
            </c:if>

            <div class="appointment-actions">


              <c:if test="${apt.status == 'confirmed'}">
                <a href="<c:url value='/consul?appointmentId=${apt.appointmentId}'/>"
                   class="btn-action btn-join">
                  상담 시작
                </a>
              </c:if>

              <c:if test="${apt.status == 'pending' || apt.status == 'confirmed'}">
                <form method="post" action="<c:url value='/appointment/cancel/${apt.appointmentId}'/>"
                      style="display:inline;"
                      onsubmit="return confirm('정말 예약을 취소하시겠습니까?');">
                  <button type="submit" class="btn-action btn-cancel">예약 취소</button>
                </form>
              </c:if>
            </div>
          </div>
        </c:forEach>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
  function filterAppointments(status) {
    // 탭 활성화
    document.querySelectorAll('.status-tab').forEach(tab => {
      tab.classList.remove('active');
    });
    event.target.classList.add('active');

    // 카드 필터링
    const cards = document.querySelectorAll('.appointment-card');
    cards.forEach(card => {
      if (status === 'all' || card.dataset.status === status) {
        card.style.display = 'block';
      } else {
        card.style.display = 'none';
      }
    });
  }
</script>