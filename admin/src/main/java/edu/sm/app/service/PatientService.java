package edu.sm.app.service;

import edu.sm.app.dto.Patient;
import edu.sm.app.repository.PatientRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PatientService implements SmService<Patient, Long> {

  private final PatientRepository patientRepository;

  // OAuth 관련 메서드
  public Patient getByEmail(String email) throws Exception {
    return patientRepository.findByPatientEmail(email)
            .orElseThrow(() -> new Exception("사용자를 찾을 수 없습니다: " + email));
  }

  public void removeByEmail(String email) throws Exception {
    patientRepository.deleteByEmail(email);
  }

  public Optional<Patient> findByProviderAndProviderId(String provider, String providerId) throws Exception {
    return patientRepository.findByProviderAndProviderId(provider, providerId);
  }

  public Optional<Patient> findById(Long patientId) throws Exception {
    return patientRepository.findByPatientId(patientId);
  }

  public void add(Patient patient) throws Exception {
    register(patient);
  }

  // ===== 관리자 기능 =====

  /**
   * 전체 환자 목록 조회
   */
  public List<Patient> getAllPatients() throws Exception {
    return patientRepository.selectAllPatients();
  }

  /**
   * 계정 상태별 환자 조회
   * @param status active, inactive, withdrawn
   */
  public List<Patient> getPatientsByStatus(String status) throws Exception {
    return patientRepository.selectByAccountStatus(status);
  }

  /**
   * 계정 상태 변경
   * @param patientId 환자 ID
   * @param status 변경할 상태 (active, inactive, withdrawn)
   */
  @Transactional
  public void changeAccountStatus(Long patientId, String status) throws Exception {
    // 상태 유효성 검증
    if (!isValidStatus(status)) {
      throw new IllegalArgumentException("유효하지 않은 계정 상태입니다: " + status);
    }

    // 환자 존재 여부 확인
    Patient patient = patientRepository.select(patientId);
    if (patient == null) {
      throw new Exception("환자를 찾을 수 없습니다: " + patientId);
    }

    patientRepository.updateAccountStatus(patientId, status);
  }

  /**
   * 환자 검색 (이름, 이메일, 전화번호)
   */
  public List<Patient> searchPatients(String keyword) throws Exception {
    if (keyword == null || keyword.trim().isEmpty()) {
      return getAllPatients();
    }
    return patientRepository.searchPatients(keyword.trim());
  }

  /**
   * 환자 상세 정보 조회
   */
  public Patient getPatientDetail(Long patientId) throws Exception {
    Patient patient = patientRepository.selectPatientDetail(patientId);
    if (patient == null) {
      throw new Exception("환자를 찾을 수 없습니다: " + patientId);
    }
    return patient;
  }

  /**
   * 복합 조건 검색
   */
  public List<Patient> searchPatientsAdvanced(String keyword, String status,
                                              String gender, LocalDateTime startDate,
                                              LocalDateTime endDate) throws Exception {
    return patientRepository.searchPatientsAdvanced(keyword, status, gender, startDate, endDate);
  }

  /**
   * 환자 정보 수정 (관리자용)
   */
  @Transactional
  public void updatePatient(Patient patient) throws Exception {
    Patient existing = get(patient.getPatientId());
    if (existing == null) {
      throw new Exception("환자를 찾을 수 없습니다: " + patient.getPatientId());
    }
    modify(patient);
  }

  /**
   * 환자 삭제 (관리자용)
   */
  @Transactional
  public void deletePatient(Long patientId) throws Exception {
    Patient patient = get(patientId);
    if (patient == null) {
      throw new Exception("환자를 찾을 수 없습니다: " + patientId);
    }
    remove(patientId);
  }

  /**
   * 통계 정보 조회
   */
  public int countByStatus(String status) throws Exception {
    return patientRepository.countByAccountStatus(status);
  }

  public int countTotalPatients() throws Exception {
    return patientRepository.countTotalPatients();
  }

  // 상태 유효성 검증
  private boolean isValidStatus(String status) {
    return status != null &&
            (status.equals("active") || status.equals("inactive") || status.equals("withdrawn"));
  }

  // 기본 CRUD 메서드
  @Override
  public void register(Patient patient) throws Exception {
    patientRepository.insert(patient);
  }

  @Override
  public void modify(Patient patient) throws Exception {
    patientRepository.update(patient);
  }

  @Override
  public void remove(Long id) throws Exception {
    patientRepository.delete(id);
  }

  @Override
  public List<Patient> get() throws Exception {
    return patientRepository.selectAll();
  }

  @Override
  public Patient get(Long id) throws Exception {
    return patientRepository.select(id);
  }
}