package edu.sm.config;

import edu.sm.app.security.OAuth2SuccessHandler;
import edu.sm.app.service.OAuth2UserService;
import jakarta.servlet.http.HttpSession;
import lombok.AllArgsConstructor;
import lombok.RequiredArgsConstructor;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;

@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(securedEnabled = true, prePostEnabled = true)
@RequiredArgsConstructor
public class SecurityConfig  {
  private final OAuth2UserService oAuth2UserService;
  private final OAuth2SuccessHandler oAuth2SuccessHandler;

    @Bean
    public static BCryptPasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public StandardPBEStringEncryptor  textEncoder(@Value("${app.key.algo}") String algo, @Value("${app.key.skey}") String skey) {
        StandardPBEStringEncryptor encryptor = new StandardPBEStringEncryptor();
        encryptor.setAlgorithm(algo);
        encryptor.setPassword(skey);
        return encryptor;
    }

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        //CSRF, CORS
        http.csrf((csrf) -> csrf.disable());
        //http.cors(Customizer.withDefaults());

        // 권한 규칙 작성
        http.authorizeHttpRequests(authorize -> authorize
                        //@PreAuthrization을 사용할 것이기 때문에 모든 경로에 대한 인증처리는 Pass
                        .anyRequest().permitAll()
//                        .anyRequest().authenticated()
        );

      // 인증되지 않은 사용자가 보호된 리소스 접근 시 처리 (람다식으로 직접 구현)
      http.exceptionHandling(exception -> exception
          .authenticationEntryPoint((request, response, authException) -> {
            // 현재 요청 URL 저장
            String requestUrl = request.getRequestURI();
            String queryString = request.getQueryString();

            if (queryString != null) {
              requestUrl += "?" + queryString;
            }

            // 세션에 리다이렉트 URL 저장
            HttpSession session = request.getSession();
            session.setAttribute("redirectUrl", requestUrl);

            // 로그인 페이지로 리다이렉트
            response.sendRedirect("/login?redirect=" + requestUrl);
          })
      );

      // OAuth2 로그인 설정
      http.oauth2Login(oauth2 -> oauth2
          .loginPage("/")
          .userInfoEndpoint(userInfo -> userInfo
              .userService(oAuth2UserService)
          )
          .successHandler(oAuth2SuccessHandler)
          .failureUrl("/login?error=oauth")
      );
      // 로그아웃 설정
      http.logout(logout -> logout
          .logoutUrl("/logout")
          .logoutSuccessUrl("/")
          .invalidateHttpSession(true)
      );
        return http.build();
    }


}