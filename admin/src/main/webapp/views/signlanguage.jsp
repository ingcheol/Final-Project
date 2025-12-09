<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .admin-sign-container {
        max-width: 900px;
        margin: 20px auto;
        padding: 20px;
        font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, system-ui, sans-serif;
    }
    .admin-header {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }
    .admin-title {
        font-size: 22px;
        font-weight: 700;
        color: #0f172a;
    }
    .status-dot {
        width: 10px;
        height: 10px;
        border-radius: 9999px;
        background: #ef4444;
        display: inline-block;
        margin-right: 6px;
    }
    .status-dot.connected {
        background: #22c55e;
    }
    .status-text {
        font-size: 13px;
        color: #64748b;
    }
    .log-panel {
        border-radius: 12px;
        border: 1px solid #e2e8f0;
        background: #f8fafc;
        padding: 15px;
        max-height: 480px;
        overflow-y: auto;
    }
    .log-item {
        padding: 8px 10px;
        border-radius: 8px;
        background: #ffffff;
        border: 1px solid #e5e7eb;
        margin-bottom: 8px;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .log-text {
        font-size: 18px;
        font-weight: 600;
        color: #111827;
    }
    .log-meta {
        font-size: 11px;
        color: #9ca3af;
        margin-left: 10px;
        white-space: nowrap;
    }
    .empty-text {
        font-size: 14px;
        color: #9ca3af;
        text-align: center;
        margin-top: 20px;
    }
</style>

<div class="admin-sign-container">
  <div class="admin-header">
    <div class="admin-title">실시간 수어 번역 모니터링</div>
    <div>
      <span id="sseStatusDot" class="status-dot"></span>
      <span id="sseStatusText" class="status-text">연결 안 됨</span>
    </div>
  </div>

  <div id="translationLog" class="log-panel">
    <div id="emptyMessage" class="empty-text">아직 수신된 번역 결과가 없습니다.</div>
  </div>
</div>

<script>
    const sseStatusDot  = document.getElementById('sseStatusDot');
    const sseStatusText = document.getElementById('sseStatusText');
    const logContainer  = document.getElementById('translationLog');
    const emptyMessage  = document.getElementById('emptyMessage');

    function connectSse() {
        // adminId는 필요에 따라 로그인 아이디 등으로 바꿔도 됨
        const source = new EventSource('/admin/signlanguage/subscribe?adminId=admin1');

        source.addEventListener('connect', function (event) {
            sseStatusDot.classList.add('connected');
            sseStatusText.textContent = '연결됨';
            console.log('SSE 연결:', event.data);
        });

        source.addEventListener('translation', function (event) {
            // SignLanguageMessage JSON 파싱
            const msg = JSON.parse(event.data);
            console.log('번역 수신:', msg);

            if (emptyMessage) {
                emptyMessage.style.display = 'none';
            }

            const item = document.createElement('div');
            item.className = 'log-item';

            const textDiv = document.createElement('div');
            textDiv.className = 'log-text';
            textDiv.textContent = msg.translatedText || '인식 불가';

            const metaDiv = document.createElement('div');
            metaDiv.className = 'log-meta';
            const time = msg.timestamp ? msg.timestamp.replace('T', ' ') : '';
            // 환자 이름/ID를 나중에 다시 쓰고 싶으면 dto에 값 채워서 같이 출력하면 됨
            metaDiv.textContent = time;

            item.appendChild(textDiv);
            item.appendChild(metaDiv);

            // 최신 메시지가 위로 오게 prepend
            if (logContainer.firstChild) {
                logContainer.insertBefore(item, logContainer.firstChild);
            } else {
                logContainer.appendChild(item);
            }
        });

        source.onerror = function (err) {
            console.error('SSE 오류', err);
            sseStatusDot.classList.remove('connected');
            sseStatusText.textContent = '연결 끊김 - 새로고침 해주세요';
        };
    }

    window.addEventListener('load', connectSse);
</script>
