package edu.sm.controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;

import java.util.Map;

@Slf4j
@Controller
public class ConsulController {

    private final SimpMessagingTemplate messagingTemplate;

    public ConsulController(SimpMessagingTemplate messagingTemplate) {
        this.messagingTemplate = messagingTemplate;
    }

    /**
     * 방(Room) 전체 채팅
     * Patient와 Adviser 모두 이 경로로 메시지를 보냄
     */
    @MessageMapping("/chat/to/{roomId}")
    public void sendToRoom(@Payload Map<String, String> message, @DestinationVariable String roomId) {
        String sendId = message.get("sendid");
        String content = message.get("content1");

        log.info("Room chat - From: {}, Room: {}, Content: {}", sendId, roomId, content);

//        // Patient용 브로드캐스트 (모든 patient가 구독)
//        messagingTemplate.convertAndSend("/send/chat/" + roomId, message);

        // Adviser용 브로드캐스트 (모든 adviser가 구독)
        messagingTemplate.convertAndSend("/advisersend/chat/" + roomId, message);
    }

    /**
     * Patient -> Adviser 개인 메시지
     */
//    @MessageMapping("/patient/send/to/{receiverId}")
//    public void patientSendToAdviser(@Payload Map<String, String> message, @DestinationVariable String receiverId) {
//        String sendId = message.get("sendid");
//        String content = message.get("content1");
//
//        log.info("Patient to Adviser - From: {} To: {}, Content: {}", sendId, receiverId, content);
//
//        // Adviser가 구독하는 경로로 전송
//        messagingTemplate.convertAndSend("/advisersend/to/" + receiverId, message);
//    }

    /**
     * Adviser -> Patient 개인 메시지
     */
    @MessageMapping("/adviser/send/to/{receiverId}")
    public void adviserSendToPatient(@Payload Map<String, String> message, @DestinationVariable String receiverId) {
        String sendId = message.get("sendid");
        String content = message.get("content1");

        log.info("Adviser to Patient - From: {} To: {}, Content: {}", sendId, receiverId, content);

        // Patient가 구독하는 경로로 전송
        messagingTemplate.convertAndSend("/send/to/" + receiverId, message);
    }
}