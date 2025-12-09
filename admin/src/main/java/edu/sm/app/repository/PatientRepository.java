package edu.sm.app.repository;

import edu.sm.app.dto.Patient;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Repository
@Mapper
public interface PatientRepository extends SmRepository<Patient, Long> {

  // OAuth 관련
  Optional<Patient> findByPatientEmail(@Param("email") String email) throws Exception;

  Optional<Patient> findByProviderAndProviderId(@Param("provider") String provider,
                                                @Param("providerId") String providerId) throws Exception;

  void deleteByEmail(@Param("email") String email) throws Exception;

  Optional<Patient> findByPatientId(@Param("patientId") Long patientId) throws Exception;

  // ===== 관리자 기능 =====

  // 전체 환자 목록 조회
  List<Patient> selectAllPatients() throws Exception;

  // 계정 상태별 환자 조회
  List<Patient> selectByAccountStatus(@Param("status") String status) throws Exception;

  // 계정 상태 변경
  void updateAccountStatus(@Param("patientId") Long patientId,
                           @Param("status") String status) throws Exception;

  // 환자 검색 (이름, 이메일, 전화번호)
  List<Patient> searchPatients(@Param("keyword") String keyword) throws Exception;

  // 환자 상세 정보 조회
  Patient selectPatientDetail(@Param("patientId") Long patientId) throws Exception;

  // 복합 조건 검색
  List<Patient> searchPatientsAdvanced(
          @Param("keyword") String keyword,
          @Param("status") String status,
          @Param("gender") String gender,
          @Param("startDate") LocalDateTime startDate,
          @Param("endDate") LocalDateTime endDate
  ) throws Exception;

  // 통계 정보
  int countByAccountStatus(@Param("status") String status) throws Exception;

  int countTotalPatients() throws Exception;
}