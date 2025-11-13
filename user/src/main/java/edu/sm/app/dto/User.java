package edu.sm.app.dto;

import lombok.*;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class User {
  private Integer userId;
  private String userPwd;
  private String userName;
  private String userPhone;
  private String userEmail;
  private LocalDate userDob;
  private String userGender;
  private String userAddr;
  private String userMedicalHistory;
  private String userLifestyleHabits;
  private String userAccountStatus;
  private String languagePreference;
  private LocalDateTime userRegdate;
  private LocalDateTime userUpdate;

  private String provider;
  private String providerId;
  private String userRole;
}