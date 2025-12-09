<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<style>
  .emr-container {
    max-width: 1400px;
    margin: 40px auto;
    padding: 0 30px;
  }

  .page-header {
    margin-bottom: 32px;
  }

  .page-title {
    font-size: 28px;
    font-weight: 700;
    color: #333;
    margin-bottom: 8px;
  }

  .page-subtitle {
    font-size: 15px;
    color: #666;
  }

  .emr-card {
    background: white;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    overflow: hidden;
  }

  .card-header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 20px 24px;
    color: white;
  }

  .card-header-content {
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  .card-title {
    font-size: 18px;
    font-weight: 600;
    margin: 0;
    display: flex;
    align-items: center;
    gap: 10px;
  }

  .count-badge {
    background: rgba(255,255,255,0.25);
    padding: 4px 12px;
    border-radius: 12px;
    font-size: 13px;
    font-weight: 500;
  }

  .emr-table {
    width: 100%;
    border-collapse: collapse;
  }

  .emr-table thead {
    background: #f8f9fa;
    border-bottom: 2px solid #e9ecef;
  }

  .emr-table th {
    padding: 16px 20px;
    text-align: left;
    font-size: 13px;
    font-weight: 600;
    color: #666;
    text-transform: uppercase;
    letter-spacing: 0.5px;
  }

  .emr-table th.center {
    text-align: center;
  }

  .emr-table tbody tr {
    border-bottom: 1px solid #f0f0f0;
    transition: all 0.2s;
  }

  .emr-table tbody tr:hover {
    background: #f8f9ff;
  }

  .emr-table td {
    padding: 18px 20px;
    font-size: 14px;
    color: #333;
  }

  .emr-table td.center {
    text-align: center;
  }

  .emr-id-badge {
    display: inline-block;
    background: #e3f2fd;
    color: #1976d2;
    padding: 6px 12px;
    border-radius: 6px;
    font-weight: 600;
    font-size: 13px;
  }

  .patient-link {
    color: #667eea;
    text-decoration: none;
    font-weight: 600;
    transition: all 0.2s;
    display: inline-flex;
    align-items: center;
    gap: 4px;
  }

  .patient-link:hover {
    color: #5568d3;
    text-decoration: underline;
  }

  .consultation-id {
    color: #666;
    font-size: 13px;
  }

  .date-cell {
    display: flex;
    flex-direction: column;
    gap: 2px;
  }

  .date-main {
    font-weight: 600;
    color: #333;
  }

  .date-time {
    font-size: 12px;
    color: #999;
  }

  .btn-detail {
    display: inline-flex;
    align-items: center;
    gap: 6px;
    padding: 10px 20px;
    background: #667eea;
    color: white;
    border: none;
    border-radius: 8px;
    font-size: 13px;
    font-weight: 600;
    text-decoration: none;
    cursor: pointer;
    transition: all 0.3s;
  }

  .btn-detail:hover {
    background: #5568d3;
    transform: translateY(-1px);
    box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
  }

  .empty-state {
    text-align: center;
    padding: 60px 20px;
  }

  .empty-icon {
    font-size: 48px;
    margin-bottom: 16px;
    opacity: 0.5;
  }

  .empty-text {
    font-size: 16px;
    color: #999;
  }

  @media (max-width: 768px) {
    .emr-container {
      padding: 0 15px;
    }

    .emr-table {
      font-size: 13px;
    }

    .emr-table th,
    .emr-table td {
      padding: 12px 10px;
    }
  }
</style>

<div class="emr-container">
  <div class="page-header">
    <h1 class="page-title">📋 EMR 관리</h1>
    <p class="page-subtitle">전자의무기록 조회 및 관리</p>
  </div>

  <div class="emr-card">
    <div class="card-header">
      <div class="card-header-content">
        <h2 class="card-title">
          📄 EMR 기록 목록
        </h2>
        <span class="count-badge">총 ${emrs.size()}건</span>
      </div>
    </div>

    <c:choose>
      <c:when test="${empty emrs}">
        <div class="empty-state">
          <div class="empty-icon">📭</div>
          <p class="empty-text">등록된 EMR 기록이 없습니다.</p>
        </div>
      </c:when>
      <c:otherwise>
        <table class="emr-table">
          <thead>
          <tr>
            <th class="center" style="width: 12%">EMR ID</th>
            <th class="center" style="width: 12%">환자 ID</th>
            <th class="center" style="width: 12%">상담 ID</th>
            <th style="width: 20%">생성일시</th>
            <th style="width: 20%">최종 수정일</th>
            <th class="center" style="width: 14%">관리</th>
          </tr>
          </thead>
          <tbody>
          <c:forEach var="e" items="${emrs}">
            <tr>
              <td class="center">
                <span class="emr-id-badge">#${e.emrId}</span>
              </td>
              <td class="center">
                <a href="/admin/patient/detail?id=${e.patientId}" class="patient-link">
                    ${e.patientId}
                  <svg width="12" height="12" viewBox="0 0 12 12" fill="none">
                    <path d="M10 6.5V10C10 10.55 9.55 11 9 11H2C1.45 11 1 10.55 1 10V3C1 2.45 1.45 2 2 2H5.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                    <path d="M7 1H11V5M10.5 1.5L5.5 6.5" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                  </svg>
                </a>
              </td>
              <td class="center">
                <span class="consultation-id">${e.consultationId}</span>
              </td>
              <td>
                <fmt:parseDate value="${e.createdAt}" pattern="yyyy-MM-dd'T'HH:mm:ss"
                               var="parsedCreatedAt" type="both" />
                <div class="date-cell">
                    <span class="date-main">
                      <fmt:formatDate value="${parsedCreatedAt}" pattern="yyyy년 MM월 dd일" />
                    </span>
                  <span class="date-time">
                      <fmt:formatDate value="${parsedCreatedAt}" pattern="HH:mm" />
                    </span>
                </div>
              </td>
              <td>
                <fmt:parseDate value="${e.updatedAt}" pattern="yyyy-MM-dd'T'HH:mm:ss"
                               var="parsedUpdatedAt" type="both" />
                <div class="date-cell">
                    <span class="date-main">
                      <fmt:formatDate value="${parsedUpdatedAt}" pattern="yyyy년 MM월 dd일" />
                    </span>
                  <span class="date-time">
                      <fmt:formatDate value="${parsedUpdatedAt}" pattern="HH:mm" />
                    </span>
                </div>
              </td>
              <td class="center">
                <a href="/admin/emr/detail?id=${e.emrId}" class="btn-detail">
                  👁️ 상세보기
                </a>
              </td>
            </tr>
          </c:forEach>
          </tbody>
        </table>
      </c:otherwise>
    </c:choose>
  </div>
</div>