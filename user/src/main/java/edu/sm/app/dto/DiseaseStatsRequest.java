package edu.sm.app.dto;


import lombok.*;
@AllArgsConstructor
@NoArgsConstructor
@ToString
@Getter
@Setter
// 외부 API 호출에 필요한 파라미터 DTO
@Data
@Builder
public class DiseaseStatsRequest {

    // 필수: 서비스 인증키
    private String serviceKey;

    // 옵션: 페이지 처리
    private Integer numOfRows;
    private Integer pageNo;

    // 조회 조건
    private String year;
    private String sickCd;
    private String sickType; // 1: 3단 상병, 2: 4단 상병
    private String medTp;    // 1: 양방, 2: 한방
}