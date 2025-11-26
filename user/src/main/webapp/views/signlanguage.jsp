<%@ page contentType="text/html;charset=UTF-8" language="java" %>

<style>
    .sign-container { max-width: 900px; margin: 20px auto; padding: 20px; font-family: 'Pretendard', sans-serif; }
    .video-wrapper { position: relative; width: 100%; max-width: 640px; margin: 0 auto 20px; border-radius: 16px; overflow: hidden; background: #000; box-shadow: 0 10px 25px rgba(0,0,0,0.1); }
    #signVideo { width: 100%; height: auto; display: block; transform: scaleX(-1); }
    #outputCanvas { position: absolute; left: 0; top: 0; width: 100%; height: 100%; transform: scaleX(-1); }
    .result-panel { background: white; border-radius: 12px; padding: 20px; box-shadow: 0 4px 6px rgba(0,0,0,0.05); border: 1px solid #e2e8f0; text-align: center; margin-bottom: 20px; }
    .detected-char-box { margin-bottom: 15px; }
    .detected-char-label { font-size: 14px; color: #64748b; margin-bottom: 5px; }
    .detected-char { font-size: 48px; font-weight: 800; color: #4f46e5; min-height: 60px; display: flex; align-items: center; justify-content: center; }
    .confidence-bar-bg { width: 100%; height: 6px; background: #e2e8f0; border-radius: 3px; overflow: hidden; margin-top: 5px; }
    .confidence-level { height: 100%; background: #22c55e; width: 0%; transition: width 0.2s ease-out; }
    .word-builder-container { background: #f8fafc; border-radius: 12px; padding: 20px; border: 1px solid #e2e8f0; }
    .word-display { background: white; border: 2px solid #cbd5e1; border-radius: 8px; padding: 15px; font-size: 24px; font-weight: bold; color: #1e293b; min-height: 60px; margin-bottom: 15px; display: flex; align-items: center; flex-wrap: wrap; }
    .control-btns { display: flex; gap: 10px; justify-content: center; flex-wrap: wrap; }
    .btn { padding: 10px 20px; border-radius: 8px; font-size: 15px; font-weight: 600; cursor: pointer; border: none; transition: all 0.2s; }
    .btn-space { background: #64748b; color: white; }
    .btn-del { background: #ef4444; color: white; }
    .btn-reset { background: #94a3b8; color: white; }
    .guide-text { margin-top: 20px; font-size: 14px; color: #1e293b; text-align: center; background: #e0f2fe; padding: 10px; border-radius: 8px; border: 1px solid #bae6fd; }
</style>

<script src="https://cdn.jsdelivr.net/npm/@mediapipe/camera_utils@0.3/camera_utils.js" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/@mediapipe/control_utils@0.6/control_utils.js" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/@mediapipe/drawing_utils@0.3/drawing_utils.js" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/@mediapipe/hands@0.4.1646424915/hands.js" crossorigin="anonymous"></script>

<div class="sign-container">
  <h2 class="text-center" style="margin-bottom: 20px;">한국수어 지문자 자음 인식</h2>

  <div class="video-wrapper">
    <video id="signVideo" playsinline></video>
    <canvas id="outputCanvas"></canvas>
  </div>

  <div class="result-panel">
    <div class="detected-char-box">
      <div class="detected-char-label">현재 인식된 자음</div>
      <div id="textContent" class="detected-char">...</div>
      <div class="confidence-bar-bg">
        <div id="confidenceLevel" class="confidence-level"></div>
      </div>
    </div>
  </div>

  <div class="word-builder-container">
    <h4 style="margin-top: 0; margin-bottom: 10px; color: #334155;">조합된 문자열</h4>
    <div id="currentWord" class="word-display"></div>
<%--    <div class="control-btns">--%>
<%--      <button class="btn btn-space" onclick="addSpace()">␣ 띄어쓰기</button>--%>
<%--      <button class="btn btn-del" onclick="deleteLastChar()">⌫ 한 글자 삭제</button>--%>
<%--      <button class="btn btn-reset" onclick="clearWord()">↺ 전체 초기화</button>--%>
<%--    </div>--%>
  </div>

</div>

<script>
    const videoElement = document.getElementById('signVideo');
    const canvasElement = document.getElementById('outputCanvas');
    const canvasCtx = canvasElement.getContext('2d');
    const textOutput = document.getElementById('textContent');
    const confidenceBar = document.getElementById('confidenceLevel');
    const wordOutput = document.getElementById('currentWord');

    const SIGN_LANGUAGE = 'ksl'; // 고정 KSL, 필요 시 버튼으로 변경

    let isTranslating = false;
    let lastAddedText = null;
    let lastAddTime = 0;
    const DEBOUNCE_TIME = 1500;

    // 최신 랜드마크 저장
    let lastLandmarks = [];

    // MediaPipe Hands
    const hands = new Hands({
        locateFile: (file) =>
            "https://cdn.jsdelivr.net/npm/@mediapipe/hands@0.4.1646424915/" + file
    });

    hands.setOptions({
        maxNumHands: 1,
        modelComplexity: 1,
        minDetectionConfidence: 0.7,
        minTrackingConfidence: 0.7
    });

    hands.onResults((results) => {
        canvasElement.width = videoElement.videoWidth;
        canvasElement.height = videoElement.videoHeight;
        canvasCtx.save();
        canvasCtx.clearRect(0, 0, canvasElement.width, canvasElement.height);

        if (results.multiHandLandmarks && results.multiHandLandmarks.length > 0) {
            const lm = results.multiHandLandmarks[0];
            lastLandmarks = lm.map(p => ({ x: p.x, y: p.y, z: p.z }));
            // 디버깅용 손 뼈대 표시
            drawConnectors(canvasCtx, lm, HAND_CONNECTIONS, { color: '#00FF00', lineWidth: 4 });
            drawLandmarks(canvasCtx, lm, { color: '#FF0000', lineWidth: 2 });
        } else {
            lastLandmarks = [];
        }

        canvasCtx.restore();
    });

    // 카메라 시작
    async function startCamera() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: { width: 640, height: 480, facingMode: 'user' }
            });
            videoElement.srcObject = stream;

            const camera = new Camera(videoElement, {
                onFrame: async () => {
                    await hands.send({ image: videoElement });
                },
                width: 640,
                height: 480
            });
            camera.start();

            // 초마다 번역 요청
            setInterval(captureAndTranslate, 2000);
        } catch (e) {
            console.error(e);
            textOutput.innerText = '카메라 권한을 확인해주세요.';
        }
    }

    // 현재 프레임 캡쳐 + 랜드마크와 함께 서버 전송
    async function captureAndTranslate() {
        if (isTranslating || videoElement.videoWidth === 0) return;
        isTranslating = true;

        try {
            const w = videoElement.videoWidth;
            const h = videoElement.videoHeight;
            const off = document.createElement('canvas');
            off.width = w;
            off.height = h;
            const ctx = off.getContext('2d');

            // 서버에는 좌우 반전 없이 전송
            ctx.drawImage(videoElement, 0, 0, w, h);

            const blob = await new Promise(resolve => off.toBlob(resolve, 'image/jpeg', 0.85));

            const formData = new FormData();
            formData.append('videoFrame', blob, 'frame.jpg');
            formData.append('signLanguage', SIGN_LANGUAGE);
            formData.append('landmarksJson', JSON.stringify(lastLandmarks || []));

            const res = await fetch('/signlanguage/translate', {
                method: 'POST',
                body: formData
            });

            const data = await res.json();
            if (data.status === 'success' && data.text) {
                const text = data.text.trim();
                textOutput.innerText = text;
                confidenceBar.style.width = '100%';

                const now = Date.now();
                if (text !== '인식 불가' &&
                    (text !== lastAddedText || now - lastAddTime > DEBOUNCE_TIME)) {
                    wordOutput.innerText += text;
                    lastAddedText = text;
                    lastAddTime = now;
                }
            } else {
                textOutput.innerText = data.message || '인식 실패';
                confidenceBar.style.width = '0%';
            }
        } catch (e) {
            console.error(e);
            textOutput.innerText = '서버 오류';
            confidenceBar.style.width = '0%';
        } finally {
            isTranslating = false;
        }
    }

    function addSpace() {
        wordOutput.innerText += ' ';
    }
    function deleteLastChar() {
        wordOutput.innerText = wordOutput.innerText.slice(0, -1);
    }
    function clearWord() {
        wordOutput.innerText = '';
    }

    window.addEventListener('load', startCamera);
</script>
