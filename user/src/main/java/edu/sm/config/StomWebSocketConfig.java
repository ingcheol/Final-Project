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
        registry.addEndpoint("/chat").setAllowedOriginPatterns("*").withSockJS();
        // 상담사용 채팅 엔드포인트 (기존 adminchat -> adviserchat으로 변경)
        registry.addEndpoint("/adviserchat").setAllowedOriginPatterns("*").withSockJS();
    }

    @Override
    public void configureMessageBroker(MessageBrokerRegistry registry) {
        // Simple Broker: 클라이언트가 구독하는 경로 (수신 경로)
        // 기존 adminsend -> advisersend로 변경
        registry.enableSimpleBroker("/send", "/advisersend");

        // Application Destination Prefix: 클라이언트가 메시지를 보낼 때 사용하는 경로 (송신 경로)
        registry.setApplicationDestinationPrefixes("/app");
    }

    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        // WebRTC 시그널링 핸들러 (WebSocket)
        registry.addHandler(new WebRTCSignalingHandler(), "/signal")
                .setAllowedOrigins("*");
    }

}