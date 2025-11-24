package edu.sm.config;

import edu.sm.rtc.WebRTCSignalingHandler;
import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

@EnableWebSocketMessageBroker
@EnableWebSocket
@Configuration
public class StomWebSocketConfig implements WebSocketMessageBrokerConfigurer, WebSocketConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 환자용 (일반 사용자) 채팅 엔드포인트
        registry.addEndpoint("/chat")
                .setAllowedOriginPatterns("*")
                .withSockJS();

        // 상담사용 채팅 엔드포인트
        // Admin 서버(8443)에서 크로스 오리진으로 접속
        registry.addEndpoint("/adviserchat")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Simple Broker: 클라이언트가 구독하는 경로 (수신 경로)
        registry.enableSimpleBroker("/send", "/advisersend");

        // Application Destination Prefix: 클라이언트가 메시지를 보낼 때 사용하는 경로 (송신 경로)
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // ✅ WebRTC 시그널링 핸들러 (WebSocket)
        // Patient(로컬)와 Adviser(크로스 오리진, 8443)가 모두 여기에 연결
        registry.addHandler(new WebRTCSignalingHandler(), "/signal")
                .setAllowedOrigins(
                        "https://127.0.0.1:8443",    // Admin 서버
                        "https://localhost:8443",
                        "https://127.0.0.1:8444",    // Shop 서버 (자기자신)
                        "https://localhost:8444"
                );
    }
}