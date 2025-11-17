package edu.sm.app.dto;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

// 상병코드, 상병명, 성별, 연령, 환자수만 포함하는 DTO
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DiseaseSimpleStatsItem {

    private String sickCd;  // 상병코드
    private String sickNm;  // 상병명
    private String sex;     // 성별
    private String age;     // 연령
    private Integer patientCount; // 환자수 (API의 'ptntCnt')
}