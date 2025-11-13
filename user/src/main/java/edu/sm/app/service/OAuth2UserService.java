package edu.sm.app.service;

import edu.sm.app.dto.User;
import edu.sm.app.dto.oauth.KakaoUserInfo;
import edu.sm.app.dto.oauth.OAuth2UserInfo;
import edu.sm.app.repository.UserRepository;
import edu.sm.app.security.PrincipalDetails;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.oauth2.client.userinfo.DefaultOAuth2UserService;
import org.springframework.security.oauth2.client.userinfo.OAuth2UserRequest;
import org.springframework.security.oauth2.core.OAuth2AuthenticationException;
import org.springframework.security.oauth2.core.user.OAuth2User;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.Map;
import java.util.Optional;

@Slf4j
@Service
@RequiredArgsConstructor
public class OAuth2UserService extends DefaultOAuth2UserService {

  private final UserRepository userRepository;
  private final BCryptPasswordEncoder passwordEncoder;

  @Override
  public OAuth2User loadUser(OAuth2UserRequest userRequest) throws OAuth2AuthenticationException {
    OAuth2User oAuth2User = super.loadUser(userRequest);

    log.info("OAuth2 User Attributes: {}", oAuth2User.getAttributes());

    // 제공자 정보 가져오기
    String registrationId = userRequest.getClientRegistration().getRegistrationId();
    OAuth2UserInfo oAuth2UserInfo = getOAuth2UserInfo(registrationId, oAuth2User.getAttributes());

    // 사용자 저장 또는 업데이트
    User user = saveOrUpdate(oAuth2UserInfo);

    // Spring Security 인증 객체 반환
    return new PrincipalDetails(user, oAuth2User.getAttributes());
  }

  private OAuth2UserInfo getOAuth2UserInfo(String registrationId, Map<String, Object> attributes) {
    if (registrationId.equals("kakao")) {
      return new KakaoUserInfo(attributes);
    }
//    else if (registrationId.equals("google")) {
//      return new GoogleUserInfo(attributes);
//    } else if (registrationId.equals("naver")) {
//      return new NaverUserInfo(attributes);
//    }
    throw new OAuth2AuthenticationException("지원하지 않는 OAuth2 제공자입니다: " + registrationId);
  }

  private User saveOrUpdate(OAuth2UserInfo oAuth2UserInfo) {
    try {
      Optional<User> userOptional = userRepository.findByProviderAndProviderId(
          oAuth2UserInfo.getProvider(),
          oAuth2UserInfo.getProviderId()
      );

      User user;
      if (userOptional.isPresent()) {
        // 기존 사용자 업데이트
        user = userOptional.get();
        user.setUserName(oAuth2UserInfo.getName());
        user.setUserEmail(oAuth2UserInfo.getEmail());
        user.setUserUpdate(LocalDateTime.now());
        userRepository.update(user);
      } else {
        String dummyPassword = "OAUTH_" + oAuth2UserInfo.getProvider().toUpperCase() + "_" + oAuth2UserInfo.getProviderId();
        String encodedPassword = passwordEncoder.encode(dummyPassword);
        // 신규 사용자 등록
        user = User.builder()
            .userEmail(oAuth2UserInfo.getEmail())
            .userPwd(encodedPassword)
            .userName(oAuth2UserInfo.getName())
            .provider(oAuth2UserInfo.getProvider())
            .providerId(oAuth2UserInfo.getProviderId())
            .userRole("ROLE_USER")
            .userAccountStatus("active")
            .userRegdate(LocalDateTime.now())
            .build();
        userRepository.insert(user);
      }

      return user;
    } catch (Exception e) {
      log.error("OAuth2 사용자 저장/업데이트 실패", e);
      throw new OAuth2AuthenticationException("사용자 정보 저장 실패");
    }
  }
}
