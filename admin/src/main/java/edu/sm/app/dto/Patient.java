package edu.sm.app.dto;

import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Patient {
  private Long patientId;
  private String patientPwd;
  private String patientName;
  private String patientPhone;
  private String patientEmail;
  private LocalDate patientDob;
  private String patientGender;
  private String patientAddr;
  private String patientMedicalHistory;
  private String patientLifestyleHabits;
  private String patientAccountStatus;
  private String languagePreference;
  private LocalDateTime patientRegdate;
  private LocalDateTime patientUpdate;

  // OAuth
  private String provider;
  private String providerId;
  private String userRole;

  // 나이 계산 메서드 (JSP에서 사용)
  public int getAge() {
    if (patientDob == null) {
      return 0;
    }
    return LocalDate.now().getYear() - patientDob.getYear();
  }

  // 계정 상태 한글명
  public String getAccountStatusKr() {
    if (patientAccountStatus == null) {
      return "알 수 없음";
    }
    switch (patientAccountStatus) {
      case "active":
        return "활성";
      case "inactive":
        return "비활성";
      case "withdrawn":
        return "탈퇴";
      default:
        return patientAccountStatus;
    }
  }

  // 성별 한글명
  public String getGenderKr() {
    if (patientGender == null) {
      return "미지정";
    }
    switch (patientGender) {
      case "male":
      case "M":
        return "남성";
      case "female":
      case "F":
        return "여성";
      default:
        return patientGender;
    }
  }
}