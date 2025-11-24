<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- views/consul.jsp --%>
<style>
  /* WebRTC 스타일 (consultation.jsp와 동일) */
  .webrtc-container{max-width:1200px;margin:0 auto;padding:20px}
  .video-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin-bottom:20px}
  .video-wrapper{position:relative;width:100%;background:#000;border-radius:8px;overflow:hidden}
  .video-stream{width:100%;height:auto;aspect-ratio:16/9}
  .video-label{position:absolute;bottom:10px;left:10px;color:white;background:rgba(0,0,0,0.5);padding:5px 10px;border-radius:4px}
  .controls{display:flex;justify-content:center;gap:10px;margin:20px 0}
  .control-button{padding:10px 20px;border-radius:4px;border:none;cursor:pointer;font-size:16px}
  .start-call{background:#4CAF50;color:white}
  .end-call{background:#f44336;color:white}
  .connection-status{text-align:center;font-size:14px}

  /* 채팅 스타일 (consultation.jsp와 동일) */
  .chat-container{margin-top:20px;border:1px solid #ddd;background:#f8fafc;border-radius:8px;overflow:hidden}
  .chat-header{background:#6366f1;color:white;padding:15px;font-weight:bold}
  .chat-messages{height:400px;overflow-y:auto;padding:20px;background:#f8fafc}
  .message{display:flex;margin-bottom:15px;align-items:flex-end}
  .message.sent{justify-content:flex-end}
  .message.received{justify-content:flex-start}
  .message-bubble{max-width:60%;padding:10px 15px;border-radius:18px;word-wrap:break-word;position:relative;box-shadow: 0 1px 1px rgba(0,0,0,0.1)}
  .message.sent .message-bubble{background:#6366f1;color:white} /* Blue for sent */
  .message.received .message-bubble{background:#fff;color:#333} /* White for received */
  .message-sender{font-size:11px;color:#64748b;margin-bottom:3px;padding:0 5px}
  .message.sent .message-sender{text-align:right}
  .message.received .message-sender{text-align:left}
  .chat-input-area{display:flex;padding:15px;background:#fff;border-top:1px solid #ddd}
  .chat-input-area input{flex:1;padding:10px;border:1px solid #e2e8f0;border-radius:20px;outline:none;font-size:14px}
  .chat-input-area button{margin-left:10px;padding:10px 20px;background:#6366f1;color:white;border:none;border-radius:20px;cursor:pointer;font-weight:bold;transition: background 0.2s}
  .chat-input-area button:hover{background:#4f46e5}
</style>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/sockjs-client/1.5.1/sockjs.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/stomp.js/2.3.3/stomp.min.js"></script>
<script>
  patientConsult = {
    id:'${sessionScope.patient.name}' || 'patient_' + Math.floor(Math.random() * 1000),
    stompClient:null,
    roomId:'1',
    peerConnection:null,
    localStream:null,
    websocket:null,
    configuration:{iceServers:[{urls:'stun:stun.l.google.com:19302'}]},

    init:async function(){
      console.log('Patient Init - ID:', this.id);

      // WebRTC 초기화
      $('#startButton').click(()=>this.startCall());
      $('#endButton').click(()=>this.endCall());
      $('#adviserArea').hide();

      // 채팅 초기화
      this.connectChat();
      $('#sendto').click(()=>this.sendMessage());
      $('#totext').keypress((e)=>{
        if(e.which === 13){
          this.sendMessage();
        }
      });

      // WebRTC 연결 후 자동 통화 시작
      await this.connectWebRTC();
    },

    connectChat:function(){
      let socket = new SockJS('${websocketurl}chat');
      this.stompClient = Stomp.over(socket);
      let self = this;

      this.stompClient.connect({}, function(frame){
        console.log('Patient Chat Connected: ' + frame);
        self.setChatConnected(true);

        // 방 채팅 구독
        self.stompClient.subscribe('/send/chat/' + self.roomId, function(msg){
          const data = JSON.parse(msg.body);
          console.log('Received room message:', data);

          if (data.sendid !== self.id) {
            self.addMessage(data.content1, 'received', data.sendid);
          }
        });

      }, function(error){
        console.error('STOMP connection error:', error);
        self.setChatConnected(false);
      });
    },

    sendMessage:function(){
      const msg = $('#totext').val().trim();
      if(!msg) return;

      var msgData = JSON.stringify({
        'sendid':this.id,
        'receiveid':this.roomId,
        'content1':msg
      });

      console.log('Sending message:', msgData);
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
    },

    setChatConnected:function(connected){
      $("#status").text(connected?"Connected":"Disconnected");
    },

    connectWebRTC:async function(){
      try{
        this.websocket = new WebSocket('${websocketurl}signal');

        this.websocket.onopen = ()=>{
          console.log('Patient WebRTC WebSocket connected');
          this.updateConnectionStatus('WebSocket Connected');
          this.sendSignalingMessage({type:'join',roomId:this.roomId});

          // Join 후 1초 대기 후 통화 시작
          setTimeout(() => {
            this.startCall();
          }, 1000);
        };

        this.setupWebSocketHandlers();
      }catch(error){
        console.error('Error initializing WebRTC:',error);
        this.updateConnectionStatus('Error: '+error.message);
      }
    },

    startCam:async function(){
      try {
        const stream = await navigator.mediaDevices.getUserMedia({
          video:{width:{ideal:1280},height:{ideal:720}},
          audio:true
        });
        this.localStream = stream;
        document.getElementById('localVideo').srcObject = stream;
        console.log('Camera started successfully');
      } catch(error) {
        console.error('Error accessing camera:', error);
        alert('카메라 접근 권한이 필요합니다.');
        throw error;
      }
    },

    startCall:async function(){
      try{
        console.log('Patient starting call...');

        if(!this.localStream){
          await this.startCam();
        }

        if(!this.peerConnection){
          await this.createPeerConnection();
        }

        const offer = await this.peerConnection.createOffer();
        await this.peerConnection.setLocalDescription(offer);

        console.log('Patient sending offer:', offer);
        this.sendSignalingMessage({type:'offer',data:offer,roomId:this.roomId});

        $('#startButton').hide();
        $('#endButton').show();
        $('#adviserArea').show();
        $('#user').html("통화 시도 중 (Offer 전송)");
      }catch(error){
        console.error('Error starting call:',error);
        this.updateConnectionStatus('Error: ' + error.message);
      }
    },

    endCall:function(){
      console.log('Patient ending call');

      if(this.localStream){
        this.localStream.getTracks().forEach(track=>track.stop());
        this.localStream = null;
      }
      if(this.peerConnection){
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

      this.sendSignalingMessage({type:'bye',roomId:this.roomId});
    },

    sendSignalingMessage:function(message){
      if(this.websocket?.readyState === WebSocket.OPEN){
        const msgStr = JSON.stringify(message);
        console.log('Patient sending signaling message:', msgStr);
        this.websocket.send(msgStr);
      } else {
        console.error('WebSocket is not open. ReadyState:', this.websocket?.readyState);
      }
    },

    setupWebSocketHandlers:function(){
      this.websocket.onmessage = async(event)=>{
        try{
          const message = JSON.parse(event.data);
          console.log('Patient received message:', message);

          switch(message.type){
            case 'offer':
              console.log('Patient received offer');
              if(!this.localStream){
                await this.startCam();
              }
              if(!this.peerConnection){
                await this.createPeerConnection();
              }

              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              const answer = await this.peerConnection.createAnswer();
              await this.peerConnection.setLocalDescription(answer);

              console.log('Patient sending answer:', answer);
              this.sendSignalingMessage({type:'answer',data:answer,roomId:this.roomId});

              $('#user').html("통화 연결됨");
              $('#startButton').hide();
              $('#endButton').show();
              $('#adviserArea').show();
              break;

            case 'answer':
              console.log('Patient received answer');
              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              $('#user').html("통화가 연결되었습니다.");
              break;

            case 'ice-candidate':
              if(this.peerConnection && message.data) {
                console.log('Patient received ICE candidate');
                await this.peerConnection.addIceCandidate(new RTCIceCandidate(message.data));
              }
              break;

            case 'join':
              console.log('Adviser joined the room');
              $('#user').html("상담사가 접속했습니다.");
              break;

            case 'bye':
              console.log('Adviser left');
              $('#user').html("상담사가 연결을 종료했습니다.");
              if(this.localStream) {
                this.localStream.getTracks().forEach(track=>track.stop());
                this.localStream = null;
              }
              if(this.peerConnection) {
                this.peerConnection.close();
                this.peerConnection = null;
              }
              document.getElementById('remoteVideo').srcObject = null;
              $('#adviserArea').hide();
              $('#startButton').show();
              $('#endButton').hide();
              break;
          }
        }catch(error){
          console.error('Error handling WebSocket message:',error);
        }
      };

      this.websocket.onclose = ()=>{
        console.log('Patient WebRTC WebSocket Disconnected');
        this.updateConnectionStatus('WebSocket Disconnected');
      };

      this.websocket.onerror = (error)=>{
        console.error('Patient WebRTC WebSocket error:',error);
        this.updateConnectionStatus('WebSocket Error');
      };
    },

    createPeerConnection:function(){
      console.log('Patient creating peer connection');
      this.peerConnection = new RTCPeerConnection(this.configuration);

      if(this.localStream) {
        this.localStream.getTracks().forEach(track=>{
          console.log('Adding track to peer connection:', track.kind);
          this.peerConnection.addTrack(track,this.localStream);
        });
      }

      this.peerConnection.ontrack = (event)=>{
        console.log('Patient received remote track:', event.track.kind);
        if(document.getElementById('remoteVideo') && event.streams[0]){
          document.getElementById('remoteVideo').srcObject = event.streams[0];
          $('#adviserArea').show();
          $('#user').html("상담사 영상이 연결되었습니다.");
        }
      };

      this.peerConnection.onicecandidate = (event)=>{
        if(event.candidate){
          console.log('Patient sending ICE candidate');
          this.sendSignalingMessage({
            type:'ice-candidate',
            data:event.candidate,
            roomId:this.roomId
          });
        }
      };

      this.peerConnection.onconnectionstatechange = ()=>{
        console.log('Patient connection state:', this.peerConnection.connectionState);
        this.updateConnectionStatus('Connection: '+this.peerConnection.connectionState);

        if(this.peerConnection.connectionState === 'connected'){
          $('#user').html("통화 연결 완료!");
        }
      };

      this.peerConnection.oniceconnectionstatechange = ()=>{
        console.log('Patient ICE connection state:', this.peerConnection.iceConnectionState);
      };

      return this.peerConnection;
    },

    updateConnectionStatus:function(status){
      document.getElementById('connectionStatus').textContent = 'Status: '+status;
    }
  }

  $(()=>patientConsult.init());

  window.onbeforeunload = function(e){
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
    <div class="chat-header">
      💬 상담사와의 채팅 (Room: ${patientConsult.roomId})
      <span style="float:right;font-size:12px;font-weight:normal">Chat Status: <span id="status">Disconnected</span></span>
    </div>
    <div class="chat-messages" id="chatMessages">
      <!-- 메시지가 여기에 표시됩니다 -->
    </div>
    <div class="chat-input-area">
      <input type="hidden" id="target" value="${patientConsult.roomId}">
      <input type="text" id="totext" placeholder="메시지를 입력하세요..." autocomplete="off">
      <button id="sendto">전송</button>
    </div>
  </div>
</div>