<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<style>
    /* WebRTC 스타일 */
    .webrtc-container {
        max-width: 1200px;
        margin: 0 auto;
        padding: 20px
    }

    .video-grid {
        display: grid;
        grid-template-columns:repeat(2, 1fr);
        gap: 20px;
        margin-bottom: 20px
    }

    .video-wrapper {
        position: relative;
        width: 100%;
        background: #000;
        border-radius: 8px;
        overflow: hidden
    }

    .video-stream {
        width: 100%;
        height: auto;
        aspect-ratio: 16/9
    }

    .video-label {
        position: absolute;
        bottom: 10px;
        left: 10px;
        color: white;
        background: rgba(0, 0, 0, 0.5);
        padding: 5px 10px;
        border-radius: 4px
    }

    .controls {
        display: flex;
        justify-content: center;
        gap: 10px;
        margin: 20px 0
    }

    .control-button {
        padding: 10px 20px;
        border-radius: 4px;
        border: none;
        cursor: pointer;
        font-size: 16px
    }

    .start-call {
        background: #4CAF50;
        color: white
    }

    .end-call {
        background: #f44336;
        color: white
    }

    .connection-status {
        text-align: center;
        font-size: 14px
    }

    /* 채팅 스타일 */
    .chat-container {
        margin-top: 20px;
        border: 1px solid #ddd;
        background: #f8fafc;
        border-radius: 8px;
        overflow: hidden
    }

    .chat-header {
        background: #6366f1;
        color: white;
        padding: 15px;
        font-weight: bold
    }

    .chat-messages {
        height: 400px;
        overflow-y: auto;
        padding: 20px;
        background: #f8fafc
    }

    .message {
        display: flex;
        margin-bottom: 15px;
        align-items: flex-end
    }

    .message.sent {
        justify-content: flex-end
    }

    .message.received {
        justify-content: flex-start
    }

    .message-bubble {
        max-width: 60%;
        padding: 10px 15px;
        border-radius: 18px;
        word-wrap: break-word;
        position: relative;
        box-shadow: 0 1px 1px rgba(0, 0, 0, 0.1)
    }

    .message.sent .message-bubble {
        background: #6366f1;
        color: white
    }

    .message.received .message-bubble {
        background: #fff;
        color: #333
    }

    .message-sender {
        font-size: 11px;
        color: #64748b;
        margin-bottom: 3px;
        padding: 0 5px
    }

    .message.sent .message-sender {
        text-align: right
    }

    .message.received .message-sender {
        text-align: left
    }

    .chat-input-area {
        display: flex;
        padding: 15px;
        background: #fff;
        border-top: 1px solid #ddd
    }

    .chat-input-area input {
        flex: 1;
        padding: 10px;
        border: 1px solid #e2e8f0;
        border-radius: 20px;
        outline: none;
        font-size: 14px
    }

    .chat-input-area button {
        margin-left: 10px;
        padding: 10px 20px;
        background: #6366f1;
        color: white;
        border: none;
        border-radius: 20px;
        cursor: pointer;
        font-weight: bold;
        transition: background 0.2s
    }

    .chat-input-area button:hover {
        background: #4f46e5
    }
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
    patientConsult = {
        // 환자 정보 및 연결 설정
        id: '${sessionScope.patient.name}' || 'patient_' + Math.floor(Math.random() * 1000),
        stompClient: null,
        roomId: '1',
        peerConnection: null,
        localStream: null,
        websocket: null,
        configuration: {iceServers: [{urls: 'stun:stun.l.google.com:19302'}]},

        // 음성 입력 관련 변수
        chatRecorder: null,
        chatChunks: [],
        isChatRecording: false,

        init: async function () {
            // WebRTC 버튼 이벤트 등록
            $('#startButton').click(() => this.startCall());
            $('#endButton').click(() => this.endCall());
            $('#adviserArea').hide();

            // 채팅 연결 초기화
            this.connectChat();

            // 채팅 입력 이벤트 등록
            $('#sendto').click(() => this.sendMessage());
            $('#totext').keypress((e) => {
                if (e.which === 13) {
                    this.sendMessage();
                }
            });

            // 음성 입력 버튼 초기화
            this.initVoiceInput();

            // WebRTC 연결
            await this.connectWebRTC();
        },

        // 음성 입력 기능 초기화
        initVoiceInput: function () {
            const chatMicBtn = document.getElementById('chatMicBtn');
            if (!chatMicBtn) return;

            const self = this;

            chatMicBtn.addEventListener('click', async (e) => {
                e.preventDefault();

                if (!self.isChatRecording) {
                    // 녹음 시작
                    try {
                        const stream = await navigator.mediaDevices.getUserMedia({audio: true});
                        self.chatRecorder = new MediaRecorder(stream);
                        self.chatChunks = [];

                        self.chatRecorder.ondataavailable = (e) => self.chatChunks.push(e.data);

                        self.chatRecorder.onstop = async () => {
                            const audioBlob = new Blob(self.chatChunks, {type: 'audio/webm'});
                            const formData = new FormData();
                            formData.append("audio", audioBlob, "recording.webm");

                            // 처리 중 UI 업데이트
                            chatMicBtn.style.backgroundColor = "#95a5a6";
                            chatMicBtn.textContent = "⏳";

                            try {
                                const sttResponse = await fetch('/api/chat-support/stt', {
                                    method: 'POST',
                                    body: formData
                                });
                                const sttData = await sttResponse.json();

                                if (sttData.status === 'success' && sttData.text) {
                                    const myLang = $('#myLanguage').val();

                                    const translateResponse = await fetch('/api/chat-support/translate', {
                                        method: 'POST',
                                        headers: {'Content-Type': 'application/json'},
                                        body: JSON.stringify({
                                            text: sttData.text,
                                            targetLang: myLang  // ← 선택한 언어로 번역
                                        })
                                    });
                                    const translateData = await translateResponse.json();

                                    const finalText = translateData.translatedText || sttData.text;
                                    $('#totext').val(finalText);
                                    self.sendMessage();
                                } else {
                                    alert("음성 인식 실패");
                                }
                            } catch (error) {
                                console.error("음성 처리 오류:", error);
                                alert("음성 처리 중 오류가 발생했습니다.");
                            } finally {
                                // UI 원상복구
                                chatMicBtn.style.backgroundColor = "#e74c3c";
                                chatMicBtn.textContent = "🎙️";
                                stream.getTracks().forEach(track => track.stop());
                            }
                        };

                        self.chatRecorder.start();
                        self.isChatRecording = true;
                        chatMicBtn.style.backgroundColor = "#c0392b";
                        chatMicBtn.textContent = "⏹️";

                    } catch (err) {
                        console.error("마이크 권한 오류:", err);
                        alert("마이크 권한을 허용해주세요.");
                    }
                } else {
                    // 녹음 종료
                    if (self.chatRecorder && self.chatRecorder.state !== 'inactive') {
                        self.chatRecorder.stop();
                    }
                    self.isChatRecording = false;
                }
            });
        },

        // 채팅 서버 연결
        connectChat: function () {
            let socket = new SockJS('/chat');
            this.stompClient = Stomp.over(socket);
            let self = this;

            this.stompClient.connect({}, function (frame) {
                self.setChatConnected(true);

                const subscriptionPath = '/send/chat/' + self.roomId;
                self.stompClient.subscribe(subscriptionPath, function (msg) {
                    const data = JSON.parse(msg.body);
                    if (data.sendid !== self.id) {
                        self.addMessage(data.content1, 'received', data.sendid);
                    }
                });

            }, function (error) {
                console.error('채팅 연결 오류:', error);
                self.setChatConnected(false);

                // 3초 후 재연결 시도
                setTimeout(function () {
                    self.connectChat();
                }, 3000);
            });
        },

        // 메시지 전송
        sendMessage: function () {
            const msg = $('#totext').val().trim();
            if (!msg) return;

            const msgData = JSON.stringify({
                'sendid': this.id,
                'receiveid': this.roomId,
                'content1': msg
            });

            this.stompClient.send('/app/chat/to/' + this.roomId, {}, msgData);
            this.addMessage(msg, 'sent', this.id);
            $('#totext').val('');
        },

        // 메시지 표시 (번역 포함)
        addMessage: async function (content, type, sender) {
            const senderDisplay = (type === 'sent' ? '나' : sender);
            let msgContent = content;
            let extraHtml = '';

            // 받은 메시지는 번역 시도
            if (type === 'received') {
                const myLang = $('#myLanguage').val();

                try {
                    const response = await fetch('/api/chat-support/translate', {
                        method: 'POST',
                        headers: {'Content-Type': 'application/json'},
                        body: JSON.stringify({text: content, targetLang: myLang})
                    });
                    const data = await response.json();

                    if (data.translatedText) {
                        const safeText = data.translatedText.replace(/'/g, "\\'").replace(/"/g, '\\"');
                        extraHtml =
                            '<hr style="margin: 5px 0; border: 0; border-top: 1px dashed rgba(0,0,0,0.2);">' +
                            '<div style="font-weight:bold; display:flex; align-items:center; gap:5px; color:#2c3e50;">' +
                            '<span>' + data.translatedText + '</span>' +
                            '<button onclick="playTTS(\'' + safeText + '\')" style="background:none; border:none; cursor:pointer; font-size:14px;">🔊</button>' +
                            '</div>';
                    }
                } catch (e) {
                    console.error("번역 실패", e);
                }
            }

            // 메시지 HTML 구성
            let messageHtml = '<div class="message ' + type + '">';
            messageHtml += '<div class="message-sender">' + senderDisplay + '</div>';
            messageHtml += '<div class="message-bubble">';
            messageHtml += msgContent;
            messageHtml += extraHtml;
            messageHtml += '</div></div>';

            $('#chatMessages').append(messageHtml);
            $('#chatMessages').scrollTop($('#chatMessages')[0].scrollHeight);
        },

        // 채팅 연결 상태 표시
        setChatConnected: function (connected) {
            $("#status").text(connected ? "Connected" : "Disconnected");
        },

        // WebRTC 연결 초기화
        connectWebRTC: async function () {
            try {
                const wsUrl = window.location.protocol === 'https:'
                    ? 'wss://' + window.location.host + '/signal'
                    : 'ws://' + window.location.host + '/signal';

                this.websocket = new WebSocket(wsUrl);

                this.websocket.onopen = () => {
                    this.updateConnectionStatus('WebSocket Connected');
                    this.sendSignalingMessage({type: 'join', roomId: this.roomId});

                    // 1초 후 통화 시작
                    setTimeout(() => {
                        this.startCall();
                    }, 1000);
                };

                this.setupWebSocketHandlers();
            } catch (error) {
                console.error('WebRTC 초기화 오류:', error);
                this.updateConnectionStatus('Error: ' + error.message);
            }
        },

        // 카메라 시작
        startCam: async function () {
            try {
                const stream = await navigator.mediaDevices.getUserMedia({
                    video: {width: {ideal: 1280}, height: {ideal: 720}},
                    audio: true
                });
                this.localStream = stream;
                document.getElementById('localVideo').srcObject = stream;
            } catch (error) {
                console.error('카메라 접근 오류:', error);
                alert('카메라 접근 권한이 필요합니다.');
                throw error;
            }
        },

        // 통화 시작
        startCall: async function () {
            try {
                if (!this.localStream) {
                    await this.startCam();
                }

                if (!this.peerConnection) {
                    await this.createPeerConnection();
                }

                const offer = await this.peerConnection.createOffer();
                await this.peerConnection.setLocalDescription(offer);

                this.sendSignalingMessage({type: 'offer', data: offer, roomId: this.roomId});

                $('#startButton').hide();
                $('#endButton').show();
                $('#adviserArea').show();
                $('#user').html("통화 시도 중");
            } catch (error) {
                console.error('통화 시작 오류:', error);
                this.updateConnectionStatus('Error: ' + error.message);
            }
        },

        // 통화 종료
        endCall: function () {
            if (this.localStream) {
                this.localStream.getTracks().forEach(track => track.stop());
                this.localStream = null;
            }
            if (this.peerConnection) {
                this.peerConnection.close();
                this.peerConnection = null;
            }

            document.getElementById('localVideo').srcObject = null;
            document.getElementById('remoteVideo').srcObject = null;

            $('#adviserArea').hide();
            $('#startButton').show();
            $('#endButton').hide();
            this.updateConnectionStatus('Call Ended');
            $('#user').html("통화가 종료되었습니다.");

            this.sendSignalingMessage({type: 'bye', roomId: this.roomId});
        },

        // 시그널링 메시지 전송
        sendSignalingMessage: function (message) {
            if (this.websocket?.readyState === WebSocket.OPEN) {
                this.websocket.send(JSON.stringify(message));
            }
        },

        // WebSocket 이벤트 핸들러 설정
        setupWebSocketHandlers: function () {
            this.websocket.onmessage = async (event) => {
                try {
                    const message = JSON.parse(event.data);

                    switch (message.type) {
                        case 'offer':
                            if (!this.localStream) {
                                await this.startCam();
                            }
                            if (!this.peerConnection) {
                                await this.createPeerConnection();
                            }

                            await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
                            const answer = await this.peerConnection.createAnswer();
                            await this.peerConnection.setLocalDescription(answer);

                            this.sendSignalingMessage({type: 'answer', data: answer, roomId: this.roomId});

                            $('#user').html("통화 연결됨");
                            $('#startButton').hide();
                            $('#endButton').show();
                            $('#adviserArea').show();
                            break;

                        case 'answer':
                            await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
                            $('#user').html("통화가 연결되었습니다.");
                            break;

                        case 'ice-candidate':
                            if (this.peerConnection && message.data) {
                                await this.peerConnection.addIceCandidate(new RTCIceCandidate(message.data));
                            }
                            break;

                        case 'join':
                            $('#user').html("상담사가 접속했습니다.");
                            break;

                        case 'bye':
                            $('#user').html("상담사가 연결을 종료했습니다.");
                            if (this.localStream) {
                                this.localStream.getTracks().forEach(track => track.stop());
                                this.localStream = null;
                            }
                            if (this.peerConnection) {
                                this.peerConnection.close();
                                this.peerConnection = null;
                            }
                            document.getElementById('remoteVideo').srcObject = null;
                            $('#adviserArea').hide();
                            $('#startButton').show();
                            $('#endButton').hide();
                            break;
                    }
                } catch (error) {
                    console.error('WebSocket 메시지 처리 오류:', error);
                }
            };

            this.websocket.onclose = () => {
                this.updateConnectionStatus('WebSocket Disconnected');
            };

            this.websocket.onerror = (error) => {
                console.error('WebSocket 오류:', error);
                this.updateConnectionStatus('WebSocket Error');
            };
        },

        // Peer Connection 생성
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
                    $('#adviserArea').show();
                    $('#user').html("상담사 영상이 연결되었습니다.");
                }
            };

            this.peerConnection.onicecandidate = (event) => {
                if (event.candidate) {
                    this.sendSignalingMessage({
                        type: 'ice-candidate',
                        data: event.candidate,
                        roomId: this.roomId
                    });
                }
            };

            this.peerConnection.onconnectionstatechange = () => {
                this.updateConnectionStatus('Connection: ' + this.peerConnection.connectionState);
                if (this.peerConnection.connectionState === 'connected') {
                    $('#user').html("통화 연결 완료!");
                }
            };

            return this.peerConnection;
        },

        // 연결 상태 업데이트
        updateConnectionStatus: function (status) {
            document.getElementById('connectionStatus').textContent = 'Status: ' + status;
        }
    };

    // TTS 재생 (전역 함수)
    function playTTS(text) {
        if (!text) return;
        fetch('/api/chat-support/tts', {
            method: 'POST',
            headers: {'Content-Type': 'application/json'},
            body: JSON.stringify({text: text})
        })
            .then(res => res.json())
            .then(data => {
                if (data.audio) {
                    const audio = new Audio("data:audio/mp3;base64," + data.audio);
                    audio.play();
                }
            })
            .catch(err => console.error("TTS 오류:", err));
    }

    // 페이지 로드 후 초기화
    $(function () {
        patientConsult.init();
    });

    // 페이지 이탈 시 통화 종료
    window.onbeforeunload = function (e) {
        patientConsult.endCall();
    };
</script>

<div class="col-sm-10">
  <h2>Patient Chat & Video Consultation</h2>
  <h4 id="user">상담사 연결 대기 중...</h4>

  <!-- 영상통화 영역 -->
  <div class="webrtc-container">
    <div class="video-grid">
      <div class="video-wrapper" id="adviserArea">
        <video id="remoteVideo" autoplay playsinline class="video-stream"></video>
        <div class="video-label">Adviser Stream</div>
      </div>
      <div class="video-wrapper">
        <video id="localVideo" autoplay playsinline muted class="video-stream"></video>
        <div class="video-label">Patient Stream</div>
      </div>
    </div>
    <div class="controls">
      <button id="startButton" class="control-button start-call" style="display:none;">Start Call</button>
      <button id="endButton" class="control-button end-call" style="display:none;">End Call</button>
    </div>
    <div class="connection-status" id="connectionStatus">Status: Disconnected</div>
  </div>

  <!-- 채팅 영역 -->
  <div class="chat-container">
    <div class="chat-header" style="display:flex; justify-content:space-between; align-items:center;">
      <span>💬 상담사와의 채팅 (Room: ${patientConsult.roomId})</span>
      <select id="myLanguage" style="font-size:12px; padding:2px; border-radius:4px; border:none; color:#333;">
        <option value="Korean" selected>전송할 언어: 한국어</option>
        <option value="English">전송할 언어: English</option>
        <option value="Japanese">전송할 언어: 日本語</option>
        <option value="Chinese">전송할 언어: 中文</option>
      </select>
    </div>
    <div class="chat-messages" id="chatMessages"></div>
    <div class="chat-input-area">
      <input type="hidden" id="target" value="${patientConsult.roomId}">
      <button id="chatMicBtn" style="margin-right:8px; background:#e74c3c; width:40px; padding:0;" title="음성 입력">🎤
      </button>
      <input type="text" id="totext" placeholder="메시지를 입력하세요..." autocomplete="off">
      <button id="sendto">전송</button>
    </div>
  </div>
</div>