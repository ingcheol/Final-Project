package edu.sm.config;


import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.servlet.config.annotation.CorsRegistry;
import org.springframework.web.servlet.config.annotation.ResourceHandlerRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.context.MessageSource;
import org.springframework.context.annotation.Bean;
import org.springframework.context.support.ResourceBundleMessageSource;
import org.springframework.web.servlet.LocaleResolver;
import org.springframework.web.servlet.config.annotation.InterceptorRegistry;
import org.springframework.web.servlet.config.annotation.WebMvcConfigurer;
import org.springframework.web.servlet.i18n.LocaleChangeInterceptor;
import org.springframework.web.servlet.i18n.SessionLocaleResolver;
import java.util.Locale;

@Slf4j
@Configuration
public class WebMvcConfig implements WebMvcConfigurer {

    @Value("${app.dir.imgsdir}")
    String imgdir;

    @Value("${app.dir.logsdir}")
    String logdir;

    @Override
    public void addResourceHandlers(ResourceHandlerRegistry registry) {
        registry.addResourceHandler("/imgs/**").addResourceLocations(imgdir);
        registry.addResourceHandler("/logs/**").addResourceLocations(logdir);

    }
    @Override
    public void addCorsMappings(CorsRegistry registry) {
        registry.addMapping("/**")
                .allowedOrigins("*")
                .allowedMethods("HEAD", "GET", "POST", "PUT", "DELETE", "OPTIONS")
                .maxAge(3600)
                .allowCredentials(false)
                .allowedHeaders("Authorization", "Cache-Control", "Content-Type");
    }
//    // 1. MessageSource: 언어 리소스 파일(properties)을 읽어오는 역할
//    @Bean
//    public MessageSource messageSource() {
//        ResourceBundleMessageSource messageSource = new ResourceBundleMessageSource();
//        // resource 폴더 아래 messages/message_ko.properties 등을 찾도록 기본 이름 설정
//        messageSource.setBasename("messages/message");
//        messageSource.setDefaultEncoding("UTF-8");
//        // 찾는 키가 없을 때 오류 대신 메시지 코드를 기본값으로 사용
//        messageSource.setUseCodeAsDefaultMessage(true);
//        return messageSource;
//    }
//
//    // 2. LocaleResolver: 사용자의 언어(Locale) 정보를 저장하는 방식 정의 (세션에 저장하여 유지)
//    @Bean
//    public LocaleResolver localeResolver() {
//        SessionLocaleResolver localeResolver = new SessionLocaleResolver();
//        // 시스템의 기본 언어를 한국어로 설정
//        localeResolver.setDefaultLocale(new Locale("ko"));
//        return localeResolver;
//    }
//
//    // 3. LocaleChangeInterceptor: URL 파라미터를 감지하여 언어를 변경하는 인터셉터
//    @Bean
//    public LocaleChangeInterceptor localeChangeInterceptor() {
//        LocaleChangeInterceptor interceptor = new LocaleChangeInterceptor();
//        // URL에 'lang' 파라미터가 오면 언어를 변경합니다. (예: ?lang=en)
//        interceptor.setParamName("lang");
//        return interceptor;
//    }
//
//    // 4. 인터셉터 등록: 스프링 MVC 설정에 LocaleChangeInterceptor를 등록
//    @Override
//    public void addInterceptors(InterceptorRegistry registry) {
//        // 모든 URL에 대해 언어 변경 요청을 감지하도록 등록
//        registry.addInterceptor(localeChangeInterceptor()).addPathPatterns("/**");
//    }


}