package edu.sm.app.dto;

import lombok.*;

import java.time.LocalDateTime;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Iot {
  private Long iotId;
  private Long patientId;
  private String deviceType;
  private String vitalType;
  private Double value;
  private Boolean isAbnormal;
  private LocalDateTime measuredAt;
}