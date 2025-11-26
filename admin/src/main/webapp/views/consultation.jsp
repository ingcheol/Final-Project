<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<style>
    /* ================= 상담(WebRTC + 채팅) 스타일 ================= */
    /* 채팅 토글 버튼 */
    .chat-toggle-wrapper {
        margin-top: 20px;
        display: flex;
        justify-content: flex-start;
        gap: 8px;
    }

    .chat-toggle-btn {
        padding: 8px 14px;
        border-radius: 20px;
        border: 1px solid #cbd5e0;
        background: #ffffff;
        font-size: 13px;
        font-weight: 500;
        color: #2d3748;
        cursor: pointer;
        display: inline-flex;
        align-items: center;
        gap: 6px;
    }

    .chat-toggle-btn.active {
        background: #3182ce;
        color: #ffffff;
        border-color: #3182ce;
    }

    .chat-toggle-badge {
        min-width: 16px;
        padding: 0 5px;
        height: 16px;
        border-radius: 999px;
        background: #e53e3e;
        color: #ffffff;
        font-size: 10px;
        font-weight: 700;
        display: none;
        align-items: center;
        justify-content: center;
    }

    .adviser-webrtc-container {max-width:1200px;margin:0 auto;padding:20px;}
    .video-grid {display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin-bottom:20px;}
    .video-wrapper {position:relative;width:100%;background:#000;border-radius:8px;overflow:hidden;}
    .video-stream {width:100%;height:auto;aspect-ratio:16/9;}
    .video-label {position:absolute;bottom:10px;left:10px;color:white;background:rgba(0,0,0,0.5);
        padding:5px 10px;border-radius:4px;}
    .controls {display:flex;justify-content:center;gap:10px;margin:20px 0;}
    .control-button {padding:10px 20px;border-radius:4px;border:none;cursor:pointer;font-size:16px;}
    .start-call {background:#4CAF50;color:white;}
    .end-call {background:#f44336;color:white;}
    .connection-status {text-align:center;font-size:14px;}

    .chat-container {margin-top:20px;border:1px solid #ddd;background:#f8fafc;border-radius:8px;overflow:hidden;}
    .chat-header {background:linear-gradient(135deg,#667eea 0%,#764ba2 100%);color:white;
        padding:15px;font-weight:bold;}
    .chat-messages {height:400px;overflow-y:auto;padding:20px;background:#f8fafc;}
    .message {display:flex;margin-bottom:15px;align-items:flex-end;}
    .message.sent {justify-content:flex-end;}
    .message.received {justify-content:flex-start;}
    .message-bubble {max-width:60%;padding:10px 15px;border-radius:18px;word-wrap:break-word;
        position:relative;box-shadow:0 1px 1px rgba(0,0,0,0.1);}
    .message.sent .message-bubble {background:#d1fae5;color:#065f46;}
    .message.received .message-bubble {background:#fff;color:#333;}
    .message-sender {font-size:11px;color:#64748b;margin-bottom:3px;padding:0 5px;}
    .message.sent .message-sender {text-align:right;}
    .message.received .message-sender {text-align:left;}
    .chat-input-area {display:flex;padding:15px;background:#fff;border-top:1px solid #ddd;}
    .chat-input-area input {flex:1;padding:10px;border:1px solid #e2e8f0;border-radius:20px;
        outline:none;font-size:14px;}
    .chat-input-area button {margin-left:10px;padding:10px 20px;background:#6366f1;color:white;
        border:none;border-radius:20px;cursor:pointer;font-weight:bold;transition:background 0.2s;}
    .chat-input-area button:hover {background:#4f46e5;}

    /* ======================= EMR 작성 스타일 ======================= */
    .language-btn {
        padding:12px 24px;border:2px solid #cbd5e0;background:white;border-radius:8px;
        font-size:16px;font-weight:500;cursor:pointer;transition:all 0.3s;
    }
    .language-btn:hover {border-color:#4299e1;background:#ebf8ff;}
    .language-btn.active {border-color:#4299e1;background:#4299e1;color:white;}
    .language-btn:disabled {opacity:0.5;cursor:not-allowed;}

    .emr-container {max-width:1400px;margin:20px auto;padding:20px;}
    .section-card {background:white;border-radius:12px;box-shadow:0 2px 8px rgba(0,0,0,0.1);
        padding:24px;margin-bottom:20px;}
    .section-title {font-size:18px;font-weight:bold;margin-bottom:16px;color:#2d3748;
        border-bottom:2px solid #4299e1;padding-bottom:8px;}

    .upload-section {background:#f0f9ff;border-left:4px solid #3b82f6;border-radius:8px;
        padding:20px;margin-bottom:20px;}
    .upload-box {border:2px dashed #cbd5e0;border-radius:8px;padding:30px 20px;text-align:center;
        background:white;cursor:pointer;transition:all 0.3s;}
    .upload-box:hover {border-color:#4299e1;background:#edf2f7;}
    .upload-box.dragover {border-color:#48bb78;background:#c6f6d5;}

    .recording-btn {
        width:120px;height:120px;border-radius:50%;border:none;font-size:32px;cursor:pointer;
        transition:all 0.3s;margin:20px auto;display:block;
    }
    .recording-btn.ready {background:#4299e1;color:white;}
    .recording-btn.recording {background:#f56565;color:white;
        animation:pulse 1.5s infinite;}
    @keyframes pulse {
        0%,100% {transform:scale(1);box-shadow:0 0 0 0 rgba(245,101,101,0.7);}
        50% {transform:scale(1.05);box-shadow:0 0 0 20px rgba(245,101,101,0);}
    }

    .status-text {text-align:center;font-size:16px;color:#718096;margin-top:12px;}
    .two-column {display:grid;grid-template-columns:1fr 1fr;gap:20px;}

    .reference-box {
        background:#f7fafc;border:1px solid #e2e8f0;border-radius:8px;padding:16px;
        max-height:400px;overflow-y:auto;white-space:pre-wrap;word-wrap:break-word;
    }

    .edit-box {
        width:100%;min-height:400px;padding:16px;border:2px solid #cbd5e0;border-radius:8px;
        font-family:'Courier New',monospace;font-size:14px;line-height:1.8;resize:vertical;
    }
    .edit-box:focus {outline:none;border-color:#4299e1;}

    .form-control {
        width:100%;padding:10px 12px;font-size:14px;border:1px solid #cbd5e0;border-radius:6px;
        transition:border-color 0.2s;
    }
    .form-control:focus {
        outline:none;border-color:#4299e1;
        box-shadow:0 0 0 3px rgba(66,153,225,0.1);
    }

    .form-label {display:block;font-weight:500;margin-bottom:6px;color:#4a5568;font-size:14px;}

    .btn-primary {
        background:#4299e1;color:white;border:none;padding:12px 24px;border-radius:8px;
        font-size:16px;cursor:pointer;transition:background 0.3s;
    }
    .btn-primary:hover:not(:disabled) {background:#3182ce;}
    .btn-primary:disabled {opacity:0.6;cursor:not-allowed;}

    .btn-secondary {
        background:#718096;color:white;border:none;padding:10px 20px;border-radius:6px;
        cursor:pointer;margin-right:8px;
    }
    .btn-success {
        background:#48bb78;color:white;border:none;padding:12px 32px;border-radius:8px;
        font-size:16px;font-weight:bold;cursor:pointer;
    }

    .alert {padding:12px 16px;border-radius:8px;margin-bottom:16px;}
    .alert-info {background:#bee3f8;color:#2c5282;border:1px solid #90cdf4;}
    .alert-success {background:#c6f6d5;color:#22543d;border:1px solid #9ae6b4;}

    .hidden {display:none;}

    .spinner {
        display:inline-block;width:20px;height:20px;border:3px solid rgba(255,255,255,.3);
        border-radius:50%;border-top-color:white;animation:spin 1s ease-in-out infinite;
    }
    @keyframes spin {to {transform:rotate(360deg);}}
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>

<script>
    /* ================ 상담(WebRTC + 채팅) 스크립트 ================ */
    const adviserConsult = {
        id: '${sessionScope.adviser.name}',
        stompClient: null,
        roomId: '1',
        peerConnection: null,
        localStream: null,
        websocket: null,
        configuration: { iceServers: [{ urls: 'stun:stun.l.google.com:19302' }] },

        init: async function () {
            if (!this.id) this.id = 'adviser_' + Math.floor(Math.random() * 100);

            $('#startButton').click(() => this.startCall());
            $('#endButton').click(() => this.endCall());
            await this.connectWebRTC();
            $('#patientArea').hide();

            this.connectChat();
            $('#sendto').click(() => this.sendMessage());
            $('#totext').keypress((e) => {
                if (e.which === 13) {
                    this.sendMessage();
                }
            });
        },

      connectChat: function () {
        // 1. [수정] 서버의 addEndpoint("/adviserchat")와 일치시킴
        // ${websocketurl} 뒤에 슬래시(/)가 포함되어 있다면 'adviserchat'만, 없다면 '/adviserchat'
        const socket = new SockJS('${websocketurl}adviserchat');

        this.stompClient = Stomp.over(socket);
        const self = this;

        this.stompClient.connect({}, function (frame) {
          console.log('Chat Connected: ' + frame);
          self.setChatConnected(true);

          // 2. [수정] 서버의 enableSimpleBroker("/advisersend")와 일치시킴
          // 기존: '/send/chat/' -> 변경: '/advisersend/chat/'
          self.stompClient.subscribe('/advisersend/chat/' + self.roomId, function (msg) {
            const data = JSON.parse(msg.body);
            if (data.sendid !== self.id) {
              self.addMessage(data.content1, 'received', data.sendid);
            }
          });

        }, function (error) {
          console.error('STOMP connection error:', error);
          self.setChatConnected(false);
        });
      },

        sendMessage: function () {
            const msg = $('#totext').val().trim();
            if (!msg) return;

            const msgData = JSON.stringify({
                sendid: this.id,
                receiveid: $('#target').val(),
                content1: msg
            });

            this.stompClient.send('/app/chat/to/' + this.roomId, {}, msgData);
            this.addMessage(msg, 'sent', this.id);
            $('#totext').val('');
        },

        addMessage:function(content, type, sender){
            const senderDisplay = (type === 'sent' ? '나' : sender);
            let messageHtml = '<div class="message ' + type + '">';
            messageHtml += '<div class="message-sender">' + senderDisplay + '</div>';
            messageHtml += '<div class="message-bubble">' + content + '</div>';
            messageHtml += '</div>';

            $('#chatMessages').append(messageHtml);
            $('#chatMessages').scrollTop($('#chatMessages')[0].scrollHeight);

            if (type === 'received' && chatCollapsed) {
                chatUnreadCount += 1;
                updateChatToggleBadge();
            }
        },

        setChatConnected: function (connected) {
            $('#status').text(connected ? 'Connected' : 'Disconnected');
        },

        connectWebRTC: function () {
            try {
                this.websocket = new WebSocket('${websocketurl}signal');
                this.websocket.onopen = () => {
                    console.log('WebRTC WebSocket connected');
                    this.updateConnectionStatus('WebSocket Connected');
                    this.sendSignalingMessage({ type: 'join', roomId: this.roomId });
                };
                this.setupWebSocketHandlers();
            } catch (error) {
                console.error('Error initializing WebRTC:', error);
                this.updateConnectionStatus('Error: ' + error.message);
            }
        },

        startCam: async function () {
            const stream = await navigator.mediaDevices.getUserMedia({
                video: { width: { ideal: 1280 }, height: { ideal: 720 } },
                audio: true
            });
            this.localStream = stream;
            document.getElementById('localVideo').srcObject = stream;
            document.getElementById('startButton').disabled = false;
        },

        startCall: async function () {
            try {
                if (!this.peerConnection || !this.localStream) {
                    await this.startCam();
                    await this.createPeerConnection();
                }

                const offer = await this.peerConnection.createOffer();
                await this.peerConnection.setLocalDescription(offer);
                this.sendSignalingMessage({ type: 'offer', data: offer, roomId: this.roomId });

                $('#startButton').hide();
                $('#endButton').show();
                $('#patientArea').show();
                $('#user').html('통화 시도 중 (Offer 전송)');
            } catch (error) {
                console.error('Error starting call:', error);
                this.updateConnectionStatus('Error starting call');
            }
        },

        endCall: function () {
            if (this.localStream) {
                this.localStream.getTracks().forEach(track => track.stop());
            }
            if (this.peerConnection) {
                this.peerConnection.close();
                this.peerConnection = null;
            }
            document.getElementById('remoteVideo').srcObject = null;
            $('#patientArea').hide();
            $('#startButton').show();
            $('#endButton').hide();
            this.updateConnectionStatus('Call Ended');
            $('#user').html('접속이 끊어졌습니다.');
            this.sendSignalingMessage({ type: 'bye', roomId: this.roomId });
        },

        sendSignalingMessage: function (message) {
            if (this.websocket?.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify(message));
            }
        },

        setupWebSocketHandlers: function () {
            this.websocket.onmessage = async (event) => {
                try {
                    const message = JSON.parse(event.data);
                    switch (message.type) {
                        case 'offer':
                            if (!this.peerConnection) {
                                await this.startCam();
                                await this.createPeerConnection();
                            }
                            await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
                            const answer = await this.peerConnection.createAnswer();
                            await this.peerConnection.setLocalDescription(answer);
                            this.sendSignalingMessage({ type: 'answer', data: answer, roomId: this.roomId });
                            $('#user').html('통화 연결됨 (Answer 전송)');
                            $('#startButton').hide();
                            $('#endButton').show();
                            $('#patientArea').show();
                            break;
                        case 'join':
                            $('#user').html('사용자가 방문하였습니다. Start Call 버튼을 눌러 통화를 시작하세요.');
                            $('#patientArea').show();
                            break;
                        case 'bye':
                            $('#user').html('상대방이 접속을 끊었습니다.');
                            if (this.localStream) this.localStream.getTracks().forEach(track => track.stop());
                            if (this.peerConnection) this.peerConnection.close();
                            this.peerConnection = null;
                            document.getElementById('remoteVideo').srcObject = null;
                            $('#patientArea').hide();
                            $('#startButton').show();
                            $('#endButton').hide();
                            this.updateConnectionStatus('Peer Disconnected');
                            break;
                        case 'answer':
                            await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
                            $('#user').html('연결되었습니다.');
                            break;
                        case 'ice-candidate':
                            if (this.peerConnection) {
                                await this.peerConnection.addIceCandidate(new RTCIceCandidate(message.data));
                            }
                            break;
                    }
                } catch (error) {
                    console.error('Error handling WebSocket message:', error);
                }
            };
            this.websocket.onclose = () => {
                console.log('WebRTC WebSocket Disconnected');
                this.updateConnectionStatus('WebSocket Disconnected');
            };
            this.websocket.onerror = (error) => {
                console.error('WebRTC WebSocket error:', error);
                this.updateConnectionStatus('WebSocket Error');
            };
        },

        createPeerConnection: function () {
            this.peerConnection = new RTCPeerConnection(this.configuration);
            if (this.localStream) {
                this.localStream.getTracks().forEach(track => {
                    this.peerConnection.addTrack(track, this.localStream);
                });
            }
            this.peerConnection.ontrack = (event) => {
                if (document.getElementById('remoteVideo') && event.streams[0]) {
                    document.getElementById('remoteVideo').srcObject = event.streams[0];
                }
            };
            this.peerConnection.onicecandidate = (event) => {
                if (event.candidate) {
                    this.sendSignalingMessage({ type: 'ice-candidate', data: event.candidate, roomId: this.roomId });
                }
            };
            this.peerConnection.onconnectionstatechange = () => {
                this.updateConnectionStatus('Connection: ' + this.peerConnection.connectionState);
            };
            return this.peerConnection;
        },

        updateConnectionStatus: function (status) {
            document.getElementById('connectionStatus').textContent = 'Status: ' + status;
        }
    };

    let chatCollapsed = true;
    let chatUnreadCount = 0;
    let templateCollapsed = true;

    function updateChatToggleBadge() {
        const badge = document.getElementById('chatToggleBadge');
        if (!badge) return;

        if (chatUnreadCount > 0) {
            badge.style.display = 'inline-flex';
            badge.textContent = chatUnreadCount > 99 ? '99+' : String(chatUnreadCount);
        } else {
            badge.style.display = 'none';
            badge.textContent = '';
        }
    }

    function toggleChat() {
        const chatSection = document.getElementById('chatSection');
        const btn = document.getElementById('chatToggleBtn');
        if (!chatSection || !btn) return;

        chatCollapsed = !chatCollapsed;

        const badge = document.getElementById('chatToggleBadge');

        if (chatCollapsed) {
            chatSection.classList.add('hidden');
            btn.classList.remove('active');
            btn.textContent = '환자 채팅 열기';
            if (badge) btn.appendChild(badge);
        } else {
            chatSection.classList.remove('hidden');
            btn.classList.add('active');
            btn.textContent = '환자 채팅 닫기';
            if (badge) btn.appendChild(badge);
            chatUnreadCount = 0;
            updateChatToggleBadge();
        }
    }

    function togglePdfPanel() {
        const panel = document.getElementById('uploadSection');
        const btn = document.getElementById('pdfToggleBtn');
        if (!panel || !btn) return;

        templateCollapsed = !templateCollapsed;

        if (templateCollapsed) {
            panel.classList.add('hidden');
            btn.classList.remove('active');
            btn.textContent = 'EMR 템플릿 추가 열기';
        } else {
            panel.classList.remove('hidden');
            btn.classList.add('active');
            btn.textContent = 'EMR 템플릿 추가 닫기';
        }
    }

    $(function () { adviserConsult.init(); });

    window.onbeforeunload = function (e) {
        e.preventDefault();
        adviserConsult.endCall();
    };

    /* ======================= EMR 작성 스크립트 ======================= */
    let mediaRecorder;
    let audioChunks = [];
    let isRecording = false;
    let audioBlob = null;
    let currentEmrId = null;
    let selectedLanguage = 'ko';

    document.addEventListener('DOMContentLoaded', function () {
        const uploadArea = document.getElementById('uploadArea');
        if (uploadArea) {
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
        }
    });

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
            const response = await fetch('/upload-template', {
                method: 'POST',
                body: formData
            });
            const result = await response.json();

            if (result.success) {
                uploadStatus.innerHTML = '<span style="color:#48bb78;font-weight:500;">' + result.message + '</span>';
                setTimeout(() => {
                    uploadStatus.style.display = 'none';
                    fileInput.value = '';
                }, 3000);
            } else {
                uploadStatus.innerHTML = '<span style="color:#f56565;font-weight:500;">' + result.message + '</span>';
            }
        } catch (error) {
            console.error('Error:', error);
            uploadStatus.innerHTML = '<span style="color:#f56565;font-weight:500;">업로드 중 오류가 발생했습니다.</span>';
        }
    }

    async function toggleRecording() {
        const recordBtn = document.getElementById('recordBtn');
        const statusText = document.getElementById('statusText');

        if (!isRecording) {
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
                    statusText.textContent = '녹음 완료. EMR 자동 생성 버튼을 클릭하세요.';
                    statusText.style.color = '#48bb78';
                };

                mediaRecorder.start();
                isRecording = true;

                recordBtn.className = 'recording-btn recording';
                recordBtn.textContent = '중지';
                statusText.textContent = '녹음 중... 다시 클릭하면 중지됩니다.';
                statusText.style.color = '#f56565';

            } catch (error) {
                console.error('마이크 접근 오류:', error);
                alert('마이크 접근 권한이 필요합니다.');
            }
        } else {
            mediaRecorder.stop();
            mediaRecorder.stream.getTracks().forEach(track => track.stop());
            isRecording = false;

            recordBtn.className = 'recording-btn ready';
            recordBtn.textContent = '녹음';
        }
    }

    function selectLanguage(lang) {
        selectedLanguage = lang;
        document.querySelectorAll('.language-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        document.querySelector('.language-btn[data-lang="' + lang + '"]').classList.add('active');
        console.log('선택된 언어:', lang);
    }

    async function generateEmr() {
        if (!audioBlob) {
            alert('먼저 음성을 녹음해주세요.');
            return;
        }

        const generateBtn = document.getElementById('generateBtn');
        const consultationId = document.getElementById('consultationId').value;
        const testResults = document.getElementById('testResults').value;
        const prescription = document.getElementById('prescription').value;
        const patientId = document.getElementById('targetPatientId').value;

        if (!patientId) {
            alert('환자 ID를 먼저 입력해주세요.');
            return;
        }

        const formData = new FormData();
        formData.append('audioFile', audioBlob, 'recording.wav');
        formData.append('language', selectedLanguage);
        formData.append('patientId', patientId);
        if (consultationId) formData.append('consultationId', consultationId);
        if (testResults) formData.append('testResults', testResults);
        if (prescription) formData.append('prescription', prescription);

        generateBtn.disabled = true;
        const langMessages = {
            ko: 'AI 생성 중 (한국어)...',
            en: 'Generating with AI (English)...'
        };
        generateBtn.innerHTML = '<span class="spinner"></span> ' + langMessages[selectedLanguage];

        try {
            const response = await fetch('/generate', {
                method: 'POST',
                body: formData
            });
            const result = await response.json();

            if (result.success) {
                currentEmrId = result.emrId;

                document.getElementById('sttTextBox').textContent = result.sttText || '변환된 내용 없음';
                document.getElementById('testResultsBox').textContent = result.testResults || '없음';
                document.getElementById('prescriptionBox').textContent = result.prescription || '없음';
                document.getElementById('emrDraft').value = result.aiDraft || '';

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

    async function saveEmr() {
        const saveBtn = document.getElementById('saveBtn');
        const finalRecord = document.getElementById('emrDraft').value.trim();

        if (!finalRecord) {
            alert('EMR 최종 기록이 비어있습니다.');
            return;
        }

        if (!confirm('최종 저장하시겠습니까? (DB에 영구 저장됩니다)')) {
            return;
        }

        saveBtn.disabled = true;
        saveBtn.innerHTML = '<span class="spinner"></span> 저장 중...';

        try {
            const params = new URLSearchParams({ finalRecord });
            const response = await fetch('/save', {
                method: 'POST',
                headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
                body: params
            });
            const result = await response.json();
            if (result.success) {
                alert('EMR이 성공적으로 저장되었습니다.');
                location.reload();
            } else {
                alert('오류: ' + result.message);
            }
        } catch (error) {
            alert('저장 중 오류가 발생했습니다.');
        } finally {
            saveBtn.disabled = false;
            saveBtn.innerHTML = '최종 저장';
        }
    }

    function resetForm() {
        if (!confirm('처음부터 다시 시작하시겠습니까?')) {
            return;
        }
        location.reload();
    }
</script>

<div class="col-sm-10">
  <h2>Adviser Consultation Center</h2>
  <h4 id="user">Start Call 버튼을 눌러 통화를 시작하세요</h4>

  <!-- ===== 상담(WebRTC) 영역 ===== -->
  <div class="adviser-webrtc-container">
    <div class="video-grid">
      <div class="video-wrapper" id="patientArea">
        <video id="remoteVideo" autoplay playsinline class="video-stream"></video>
        <div class="video-label">Patient Stream</div>
      </div>
      <div class="video-wrapper">
        <video id="localVideo" autoplay playsinline muted class="video-stream"></video>
        <div class="video-label">Adviser Stream</div>
      </div>
    </div>
    <div class="controls">
      <button id="startButton" class="control-button start-call">Start Call</button>
      <button id="endButton" class="control-button end-call" style="display:none;">End Call</button>
    </div>
    <div class="connection-status" id="connectionStatus">Status: Disconnected</div>
  </div>

  <!-- ===== 상담 채팅 영역 ===== -->
  <div class="chat-toggle-wrapper">
    <button id="chatToggleBtn" class="chat-toggle-btn" type="button" onclick="toggleChat()">
      환자 채팅 열기
      <span id="chatToggleBadge" class="chat-toggle-badge"></span>
    </button>
    <button id="pdfToggleBtn" class="chat-toggle-btn" type="button" onclick="togglePdfPanel()">
      EMR 템플릿 추가 열기
    </button>
  </div>

  <div id="chatSection" class="chat-container hidden">
    <div class="chat-header">
      환자와의 채팅 (Room: ${adviserConsult.roomId})
      <span style="float:right;font-size:12px;font-weight:normal">
        Chat Status: <span id="status">Disconnected</span>
      </span>
    </div>
    <div class="chat-messages" id="chatMessages"></div>
    <div class="chat-input-area">
      <input type="hidden" id="target" value="${adviserConsult.roomId}">
      <input type="text" id="totext" placeholder="메시지를 입력하세요..." autocomplete="off">
      <button id="sendto" type="button">전송</button>
    </div>
  </div>

  <!-- ===== EMR 작성 영역 ===== -->
  <div class="emr-container">
    <h3 style="margin-bottom:24px;">전자의무기록(EMR) 작성</h3>

    <!-- EMR 템플릿 업로드  -->
    <div class="upload-section hidden" id="uploadSection">
      <div class="section-title" style="border-color:#3b82f6;color:#1e40af;">
        EMR 템플릿 추가 (선택사항)
      </div>

      <div class="alert alert-info" style="margin-bottom:16px;">
        <strong>안내:</strong> EMR 작성 규칙이나 예시 문서를 업로드하면 AI가 더 정확한 EMR을 생성합니다.
        <br>
        <small>지원 형식: TXT, PDF, DOCX | 예시: "EMR_작성_가이드.txt", "진료기록_양식.pdf"</small>
      </div>

      <div class="upload-box" id="uploadArea"
           onclick="document.getElementById('templateFile').click()">
        <div style="font-size:48px;margin-bottom:12px;">📄</div>
        <p style="margin:0;color:#4a5568;font-weight:500;">
          EMR 템플릿 파일을 클릭하여 선택하거나 드래그하세요
        </p>
        <p style="margin:8px 0 0 0;color:#718096;font-size:14px;">
          업로드된 문서는 Vector DB에 저장되어 AI 생성에 활용됩니다
        </p>
      </div>

      <input type="file" id="templateFile" style="display:none;"
             accept=".txt,.pdf,.doc,.docx" onchange="uploadTemplate()">

      <div id="uploadStatus"
           style="margin-top:12px;text-align:center;display:none;"></div>
    </div>

    <!-- 녹음/입력 단계 -->
    <div class="section-card" id="recordingSection">
      <div class="section-title">상담 녹음</div>

      <div style="text-align:center;margin-bottom:20px;">
        <label class="form-label">EMR 작성 언어 선택</label>
        <div style="display:flex;justify-content:center;gap:10px;margin-top:8px;">
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
      <div class="status-text" id="statusText">녹음을 시작하려면 버튼을 클릭하세요.</div>

      <div style="margin-top:20px;text-align:center;">
        <label class="form-label">환자 ID</label>
        <input type="number" id="targetPatientId" class="form-control"
               style="max-width:300px;margin:8px auto;"
               placeholder="환자 ID 입력 (필수)">
      </div>

      <div style="margin-top:20px;text-align:center;">
        <label class="form-label">상담 ID (선택)</label>
        <input type="number" id="consultationId" class="form-control"
               style="max-width:300px;margin:8px auto;"
               placeholder="상담 ID 입력">
      </div>

      <div class="two-column" style="margin-top:20px;">
        <div>
          <label class="form-label">검사 결과</label>
          <textarea id="testResults" class="form-control" rows="4"
                    placeholder="예: MRI - 요추 4-5번 추간판 팽윤 소견&#10;X-ray - 특이 소견 없음"></textarea>
        </div>
        <div>
          <label class="form-label">처방 내역</label>
          <textarea id="prescription" class="form-control" rows="4"
                    placeholder="예: 소염진통제 200mg 1일 3회"></textarea>
        </div>
      </div>

      <div style="text-align:center;margin-top:20px;">
        <button class="btn-primary" id="generateBtn" onclick="generateEmr()" disabled>
          EMR 자동 생성
        </button>
      </div>
    </div>

    <div class="section-card hidden" id="resultSection">
      <div class="section-title">AI 생성 EMR 확인</div>

      <div class="alert alert-success">
        EMR이 생성되었습니다. 아래 내용을 확인하고 필요 시 수정한 후 저장하세요.
      </div>

      <div class="two-column">
        <div>
          <h6 style="font-weight:bold;margin-bottom:12px;">참고 정보 (읽기 전용)</h6>
          <div style="margin-bottom:16px;">
            <label style="font-weight:bold;display:block;margin-bottom:4px;">STT 변환 내용</label>
            <div class="reference-box" id="sttTextBox"></div>
          </div>
          <div style="margin-bottom:16px;">
            <label style="font-weight:bold;display:block;margin-bottom:4px;">검사 결과</label>
            <div class="reference-box" id="testResultsBox"></div>
          </div>
          <div>
            <label style="font-weight:bold;display:block;margin-bottom:4px;">처방 내역</label>
            <div class="reference-box" id="prescriptionBox"></div>
          </div>
        </div>

        <div>
          <h6 style="font-weight:bold;margin-bottom:12px;">EMR 내용 (편집 가능)</h6>
          <textarea class="edit-box" id="emrDraft"></textarea>
        </div>
      </div>

      <div style="text-align:center;margin-top:24px;">
        <button class="btn-secondary" onclick="resetForm()">처음으로</button>
        <button class="btn-success" id="saveBtn" onclick="saveEmr()">최종 저장</button>
      </div>
    </div>

  </div>
</div>
