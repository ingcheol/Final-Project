package edu.sm.app.service;

import edu.sm.app.dto.Appointment;
import edu.sm.app.repository.AppointmentRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
@Slf4j
public class AppointmentService implements SmService<Appointment, Long> {

    private final AppointmentRepository appointmentRepository;

    @Override
    @Transactional
    public void register(Appointment appointment) throws Exception {
        // 기본 상태는 'pending' (승인 대기)
        if (appointment.getStatus() == null) {
            appointment.setStatus("pending");
        }
        appointmentRepository.insert(appointment);
        log.info("예약 신청 완료 - ID: {}, 환자: {}", appointment.getAppointmentId(), appointment.getPatientId());
    }

    @Override
    @Transactional
    public void modify(Appointment appointment) throws Exception {
        appointmentRepository.update(appointment);
    }

    @Override
    @Transactional
    public void remove(Long id) throws Exception {
        appointmentRepository.delete(id);
    }

    @Override
    public List<Appointment> get() throws Exception {
        return appointmentRepository.selectAll();
    }

    @Override
    public Appointment get(Long id) throws Exception {
        return appointmentRepository.select(id);
    }

    // 환자별 예약 조회
    public List<Appointment> getByPatientId(Long patientId) throws Exception {
        return appointmentRepository.findByPatientId(patientId);
    }

    // 상태별 예약 조회
    public List<Appointment> getByStatus(String status) throws Exception {
        return appointmentRepository.findByStatus(status);
    }

    // 예약 승인
    @Transactional
    public void confirmAppointment(Long appointmentId) throws Exception {
        Appointment appointment = appointmentRepository.select(appointmentId);
        if (appointment == null) {
            throw new Exception("예약을 찾을 수 없습니다.");
        }

        appointmentRepository.updateStatus(appointmentId, "confirmed");
        log.info("예약 승인 - ID: {}", appointmentId);

        // TODO: 이메일 또는 SMS 알림 전송
    }

    // 예약 취소
    @Transactional
    public void cancelAppointment(Long appointmentId, String reason) throws Exception {
        Appointment appointment = appointmentRepository.select(appointmentId);
        if (appointment == null) {
            throw new Exception("예약을 찾을 수 없습니다.");
        }

        // 메모에 취소 사유 추가
        String updatedNotes = appointment.getNotes() + "\n[취소 사유: " + reason + "]";
        appointment.setNotes(updatedNotes);
        appointment.setStatus("cancelled");

        appointmentRepository.update(appointment);
        log.info("예약 취소 - ID: {}, 사유: {}", appointmentId, reason);
    }

    // 예약 완료 처리
    @Transactional
    public void completeAppointment(Long appointmentId) throws Exception {
        appointmentRepository.updateStatus(appointmentId, "completed");
        log.info("상담 완료 - ID: {}", appointmentId);
    }

    // 특정 날짜의 예약 조회
    public List<Appointment> getByDate(LocalDateTime date) throws Exception {
        return appointmentRepository.findByDate(date);
    }

    // 최근 예약 조회
    public List<Appointment> getRecentAppointments(int limit) throws Exception {
        return appointmentRepository.findRecentAppointments(limit);
    }

    // 승인 대기 개수
    public int countPendingAppointments() throws Exception {
        return appointmentRepository.countPendingAppointments();
    }

    // 예약 가능 시간 체크
    public boolean isTimeSlotAvailable(LocalDateTime appointmentTime) throws Exception {
        List<Appointment> appointments = appointmentRepository.findByDate(appointmentTime);

        // 같은 시간대에 confirmed 상태인 예약이 있는지 확인
        for (Appointment apt : appointments) {
            if ("confirmed".equals(apt.getStatus()) &&
                    apt.getAppointmentTime().equals(appointmentTime)) {
                return false;
            }
        }
        return true;
    }
    // 날짜 범위로 예약 조회 메서드 추가
    public List<Appointment> getAppointmentsByDateRange(String startDate, String endDate) throws Exception {
        return appointmentRepository.findByDateRange(startDate, endDate);
    }

}