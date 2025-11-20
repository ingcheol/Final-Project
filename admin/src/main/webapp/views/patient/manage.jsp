<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
  .manage-container {
    max-width: 1400px;
    margin: 20px auto;
    padding: 20px;
  }

  .manage-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 10px;
    margin-bottom: 30px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  }

  .manage-header h2 {
    margin: 0 0 10px 0;
    font-size: 28px;
  }

  .manage-header p {
    margin: 0;
    opacity: 0.9;
  }

  /* 검색 및 필터 영역 */
  .search-filter-box {
    background: white;
    padding: 25px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    margin-bottom: 30px;
  }

  .search-row {
    display: flex;
    gap: 15px;
    align-items: center;
    flex-wrap: wrap;
  }

  .search-input {
    flex: 1;
    min-width: 250px;
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.3s;
  }

  .search-input:focus {
    outline: none;
    border-color: #667eea;
  }

  .status-filter {
    padding: 12px 15px;
    border: 2px solid #e0e0e0;
    border-radius: 8px;
    font-size: 14px;
    cursor: pointer;
    min-width: 150px;
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

  .btn-success {
    background: #10b981;
    color: white;
  }

  .btn-warning {
    background: #f59e0b;
    color: white;
  }

  .btn-danger {
    background: #ef4444;
    color: white;
  }

  .btn-sm {
    padding: 8px 16px;
    font-size: 13px;
  }

  /* 통계 카드 */
  .stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
  }

  .stat-card {
    background: white;
    padding: 20px;
    border-radius: 10px;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    border-left: 4px solid;
  }

  .stat-card.total {
    border-left-color: #667eea;
  }

  .stat-card.active {
    border-left-color: #10b981;
  }

  .stat-card.inactive {
    border-left-color: #f59e0b;
  }

  .stat-card.withdrawn {
    border-left-color: #ef4444;
  }

  .stat-label {
    color: #6b7280;
    font-size: 13px;
    margin-bottom: 5px;
  }

  .stat-value {
    font-size: 28px;
    font-weight: bold;
    color: #1f2937;
  }

  /* 테이블 스타일 */
  .patient-table {
    background: white;
    border-radius: 10px;
    overflow: hidden;
    box-shadow: 0 2px 4px rgba(0,0,0,0.1);
  }

  .patient-table table {
    width: 100%;
    border-collapse: collapse;
  }

  .patient-table thead {
    background: #f9fafb;
    border-bottom: 2px solid #e5e7eb;
  }

  .patient-table th {
    padding: 15px;
    text-align: left;
    font-weight: 600;
    color: #374151;
    font-size: 14px;
  }

  .patient-table td {
    padding: 15px;
    border-bottom: 1px solid #f3f4f6;
    font-size: 14px;
  }

  .patient-table tbody tr:hover {
    background: #f9fafb;
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

  /* 액션 버튼 그룹 */
  .action-buttons {
    display: flex;
    gap: 8px;
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

  /* 빈 상태 */
  .empty-state {
    text-align: center;
    padding: 60px 20px;
    color: #6b7280;
  }

  .empty-state i {
    font-size: 48px;
    margin-bottom: 15px;
    opacity: 0.5;
  }
</style>

<div class="manage-container">
  <!-- 헤더 -->
  <div class="manage-header">
    <h2>🏥 환자 관리</h2>
    <p>등록된 환자의 정보를 조회하고 관리합니다</p>
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

  <!-- 통계 카드 -->
  <div class="stats-container">
    <div class="stat-card total">
      <div class="stat-label">전체 환자</div>
      <div class="stat-value">${patients.size()}</div>
    </div>
    <div class="stat-card active">
      <div class="stat-label">활성 환자</div>
      <div class="stat-value">
        <c:set var="activeCount" value="0"/>
        <c:forEach items="${patients}" var="p">
          <c:if test="${p.patientAccountStatus == 'active'}">
            <c:set var="activeCount" value="${activeCount + 1}"/>
          </c:if>
        </c:forEach>
        ${activeCount}
      </div>
    </div>
    <div class="stat-card inactive">
      <div class="stat-label">비활성 환자</div>
      <div class="stat-value">
        <c:set var="inactiveCount" value="0"/>
        <c:forEach items="${patients}" var="p">
          <c:if test="${p.patientAccountStatus == 'inactive'}">
            <c:set var="inactiveCount" value="${inactiveCount + 1}"/>
          </c:if>
        </c:forEach>
        ${inactiveCount}
      </div>
    </div>
    <div class="stat-card withdrawn">
      <div class="stat-label">탈퇴 환자</div>
      <div class="stat-value">
        <c:set var="withdrawnCount" value="0"/>
        <c:forEach items="${patients}" var="p">
          <c:if test="${p.patientAccountStatus == 'withdrawn'}">
            <c:set var="withdrawnCount" value="${withdrawnCount + 1}"/>
          </c:if>
        </c:forEach>
        ${withdrawnCount}
      </div>
    </div>
  </div>

  <!-- 검색 및 필터 -->
  <div class="search-filter-box">
    <form action="<c:url value='/manage/search'/>" method="get">
      <div class="search-row">
        <input type="text" name="keyword" class="search-input"
               placeholder="이름, 이메일, 전화번호로 검색..."
               value="${keyword}">

        <select name="status" class="status-filter">
          <option value="all" ${status == 'all' ? 'selected' : ''}>전체 상태</option>
          <option value="active" ${status == 'active' ? 'selected' : ''}>활성</option>
          <option value="inactive" ${status == 'inactive' ? 'selected' : ''}>비활성</option>
          <option value="withdrawn" ${status == 'withdrawn' ? 'selected' : ''}>탈퇴</option>
        </select>

        <button type="submit" class="btn btn-primary">
          🔍 검색
        </button>

        <button type="button" class="btn btn-success" onclick="location.href='<c:url value="/manage"/>'">
          🔄 전체 목록
        </button>
      </div>
    </form>
  </div>

  <!-- 환자 테이블 -->
  <div class="patient-table">
    <c:choose>
      <c:when test="${empty patients}">
        <div class="empty-state">
          <i>📋</i>
          <h3>등록된 환자가 없습니다</h3>
          <p>검색 조건을 변경하거나 새로운 환자를 등록해주세요.</p>
        </div>
      </c:when>
      <c:otherwise>
        <table>
          <thead>
          <tr>
            <th>ID</th>
            <th>이름</th>
            <th>이메일</th>
            <th>전화번호</th>
            <th>성별</th>
            <th>나이</th>
            <th>계정상태</th>
            <th>가입일</th>
            <th>관리</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach items="${patients}" var="patient">
            <tr>
              <td>${patient.patientId}</td>
              <td><strong>${patient.patientName}</strong></td>
              <td>${patient.patientEmail}</td>
              <td>${patient.patientPhone}</td>
              <td>${patient.genderKr}</td>
              <td>${patient.age}세</td>
              <td>
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
              </td>
              <td>
                <%-- LocalDateTime을 JSTL fmt 태그에서 사용하기 위해 파싱 후 포맷팅 --%>
                <fmt:parseDate value="${patient.patientRegdate}" pattern="yyyy-MM-dd'T'HH:mm:ss" var="parsedDate" type="both" />
                <fmt:formatDate value="${parsedDate}" pattern="yyyy-MM-dd" />
              </td>
              <td>
                <div class="action-buttons">
                  <button class="btn btn-primary btn-sm"
                          onclick="location.href='<c:url value="/manage/${patient.patientId}"/>'">
                    📋 상세
                  </button>
                  <button class="btn btn-warning btn-sm"
                          onclick="location.href='<c:url value="/manage/edit/${patient.patientId}"/>'">
                    ✏️ 수정
                  </button>
                </div>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </c:otherwise>
    </c:choose>
  </div>
</div>

<script>
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