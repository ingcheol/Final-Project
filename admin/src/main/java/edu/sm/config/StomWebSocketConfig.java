package edu.sm.config;

import org.springframework.context.annotation.Configuration;
import org.springframework.messaging.simp.config.MessageBrokerRegistry;
import org.springframework.web.socket.config.annotation.*;

@EnableWebSocketMessageBroker
@Configuration
public class StomWebSocketConfig implements WebSocketMessageBrokerConfigurer {

    @Override
    public void registerStompEndpoints(StompEndpointRegistry registry) {
        // 상담사용 채팅 엔드포인트만 유지
        // Adviser는 실제로는 Shop 서버(8444)의 /adviserchat을 사용하지만
        // 혹시 모를 로컬 연결을 위해 엔드포인트는 유지
        registry.addEndpoint("/adviserchat")
                .setAllowedOriginPatterns("*")
                .withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Simple Broker: 클라이언트가 구독하는 경로 (수신 경로)
        registry.enableSimpleBroker("/advisersend");

        // Application Destination Prefix: 클라이언트가 메시지를 보낼 때 사용하는 경로 (송신 경로)
        registry.setApplicationDestinationPrefixes("/app");
    }


    // ❌ registerWebSocketHandlers 메서드 제거
    // WebRTC 시그널링은 Shop 서버(8444)에서만 처리
    // Admin 서버는 UI만 제공하고, WebSocket은 Shop 서버로 연결
}