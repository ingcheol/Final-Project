package edu.sm.app.repository;

import edu.sm.app.dto.Appointment;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.time.LocalDateTime;
import java.util.List;

@Repository
@Mapper
public interface AppointmentRepository extends SmRepository<Appointment, Long> {

    // 환자별 예약 목록 조회
    List<Appointment> findByPatientId(@Param("patientId") Long patientId) throws Exception;

    // 상태별 예약 조회
    List<Appointment> findByStatus(@Param("status") String status) throws Exception;

    // 환자별 + 상태별 예약 조회
    List<Appointment> findByPatientIdAndStatus(
            @Param("patientId") Long patientId,
            @Param("status") String status) throws Exception;

    // 특정 날짜의 예약 조회
    List<Appointment> findByDate(@Param("date") LocalDateTime date) throws Exception;

    // 예약 상태 변경
    void updateStatus(
            @Param("appointmentId") Long appointmentId,
            @Param("status") String status) throws Exception;

    // 최근 예약 조회 (관리자용)
    List<Appointment> findRecentAppointments(@Param("limit") int limit) throws Exception;

    // 승인 대기 중인 예약 개수
    int countPendingAppointments() throws Exception;
}