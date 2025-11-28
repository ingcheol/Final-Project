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

  private String provider;
  private String providerId;
  private String userRole;

  public Long getUserId() {
    return this.patientId;
  }

  public String getUserName() {
    return this.patientName;
  }

  public String getUserPwd() { return patientPwd; }
  public String getUserPhone() { return patientPhone; }
  public String getUserEmail() { return patientEmail; }
  public LocalDate getUserDob() { return patientDob; }
  public String getUserGender() { return patientGender; }
  public String getUserAddr() { return patientAddr; }
  public String getUserMedicalHistory() { return patientMedicalHistory; }
  public String getUserLifestyleHabits() { return patientLifestyleHabits; }
  public String getUserAccountStatus() { return patientAccountStatus; }
  public String getUserLanguagePreference() { return languagePreference; }
  public LocalDateTime getUserRegdate() { return patientRegdate; }
  public LocalDateTime getUserUpdate() { return patientUpdate; }
  public String getUserProvider() { return provider; }
  public String getUserProviderId() { return providerId; }
  public String getUserRole() { return userRole; }

////  user dto에 추가할것
//  public Integer getPatientId() { return userId; }
//  public String getPatientName() { return userName; }
//  public String getPatientPwd() { return userPwd; }
//  public String getPatientPhone() { return userPhone; }
//  public String getPatientEmail() { return userEmail; }
//  public LocalDate getPatientDob() { return userDob; }
//  public String getPatientGender() { return userGender; }
//  public String getPatientAddr() { return userAddr; }
//  public String getPatientMedicalHistory() { return userMedicalHistory; }
//  public String getPatientLifestyleHabits() { return userLifestyleHabits; }
//  public String getPatientAccountStatus() { return userAccountStatus; }
//  public String getPatientLanguagePreference() { return languagePreference; }
//  public LocalDateTime getPatientRegdate() { return userRegdate; }
//  public LocalDateTime getPatientUpdate() { return userUpdate; }
//  public String getPatientProvider() { return provider; }
//  public String getPatientProviderId() { return providerId; }
//  public String getPatientRole() { return userRole; }
}