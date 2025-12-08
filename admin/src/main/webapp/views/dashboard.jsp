<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
  .dashboard-container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
  }

  /* 환영 배너 */
  .welcome-banner {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 30px;
    border-radius: 12px;
    margin-bottom: 30px;
    box-shadow: 0 4px 6px rgba(0,0,0,0.1);
  }

  .welcome-banner h1 {
    margin: 0 0 10px 0;
    font-size: 32px;
    font-weight: bold;
  }

  .welcome-banner p {
    margin: 0;
    font-size: 16px;
    opacity: 0.9;
  }

  /* 통계 카드 그리드 */
  .stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 20px;
    margin-bottom: 30px;
  }

  .stat-card {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    border-left: 4px solid;
    transition: transform 0.3s, box-shadow 0.3s;
  }

  .stat-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  }

  .stat-card.primary { border-left-color: #667eea; }
  .stat-card.success { border-left-color: #10b981; }
  .stat-card.warning { border-left-color: #f59e0b; }
  .stat-card.danger { border-left-color: #ef4444; }

  .stat-icon {
    font-size: 36px;
    margin-bottom: 12px;
  }

  .stat-label {
    font-size: 14px;
    color: #6b7280;
    margin-bottom: 8px;
  }

  .stat-value {
    font-size: 32px;
    font-weight: bold;
    color: #1f2937;
    margin-bottom: 8px;
  }

  .stat-change {
    font-size: 13px;
    font-weight: 500;
  }

  .stat-change.up { color: #10b981; }
  .stat-change.down { color: #ef4444; }

  /* 빠른 액션 */
  .quick-actions {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    margin-bottom: 30px;
  }

  .section-title {
    font-size: 18px;
    font-weight: 600;
    color: #1f2937;
    margin-bottom: 16px;
  }

  .action-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 15px;
  }

  .action-btn {
    padding: 20px;
    border: 2px solid #e5e7eb;
    border-radius: 10px;
    background: white;
    cursor: pointer;
    transition: all 0.3s;
    text-align: center;
    text-decoration: none;
    color: inherit;
    display: block;
  }

  .action-btn:hover {
    border-color: #667eea;
    background: #f9fafb;
    transform: scale(1.05);
  }

  .action-icon {
    font-size: 32px;
    margin-bottom: 8px;
  }

  .action-label {
    font-size: 14px;
    font-weight: 500;
    color: #374151;
  }

  /* 콘텐츠 그리드 */
  .content-grid {
    display: grid;
    grid-template-columns: 2fr 1fr;
    gap: 20px;
    margin-bottom: 30px;
  }

  @media (max-width: 1024px) {
    .content-grid {
      grid-template-columns: 1fr;
    }
  }

  /* 최근 활동 */
  .recent-activity {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .activity-list {
    display: flex;
    flex-direction: column;
    gap: 16px;
  }

  .activity-item {
    display: flex;
    gap: 12px;
    padding: 12px;
    border-radius: 8px;
    border: 1px solid #e5e7eb;
    transition: background 0.2s;
  }

  .activity-item:hover {
    background: #f9fafb;
  }

  .activity-icon {
    width: 40px;
    height: 40px;
    border-radius: 8px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 20px;
    flex-shrink: 0;
  }

  .activity-icon.primary { background: #eef2ff; }
  .activity-icon.success { background: #d1fae5; }
  .activity-icon.warning { background: #fef3c7; }

  .activity-content {
    flex: 1;
  }

  .activity-title {
    font-size: 14px;
    font-weight: 500;
    color: #1f2937;
    margin-bottom: 4px;
  }

  .activity-time {
    font-size: 12px;
    color: #6b7280;
  }

  /* 알림 패널 */
  .alerts-panel {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
  }

  .alert-item {
    padding: 12px;
    border-radius: 8px;
    margin-bottom: 12px;
    border-left: 4px solid;
  }

  .alert-item.warning {
    background: #fef3c7;
    border-left-color: #f59e0b;
  }

  .alert-item.danger {
    background: #fee2e2;
    border-left-color: #ef4444;
  }

  .alert-item.info {
    background: #dbeafe;
    border-left-color: #3b82f6;
  }

  .alert-title {
    font-size: 14px;
    font-weight: 600;
    margin-bottom: 4px;
  }

  .alert-text {
    font-size: 13px;
    color: #4b5563;
  }

  /* 차트 컨테이너 */
  .chart-container {
    background: white;
    padding: 24px;
    border-radius: 12px;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    height: 400px;
    margin-bottom: 30px;
  }

  .chart-wrapper {
    height: calc(100% - 40px);
    position: relative;
  }
</style>

<div class="dashboard-container">
  <!-- 환영 배너 -->
  <div class="welcome-banner">
    <h1>안녕하세요,
      <c:choose>
        <c:when test="${not empty sessionScope.admin}">
          ${sessionScope.admin.name} 관리자님
        </c:when>
        <c:otherwise>
          ${sessionScope.adviser.name} 상담사님
        </c:otherwise>
      </c:choose>
    </h1>
    <p>오늘도 환자 관리에 최선을 다해주셔서 감사합니다.</p>
  </div>

  <!-- 통계 카드 -->
  <div class="stats-grid">
    <div class="stat-card primary">
      <div class="stat-icon">📅</div>
      <div class="stat-label">오늘의 예약</div>
      <div class="stat-value">12</div>
      <div class="stat-change up">↑ 전일 대비 +3</div>
    </div>

    <div class="stat-card warning">
      <div class="stat-icon">⏰</div>
      <div class="stat-label">승인 대기</div>
      <div class="stat-value">5</div>
      <div class="stat-change">신규 예약 요청</div>
    </div>

    <div class="stat-card success">
      <div class="stat-icon">✅</div>
      <div class="stat-label">완료된 상담</div>
      <div class="stat-value">38</div>
      <div class="stat-change up">↑ 이번 주 +12</div>
    </div>

    <div class="stat-card danger">
      <div class="stat-icon">🚨</div>
      <div class="stat-label">긴급 알림</div>
      <div class="stat-value">2</div>
      <div class="stat-change">확인 필요</div>
    </div>
  </div>

  <!-- 빠른 액션 -->
  <div class="quick-actions">
    <h3 class="section-title">빠른 작업</h3>
    <div class="action-grid">
      <a href="<c:url value='/consultation'/>" class="action-btn">
        <div class="action-icon">🎥</div>
        <div class="action-label">상담 시작</div>
      </a>

      <a href="<c:url value='/admin/appointments'/>" class="action-btn">
        <div class="action-icon">📋</div>
        <div class="action-label">예약 관리</div>
      </a>

      <a href="<c:url value='/manage'/>" class="action-btn">
        <div class="action-icon">👥</div>
        <div class="action-label">환자 조회</div>
      </a>

      <a href="<c:url value='/admin/signlanguage'/>" class="action-btn">
        <div class="action-icon">👌</div>
        <div class="action-label">수어 번역</div>
      </a>
    </div>
  </div>

  <!-- 콘텐츠 그리드 -->
  <div class="content-grid">
    <!-- 최근 활동 -->
    <div class="recent-activity">
      <h3 class="section-title">최근 활동</h3>
      <div class="activity-list">
        <div class="activity-item">
          <div class="activity-icon success">✅</div>
          <div class="activity-content">
            <div class="activity-title">김철수 님 화상 상담 완료</div>
            <div class="activity-time">10분 전</div>
          </div>
        </div>

        <div class="activity-item">
          <div class="activity-icon warning">📅</div>
          <div class="activity-content">
            <div class="activity-title">이영희 님 예약 승인 대기</div>
            <div class="activity-time">30분 전</div>
          </div>
        </div>

        <div class="activity-item">
          <div class="activity-icon primary">📋</div>
          <div class="activity-content">
            <div class="activity-title">박민수 님 EMR 작성 완료</div>
            <div class="activity-time">1시간 전</div>
          </div>
        </div>

        <div class="activity-item">
          <div class="activity-icon success">👤</div>
          <div class="activity-content">
            <div class="activity-title">신규 환자 등록 (정수진 님)</div>
            <div class="activity-time">2시간 전</div>
          </div>
        </div>

        <div class="activity-item">
          <div class="activity-icon primary">💬</div>
          <div class="activity-content">
            <div class="activity-title">최유리 님 채팅 상담 완료</div>
            <div class="activity-time">3시간 전</div>
          </div>
        </div>
      </div>
    </div>

    <!-- 알림 패널 -->
    <div class="alerts-panel">
      <h3 class="section-title">알림</h3>

      <div class="alert-item danger">
        <div class="alert-title">🚨 긴급 알림</div>
        <div class="alert-text">김철수 님 심박수 이상 감지</div>
      </div>

      <div class="alert-item warning">
        <div class="alert-title">⏰ 예약 알림</div>
        <div class="alert-text">30분 후 이영희 님 화상 상담</div>
      </div>

      <div class="alert-item info">
        <div class="alert-title">📢 시스템 공지</div>
        <div class="alert-text">시스템 업데이트 예정 (오후 11시)</div>
      </div>

      <div class="alert-item warning">
        <div class="alert-title">📋 승인 요청</div>
        <div class="alert-text">5건의 예약이 승인을 기다리고 있습니다</div>
      </div>
    </div>
  </div>

  <!-- 차트 영역 -->
  <div class="chart-container">
    <h3 class="section-title">이번 주 상담 추이</h3>
    <div class="chart-wrapper">
      <canvas id="consultationChart"></canvas>
    </div>
  </div>
</div>

<!-- Chart.js 라이브러리 CDN -->
<script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>

<script>
  let consultationChart;

  // 차트 초기화
  function initChart() {
    const ctx = document.getElementById('consultationChart');

    consultationChart = new Chart(ctx, {
      type: 'line',
      data: {
        labels: ['월요일', '화요일', '수요일', '목요일', '금요일', '토요일', '일요일'],
        datasets: [{
          label: '완료된 상담',
          data: [12, 19, 15, 25, 22, 18, 20],
          borderColor: '#667eea',
          backgroundColor: 'rgba(102, 126, 234, 0.1)',
          tension: 0.4,
          fill: true,
          pointBackgroundColor: '#667eea',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 5,
          pointHoverRadius: 7
        }, {
          label: '예약된 상담',
          data: [8, 12, 10, 15, 14, 11, 13],
          borderColor: '#10b981',
          backgroundColor: 'rgba(16, 185, 129, 0.1)',
          tension: 0.4,
          fill: true,
          pointBackgroundColor: '#10b981',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 5,
          pointHoverRadius: 7
        }, {
          label: '취소된 상담',
          data: [2, 3, 4, 2, 3, 2, 1],
          borderColor: '#ef4444',
          backgroundColor: 'rgba(239, 68, 68, 0.1)',
          tension: 0.4,
          fill: true,
          pointBackgroundColor: '#ef4444',
          pointBorderColor: '#fff',
          pointBorderWidth: 2,
          pointRadius: 5,
          pointHoverRadius: 7
        }]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: true,
            position: 'top',
            labels: {
              usePointStyle: true,
              padding: 15,
              font: {
                size: 12
              }
            }
          },
          tooltip: {
            mode: 'index',
            intersect: false,
            backgroundColor: 'rgba(0, 0, 0, 0.8)',
            titleColor: '#fff',
            bodyColor: '#fff',
            borderColor: '#667eea',
            borderWidth: 1,
            padding: 12,
            displayColors: true,
            callbacks: {
              label: function(context) {
                return context.dataset.label + ': ' + context.parsed.y + '건';
              }
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 5,
              callback: function(value) {
                return value + '건';
              }
            },
            grid: {
              color: 'rgba(0, 0, 0, 0.05)'
            }
          },
          x: {
            grid: {
              display: false
            }
          }
        },
        interaction: {
          mode: 'nearest',
          axis: 'x',
          intersect: false
        },
        animation: {
          duration: 1000,
          easing: 'easeInOutQuart'
        }
      }
    });
  }

  // 실시간 데이터 업데이트 (시뮬레이션)
  function updateChartData() {
    if (!consultationChart) return;

    // 랜덤하게 데이터 업데이트
    consultationChart.data.datasets[0].data = consultationChart.data.datasets[0].data.map(() =>
            Math.floor(Math.random() * 20) + 10
    );
    consultationChart.data.datasets[1].data = consultationChart.data.datasets[1].data.map(() =>
            Math.floor(Math.random() * 15) + 5
    );
    consultationChart.data.datasets[2].data = consultationChart.data.datasets[2].data.map(() =>
            Math.floor(Math.random() * 5) + 1
    );

    consultationChart.update('active');
  }

  // 페이지 로드 시 초기화
  document.addEventListener('DOMContentLoaded', function() {
    console.log('Dashboard loaded');
    initChart();

    // 10초마다 차트 업데이트
    setInterval(updateChartData, 10000);
  });
</script>