<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-11-19
  Time: 오후 7:15:27
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page isELIgnored="false" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>관리자 알림</title>
  <style>
      body {
          font-family: Arial, sans-serif;
          padding: 20px;
          max-width: 800px;
          margin: 0 auto;
      }
      .status { padding: 10px; margin-bottom: 20px; text-align: center; }
      .alerts { display: flex; flex-direction: column; gap: 10px; }
      .alert { padding: 15px; border-left: 4px solid #ffc107; }
      .alert.emergency { border-left-color: #e74c3c; }
      .alert-time { font-size: 12px; color: #666; margin-bottom: 5px; }
      .alert-message { white-space: pre-line; }
      button { padding: 10px 20px; width: 100%; margin-top: 20px; cursor: pointer; }
  </style>
</head>
<body>

<div id="status" class="status">연결 중...</div>

<div id="alerts" class="alerts">
  <p>알림을 기다리는 중...</p>
</div>

<button onclick="clearAlerts()">알림 전체 삭제</button>

<script>
    let eventSource = null;
    const statusEl = document.getElementById('status');
    const alertsEl = document.getElementById('alerts');

    function connect() {
        eventSource = new EventSource('https://localhost:8444/iot/admin/subscribe');

        eventSource.addEventListener('connect', function(event) {
            statusEl.textContent = '● 알림 구독 중';
        });

        eventSource.addEventListener('warning', function(event) {
            addAlert(event.data, 'warning');
        });

        eventSource.addEventListener('emergency', function(event) {
            addAlert(event.data, 'emergency');
            playAlertSound();
        });

        eventSource.onerror = function(error) {
            statusEl.textContent = '● 연결 끊김';
        };
    }

    function addAlert(message, type) {
        const alertDiv = document.createElement('div');
        alertDiv.className = 'alert ' + type;

        const now = new Date();
        const timeStr = now.getHours() + ':' +
            String(now.getMinutes()).padStart(2, '0') + ':' +
            String(now.getSeconds()).padStart(2, '0');

        alertDiv.innerHTML = '<div class="alert-time">' + timeStr + '</div>' +
            '<div class="alert-message">' + message + '</div>';

        if (alertsEl.firstChild && alertsEl.firstChild.tagName === 'P') {
            alertsEl.innerHTML = '';
        }
        alertsEl.insertBefore(alertDiv, alertsEl.firstChild);

        while (alertsEl.children.length > 20) {
            alertsEl.removeChild(alertsEl.lastChild);
        }
    }

    function clearAlerts() {
        alertsEl.innerHTML = '<p>알림을 기다리는 중...</p>';
    }

    function playAlertSound() {
        const audio = new Audio('data:audio/wav;base64,UklGRnoGAABXQVZFZm10IBAAAAABAAEAQB8AAEAfAAABAAgAZGF0YQoGAACBhYqFbF1fdJivrJBhNjVgodDbq2EcBj+a2/LDciUFLIHO8tiJNwgZaLvt559NEAxQp+PwtmMcBjiR1/LMeSwFJHfH8N2QQAoUXrTp66hVFApGn+DyvmwhBSuAyvLZimwQHTfE7efHdCUFM4fN8t2WQAoTXbPp7KlXFApFoN/yvnsgBSyAy/LaiXwQHDnE7efHdCUFM4fO8t2XQAsUX7To66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvnweBSyBy/PaiwwQIDnB7efHdCUFM4fP8tyXQAsUXrTp66lWFApFoN/yvg==');
        audio.play().catch(function(e) {});
    }

    window.addEventListener('beforeunload', function() {
        if (eventSource) {
            eventSource.close();
        }
    });

    connect();
</script>
</body>
</html>


