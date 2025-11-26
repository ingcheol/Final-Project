<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .admin-appointments-container {
    max-width: 1400px;
    margin: 40px auto;
    padding: 30px;
  }

  .page-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 30px;
  }

  .page-title {
    font-size: 28px;
    font-weight: bold;
    color: #333;
  }

  .stats-grid {
    display: grid;
    grid-template-columns: repeat(4, 1fr);
    gap: 20px;
    margin-bottom: 30px;
  }

  .stat-card {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: all 0.3s;
  }

  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 16px rgba(0,0,0,0.15);
  }

  .stat-card.pending { border-left: 4px solid #ffc107; }
  .stat-card.confirmed { border-left: 4px solid #28a745; }
  .stat-card.completed { border-left: 4px solid #17a2b8; }
  .stat-card.cancelled { border-left: 4px solid #dc3545; }

  .stat-label {
    font-size: 14px;
    color: #666;
    margin-bottom: 8px;
  }

  .stat-value {
    font-size: 32px;
    font-weight: bold;
    color: #333;
  }

  .filter-section {
    background: white;
    padding: 20px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 20px;
  }

  .filter-tabs {
    display: flex;
    gap: 10px;
    flex-wrap: wrap;
  }

  .filter-tab {
    padding: 10px 20px;
    border: 2px solid #e0e0e0;
    background: white;
    border-radius: 8px;
    cursor: pointer;
    font-size: 14px;
    font-weight: 500;
    color: #666;
    transition: all 0.3s;
  }

  .filter-tab:hover {
    border-color: #5B6FB5;
    color: #5B6FB5;
  }

  .filter-tab.active {
    background: #5B6FB5;
    border-color: #5B6FB5;
    color: white;
  }

  .appointments-table {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
  }

  .table-responsive {
    overflow-x: auto;
  }

  table {
    width: 100%;
    border-collapse: collapse;
  }

  thead {
    background: #f8f9fa;
  }

  th {
    padding: 16px;
    text-align: left;
    font-size: 13px;
    font-weight: 600;
    color: #495057;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  td {
    padding: 16px;
    border-bottom: 1px solid #e9ecef;
    font-size: 14px;
    color: #333;
  }

  tbody tr {
    transition: background 0.2s;
  }

  tbody tr:hover {
    background: #f8f9fa;
  }

  .status-badge {
    display: inline-block;
    padding: 6px 12px;
    border-radius: 20px;
    font-size: 12px;
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

  .action-buttons {
    display: flex;
    gap: 8px;
  }

  .btn-sm {
    padding: 6px 12px;
    font-size: 12px;
    border: none;
    border-radius: 6px;
    cursor: pointer;
    font-weight: 500;
    transition: all 0.3s;
  }

  .btn-view {
    background: #6c757d;
    color: white;
  }

  .btn-view:hover {
    background: #5a6268;
  }

  .btn-confirm {
    background: #28a745;
    color: white;
  }

  .btn-confirm:hover {
    background: #218838;
  }

  .btn-reject {
    background: #dc3545;
    color: white;
  }

  .btn-reject:hover {
    background: #c82333;
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

  @media (max-width: 1024px) {
    .stats-grid {
      grid-template-columns: repeat(2, 1fr);
    }
  }

  @media (max-width: 768px) {
    .stats-grid {
      grid-template-columns: 1fr;
    }

    .filter-tabs {
      overflow-x: auto;
      white-space: nowrap;
    }
  }
</style>

<div class="admin-appointments-container">
  <div class="page-header">
    <h2 class="page-title">📅 예약 관리</h2>
  </div>

  <c:if test="${not empty message}">
    <div class="alert alert-success">${message}</div>
  </c:if>

  <c:if test="${not empty error}">
    <div class="alert alert-error">${error}</div>
  </c:if>

  <!-- 통계 카드 -->
  <div class="stats-grid">
    <div class="stat-card pending">
      <div class="stat-label">승인 대기</div>
      <div class="stat-value">${pendingCount != null ? pendingCount : 0}</div>
    </div>

    <div class="stat-card confirmed">
      <div class="stat-label">예약 확정</div>
      <div class="stat-value">${confirmedCount != null ? confirmedCount : 0}</div>
    </div>

    <div class="stat-card completed">
      <div class="stat-label">상담 완료</div>
      <div class="stat-value">${completedCount != null ? completedCount : 0}</div>
    </div>

    <div class="stat-card cancelled">
      <div class="stat-label">취소됨</div>
      <div class="stat-value">${cancelledCount != null ? cancelledCount : 0}</div>
    </div>
  </div>

  <!-- 필터 -->
  <div class="filter-section">
    <div class="filter-tabs">
      <button class="filter-tab active" onclick="filterAppointments('all')">전체 보기</button>
      <button class="filter-tab" onclick="filterAppointments('pending')">승인 대기</button>
      <button class="filter-tab" onclick="filterAppointments('confirmed')">예약 확정</button>
      <button class="filter-tab" onclick="filterAppointments('completed')">완료</button>
      <button class="filter-tab" onclick="filterAppointments('cancelled')">취소</button>
    </div>
  </div>

  <!-- 예약 테이블 -->
  <div class="appointments-table">
    <div class="table-responsive">
      <table>
        <thead>
        <tr>
          <th>예약번호</th>
          <th>환자명</th>
          <th>연락처</th>
          <th>예약일시</th>
          <th>상담유형</th>
          <th>상태</th>
          <th>작업</th>
        </tr>
        </thead>
        <tbody id="appointmentTableBody">
        <c:choose>
          <c:when test="${empty appointments}">
            <tr>
              <td colspan="7">
                <div class="empty-state">
                  <div class="empty-state-icon">📭</div>
                  <h3>예약 내역이 없습니다</h3>
                </div>
              </td>
            </tr>
          </c:when>
          <c:otherwise>
            <c:forEach var="apt" items="${appointments}">
              <tr data-status="${apt.status}">
                <td><strong>#${apt.appointmentId}</strong></td>
                <td>${apt.name != null ? apt.name : '정보 없음'}</td>
                <td>${apt.phone != null ? apt.phone : '-'}</td>
                <td>
                  <fmt:formatDate value="${apt.appointmentTime}" pattern="yyyy-MM-dd HH:mm"/>
                </td>
                <td>${apt.appointmentTypeKr}</td>
                <td>
                    <span class="status-badge badge-${apt.status}">
                        ${apt.statusKr}
                    </span>
                </td>
                <td>
                  <div class="action-buttons">
                    <a href="<c:url value='/admin/appointments/${apt.appointmentId}'/>"
                       class="btn-sm btn-view">
                      상세
                    </a>

                    <c:if test="${apt.status == 'pending'}">
                      <form method="post"
                            action="<c:url value='/admin/appointments/${apt.appointmentId}/confirm'/>"
                            style="display:inline;">
                        <button type="submit" class="btn-sm btn-confirm"
                                onclick="return confirm('이 예약을 승인하시겠습니까?');">
                          승인
                        </button>
                      </form>

                      <form method="post"
                            action="<c:url value='/admin/appointments/${apt.appointmentId}/reject'/>"
                            style="display:inline;"
                            onsubmit="return handleReject(event);">
                        <button type="submit" class="btn-sm btn-reject">
                          거절
                        </button>
                      </form>
                    </c:if>
                  </div>
                </td>
              </tr>
            </c:forEach>
          </c:otherwise>
        </c:choose>
        </tbody>
      </table>
    </div>
  </div>
</div>

<script>
  function filterAppointments(status) {
    // 탭 활성화
    document.querySelectorAll('.filter-tab').forEach(tab => {
      tab.classList.remove('active');
    });
    event.target.classList.add('active');

    // 테이블 행 필터링
    const rows = document.querySelectorAll('#appointmentTableBody tr');
    rows.forEach(row => {
      if (status === 'all' || row.dataset.status === status) {
        row.style.display = '';
      } else {
        row.style.display = 'none';
      }
    });
  }

  function handleReject(event) {
    event.preventDefault();

    const reason = prompt('거절 사유를 입력해주세요 (선택사항):');

    if (reason === null) {
      return false; // 취소 클릭
    }

    const form = event.target;
    const input = document.createElement('input');
    input.type = 'hidden';
    input.name = 'reason';
    input.value = reason || '관리자 거절';
    form.appendChild(input);

    form.submit();
    return true;
  }
</script>