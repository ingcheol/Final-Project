package edu.sm.app.dto;


import lombok.*;
import java.sql.Timestamp; // created_at 필드를 위해 Timestamp를 임포트합니다.

/**
 * adviser 테이블의 구조를 반영하는 DTO (Data Transfer Object) 클래스입니다.
 */
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Adviser {

    // adviser_id BIGSERIAL NOT NULL
    private Long adviserId;

    // password VARCHAR(255) NOT NULL
    private String password;

    // name VARCHAR(100) NOT NULL (로그인 ID 또는 이름으로 사용될 수 있음)
    private String name;

    // phone VARCHAR(20) NULL
    private String phone;

    // email VARCHAR(100) NOT NULL
    private String email;

    // license_number VARCHAR(50) NOT NULL (고유한 자격증 번호)
    private String licenseNumber;

    // account_status VARCHAR(20) NULL DEFAULT 'active'
    private String accountStatus;

    // created_at TIMESTAMP NULL
    private Timestamp createdAt;
}