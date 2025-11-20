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
public interface IotRepository extends SmRepository<Long, Iot> {

  // 기간별 조회
  List<Iot> findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(
      @Param("patientId") Long patientId,
      @Param("measuredAt") LocalDateTime measuredAt) throws Exception;

  // 환자별 전체 조회
  List<Iot> findByPatientId(@Param("patientId") Long patientId) throws Exception;

  // 비정상 데이터 조회
  List<Iot> findByPatientIdAndIsAbnormal(
      @Param("patientId") Long patientId,
      @Param("isAbnormal") Boolean isAbnormal) throws Exception;

  // 특정 바이탈 타입 조회
  List<Iot> findByPatientIdAndVitalType(
      @Param("patientId") Long patientId,
      @Param("vitalType") String vitalType) throws Exception;

  // 🆕 최근 N개 데이터 조회 (AI 분석용)
  List<Iot> findRecentByPatientId(
      @Param("patientId") Long patientId,
      @Param("limit") int limit) throws Exception;

  // 🆕 특정 바이탈의 최근 N개 조회 (추세 분석용)
  List<Iot> findRecentByPatientIdAndVitalType(
      @Param("patientId") Long patientId,
      @Param("vitalType") String vitalType,
      @Param("limit") int limit) throws Exception;

  // CRUD 메서드
  Iot select(Long dataId);
  void insert(Iot iot);
  void update(Iot iot);
  void delete(Long dataId);
}
