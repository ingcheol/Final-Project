package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
@Builder
public class Appointment {
    private Long appointmentId;
    private LocalDateTime appointmentTime;
    private String appointmentType;  // "video", "chat", "phone" 등
    private String status;           // "pending", "confirmed", "cancelled", "completed"
    private String notes;            // 예약 메모
    private Long patientId;

    // 추가 정보 (조인용 - Patient 테이블 필드명 맞춤)
    private String name;          // patient.name
    private String email;         // patient.email
    private String phone;         // patient.phone

    // 하위 호환성을 위한 Getter (JSP에서 기존 변수명 사용 가능)
    public String getPatientName() {
        return this.name;
    }

    public String getPatientEmail() {
        return this.email;
    }

    public String getPatientPhone() {
        return this.phone;
    }

    // 날짜 포맷팅 메서드 (JSP에서 쉽게 사용)
    public String getFormattedDateTime() {
        if (appointmentTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일 HH:mm");
        return appointmentTime.format(formatter);
    }

    public String getFormattedDate() {
        if (appointmentTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd");
        return appointmentTime.format(formatter);
    }

    public String getFormattedTime() {
        if (appointmentTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("HH:mm");
        return appointmentTime.format(formatter);
    }

    public String getFormattedDateTimeWithDay() {
        if (appointmentTime == null) {
            return "";
        }
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy년 MM월 dd일 (E) HH:mm");
        return appointmentTime.format(formatter);
    }

    // 상태 한글명
    public String getStatusKr() {
        if (status == null) return "알 수 없음";

        switch (status) {
            case "pending":
                return "승인 대기";
            case "confirmed":
                return "예약 확정";
            case "cancelled":
                return "취소됨";
            case "completed":
                return "상담 완료";
            default:
                return status;
        }
    }

    // 예약 타입 한글명
    public String getAppointmentTypeKr() {
        if (appointmentType == null) return "미지정";

        switch (appointmentType) {
            case "video":
                return "화상 상담";
            case "chat":
                return "채팅 상담";
            case "phone":
                return "전화 상담";
            default:
                return appointmentType;
        }
    }
}