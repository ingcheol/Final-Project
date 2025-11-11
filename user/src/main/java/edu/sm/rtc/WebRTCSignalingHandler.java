package edu.sm.rtc;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Slf4j
public class WebRTCSignalingHandler extends TextWebSocketHandler {
    private final ObjectMapper objectMapper = new ObjectMapper();
    private final Map<String, WebSocketSession> sessions = new ConcurrentHashMap<>();
    private final Map<String, String> roomSessions = new ConcurrentHashMap<>();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) {
        log.info("New WebSocket connection established: {}", session.getId());
    }

    @Override
    public void handleTextMessage(WebSocketSession wsession, TextMessage message) {
        try {
            log.info("Received message from client {}: {}", wsession.getId(), message.getPayload());

            SignalMessage signalMessage = objectMapper.readValue(message.getPayload(), SignalMessage.class);
            String roomId = signalMessage.getRoomId();

            log.info("Processing {} message for room: {}", signalMessage.getType(), roomId);

            switch (signalMessage.getType()) {
                case "join":
                    handleJoinMessage(wsession, roomId);
                    signalMessage.setType("join");
                    broadcastToRoom(wsession, new TextMessage(objectMapper.writeValueAsString(signalMessage)), roomId);
                    break;
                case "bye":
                    log.info("Received bye from: {}", wsession.getId());
//                    Map<String, Object> chatData = new HashMap<>();
//                    chatData.put("content", "Bye ...");
//                    signalMessage.setData(chatData);
                    signalMessage.setType("bye");
                    broadcastToRoom(wsession, new TextMessage(objectMapper.writeValueAsString(signalMessage)), roomId);
                    break;
                case "offer":
                    log.info("1Received offer from: {}", wsession.getId());
                    log.info("2Received offer from: {}", message);
                    broadcastToRoom(wsession, message, roomId);
                    break;
                case "answer":
                    log.info("Received answer from: {}", wsession.getId());
                    broadcastToRoom(wsession, message, roomId);
                    break;
                case "ice-candidate":
                    log.info("Received ICE candidate from: {}", wsession.getId());
                    broadcastToRoom(wsession, message, roomId);
                    break;
                default:
                    log.warn("Unknown message type: {}", signalMessage.getType());
            }
        } catch (Exception e) {
            log.error("Error handling message: ", e);
        }
    }

    private void broadcastToRoom(WebSocketSession sender, TextMessage message, String roomId) {
        sessions.forEach((sessionId, webSocketSession) -> {
            if (!sender.getId().equals(sessionId) &&
                    roomId.equals(roomSessions.get(sessionId))) {
                try {
                    log.info("Broadcasting message to session {} in room {}", sessionId, roomId);
                    webSocketSession.sendMessage(message);
                } catch (IOException e) {
                    log.error("Error sending message to session {}: {}", sessionId, e.getMessage());
                }
            }
        });
    }

    private void handleJoinMessage(WebSocketSession session, String roomId) {
        sessions.put(session.getId(), session);
        roomSessions.put(session.getId(), roomId);
        log.info("Client {} joined room: {}", session.getId(), roomId);

        // 같은 방의 참가자 수 로깅
        long roomParticipants = roomSessions.values()
                .stream()
                .filter(room -> room.equals(roomId))
                .count();
        log.info("Room {} now has {} participants", roomId, roomParticipants);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession wsession, CloseStatus status) {
        String roomId = roomSessions.get(wsession.getId());
        sessions.remove(wsession.getId());
        roomSessions.remove(wsession.getId());
        log.info("Client {} disconnected from room {}", wsession.getId(), roomId);

        // 남은 참가자 수 로깅
        if (roomId != null) {
            long remainingParticipants = roomSessions.values()
                    .stream()
                    .filter(room -> room.equals(roomId))
                    .count();
            log.info("Room {} now has {} participants remaining", roomId, remainingParticipants);

        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) {
        log.error("Transport error for session {}: {}", session.getId(), exception.getMessage());
    }
}