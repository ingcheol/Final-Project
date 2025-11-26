package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class SignLanguageMessage {
  private Long patientId;
  private String patientName;
  private String signLanguage; // "ksl" or "asl"로 변경
  private String translatedText;
  private Double confidence;
  private LocalDateTime timestamp;
}