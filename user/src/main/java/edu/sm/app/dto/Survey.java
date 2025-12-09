package edu.sm.app.dto;

import lombok.*;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Survey {
  private Long surveyId;
  private Long patientId;
  private String surveyType;
  private String questions;
  private String answers;
  private LocalDateTime createdAt;
  private LocalDateTime submittedAt;
}