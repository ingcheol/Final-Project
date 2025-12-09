package edu.sm.app.dto;

import lombok.*;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Emr {
  private Long emrId;
  private Long consultationId;
  private String patientStatement;
  private String testResults;
  private String prescriptionDetails;
  private String aiGeneratedDraft;
  private String finalRecord;
  private LocalDateTime createdAt;
  private LocalDateTime updatedAt;

  private Long patientId;
}