<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<html>
<head>
  <title>질병 통계 데이터 조회</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body { font-family: 'Malgun Gothic', -apple-system, sans-serif; padding: 20px; background-color: #f5f6fa; }
    .container { max-width: 1100px; margin: auto; background: white; padding: 40px; border-radius: 12px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
    h2 { font-size: 28px; color: #2c3e50; margin-bottom: 30px; padding-bottom: 15px; border-bottom: 2px solid #3498db; }

    /* 검색 폼 */
    .search-form { background: #f8f9fa; padding: 30px; border-radius: 8px; margin-bottom: 30px; border: 1px solid #e9ecef; }
    .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 20px; }
    .form-group label { display: block; font-size: 14px; font-weight: 600; color: #495057; margin-bottom: 8px; }
    .form-group label .required { color: #e74c3c; margin-left: 3px; }
    .form-group input[type="text"], .form-group select { width: 100%; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 14px; background: white; transition: border-color 0.2s; }
    .form-group input[type="text"]:focus, .form-group select:focus { outline: none; border-color: #3498db; }

    /* 상병코드 예시 */
    .example-codes { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
    .code-card { padding: 6px 12px; background: white; border: 1px solid #dee2e6; border-radius: 4px; font-size: 13px; cursor: pointer; transition: all 0.2s; color: #495057; }
    .code-card:hover { background: #3498db; color: white; border-color: #3498db; }

    /* 버튼 */
    .btn-search { width: 100%; padding: 14px; border: none; border-radius: 6px; background: #3498db; color: white; font-size: 16px; font-weight: 600; cursor: pointer; transition: background 0.2s; margin-top: 10px; }
    .btn-search:hover { background: #2980b9; }

    /* 도움말 */
    .help-icon { display: inline-block; width: 16px; height: 16px; background: #95a5a6; color: white; border-radius: 50%; text-align: center; line-height: 16px; font-size: 11px; margin-left: 5px; cursor: help; }
    .tooltip { position: relative; }
    .tooltip .tooltiptext { visibility: hidden; width: 240px; background-color: #34495e; color: white; text-align: left; border-radius: 6px; padding: 12px; position: absolute; z-index: 1; bottom: 125%; left: 50%; margin-left: -120px; opacity: 0; transition: opacity 0.3s; font-size: 12px; line-height: 1.6; }
    .tooltip:hover .tooltiptext { visibility: visible; opacity: 1; }

    /* 결과 헤더 */
    .results-header { padding: 16px 20px; background: #ecf0f1; border-radius: 6px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; border-left: 4px solid #3498db; }
    .results-count { font-size: 16px; font-weight: 600; color: #2c3e50; }
    .results-meta { font-size: 14px; color: #7f8c8d; }

    /* 테이블 */
    table { width: 100%; border-collapse: collapse; margin-top: 0; border: 1px solid #e9ecef; }
    th, td { border: 1px solid #e9ecef; padding: 12px 15px; text-align: center; font-size: 14px; }
    th { background: #f8f9fa; color: #495057; font-weight: 600; }
    tr:hover { background-color: #f8f9fa; }
    td:first-child { font-weight: 600; color: #3498db; }
    td:nth-child(2) { text-align: left; padding-left: 20px; }
    td:last-child { font-weight: 600; color: #2c3e50; }

    /* 메시지 */
    .info { padding: 16px 20px; background: #e8f4f8; border-left: 4px solid #3498db; border-radius: 4px; margin-bottom: 20px; color: #2c3e50; line-height: 1.8; }
    .info h3 { margin-bottom: 12px; font-size: 16px; }
    .info ol { margin-left: 20px; }
    .error-msg { padding: 16px 20px; background: #fee; border-left: 4px solid #e74c3c; border-radius: 4px; color: #c0392b; }

    /* 차트 */
    .chart-container { margin-top: 40px; padding: 30px; background: #f8f9fa; border-radius: 8px; border: 1px solid #e9ecef; }
    .chart-header { font-size: 18px; font-weight: 600; color: #2c3e50; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #3498db; }
    .chart-wrapper { background: white; padding: 20px; border-radius: 6px; margin-bottom: 20px; }
    canvas { max-height: 400px; }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>
</head>
<body>

<div class="container">
  <h2>🏥 질병 통계 조회 시스템</h2>

  <form class="search-form" method="GET" action="/statview">
    <div class="form-row">
      <div class="form-group">
        <label for="year">
          연도<span class="required">*</span>
          <span class="tooltip">
            <span class="help-icon">?</span>
            <span class="tooltiptext">조회할 통계 연도를 입력하세요.<br>예: 2022, 2023<br>※ 최근 2-3년 데이터만 제공됩니다.</span>
          </span>
        </label>
        <input type="text" id="year" name="year" value="${year}" placeholder="예: 2022" required>
      </div>

      <div class="form-group">
        <label for="sickCd">
          상병코드<span class="required">*</span>
          <span class="tooltip">
            <span class="help-icon">?</span>
            <span class="tooltiptext">질병의 표준 코드를 입력하세요.<br>예: A00(콜레라), J45(천식)<br>아래 예시를 클릭하면 자동 입력됩니다.</span>
          </span>
        </label>
        <input type="text" id="sickCd" name="sickCd" value="${sickCd}" placeholder="예: A00, J45, I10" required>
        <div class="example-codes">
          <div class="code-card" onclick="document.getElementById('sickCd').value='A00'">A00 콜레라</div>
          <div class="code-card" onclick="document.getElementById('sickCd').value='J45'">J45 천식</div>
          <div class="code-card" onclick="document.getElementById('sickCd').value='I10'">I10 고혈압</div>
          <div class="code-card" onclick="document.getElementById('sickCd').value='E11'">E11 당뇨병</div>
          <div class="code-card" onclick="document.getElementById('sickCd').value='J06'">J06 감기</div>
        </div>
      </div>
    </div>

    <div class="form-row">
      <div class="form-group">
        <label for="sickType">
          상병 구분
          <span class="tooltip">
            <span class="help-icon">?</span>
            <span class="tooltiptext">주상병: 주된 진단명<br>부상병: 부수적 진단명<br>전체: 모든 상병</span>
          </span>
        </label>
        <select id="sickType" name="sickType">
          <option value="0" ${sickType == '0' ? 'selected' : ''}>전체</option>
          <option value="1" ${empty sickType || sickType == '1' ? 'selected' : ''}>주상병</option>
          <option value="2" ${sickType == '2' ? 'selected' : ''}>부상병</option>
        </select>
      </div>

      <div class="form-group">
        <label for="medTp">
          진료 구분
          <span class="tooltip">
            <span class="help-icon">?</span>
            <span class="tooltiptext">양방: 일반 병·의원<br>한방: 한의원<br>전체: 모든 진료</span>
          </span>
        </label>
        <select id="medTp" name="medTp">
          <option value="0" ${medTp == '0' ? 'selected' : ''}>전체</option>
          <option value="1" ${empty medTp || medTp == '1' ? 'selected' : ''}>양방</option>
          <option value="2" ${medTp == '2' ? 'selected' : ''}>한방</option>
        </select>
      </div>

      <div class="form-group">
        <label for="numOfRows">조회 건수</label>
        <select id="numOfRows" name="numOfRows">
          <option value="10" ${empty numOfRows || numOfRows == 10 ? 'selected' : ''}>10건</option>
          <option value="50" ${numOfRows == 50 ? 'selected' : ''}>50건</option>
          <option value="100" ${numOfRows == 100 ? 'selected' : ''}>100건</option>
          <option value="500" ${numOfRows == 500 ? 'selected' : ''}>500건</option>
        </select>
      </div>
    </div>

    <button type="submit" class="btn-search">🔍 통계 조회하기</button>
  </form>

  <c:if test="${not empty errorMessage}">
    <div class="error-msg">
      <strong>오류 발생:</strong> ${errorMessage}
    </div>
  </c:if>

  <c:choose>
    <c:when test="${not empty statsList}">
      <div class="results-header">
        <div class="results-count">
            ${year}년도 | 상병코드: ${sickCd} | 총 ${statsList.size()}건
        </div>
        <div class="results-meta">
            ${sickType == '1' ? '주상병' : sickType == '2' ? '부상병' : '전체'} |
            ${medTp == '1' ? '양방' : medTp == '2' ? '한방' : '전체'}
        </div>
      </div>
      <table>
        <thead>
        <tr>
          <th>상병코드</th>
          <th>상병명</th>
          <th>성별</th>
          <th>연령대</th>
          <th>환자수 (명)</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="item" items="${statsList}">
          <tr>
            <td>${item.sickCd}</td>
            <td>${item.sickNm}</td>
            <td>${item.sex == 'M' ? '남성' : item.sex == 'F' ? '여성' : '전체'}</td>
            <td>${item.age}</td>
            <td>${item.patientCount}</td>
          </tr>
        </c:forEach>
        </tbody>
      </table>

      <!-- 차트 섹션 -->
      <div class="chart-container">
        <div class="chart-header">📊 연령대별 환자수 분석</div>

        <div class="chart-wrapper">
          <canvas id="barChart"></canvas>
        </div>

        <div class="chart-wrapper">
          <canvas id="lineChart"></canvas>
        </div>
      </div>

      <script>
        // 데이터 준비
        const ageGroups = [];
        const patientCounts = [];

        <c:forEach var="item" items="${statsList}">
        ageGroups.push('${item.age}');
        patientCounts.push(${item.patientCount});
        </c:forEach>

        // 막대 그래프
        const barCtx = document.getElementById('barChart').getContext('2d');
        new Chart(barCtx, {
          type: 'bar',
          data: {
            labels: ageGroups,
            datasets: [{
              label: '환자수 (명)',
              data: patientCounts,
              backgroundColor: 'rgba(52, 152, 219, 0.7)',
              borderColor: 'rgba(52, 152, 219, 1)',
              borderWidth: 2,
              borderRadius: 6
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
              legend: {
                display: true,
                position: 'top',
                labels: {
                  font: { size: 13, weight: '600' },
                  padding: 15
                }
              },
              title: {
                display: true,
                text: '연령대별 환자수 (막대 그래프)',
                font: { size: 16, weight: '600' },
                padding: 20
              },
              tooltip: {
                backgroundColor: 'rgba(44, 62, 80, 0.9)',
                padding: 12,
                titleFont: { size: 13 },
                bodyFont: { size: 13 },
                callbacks: {
                  label: function(context) {
                    return '환자수: ' + context.parsed.y.toLocaleString() + '명';
                  }
                }
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: {
                  callback: function(value) {
                    return value.toLocaleString() + '명';
                  },
                  font: { size: 12 }
                },
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                }
              },
              x: {
                ticks: {
                  font: { size: 12 }
                },
                grid: {
                  display: false
                }
              }
            }
          }
        });

        // 선 그래프
        const lineCtx = document.getElementById('lineChart').getContext('2d');
        new Chart(lineCtx, {
          type: 'line',
          data: {
            labels: ageGroups,
            datasets: [{
              label: '환자수 (명)',
              data: patientCounts,
              borderColor: 'rgba(231, 76, 60, 1)',
              backgroundColor: 'rgba(231, 76, 60, 0.1)',
              borderWidth: 3,
              fill: true,
              tension: 0.4,
              pointRadius: 5,
              pointBackgroundColor: 'rgba(231, 76, 60, 1)',
              pointBorderColor: '#fff',
              pointBorderWidth: 2,
              pointHoverRadius: 7
            }]
          },
          options: {
            responsive: true,
            maintainAspectRatio: true,
            plugins: {
              legend: {
                display: true,
                position: 'top',
                labels: {
                  font: { size: 13, weight: '600' },
                  padding: 15
                }
              },
              title: {
                display: true,
                text: '연령대별 환자수 추이 (선 그래프)',
                font: { size: 16, weight: '600' },
                padding: 20
              },
              tooltip: {
                backgroundColor: 'rgba(44, 62, 80, 0.9)',
                padding: 12,
                titleFont: { size: 13 },
                bodyFont: { size: 13 },
                callbacks: {
                  label: function(context) {
                    return '환자수: ' + context.parsed.y.toLocaleString() + '명';
                  }
                }
              }
            },
            scales: {
              y: {
                beginAtZero: true,
                ticks: {
                  callback: function(value) {
                    return value.toLocaleString() + '명';
                  },
                  font: { size: 12 }
                },
                grid: {
                  color: 'rgba(0, 0, 0, 0.05)'
                }
              },
              x: {
                ticks: {
                  font: { size: 12 }
                },
                grid: {
                  display: false
                }
              }
            }
          }
        });
      </script>
    </c:when>

    <c:when test="${not empty year && not empty sickCd && empty statsList && empty errorMessage}">
      <div class="info">
        <strong>${year}년도, 상병코드 ${sickCd}</strong>에 대한 조회 결과가 없습니다.<br>
        • 연도나 상병코드를 확인해주세요.<br>
        • 최근 2-3년 데이터만 제공될 수 있습니다.
      </div>
    </c:when>

    <c:otherwise>
      <div class="info">
        <h3>📋 사용 방법</h3>
        <ol>
          <li><strong>연도</strong>와 <strong>상병코드</strong>는 필수 입력 항목입니다.</li>
          <li>상병코드 예시를 클릭하면 자동으로 입력됩니다.</li>
          <li>상병 구분과 진료 구분은 선택사항입니다.</li>
          <li>조회 버튼을 눌러 통계 데이터를 확인하세요.</li>
        </ol>
        <p style="margin-top: 15px; padding-top: 12px; border-top: 1px solid #ddd; color: #7f8c8d; font-size: 14px;">
          💡 각 항목의 <strong>?</strong> 아이콘에 마우스를 올리면 상세 설명을 확인할 수 있습니다.
        </p>
      </div>
    </c:otherwise>
  </c:choose>

</div>

</body>
</html>