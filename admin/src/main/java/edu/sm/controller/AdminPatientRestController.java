package edu.sm.controller;

import edu.sm.app.dto.Patient;
import edu.sm.app.service.PatientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin/patient")
@RequiredArgsConstructor
@Slf4j
public class AdminPatientRestController {

    private final PatientService patientService;

    /**
     * 전체 환자 목록 조회
     */
    @GetMapping("/list")
    public ResponseEntity<Map<String, Object>> getAllPatients() {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Patient> patients = patientService.getAllPatients();
            response.put("success", true);
            response.put("patients", patients);
            response.put("count", patients.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("환자 목록 조회 실패", e);
            response.put("success", false);
            response.put("message", "환자 목록 조회에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 환자 상세 정보 조회
     */
    @GetMapping("/{patientId}")
    public ResponseEntity<Map<String, Object>> getPatientDetail(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();
        try {
            Patient patient = patientService.getPatientDetail(patientId);
            response.put("success", true);
            response.put("patient", patient);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("환자 상세 조회 실패: {}", patientId, e);
            response.put("success", false);
            response.put("message", "환자 정보를 찾을 수 없습니다.");
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(response);
        }
    }

    /**
     * 환자 검색
     */
    @GetMapping("/search")
    public ResponseEntity<Map<String, Object>> searchPatients(
            @RequestParam(required = false) String keyword) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Patient> patients = patientService.searchPatients(keyword);
            response.put("success", true);
            response.put("patients", patients);
            response.put("count", patients.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("환자 검색 실패", e);
            response.put("success", false);
            response.put("message", "검색에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 계정 상태별 환자 조회
     */
    @GetMapping("/status/{status}")
    public ResponseEntity<Map<String, Object>> getPatientsByStatus(@PathVariable String status) {
        Map<String, Object> response = new HashMap<>();
        try {
            List<Patient> patients = patientService.getPatientsByStatus(status);
            response.put("success", true);
            response.put("patients", patients);
            response.put("count", patients.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("계정 상태별 조회 실패: {}", status, e);
            response.put("success", false);
            response.put("message", "조회에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 계정 상태 변경
     */
    @PatchMapping("/{patientId}/status")
    public ResponseEntity<Map<String, Object>> changeAccountStatus(
            @PathVariable Long patientId,
            @RequestBody Map<String, String> request) {
        Map<String, Object> response = new HashMap<>();
        try {
            String status = request.get("status");
            if (status == null || status.trim().isEmpty()) {
                response.put("success", false);
                response.put("message", "상태 값이 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            patientService.changeAccountStatus(patientId, status);
            response.put("success", true);
            response.put("message", "계정 상태가 변경되었습니다.");
            return ResponseEntity.ok(response);
        } catch (IllegalArgumentException e) {
            log.error("유효하지 않은 상태: {}", request.get("status"), e);
            response.put("success", false);
            response.put("message", e.getMessage());
            return ResponseEntity.badRequest().body(response);
        } catch (Exception e) {
            log.error("계정 상태 변경 실패: {}", patientId, e);
            response.put("success", false);
            response.put("message", "계정 상태 변경에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 환자 정보 수정
     */
    @PutMapping("/{patientId}")
    public ResponseEntity<Map<String, Object>> updatePatient(
            @PathVariable Long patientId,
            @RequestBody Patient patient) {
        Map<String, Object> response = new HashMap<>();
        try {
            patient.setPatientId(patientId);
            patientService.updatePatient(patient);
            response.put("success", true);
            response.put("message", "환자 정보가 수정되었습니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("환자 정보 수정 실패: {}", patientId, e);
            response.put("success", false);
            response.put("message", "환자 정보 수정에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 환자 삭제
     */
    @DeleteMapping("/{patientId}")
    public ResponseEntity<Map<String, Object>> deletePatient(@PathVariable Long patientId) {
        Map<String, Object> response = new HashMap<>();
        try {
            patientService.deletePatient(patientId);
            response.put("success", true);
            response.put("message", "환자 정보가 삭제되었습니다.");
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("환자 삭제 실패: {}", patientId, e);
            response.put("success", false);
            response.put("message", "환자 삭제에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 고급 검색
     */
    @GetMapping("/advanced-search")
    public ResponseEntity<Map<String, Object>> advancedSearch(
            @RequestParam(required = false) String keyword,
            @RequestParam(required = false) String status,
            @RequestParam(required = false) String gender,
            @RequestParam(required = false) String startDate,
            @RequestParam(required = false) String endDate) {
        Map<String, Object> response = new HashMap<>();
        try {
            LocalDateTime start = startDate != null && !startDate.isEmpty()
                    ? LocalDateTime.parse(startDate) : null;
            LocalDateTime end = endDate != null && !endDate.isEmpty()
                    ? LocalDateTime.parse(endDate) : null;

            List<Patient> patients = patientService.searchPatientsAdvanced(
                    keyword, status, gender, start, end
            );

            response.put("success", true);
            response.put("patients", patients);
            response.put("count", patients.size());
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("고급 검색 실패", e);
            response.put("success", false);
            response.put("message", "검색에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 통계 정보
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        Map<String, Object> response = new HashMap<>();
        try {
            Map<String, Integer> stats = new HashMap<>();
            stats.put("total", patientService.countTotalPatients());
            stats.put("active", patientService.countByStatus("active"));
            stats.put("inactive", patientService.countByStatus("inactive"));
            stats.put("withdrawn", patientService.countByStatus("withdrawn"));

            response.put("success", true);
            response.put("statistics", stats);
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("통계 조회 실패", e);
            response.put("success", false);
            response.put("message", "통계 조회에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }

    /**
     * 일괄 계정 상태 변경
     */
    @PatchMapping("/bulk/status")
    public ResponseEntity<Map<String, Object>> bulkChangeStatus(
            @RequestBody Map<String, Object> request) {
        Map<String, Object> response = new HashMap<>();
        try {
            @SuppressWarnings("unchecked")
            List<Long> patientIds = (List<Long>) request.get("patientIds");
            String status = (String) request.get("status");

            if (patientIds == null || patientIds.isEmpty()) {
                response.put("success", false);
                response.put("message", "환자 ID 목록이 필요합니다.");
                return ResponseEntity.badRequest().body(response);
            }

            int successCount = 0;
            int failCount = 0;

            for (Long patientId : patientIds) {
                try {
                    patientService.changeAccountStatus(patientId, status);
                    successCount++;
                } catch (Exception e) {
                    log.error("계정 상태 변경 실패: {}", patientId, e);
                    failCount++;
                }
            }

            response.put("success", true);
            response.put("successCount", successCount);
            response.put("failCount", failCount);
            response.put("message", String.format("%d건 성공, %d건 실패", successCount, failCount));
            return ResponseEntity.ok(response);
        } catch (Exception e) {
            log.error("일괄 상태 변경 실패", e);
            response.put("success", false);
            response.put("message", "일괄 처리에 실패했습니다.");
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(response);
        }
    }
}