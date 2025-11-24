<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<script src="https://cdnjs.cloudflare.com/ajax/libs/Chart.js/3.9.1/chart.min.js"></script>

<style>
  /* [중요] * { margin:0 } 같은 전역 스타일은 삭제했습니다 (상단바 깨짐 원인) */

  /* .container 대신 .stat-container 사용 (메인 레이아웃 충돌 방지) */
  .stat-container {
    max-width: 1100px;
    margin: 0 auto;
    background: white;
    padding: 40px;
    border-radius: 12px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.08);
  }

  .stat-header-title {
    font-size: 28px;
    color: #2c3e50;
    margin-bottom: 30px;
    padding-bottom: 15px;
    border-bottom: 2px solid #3498db;
  }

  /* 검색 폼 */
  .search-form { background: #f8f9fa; padding: 30px; border-radius: 8px; margin-bottom: 30px; border: 1px solid #e9ecef; }
  .form-row { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 20px; }

  /* 라벨 스타일 */
  .form-group label { display: block; font-size: 14px; font-weight: 600; color: #495057; margin-bottom: 8px; }
  .form-group label .required { color: #e74c3c; margin-left: 3px; }

  /* 입력창 스타일 */
  .form-group input[type="text"], .form-group select { width: 100%; padding: 10px 12px; border: 1px solid #ced4da; border-radius: 6px; font-size: 14px; background: white; transition: border-color 0.2s; }
  .form-group input[type="text"]:focus, .form-group select:focus { outline: none; border-color: #3498db; }

  /* 상병코드 예시 */
  .example-codes { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; }
  .code-card { padding: 6px 12px; background: white; border: 1px solid #dee2e6; border-radius: 4px; font-size: 13px; cursor: pointer; transition: all 0.2s; color: #495057; }
  .code-card:hover { background: #3498db; color: white; border-color: #3498db; }

  /* 버튼 */
  .btn-search { width: 100%; padding: 14px; border: none; border-radius: 6px; background: #3498db; color: white; font-size: 16px; font-weight: 600; cursor: pointer; transition: background 0.2s; margin-top: 10px; }
  .btn-search:hover { background: #2980b9; }

  /* 도움말 툴팁 */
  .help-icon { display: inline-block; width: 16px; height: 16px; background: #95a5a6; color: white; border-radius: 50%; text-align: center; line-height: 16px; font-size: 11px; margin-left: 5px; cursor: help; }
  .tooltip-custom { position: relative; display: inline-block; }
  .tooltip-custom .tooltiptext { visibility: hidden; width: 240px; background-color: #34495e; color: white; text-align: left; border-radius: 6px; padding: 12px; position: absolute; z-index: 1; bottom: 125%; left: 50%; margin-left: -120px; opacity: 0; transition: opacity 0.3s; font-size: 12px; line-height: 1.6; }
  .tooltip-custom:hover .tooltiptext { visibility: visible; opacity: 1; }

  /* 결과 요약 헤더 */
  .results-header { padding: 16px 20px; background: #ecf0f1; border-radius: 6px; margin-bottom: 20px; display: flex; justify-content: space-between; align-items: center; border-left: 4px solid #3498db; }
  .results-count { font-size: 16px; font-weight: 600; color: #2c3e50; }
  .results-meta { font-size: 14px; color: #7f8c8d; }

  /* 테이블 스타일 */
  .stat-table { width: 100%; border-collapse: collapse; margin-top: 0; border: 1px solid #e9ecef; }
  .stat-table th, .stat-table td { border: 1px solid #e9ecef; padding: 12px 15px; text-align: center; font-size: 14px; }
  .stat-table th { background: #f8f9fa; color: #495057; font-weight: 600; }
  .stat-table tr:hover { background-color: #f8f9fa; }
  .stat-table td:first-child { font-weight: 600; color: #3498db; }
  .stat-table td:nth-child(2) { text-align: left; padding-left: 20px; }
  .stat-table td:last-child { font-weight: 600; color: #2c3e50; }

  /* 안내 박스 */
  .info-box { padding: 16px 20px; background: #e8f4f8; border-left: 4px solid #3498db; border-radius: 4px; margin-bottom: 20px; color: #2c3e50; line-height: 1.8; }
  .info-box h3 { margin-bottom: 12px; font-size: 16px; }
  .info-box ol { margin-left: 20px; }
  .error-msg { padding: 16px 20px; background: #fee; border-left: 4px solid #e74c3c; border-radius: 4px; color: #c0392b; }

  /* 차트 영역 */
  .chart-container { margin-top: 40px; padding: 30px; background: #f8f9fa; border-radius: 8px; border: 1px solid #e9ecef; }
  .chart-header { font-size: 18px; font-weight: 600; color: #2c3e50; margin-bottom: 20px; padding-bottom: 10px; border-bottom: 2px solid #3498db; }
  .chart-wrapper { background: white; padding: 20px; border-radius: 6px; margin-bottom: 20px; }
  .chart-wrapper canvas { max-height: 400px; }

  /* AI 뉴스 섹션 */
  .news-container { margin-top: 50px; padding-top: 30px; border-top: 2px solid #eee; }
  .news-header { font-size: 22px; font-weight: 700; color: #2c3e50; margin-bottom: 20px; display: flex; align-items: center; gap: 10px; }
  .ai-badge { background: linear-gradient(135deg, #6366f1, #8b5cf6); color: white; padding: 4px 12px; border-radius: 20px; font-size: 12px; font-weight: 600; box-shadow: 0 2px 4px rgba(99, 102, 241, 0.3); display: inline-block; vertical-align: middle; }

  .news-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
  .news-card { background: white; border: 1px solid #e0e0e0; border-radius: 12px; padding: 24px; transition: transform 0.2s, box-shadow 0.2s, border-color 0.2s; display: flex; flex-direction: column; justify-content: space-between; min-height: 200px; }
  .news-card:hover { transform: translateY(-5px); box-shadow: 0 10px 20px rgba(0,0,0,0.08); border-color: #3498db; }

  .news-title { font-size: 16px; font-weight: 700; color: #2c3e50; margin-bottom: 12px; line-height: 1.5; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical; overflow: hidden; }
  .news-desc { font-size: 14px; color: #57606f; margin-bottom: 20px; line-height: 1.6; flex-grow: 1; display: -webkit-box; -webkit-line-clamp: 3; -webkit-box-orient: vertical; overflow: hidden; }
  .news-footer { display: flex; justify-content: space-between; align-items: center; border-top: 1px solid #f1f2f6; padding-top: 15px; margin-top: auto; }
  .news-date { font-size: 12px; color: #a4b0be; }
  .news-link { color: #3498db; text-decoration: none; font-weight: 600; font-size: 13px; display: inline-flex; align-items: center; gap: 4px; transition: color 0.2s; }
  .news-link:hover { color: #2980b9; text-decoration: underline; }
</style>

<div class="stat-container">
  <h2 class="stat-header-title">🏥 질병 통계 조회 시스템</h2>

  <form class="search-form" method="GET" action="/statview">
    <div class="form-row">
      <div class="form-group">
        <label for="year">
          연도<span class="required">*</span>
          <span class="tooltip-custom">
            <span class="help-icon">?</span>
            <span class="tooltiptext">조회할 통계 연도를 입력하세요.<br>예: 2022, 2023<br>※ 최근 2-3년 데이터만 제공됩니다.</span>
          </span>
        </label>
        <input type="text" id="year" name="year" value="${year}" placeholder="예: 2022" required>
      </div>

      <div class="form-group">
        <label for="sickCd">
          상병코드<span class="required">*</span>
          <span class="tooltip-custom">
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
        <label for="sickType">상병 구분</label>
        <select id="sickType" name="sickType">
          <option value="0" ${sickType == '0' ? 'selected' : ''}>전체</option>
          <option value="1" ${empty sickType || sickType == '1' ? 'selected' : ''}>주상병</option>
          <option value="2" ${sickType == '2' ? 'selected' : ''}>부상병</option>
        </select>
      </div>

      <div class="form-group">
        <label for="medTp">진료 구분</label>
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
    <div class="error-msg"><strong>오류 발생:</strong> ${errorMessage}</div>
  </c:if>

  <c:choose>
    <c:when test="${not empty statsList}">
      <div class="results-header">
        <div class="results-count">${year}년도 | 상병코드: ${sickCd} | 총 ${statsList.size()}건</div>
        <div class="results-meta">
            ${sickType == '1' ? '주상병' : sickType == '2' ? '부상병' : '전체'} |
            ${medTp == '1' ? '양방' : medTp == '2' ? '한방' : '전체'}
        </div>
      </div>

      <table class="stat-table">
        <thead>
        <tr>
          <th>상병코드</th><th>상병명</th><th>성별</th><th>연령대</th><th>환자수 (명)</th>
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

      <div class="chart-container">
        <div class="chart-header">📊 연령대별 환자수 분석</div>
        <div class="chart-wrapper"><canvas id="barChart"></canvas></div>
        <div class="chart-wrapper"><canvas id="lineChart"></canvas></div>

        <div class="news-container">
          <div class="news-header">
            🤖 AI 맞춤 의료 뉴스 <span class="ai-badge">Powered by GPT-4</span>
          </div>

          <c:choose>
            <c:when test="${not empty newsList}">
              <div class="news-grid">
                <c:forEach var="news" items="${newsList}">
                  <div class="news-card">
                    <div>
                      <div class="news-title">${news.title}</div>
                      <div class="news-desc">${news.description}</div>
                    </div>
                    <div class="news-footer">
                      <span class="news-date">${news.pubDate}</span>
                      <a href="${news.originLink}" target="_blank" class="news-link">기사 원문 보기 🔗</a>
                    </div>
                  </div>
                </c:forEach>
              </div>
            </c:when>
            <c:when test="${not empty aiErrorMessage}">
              <div style="padding: 20px; background: #fff1f0; border: 1px solid #ffa39e; border-radius: 8px; color: #cf1322; text-align: center;">
                ⚠️ <strong>${aiErrorMessage}</strong><br>
                <span style="font-size:13px; color:#888;">관리자에게 문의하거나 잠시 후 다시 시도해주세요.</span>
              </div>
            </c:when>
            <c:otherwise>
              <div style="text-align: center; color: #999; padding: 20px;">관련된 뉴스 데이터가 없습니다.</div>
            </c:otherwise>
          </c:choose>
        </div>
      </div>

      <script>
        // 차트 데이터 준비
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
          options: { responsive: true, plugins: { legend: { position: 'top' }, title: { display: true, text: '연령대별 환자수 (막대 그래프)' } } }
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
              tension: 0.4
            }]
          },
          options: { responsive: true, plugins: { legend: { position: 'top' }, title: { display: true, text: '연령대별 환자수 추이 (선 그래프)' } } }
        });
      </script>
    </c:when>

    <c:when test="${not empty year && not empty sickCd && empty statsList && empty errorMessage}">
      <div class="info-box">
        <strong>${year}년도, 상병코드 ${sickCd}</strong>에 대한 조회 결과가 없습니다.<br>
        • 연도나 상병코드를 확인해주세요.
      </div>
    </c:when>

    <c:otherwise>
      <div class="info-box">
        <h3>📋 사용 방법</h3>
        <ol>
          <li><strong>연도</strong>와 <strong>상병코드</strong>는 필수 입력 항목입니다.</li>
          <li>예: 2022, J06 (감기)</li>
        </ol>
      </div>
    </c:otherwise>
  </c:choose>
</div>