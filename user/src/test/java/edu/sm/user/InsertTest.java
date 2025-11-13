package edu.sm.user;

import edu.sm.app.dto.User;
import edu.sm.app.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@SpringBootTest
@Slf4j
public class InsertTest {

  @Autowired
  UserService userService;

  @Autowired
  BCryptPasswordEncoder encoder;

  @Autowired
  StandardPBEStringEncryptor txtEncoder;

  @Test
  void insertUser1() throws Exception {
    User user = User.builder()
        .userEmail("minho.kim@email.com")
        .userPwd(encoder.encode("111111"))
        .userName("김민호")
        .userPhone("010-1234-5678")
        .userDob(LocalDate.of(1985, 3, 15))
        .userGender("male")
        .userAddr(txtEncoder.encrypt("서울시 강남구 테헤란로 123"))
        .userMedicalHistory("고혈압, 당뇨")
        .userLifestyleHabits("규칙적인 운동, 비흡연")
        .userAccountStatus("active")
        .languagePreference("ko")
        .userRegdate(LocalDateTime.now())
        .build();

    userService.register(user);
    log.info("User inserted: {}", user);
  }

  @Test
  void insertMultipleUsers() throws Exception {
    // 여러 사용자 한번에 등록
    User[] users = {
        User.builder()
            .userEmail("minho.kim@email.com")
            .userPwd(encoder.encode("111111"))
            .userName("김민호")
            .userPhone("010-1234-5678")
            .userDob(LocalDate.of(1985, 3, 15))
            .userGender("male")
            .userAddr(txtEncoder.encrypt("서울시 강남구 테헤란로 123"))
            .userMedicalHistory("고혈압, 당뇨")
            .userLifestyleHabits("규칙적인 운동, 비흡연")
            .userAccountStatus("active")
            .languagePreference("ko")
            .userRegdate(LocalDateTime.now())
            .build(),

        User.builder()
            .userEmail("jisoo.lee@email.com")
            .userPwd(encoder.encode("111111"))
            .userName("이지수")
            .userPhone("010-2345-6789")
            .userDob(LocalDate.of(1990, 7, 22))
            .userGender("female")
            .userAddr(txtEncoder.encrypt("서울시 송파구 올림픽로 456"))
            .userMedicalHistory("천식")
            .userLifestyleHabits("요가, 채식주의")
            .userAccountStatus("active")
            .languagePreference("ko")
            .userRegdate(LocalDateTime.now())
            .build(),

        User.builder()
            .userEmail("junho.park@email.com")
            .userPwd(encoder.encode("111111"))
            .userName("박준호")
            .userPhone("010-3456-7890")
            .userDob(LocalDate.of(1978, 11, 8))
            .userGender("male")
            .userAddr(txtEncoder.encrypt("부산시 해운대구 해운대로 789"))
            .userMedicalHistory("심장질환")
            .userLifestyleHabits("수영")
            .userAccountStatus("active")
            .languagePreference("ko")
            .userRegdate(LocalDateTime.now())
            .build()
    };

    for (User user : users) {
      userService.register(user);
      log.info("User inserted: {}", user.getUserEmail());
    }
  }
}
