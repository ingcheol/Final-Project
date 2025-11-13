package edu.sm.user;

import edu.sm.app.dto.User;
import edu.sm.app.service.UserService;
import lombok.extern.slf4j.Slf4j;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@SpringBootTest
@Slf4j
public class SelectTest {

  @Autowired
  UserService userService;

  @Autowired
  BCryptPasswordEncoder encoder;

  @Autowired
  StandardPBEStringEncryptor txtEncoder;

  @Test
  void getAllTest() throws Exception {
    DateTimeFormatter sdf = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일 HH시 mm분 ss초");
    List<User> list = userService.get();

    list.forEach((user) -> {
      String email = user.getUserEmail();
      String name = user.getUserName();
      String addr = txtEncoder.decrypt(user.getUserAddr());
      LocalDateTime regdate = user.getUserRegdate();
      LocalDateTime update = user.getUserUpdate();

      log.info("Email: {}, Name: {}", email, name);
      log.info("Address: {}", addr);
      log.info("Registered: {}", regdate != null ? sdf.format(regdate) : "N/A");
      log.info("Updated: {}", update != null ? sdf.format(update) : "N/A");
      log.info("------------------------------------------");
    });
  }

  @Test
  void getByIdTest() {
    User user = null;
    try {
      // userId로 조회 (예: 1번 사용자)
      user = userService.get(1);
      if (user != null) {
        log.info("User found: {}", user.toString());
        log.info("Decrypted Address: {}", txtEncoder.decrypt(user.getUserAddr()));
      } else {
        log.info("User not found");
      }
      log.info("Select End ------------------------------------------");
    } catch (Exception e) {
      log.info("Error Test ...");
      e.printStackTrace();
    }
  }

  @Test
  void getByEmailTest() {
    User user = null;
    try {
      // 이메일로 조회
      user = userService.getByEmail("minho.kim@email.com");
      if (user != null) {
        log.info("User found: {}", user.toString());
        log.info("Decrypted Address: {}", txtEncoder.decrypt(user.getUserAddr()));
      } else {
        log.info("User not found with email");
      }
      log.info("Select End ------------------------------------------");
    } catch (Exception e) {
      log.info("Error Test ...");
      e.printStackTrace();
    }
  }

  @Test
  void testLogin() {
    try {
      String email = "minho.kim@email.com";
      String password = "111111";

      User user = userService.getByEmail(email);
      if (user != null) {
        boolean matches = encoder.matches(password, user.getUserPwd());
        log.info("Login test for {}: {}", email, matches ? "SUCCESS" : "FAILED");

        if (matches) {
          log.info("User info: {}", user.getUserName());
          log.info("Phone: {}", user.getUserPhone());
          log.info("Medical History: {}", user.getUserMedicalHistory());
        }
      } else {
        log.info("User not found");
      }
    } catch (Exception e) {
      log.info("Error Test ...");
      e.printStackTrace();
    }
  }
}
