<%--
  Created by IntelliJ IDEA.
  User: 건
  Date: 2025-11-18
  Time: 오후 3:08:58
  To change this template use File | Settings | File Templates.
--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    /* 언어 선택 버튼 스타일 */
    .language-btn {
        padding: 12px 24px;
        border: 2px solid #cbd5e0;
        background: white;
        border-radius: 8px;
        font-size: 16px;
        font-weight: 500;
        cursor: pointer;
        transition: all 0.3s;
    }

    .language-btn:hover {
        border-color: #4299e1;
        background: #ebf8ff;
    }

    .language-btn.active {
        border-color: #4299e1;
        background: #4299e1;
        color: white;
    }

    .language-btn:disabled {
        opacity: 0.5;
        cursor: not-allowed;
    }

    .emr-container {
        max-width: 1400px;
        margin: 20px auto;
        padding: 20px;
    }

    .section-card {
        background: white;
        border-radius: 12px;
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
        padding: 24px;
        margin-bottom: 20px;
    }

    .section-title {
        font-size: 18px;
        font-weight: bold;
        margin-bottom: 16px;
        color: #2d3748;
        border-bottom: 2px solid #4299e1;
        padding-bottom: 8px;
    }

    /* 템플릿 업로드 섹션 */
    .upload-section {
        background: #f0f9ff;
        border-left: 4px solid #3b82f6;
        border-radius: 8px;
        padding: 20px;
        margin-bottom: 20px;
    }

    .upload-box {
        border: 2px dashed #cbd5e0;
        border-radius: 8px;
        padding: 30px 20px;
        text-align: center;
        background: white;
        cursor: pointer;
        transition: all 0.3s;
    }

    .upload-box:hover {
        border-color: #4299e1;
        background: #edf2f7;
    }

    .upload-box.dragover {
        border-color: #48bb78;
        background: #c6f6d5;
    }

    .recording-btn {
        width: 120px;
        height: 120px;
        border-radius: 50%;
        border: none;
        font-size: 48px;
        cursor: pointer;
        transition: all 0.3s;
        margin: 20px auto;
        display: block;
    }

    .recording-btn.ready {
        background: #4299e1;
        color: white;
    }

    .recording-btn.recording {
        background: #f56565;
        color: white;
        animation: pulse 1.5s infinite;
    }

    @keyframes pulse {
        0%, 100% { transform: scale(1); box-shadow: 0 0 0 0 rgba(245, 101, 101, 0.7); }
        50% { transform: scale(1.05); box-shadow: 0 0 0 20px rgba(245, 101, 101, 0); }
    }

    .status-text {
        text-align: center;
        font-size: 16px;
        color: #718096;
        margin-top: 12px;
    }

    .two-column {
        display: grid;
        grid-template-columns: 1fr 1fr;
        gap: 20px;
    }

    .reference-box {
        background: #f7fafc;
        border: 1px solid #e2e8f0;
        border-radius: 8px;
        padding: 16px;
        max-height: 400px;
        overflow-y: auto;
        white-space: pre-wrap;
        word-wrap: break-word;
    }

    .edit-box {
        width: 100%;
        min-height: 400px;
        padding: 16px;
        border: 2px solid #cbd5e0;
        border-radius: 8px;
        font-family: 'Courier New', monospace;
        font-size: 14px;
        line-height: 1.8;
        resize: vertical;
    }

    .edit-box:focus {
        outline: none;
        border-color: #4299e1;
    }

    .form-control {
        width: 100%;
        padding: 10px 12px;
        font-size: 14px;
        border: 1px solid #cbd5e0;
        border-radius: 6px;
        transition: border-color 0.2s;
    }

    .form-control:focus {
        outline: none;
        border-color: #4299e1;
        box-shadow: 0 0 0 3px rgba(66, 153, 225, 0.1);
    }

    .form-label {
        display: block;
        font-weight: 500;
        margin-bottom: 6px;
        color: #4a5568;
        font-size: 14px;
    }

    .btn-primary {
        background: #4299e1;
        color: white;
        border: none;
        padding: 12px 24px;
        border-radius: 8px;
        font-size: 16px;
        cursor: pointer;
        transition: background 0.3s;
    }

    .btn-primary:hover:not(:disabled) {
        background: #3182ce;
    }

    .btn-primary:disabled {
        opacity: 0.6;
        cursor: not-allowed;
    }

    .btn-secondary {
        background: #718096;
        color: white;
        border: none;
        padding: 10px 20px;
        border-radius: 6px;
        cursor: pointer;
        margin-right: 8px;
    }

    .btn-success {
        background: #48bb78;
        color: white;
        border: none;
        padding: 12px 32px;
        border-radius: 8px;
        font-size: 16px;
        font-weight: bold;
        cursor: pointer;
    }

    .alert {
        padding: 12px 16px;
        border-radius: 8px;
        margin-bottom: 16px;
    }

    .alert-info {
        background: #bee3f8;
        color: #2c5282;
        border: 1px solid #90cdf4;
    }

    .alert-success {
        background: #c6f6d5;
        color: #22543d;
        border: 1px solid #9ae6b4;
    }

    .hidden {
        display: none;
    }

    .spinner {
        display: inline-block;
        width: 20px;
        height: 20px;
        border: 3px solid rgba(255,255,255,.3);
        border-radius: 50%;
        border-top-color: white;
        animation: spin 1s ease-in-out infinite;
    }

    @keyframes spin {
        to { transform: rotate(360deg); }
    }
</style>

<div class="emr-container">
  <h2 style="margin-bottom: 24px;">전자의무기록(EMR) 작성</h2>

  <!-- EMR 템플릿 업로드 -->
  <div class="upload-section">
    <div class="section-title" style="border-color: #3b82f6; color: #1e40af;">
      EMR 템플릿 추가 (선택사항)
    </div>

    <div class="alert alert-info" style="margin-bottom: 16px;">
      <strong>ℹ️ 안내:</strong> EMR 작성 규칙이나 예시 문서를 업로드하면 AI가 더 정확한 EMR을 생성합니다.
      <br>
      <small>지원 형식: TXT, PDF, DOCX | 예시: "EMR_작성_가이드.txt", "진료기록_양식.pdf"</small>
    </div>

    <div class="upload-box" id="uploadArea" onclick="document.getElementById('templateFile').click()">
      <div style="font-size: 48px; margin-bottom: 12px;">📄</div>
      <p style="margin: 0; color: #4a5568; font-weight: 500;">
        EMR 템플릿 파일을 클릭하여 선택하거나 드래그하세요
      </p>
      <p style="margin: 8px 0 0 0; color: #718096; font-size: 14px;">
        업로드된 문서는 Vector DB에 저장되어 AI 생성에 활용됩니다
      </p>
    </div>

    <input type="file" id="templateFile" style="display: none;"
           accept=".txt,.pdf,.doc,.docx" onchange="uploadTemplate()">

    <div id="uploadStatus" style="margin-top: 12px; text-align: center; display: none;"></div>
  </div>

  <!-- 음성 녹음 -->
  <div class="section-card" id="recordingSection">
    <div class="section-title">상담 녹음</div>

    <div style="text-align: center; margin-bottom: 20px;">
      <label class="form-label">EMR 작성 언어 선택</label>
      <div style="display: flex; justify-content: center; gap: 10px; margin-top: 8px;">
        <button class="language-btn active" data-lang="ko" onclick="selectLanguage('ko')">
          한국어
        </button>
        <button class="language-btn" data-lang="en" onclick="selectLanguage('en')">
          English
        </button>
      </div>
    </div>

    <button class="recording-btn ready" id="recordBtn" onclick="toggleRecording()">
      🎙️
    </button>
    <div class="status-text" id="statusText">녹음 시작하려면 버튼을 클릭하세요</div>

    <div style="margin-top: 20px; text-align: center;">
      <label class="form-label">상담 ID (선택)</label>
      <input type="number" id="consultationId" class="form-control"
             style="max-width: 300px; margin: 8px auto;"
             placeholder="상담 ID 입력">
    </div>

    <div class="two-column" style="margin-top: 20px;">
      <div>
        <label class="form-label">검사 결과</label>
        <textarea id="testResults" class="form-control" rows="4"
                  placeholder="예: MRI - 요추 4-5번 추간판 팽윤 소견&#10;X-ray - 특이 소견 없음"></textarea>
      </div>
      <div>
        <label class="form-label">처방 내역</label>
        <textarea id="prescription" class="form-control" rows="4"
                  placeholder="예: 소염진통제(이부프로펜) 200mg, 1일 3회&#10;근육이완제(에페리손) 50mg, 1일 2회"></textarea>
      </div>
    </div>

    <div style="text-align: center; margin-top: 20px;">
      <button class="btn-primary" id="generateBtn" onclick="generateEmr()" disabled>
        EMR 자동 생성
      </button>
    </div>
  </div>

  <!-- 2단계: AI 생성 결과 -->
  <div class="section-card hidden" id="resultSection">
    <div class="section-title">AI 생성 EMR 확인</div>

    <div class="alert alert-success">
      <strong>EMR이 생성되었습니다!</strong> 아래 내용을 확인하고 필요시 수정하세요.
    </div>

    <div class="two-column">
      <!-- 좌측: 참고 정보 -->
      <div>
        <h6 style="font-weight: bold; margin-bottom: 12px;">📋 참고 정보 (읽기 전용)</h6>

        <div style="margin-bottom: 16px;">
          <label style="font-weight: bold; display: block; margin-bottom: 4px;">STT 변환 내용:</label>
          <div class="reference-box" id="sttTextBox"></div>
        </div>

        <div style="margin-bottom: 16px;">
          <label style="font-weight: bold; display: block; margin-bottom: 4px;">검사 결과:</label>
          <div class="reference-box" id="testResultsBox"></div>
        </div>

        <div>
          <label style="font-weight: bold; display: block; margin-bottom: 4px;">처방 내역:</label>
          <div class="reference-box" id="prescriptionBox"></div>
        </div>
      </div>

      <!-- 우측: 수정 가능 EMR -->
      <div>
        <h6 style="font-weight: bold; margin-bottom: 12px;">✏️ EMR 수정 (편집 가능)</h6>
        <textarea class="edit-box" id="emrDraft"></textarea>
      </div>
    </div>

    <div style="text-align: center; margin-top: 24px;">
      <button class="btn-secondary" onclick="resetForm()">처음으로</button>
      <button class="btn-success" id="saveBtn" onclick="saveEmr()">
        최종 저장
      </button>
    </div>
  </div>
</div>

<script>
    let mediaRecorder;
    let audioChunks = [];
    let isRecording = false;
    let audioBlob = null;
    let currentEmrId = null;
    let selectedLanguage = 'ko';

    // Drag & Drop 이벤트
    const uploadArea = document.getElementById('uploadArea');

    uploadArea.addEventListener('dragover', (e) => {
        e.preventDefault();
        uploadArea.classList.add('dragover');
    });

    uploadArea.addEventListener('dragleave', () => {
        uploadArea.classList.remove('dragover');
    });

    uploadArea.addEventListener('drop', (e) => {
        e.preventDefault();
        uploadArea.classList.remove('dragover');

        const files = e.dataTransfer.files;
        if (files.length > 0) {
            document.getElementById('templateFile').files = files;
            uploadTemplate();
        }
    });

    // 템플릿 파일 업로드
    async function uploadTemplate() {
        const fileInput = document.getElementById('templateFile');
        const file = fileInput.files[0];

        if (!file) return;

        const uploadStatus = document.getElementById('uploadStatus');
        uploadStatus.style.display = 'block';
        uploadStatus.innerHTML = '<span class="spinner"></span> 업로드 중...';

        const formData = new FormData();
        formData.append('templateFile', file);

        try {
            const response = await fetch('/emr/upload-template', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                uploadStatus.innerHTML = '<span style="color: #48bb78; font-weight: 500;">✓ ' + result.message + '</span>';
                setTimeout(() => {
                    uploadStatus.style.display = 'none';
                    fileInput.value = ''; // 파일 입력 초기화
                }, 3000);
            } else {
                uploadStatus.innerHTML = '<span style="color: #f56565; font-weight: 500;">✗ ' + result.message + '</span>';
            }
        } catch (error) {
            console.error('Error:', error);
            uploadStatus.innerHTML = '<span style="color: #f56565; font-weight: 500;">✗ 업로드 중 오류가 발생했습니다.</span>';
        }
    }

    // 음성 녹음 시작/중지
    async function toggleRecording() {
        const recordBtn = document.getElementById('recordBtn');
        const statusText = document.getElementById('statusText');

        if (!isRecording) {
            // 녹음 시작
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                mediaRecorder = new MediaRecorder(stream);
                audioChunks = [];

                mediaRecorder.ondataavailable = (event) => {
                    audioChunks.push(event.data);
                };

                mediaRecorder.onstop = () => {
                    audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
                    document.getElementById('generateBtn').disabled = false;
                    statusText.textContent = '녹음 완료! EMR 자동 생성 버튼을 클릭하세요';
                    statusText.style.color = '#48bb78';
                };

                mediaRecorder.start();
                isRecording = true;

                recordBtn.className = 'recording-btn recording';
                recordBtn.textContent = '⏹️';
                statusText.textContent = '녹음 중... (다시 클릭하여 중지)';
                statusText.style.color = '#f56565';

            } catch (error) {
                console.error('마이크 접근 오류:', error);
                alert('마이크 접근 권한이 필요합니다.');
            }
        } else {
            // 녹음 중지
            mediaRecorder.stop();
            mediaRecorder.stream.getTracks().forEach(track => track.stop());
            isRecording = false;

            recordBtn.className = 'recording-btn ready';
            recordBtn.textContent = '🎙️';
        }
    }

    // 언어 선택 함수
    function selectLanguage(lang) {
        selectedLanguage = lang;

        // 버튼 활성화 상태 변경
        document.querySelectorAll('.language-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector(`.language-btn[data-lang="${lang}"]`).classList.add('active');

        // 상태 텍스트 업데이트
        const langText = {
            'ko': '한국어',
            'en': 'English',
        };
        console.log(`선택된 언어: ${langText[lang]}`);
    }

    // EMR 자동 생성
    async function generateEmr() {
        if (!audioBlob) {
            alert('먼저 음성을 녹음해주세요.');
            return;
        }

        const generateBtn = document.getElementById('generateBtn');
        const consultationId = document.getElementById('consultationId').value;
        const testResults = document.getElementById('testResults').value;
        const prescription = document.getElementById('prescription').value;

        // FormData 생성
        const formData = new FormData();
        formData.append('audioFile', audioBlob, 'recording.wav');
        formData.append('language', selectedLanguage);
        if (consultationId) formData.append('consultationId', consultationId);
        if (testResults) formData.append('testResults', testResults);
        if (prescription) formData.append('prescription', prescription);

        // 버튼 비활성화
        generateBtn.disabled = true;

        // 선택된 언어에 따라 메시지 표시
        const langMessages = {
            'ko': 'AI 생성 중 (한국어)...',
            'en': 'Generating with AI (English)...',
        };
        generateBtn.innerHTML = `<span class="spinner"></span> ${langMessages[selectedLanguage]}`;

        try {
            const response = await fetch('/emr/generate', {
                method: 'POST',
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                currentEmrId = result.emrId;

                // 결과 표시
                document.getElementById('sttTextBox').textContent = result.sttText || '변환된 내용 없음';
                document.getElementById('testResultsBox').textContent = result.testResults || '없음';
                document.getElementById('prescriptionBox').textContent = result.prescription || '없음';
                document.getElementById('emrDraft').value = result.aiDraft || '';

                // 섹션 전환
                document.getElementById('recordingSection').classList.add('hidden');
                document.getElementById('resultSection').classList.remove('hidden');

            } else {
                alert('오류: ' + result.message);
            }
        } catch (error) {
            console.error('Error:', error);
            alert('EMR 생성 중 오류가 발생했습니다.');
        } finally {
            generateBtn.disabled = false;
            generateBtn.innerHTML = 'EMR 자동 생성';
        }
    }

    // EMR 최종 저장
    async function saveEmr() {
        const saveBtn = document.getElementById('saveBtn');
        const finalRecord = document.getElementById('emrDraft').value.trim();

        if (!finalRecord) {
            alert('EMR 최종 기록이 비어있습니다.');
            return;
        }

        if (!confirm('최종 저장하시겠습니까?\n(DB에 영구 저장됩니다)')) {
            return;
        }

        saveBtn.disabled = true;
        saveBtn.innerHTML = '<span class="spinner"></span> 저장 중...';

        try {
            const params = new URLSearchParams({finalRecord});
            const response = await fetch('/emr/save', {
                method: 'POST',
                headers: {'Content-Type': 'application/x-www-form-urlencoded'},
                body: params
            });

            const result = await response.json();
            if (result.success) {
                alert('✓ EMR이 성공적으로 저장되었습니다!');
                location.reload();
            } else {
                alert('오류: ' + result.message);
            }
        } catch (error) {
            alert('저장 중 오류가 발생했습니다.');
        } finally {
            saveBtn.disabled = false;
            saveBtn.innerHTML = '💾 최종 저장';
        }
    }

    // 처음으로 돌아가기
    function resetForm() {
        if (!confirm('처음부터 다시 시작하시겠습니까?')) {
            return;
        }
        location.reload();
    }
</script>

