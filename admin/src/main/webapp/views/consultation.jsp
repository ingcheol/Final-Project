<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%-- views/consultation.jsp --%>
<style>
  /* WebRTC 스타일 */
  .adviser-webrtc-container{max-width:1200px;margin:0 auto;padding:20px}
  .video-grid{display:grid;grid-template-columns:repeat(2,1fr);gap:20px;margin-bottom:20px}
  .video-wrapper{position:relative;width:100%;background:#000;border-radius:8px;overflow:hidden}
  .video-stream{width:100%;height:auto;aspect-ratio:16/9}
  .video-label{position:absolute;bottom:10px;left:10px;color:white;background:rgba(0,0,0,0.5);padding:5px 10px;border-radius:4px}
  .controls{display:flex;justify-content:center;gap:10px;margin:20px 0}
  .control-button{padding:10px 20px;border-radius:4px;border:none;cursor:pointer;font-size:16px}
  .start-call{background:#4CAF50;color:white}
  .end-call{background:#f44336;color:white}
  .connection-status{text-align:center;font-size:14px}

  /* 채팅 스타일 */
  .chat-container{margin-top:20px;border:1px solid #ddd;background:#f8fafc;border-radius:8px;overflow:hidden}
  .chat-header{background:linear-gradient(135deg, #667eea 0%, #764ba2 100%);color:white;padding:15px;font-weight:bold}
  .chat-messages{height:400px;overflow-y:auto;padding:20px;background:#f8fafc}
  .message{display:flex;margin-bottom:15px;align-items:flex-end}
  .message.sent{justify-content:flex-end}
  .message.received{justify-content:flex-start}
  .message-bubble{max-width:60%;padding:10px 15px;border-radius:18px;word-wrap:break-word;position:relative;box-shadow: 0 1px 1px rgba(0,0,0,0.1)}
  .message.sent .message-bubble{background:#d1fae5;color:#065f46} /* Green for sent */
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
  adviserConsult = {
    id:'${sessionScope.adviser.name}',
    stompClient:null,
    roomId:'1',
    peerConnection:null,
    localStream:null,
    websocket:null,
    configuration:{iceServers:[{urls:'stun:stun.l.google.com:19302'}]},

    init:async function(){
      if (!this.id) this.id = 'adviser_' + Math.floor(Math.random() * 100);

      $('#startButton').click(()=>this.startCall());
      $('#endButton').click(()=>this.endCall());
      await this.connectWebRTC();
      $('#patientArea').hide();

      this.connectChat();
      $('#sendto').click(()=>this.sendMessage());
      $('#totext').keypress((e)=>{
        if(e.which === 13){
          this.sendMessage();
        }
      });
    },

    // ===== 채팅 관련 수정된 부분 =====
    connectChat:function(){
      // [수정 1] 환자와 동일한 엔드포인트 사용 (adviserchat -> chat)
      let socket = new SockJS('${websocketurl}chat');
      this.stompClient = Stomp.over(socket);
      let self = this;

      this.stompClient.connect({}, function(frame){
        console.log('Chat Connected: ' + frame);
        self.setChatConnected(true);

        // [수정 2] 환자와 동일한 구독 주소 사용 (/advisersend/chat -> /send/chat)
        // 이렇게 해야 환자가 보낸 메시지도 받고, 내가 보낸 메시지가 서버를 거쳐 환자에게 가는 경로를 공유하게 됩니다.
        self.stompClient.subscribe('/send/chat/' + self.roomId, function(msg){
          const data = JSON.parse(msg.body);
          // 자신의 메시지가 아닌 경우에만 received로 표시
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
        'receiveid':$('#target').val(),
        'content1':msg
      });

      // 환자와 동일한 전송 주소 사용
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

    // ===== WebRTC 관련 메서드 (변경 없음) =====
    connectWebRTC:function(){
      try{
        this.websocket = new WebSocket('${websocketurl}signal');
        this.websocket.onopen = ()=>{
          console.log('WebRTC WebSocket connected');
          this.updateConnectionStatus('WebSocket Connected');
          this.sendSignalingMessage({type:'join',roomId:this.roomId});
        };
        this.setupWebSocketHandlers();
      }catch(error){
        console.error('Error initializing WebRTC:',error);
        this.updateConnectionStatus('Error: '+error.message);
      }
    },

    startCam:async function(){
      const stream = await navigator.mediaDevices.getUserMedia({
        video:{width:{ideal:1280},height:{ideal:720}},
        audio:true
      });
      this.localStream = stream;
      document.getElementById('localVideo').srcObject = stream;
      document.getElementById('startButton').disabled = false;
    },

    startCall:async function(){
      try{
        if(!this.peerConnection || !this.localStream){
          await this.startCam();
          await this.createPeerConnection();
        }

        const offer = await this.peerConnection.createOffer();
        await this.peerConnection.setLocalDescription(offer);
        this.sendSignalingMessage({type:'offer',data:offer,roomId:this.roomId});

        $('#startButton').hide();
        $('#endButton').show();
        $('#patientArea').show();
        $('#user').html("통화 시도 중 (Offer 전송)");
      }catch(error){
        console.error('Error starting call:',error);
        this.updateConnectionStatus('Error starting call');
      }
    },

    endCall:function(){
      if(this.localStream){
        this.localStream.getTracks().forEach(track=>track.stop());
      }
      if(this.peerConnection){
        this.peerConnection.close();
        this.peerConnection = null;
      }
      document.getElementById('remoteVideo').srcObject = null;
      $('#patientArea').hide();
      $('#startButton').show();
      $('#endButton').hide();
      this.updateConnectionStatus('Call Ended');
      $('#user').html("접속이 끊어 졌습니다.");
      this.sendSignalingMessage({type:'bye',roomId:this.roomId});
    },

    sendSignalingMessage:function(message){
      if(this.websocket?.readyState === WebSocket.OPEN){
        this.websocket.send(JSON.stringify(message));
      }
    },

    setupWebSocketHandlers:function(){
      this.websocket.onmessage = async(event)=>{
        try{
          const message = JSON.parse(event.data);
          switch(message.type){
            case 'offer':
              if(!this.peerConnection){
                await this.startCam();
                await this.createPeerConnection();
              }
              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              const answer = await this.peerConnection.createAnswer();
              await this.peerConnection.setLocalDescription(answer);
              this.sendSignalingMessage({type:'answer',data:answer,roomId:this.roomId});
              $('#user').html("통화 연결됨 (Answer 전송)");
              $('#startButton').hide();
              $('#endButton').show();
              $('#patientArea').show();
              break;
            case 'join':
              $('#user').html("사용자가 방문 하였습니다. Start Call 버튼을 눌러 통화를 시작하세요.");
              $('#patientArea').show();
              break;
            case 'bye':
              $('#user').html("상대방이 접속을 끊었습니다.");
              if(this.localStream) this.localStream.getTracks().forEach(track=>track.stop());
              if(this.peerConnection) this.peerConnection.close();
              this.peerConnection = null;
              document.getElementById('remoteVideo').srcObject = null;
              $('#patientArea').hide();
              $('#startButton').show();
              $('#endButton').hide();
              this.updateConnectionStatus('Peer Disconnected');
              break;
            case 'answer':
              await this.peerConnection.setRemoteDescription(new RTCSessionDescription(message.data));
              $('#user').html("연결 되었습니다.");
              break;
            case 'ice-candidate':
              if(this.peerConnection) {
                await this.peerConnection.addIceCandidate(new RTCIceCandidate(message.data));
              }
              break;
          }
        }catch(error){
          console.error('Error handling WebSocket message:',error);
        }
      };
      this.websocket.onclose = ()=>{
        console.log('WebRTC WebSocket Disconnected');
        this.updateConnectionStatus('WebSocket Disconnected');
      };
      this.websocket.onerror = (error)=>{
        console.error('WebRTC WebSocket error:',error);
        this.updateConnectionStatus('WebSocket Error');
      };
    },

    createPeerConnection:function(){
      this.peerConnection = new RTCPeerConnection(this.configuration);
      if(this.localStream) {
        this.localStream.getTracks().forEach(track=>{
          this.peerConnection.addTrack(track,this.localStream);
        });
      }
      this.peerConnection.ontrack = (event)=>{
        if(document.getElementById('remoteVideo') && event.streams[0]){
          document.getElementById('remoteVideo').srcObject = event.streams[0];
        }
      };
      this.peerConnection.onicecandidate = (event)=>{
        if(event.candidate){
          this.sendSignalingMessage({type:'ice-candidate',data:event.candidate,roomId:this.roomId});
        }
      };
      this.peerConnection.onconnectionstatechange = ()=>{
        this.updateConnectionStatus('Connection: '+this.peerConnection.connectionState);
      };
      return this.peerConnection;
    },

    updateConnectionStatus:function(status){
      document.getElementById('connectionStatus').textContent = 'Status: '+status;
    }
  }

  $(()=>adviserConsult.init());

  window.onbeforeunload = function(e){
    e.preventDefault();
    adviserConsult.endCall();
  };
</script>

<div class="col-sm-10">
  <h2>Adviser Consultation Center</h2>
  <h4 id="user">Start Call 버튼을 눌러 통화를 시작하세요</h4>

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

  <div class="chat-container">
    <div class="chat-header">
      💬 환자와의 채팅 (Room: ${adviserConsult.roomId})
      <span style="float:right;font-size:12px;font-weight:normal">Chat Status: <span id="status">Disconnected</span></span>
    </div>
    <div class="chat-messages" id="chatMessages">
    </div>
    <div class="chat-input-area">
      <input type="hidden" id="target" value="${adviserConsult.roomId}">
      <input type="text" id="totext" placeholder="메시지를 입력하세요..." autocomplete="off">
      <button id="sendto">전송</button>
    </div>
  </div>
</div>