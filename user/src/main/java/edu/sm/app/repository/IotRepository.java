package edu.sm.app.repository;

import edu.sm.app.dto.Iot;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
@Mapper
public interface IotRepository extends SmRepository<Iot, Long> {
  // 최근 7일 바이탈 데이터 조회 (AI 건강관리에서 사용)
  List<Iot> findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(
      @Param("patientId") Long patientId,
      @Param("measuredAt") LocalDateTime measuredAt) throws Exception;

  // 환자별 모든 IoT 데이터 조회
  List<Iot> findByPatientId(@Param("patientId") Long patientId) throws Exception;

  // 비정상 데이터 조회
  List<Iot> findByPatientIdAndIsAbnormal(@Param("patientId") Long patientId,
                                         @Param("isAbnormal") Boolean isAbnormal) throws Exception;

  // 특정 바이탈 타입 조회
  List<Iot> findByPatientIdAndVitalType(@Param("patientId") Long patientId,
                                        @Param("vitalType") String vitalType) throws Exception;
}