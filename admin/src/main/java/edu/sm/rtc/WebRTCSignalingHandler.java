package edu.sm.rtc;

import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Component;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArraySet;

@Slf4j
@Component
public class WebRTCSignalingHandler extends TextWebSocketHandler {

    // roomId -> Set of sessions in that room
    private static final Map<String, CopyOnWriteArraySet<WebSocketSession>> roomSessions = new ConcurrentHashMap<>();
    // sessionId -> roomId mapping
    private static final Map<String, String> sessionRoomMap = new ConcurrentHashMap<>();

    private final ObjectMapper objectMapper = new ObjectMapper();

    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        log.info("WebRTC WebSocket connected: {}", session.getId());
    }

    @Override
    protected void handleTextMessage(WebSocketSession session, TextMessage message) throws Exception {
        String payload = message.getPayload();
        log.info("Received message from client {}: {}", session.getId(), payload);

        try {
            Map<String, Object> messageData = objectMapper.readValue(payload, Map.class);
            String type = (String) messageData.get("type");
            String roomId = (String) messageData.get("roomId");

            if (roomId == null) {
                log.error("RoomId is null in message from {}", session.getId());
                return;
            }

            switch (type) {
                case "join":
                    handleJoin(session, roomId);
                    break;
                case "offer":
                case "answer":
                case "ice-candidate":
                    broadcastToRoom(session, roomId, payload);
                    break;
                case "bye":
                    handleBye(session, roomId);
                    break;
                default:
                    log.warn("Unknown message type: {}", type);
            }
        } catch (Exception e) {
            log.error("Error handling message from {}: {}", session.getId(), e.getMessage(), e);
        }
    }

    private void handleJoin(WebSocketSession session, String roomId) throws IOException {
        // Add session to room
        roomSessions.computeIfAbsent(roomId, k -> new CopyOnWriteArraySet<>()).add(session);
        sessionRoomMap.put(session.getId(), roomId);

        log.info("Session {} joined room {}. Room now has {} participants",
                session.getId(), roomId, roomSessions.get(roomId).size());

        // Notify others in the room
        Map<String, Object> joinMessage = Map.of(
                "type", "join",
                "roomId", roomId,
                "sessionId", session.getId()
        );

        broadcastToRoom(session, roomId, objectMapper.writeValueAsString(joinMessage));
    }

    private void handleBye(WebSocketSession session, String roomId) throws IOException {
        removeSession(session);

        // Notify others in the room
        Map<String, Object> byeMessage = Map.of(
                "type", "bye",
                "roomId", roomId,
                "sessionId", session.getId()
        );

        broadcastToRoom(session, roomId, objectMapper.writeValueAsString(byeMessage));
    }

    private void broadcastToRoom(WebSocketSession sender, String roomId, String message) {
        CopyOnWriteArraySet<WebSocketSession> sessions = roomSessions.get(roomId);
        if (sessions == null) {
            log.warn("No sessions found for room: {}", roomId);
            return;
        }

        int sentCount = 0;
        for (WebSocketSession session : sessions) {
            if (session.isOpen() && !session.getId().equals(sender.getId())) {
                try {
                    session.sendMessage(new TextMessage(message));
                    sentCount++;
                } catch (IOException e) {
                    log.error("Error sending message to session {}: {}", session.getId(), e.getMessage());
                    removeSession(session);
                }
            }
        }

        log.info("Broadcasted message to {} participants in room {}", sentCount, roomId);
    }

    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        log.info("WebRTC WebSocket disconnected: {} with status {}", session.getId(), status);
        removeSession(session);
    }

    private void removeSession(WebSocketSession session) {
        String roomId = sessionRoomMap.remove(session.getId());
        if (roomId != null) {
            CopyOnWriteArraySet<WebSocketSession> sessions = roomSessions.get(roomId);
            if (sessions != null) {
                sessions.remove(session);
                log.info("Removed session {} from room {}. Room now has {} participants",
                        session.getId(), roomId, sessions.size());

                if (sessions.isEmpty()) {
                    roomSessions.remove(roomId);
                    log.info("Room {} is now empty and removed", roomId);
                }
            }
        }
    }

    @Override
    public void handleTransportError(WebSocketSession session, Throwable exception) throws Exception {
        log.error("WebSocket transport error for session {}: {}", session.getId(), exception.getMessage());
        removeSession(session);
    }
}