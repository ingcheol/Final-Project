<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-11-19
  Time: 오후 2:44:24
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<script src="https://cdn.jsdelivr.net/npm/sockjs-client@1/dist/sockjs.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/stompjs/lib/stomp.min.js"></script>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <script src="https://code.highcharts.com/highcharts.js"></script>
  <style>
      * { margin: 0; padding: 0; box-sizing: border-box; }
      body { font-family: 'Segoe UI', Arial, sans-serif; background: #f5f7fa; padding: 20px; }
      .container { max-width: 1400px; margin: 0 auto; }
      h1 { color: #2c3e50; margin-bottom: 20px; text-align: center; }

      .chart-section {
          margin-bottom: 30px;
      }

      .chart-title {
          background: white;
          padding: 15px;
          border-radius: 8px 8px 0 0;
          font-size: 24px;
          font-weight: bold;
          color: #2c3e50;
          display: flex;
          justify-content: space-between;
          align-items: center;
      }

      .live-indicator {
          display: inline-flex;
          align-items: center;
          gap: 8px;
          font-size: 18px;
          color: #27ae60;
      }

      .live-dot {
          width: 10px;
          height: 10px;
          background: #27ae60;
          border-radius: 50%;
          animation: pulse 1.5s infinite;
      }

      @keyframes pulse {
          0%, 100% { opacity: 1; }
          50% { opacity: 0.3; }
      }

      .chart-controls {
          background: white;
          padding: 15px;
          border-radius: 8px;
          margin-bottom: 20px;
          display: flex;
          gap: 10px;
          align-items: center;
      }

      .chart-controls button {
          padding: 10px 20px;
          border: none;
          border-radius: 6px;
          background: #3498db;
          color: white;
          cursor: pointer;
          transition: background 0.2s;
      }

      .chart-controls button:hover {
          background: #2980b9;
      }

      .chart-controls button.active {
          background: #27ae60;
      }

      .chart-container {
          background: white;
          border-radius: 0 0 8px 8px;
          padding: 20px;
          box-shadow: 0 2px 8px rgba(0,0,0,0.1);
      }

      /* AI 일일 미션 알림 스타일(어르신의 가독성을 위한 폰트 크기) */
      .mission-notification {
          position: fixed;
          top: 50%;
          left: 50%;
          transform: translate(-50%, -50%);
          background: linear-gradient(135deg, #00695c 0%, yellowgreen 100%);
          color: white;
          padding: 0;
          border-radius: 12px;
          box-shadow: 0 10px 40px rgba(0,0,0,0.3);
          width: 80%;
          max-width: 500px;
          z-index: 9999;
          animation: popUp 0.5s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      }

      .notification-header {
          background: rgba(0,0,0,0.2);
          padding: 15px 20px;
          display: flex;
          justify-content: space-between;
          align-items: center;
          border-radius: 12px 12px 0 0;
          font-weight: bold;
      }

      .notification-header button {
          background: none;
          border: none;
          color: white;
          font-size: 28px;
          cursor: pointer;
          padding: 0;
          width: 30px;
          height: 30px;
          display: flex;
          align-items: center;
          justify-content: center;
          border-radius: 50%;
          transition: background 0.2s;
      }

      .notification-header button:hover {
          background: rgba(255,255,255,0.2);
      }

      .notification-body {
          padding: 40px;
          font-size: 24px;        /* 본문 글자 크기 확대 */
          line-height: 1.6;       /* 줄 간격 넓게 */
          font-weight: 500;       /* 글자 두께 약간 두껍게 */
          word-break: keep-all;   /* 단어 중간에 끊기지 않게 */
      }

      @keyframes slideIn {
          from {
              transform: translateX(400px);
              opacity: 0;
          }
          to {
              transform: translateX(0);
              opacity: 1;
          }
      }

  </style>
</head>
<body>
<div class="container">
  <h1>${patientName} IoT 모니터링 (ID: ${patientId})
    <br>AI가 IoT값을 참고하여 선별 및 건강 일일미션, 복약 알림을 제공합니다.</h1>

  <!-- 실시간 차트 (최근 1분) -->
  <div class="chart-section">
    <div class="chart-title">
      실시간 모니터링
      <div class="live-indicator">
        <div class="live-dot"></div>
        <span>LIVE (3초마다 자동 업데이트)</span>
      </div>
    </div>
    <div class="chart-container" id="liveChartContainer"></div>
  </div>

  <!-- 기간별 차트-->
  <div class="chart-section">
    <div class="chart-controls">
      <span style="font-weight: bold;">기간 선택:</span>
      <button onclick="loadHistoryChart(1)" class="active" id="btn1">최근 1일</button>
      <button onclick="loadHistoryChart(7)" id="btn7">최근 7일</button>
      <button onclick="loadHistoryChart(30)" id="btn30">최근 30일</button>
    </div>
    <div class="chart-container" id="historyChartContainer"></div>
  </div>
</div>

<script>
    const patientId = ${patientId};
    let liveChart = null;
    let historyChart = null;
    let currentPeriod = 7;
    let liveUpdateInterval = null;

    function speakMessage(message) {
        // Web Speech API 지원 확인
        if ('speechSynthesis' in window) {
            // 기존 음성이 재생 중이면 중지
            window.speechSynthesis.cancel();

            const utterance = new SpeechSynthesisUtterance(message);

            // 한국어 음성 설정
            utterance.lang = 'ko-KR';
            utterance.rate = 0.8;  // 속도 (0.1 ~ 10, 기본 1)
            utterance.pitch = 1;   // 음높이 (0 ~ 2, 기본 1)
            utterance.volume = 1;  // 볼륨 (0 ~ 1, 기본 1)

            // 한국어 음성 선택 (사용 가능한 경우)
            const voices = window.speechSynthesis.getVoices();
            const koreanVoice = voices.find(voice => voice.lang.includes('ko'));
            if (koreanVoice) {
                utterance.voice = koreanVoice;
            }

            // 음성 재생
            window.speechSynthesis.speak(utterance);
        } else {
            console.warn("⚠️ 브라우저가 음성 출력을 지원하지 않습니다.");
            alert(message);
        }
    }

    // 웹소켓 연결
    const socket = new SockJS('/chat');
    const stompClient = Stomp.over(socket);

    stompClient.connect({}, function(frame) {
        // 환자 미션 메시지 구독
        stompClient.subscribe('/send/mission/' + patientId, function(message) {
            console.log("AI 메시지 도착:", message.body);

            showMissionNotification(message.body);
            speakMessage(message.body);
        });
    }, function(error) {
        console.error("🔥 웹소켓 연결 실패:", error);
    });

    // 모달 알림
    function showMissionNotification(message) {
        const notification = document.createElement('div');
        notification.className = 'mission-notification';
        notification.innerHTML =
            '<div class="notification-header">' +
            '<span>AI 건강 일일 미션</span>' +
            '<button onclick="this.parentElement.parentElement.remove()">✖</button>' +
            '</div>' +
            '<div class="notification-body">' + message + '</div>';

        document.body.appendChild(notification);

        // 15초 후 자동 제거
        setTimeout(() => notification.remove(), 15000);
    }

    // 페이지 로드 시 음성 목록 초기화 (일부 브라우저 필요)
    window.speechSynthesis.onvoiceschanged = function() {
        const voices = window.speechSynthesis.getVoices();
    };

    // 실시간 차트 로드 (최근 1분)
    function loadLiveChart() {
        fetch('/iot/getlive?patientId=' + patientId)
            .then(response => response.json())
            .then(data => {
                renderLiveChart(data);
            })
            .catch(error => {
                console.error('실시간 데이터 조회 실패:', error);
            });
    }

    // 실시간 차트 렌더링
    function renderLiveChart(data) {
        const seriesData = {
            'HEART_RATE': [],
            'TEMPERATURE': [],
            'BLOOD_SUGAR': [],
            'BP_SYSTOLIC': [],
            'BP_DIASTOLIC': []
        };

        data.forEach(item => {
            const timestamp = new Date(item.measuredAt).getTime();
            if (seriesData[item.vitalType]) {
                seriesData[item.vitalType].push([timestamp, item.value]);
            }
        });

        Object.keys(seriesData).forEach(key => {
            seriesData[key].sort((a, b) => a[0] - b[0]);
        });

        const series = [
            { name: '심박수 (bpm)', data: seriesData['HEART_RATE'], color: '#e74c3c' },
            { name: '체온 (°C)', data: seriesData['TEMPERATURE'], color: '#f39c12', yAxis: 1 },
            { name: '혈당 (mg/dL)', data: seriesData['BLOOD_SUGAR'], color: '#9b59b6' },
            { name: '수축기 혈압 (mmHg)', data: seriesData['BP_SYSTOLIC'], color: '#3498db' },
            { name: '이완기 혈압 (mmHg)', data: seriesData['BP_DIASTOLIC'], color: '#1abc9c' }
        ];

        if (!liveChart) {
            liveChart = Highcharts.chart('liveChartContainer', {
                chart: {
                    type: 'line',
                    animation: Highcharts.svg,
                    height: 400
                },
                title: { text: '최근 측정 데이터 (실시간)' },
                xAxis: {
                    type: 'datetime',
                    title: { text: '측정 시간' },
                    labels: {
                        format: '{value:%H:%M:%S}'
                    }
                },
                yAxis: [
                    {
                        title: { text: '바이탈 수치' },
                        opposite: false
                    },
                    {
                        title: { text: '체온 (°C)' },
                        opposite: true,
                        min: 35,
                        max: 40
                    }
                ],
                tooltip: {
                    shared: true,
                    crosshairs: true,
                    xDateFormat: '%H:%M:%S'
                },
                legend: { enabled: true },
                series: series,
                credits: { enabled: false },
                plotOptions: {
                    line: {
                        marker: {
                            enabled: true,
                            radius: 4
                        }
                    }
                }
            });
        } else {
            // 기존 차트 업데이트
            series.forEach((s, index) => {
                liveChart.series[index].setData(s.data, false);
            });
            liveChart.redraw();
        }
    }

    // 기간별 차트 로드
    function loadHistoryChart(days) {
        currentPeriod = days;

        document.querySelectorAll('.chart-controls button').forEach(btn => {
            btn.classList.remove('active');
        });
        document.getElementById('btn' + days).classList.add('active');

        fetch('/iot/chart?patientId=' + patientId + '&days=' + days)
            .then(response => response.json())
            .then(data => {
                renderHistoryChart(data);
            })
            .catch(error => {
                alert('차트 데이터를 불러올 수 없습니다.');
            });
    }

    // 기간별 차트 렌더링
    function renderHistoryChart(data) {
        const seriesData = {
            'HEART_RATE': [],
            'TEMPERATURE': [],
            'BLOOD_SUGAR': [],
            'BP_SYSTOLIC': [],
            'BP_DIASTOLIC': []
        };

        data.forEach(item => {
            const timestamp = new Date(item.measuredAt).getTime();
            if (seriesData[item.vitalType]) {
                seriesData[item.vitalType].push([timestamp, item.value]);
            }
        });

        Object.keys(seriesData).forEach(key => {
            seriesData[key].sort((a, b) => a[0] - b[0]);
        });

        const series = [
            { name: '심박수 (bpm)', data: seriesData['HEART_RATE'], color: '#e74c3c' },
            { name: '체온 (°C)', data: seriesData['TEMPERATURE'], color: '#f39c12', yAxis: 1 },
            { name: '혈당 (mg/dL)', data: seriesData['BLOOD_SUGAR'], color: '#9b59b6' },
            { name: '수축기 혈압 (mmHg)', data: seriesData['BP_SYSTOLIC'], color: '#3498db' },
            { name: '이완기 혈압 (mmHg)', data: seriesData['BP_DIASTOLIC'], color: '#1abc9c' }
        ];

        historyChart = Highcharts.chart('historyChartContainer', {
            chart: {
                type: 'line',
                zoomType: 'x',
                height: 500
            },
            title: { text: '최근 ' + currentPeriod + '일 건강 데이터 추이' },
            xAxis: {
                type: 'datetime',
                title: { text: '측정 시간' }
            },
            yAxis: [
                {
                    title: { text: '바이탈 수치' },
                    opposite: false
                },
                {
                    title: { text: '체온 (°C)' },
                    opposite: true,
                    min: 35,
                    max: 40
                }
            ],
            tooltip: {
                shared: true,
                crosshairs: true,
                xDateFormat: '%Y-%m-%d %H:%M'
            },
            legend: { enabled: true },
            series: series,
            credits: { enabled: false }
        });
    }

    // 3초마다 실시간 차트 자동 업데이트
    function startLiveUpdate() {
        loadLiveChart();
        liveUpdateInterval = setInterval(function() {
            loadLiveChart();
        }, 3000);
    }

    // 페이지 종료 시 자동 업데이트 중지
    window.addEventListener('beforeunload', function() {
        if (liveUpdateInterval) {
            clearInterval(liveUpdateInterval);
        }
    });

    // 초기 실행
    startLiveUpdate();        // 실시간 차트 (3초마다 자동 업데이트)
    loadHistoryChart(1);      // 기간별 차트
</script>
</body>
</html>
