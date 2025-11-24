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
}