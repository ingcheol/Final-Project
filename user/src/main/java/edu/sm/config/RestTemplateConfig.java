package edu.sm.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.http.client.SimpleClientHttpRequestFactory;
import org.springframework.web.client.RestTemplate;
import javax.net.ssl.*;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.security.cert.X509Certificate;

@Configuration
public class RestTemplateConfig {

  @Bean
  public RestTemplate restTemplate() {
    return new RestTemplate(new TrustAllClientHttpRequestFactory());
  }

  // SSL 검증 무시
  static class TrustAllClientHttpRequestFactory extends SimpleClientHttpRequestFactory {
    @Override
    protected void prepareConnection(HttpURLConnection connection, String httpMethod) throws IOException {
      if (connection instanceof HttpsURLConnection) {
        ((HttpsURLConnection) connection).setHostnameVerifier((hostname, session) -> true);
        try {
          SSLContext sc = SSLContext.getInstance("TLS");
          sc.init(null, new TrustManager[]{new X509TrustManager() {
            public X509Certificate[] getAcceptedIssuers() { return null; }
            public void checkClientTrusted(X509Certificate[] certs, String authType) {}
            public void checkServerTrusted(X509Certificate[] certs, String authType) {}
          }}, new java.security.SecureRandom());
          ((HttpsURLConnection) connection).setSSLSocketFactory(sc.getSocketFactory());
        } catch (Exception e) {
          throw new RuntimeException(e);
        }
      }
      super.prepareConnection(connection, httpMethod);
    }
  }
}