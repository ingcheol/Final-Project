package edu.sm.config;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.boot.web.client.RestClientCustomizer;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import javax.net.ssl.*;


@Configuration
public class AiConfig {

  // RestClientCustomizer를 빈으로 등록하면 Spring AI가 자동으로 이를 감지하여 적용
  @Bean
  public RestClientCustomizer sslIgnoringRestClientCustomizer() {
    return restClientBuilder ->
        restClientBuilder.requestFactory(new RestTemplateConfig.TrustAllClientHttpRequestFactory());
  }

  @Bean
  public ChatClient chatClient(ChatClient.Builder builder) {
    return builder.build();
  }
}
