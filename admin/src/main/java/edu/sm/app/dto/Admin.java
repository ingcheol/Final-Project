package edu.sm.app.dto;

import lombok.*;
import java.time.LocalDateTime;

/**
 * admin 테이블의 구조를 반영하는 DTO (Data Transfer Object)입니다.
 * Lombok 애너테이션을 사용하여 보일러플레이트 코드를 줄였습니다.
 */
@AllArgsConstructor // 모든 필드를 포함하는 생성자
@NoArgsConstructor  // 기본 생성자
@ToString           // toString() 메서드 자동 생성
@Getter             // Getter 메서드 자동 생성
@Setter             // Setter 메서드 자동 생성
@Builder            // Builder 패턴 메서드 자동 생성
public class Admin {

    // admin_id (BIGSERIAL, Primary Key)
    private Long adminId;

    // password (VARCHAR)
    private String password;

    // name (VARCHAR)
    private String name;

    // phone (VARCHAR)
    private String phone;

    // email (VARCHAR)
    private String email;

    // account_status (VARCHAR, 기본값 'active')
    private String accountStatus;

    // created_at (TIMESTAMP) - LocalDateTime 사용
    private LocalDateTime createdAt;

    // patient_id (BIGSERIAL, Foreign Key)
    private Long patientId;
}