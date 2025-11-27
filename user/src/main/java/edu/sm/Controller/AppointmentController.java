package edu.sm.controller;

import edu.sm.app.dto.Appointment;
import edu.sm.app.dto.Patient;
import edu.sm.app.service.AppointmentService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.http.ResponseEntity;


import java.time.LocalDateTime;
import java.util.List;

@Controller
@RequestMapping("/appointment")
@RequiredArgsConstructor
@Slf4j
public class AppointmentController {

    private final AppointmentService appointmentService;

    /**
     * 예약 신청 페이지
     */
    @GetMapping("/new")
    public String newAppointmentForm(Model model, HttpSession session) {
        Patient patient = (Patient) session.getAttribute("loginuser");
        if (patient == null) {
            return "redirect:/login";
        }

        model.addAttribute("center", "appointment/form");
        return "index";
    }

    /**
     * 예약 신청 처리
     */
    @PostMapping("/create")
    public String createAppointment(
            @RequestParam @DateTimeFormat(pattern = "yyyy-MM-dd'T'HH:mm") LocalDateTime appointmentTime,
            @RequestParam String appointmentType,
            @RequestParam(required = false) String notes,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                return "redirect:/login";
            }

            // 시간대 중복 체크
            if (!appointmentService.isTimeSlotAvailable(appointmentTime)) {
                redirectAttributes.addFlashAttribute("error", "해당 시간대는 이미 예약이 있습니다. 다른 시간을 선택해주세요.");
                return "redirect:/appointment/new";
            }

            Appointment appointment = Appointment.builder()
                    .patientId(patient.getPatientId())
                    .appointmentTime(appointmentTime)
                    .appointmentType(appointmentType)
                    .notes(notes)
                    .status("pending")
                    .build();

            appointmentService.register(appointment);

            redirectAttributes.addFlashAttribute("message", "예약 신청이 완료되었습니다. 승인 후 알림을 보내드립니다.");
            return "redirect:/appointment/my";

        } catch (Exception e) {
            log.error("예약 신청 실패", e);
            redirectAttributes.addFlashAttribute("error", "예약 신청 중 오류가 발생했습니다.");
            return "redirect:/appointment/new";
        }
    }

    /**
     * 내 예약 목록
     */
    @GetMapping("/my")
    public String myAppointments(Model model, HttpSession session) {
        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                return "redirect:/login";
            }

            List<Appointment> appointments = appointmentService.getByPatientId(patient.getPatientId());
            model.addAttribute("appointments", appointments);
            model.addAttribute("center", "appointment/my");
            return "index";

        } catch (Exception e) {
            log.error("예약 목록 조회 실패", e);
            model.addAttribute("error", "예약 목록을 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 예약 상세 조회 (JSON / View 모두 처리)
     */
    @GetMapping("/{id}")
    @ResponseBody
    public ResponseEntity<?> appointmentDetail(
            @PathVariable Long id,
            HttpSession session,
            @RequestHeader(value = "Accept", defaultValue = "") String accept) {

        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                if (accept.contains("application/json")) {
                    Map<String, String> error = new HashMap<>();
                    error.put("error", "로그인이 필요합니다.");
                    return ResponseEntity.status(401).body(error);
                }
                return ResponseEntity.status(302).header("Location", "/login").build();
            }

            Appointment appointment = appointmentService.get(id);

            // 본인 예약만 조회 가능
            if (!appointment.getPatientId().equals(patient.getPatientId())) {
                if (accept.contains("application/json")) {
                    Map<String, String> error = new HashMap<>();
                    error.put("error", "권한이 없습니다.");
                    return ResponseEntity.status(403).body(error);
                }
                return ResponseEntity.status(403).build();
            }

            // AJAX 요청인 경우 JSON 반환
            if (accept.contains("application/json")) {
                return ResponseEntity.ok(appointment);
            }

            // 일반 요청인 경우는 처리하지 않음 (다른 메서드에서 처리)
            return ResponseEntity.status(404).build();

        } catch (Exception e) {
            log.error("예약 상세 조회 실패", e);

            if (accept.contains("application/json")) {
                Map<String, String> error = new HashMap<>();
                error.put("error", "예약 정보를 불러오는데 실패했습니다.");
                return ResponseEntity.status(500).body(error);
            }

            return ResponseEntity.status(500).build();
        }
    }

    /**
     * 예약 취소
     */
    @PostMapping("/cancel/{id}")
    public String cancelAppointment(
            @PathVariable Long id,
            @RequestParam(required = false) String reason,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                return "redirect:/login";
            }

            Appointment appointment = appointmentService.get(id);

            // 본인 예약만 취소 가능
            if (!appointment.getPatientId().equals(patient.getPatientId())) {
                redirectAttributes.addFlashAttribute("error", "권한이 없습니다.");
                return "redirect:/appointment/my";
            }

            // 이미 완료되거나 취소된 예약은 취소 불가
            if ("completed".equals(appointment.getStatus()) ||
                    "cancelled".equals(appointment.getStatus())) {
                redirectAttributes.addFlashAttribute("error", "이미 완료되거나 취소된 예약입니다.");
                return "redirect:/appointment/my";
            }

            appointmentService.cancelAppointment(id, reason != null ? reason : "환자 요청");
            redirectAttributes.addFlashAttribute("message", "예약이 취소되었습니다.");
            return "redirect:/appointment/my";

        } catch (Exception e) {
            log.error("예약 취소 실패", e);
            redirectAttributes.addFlashAttribute("error", "예약 취소 중 오류가 발생했습니다.");
            return "redirect:/appointment/my";
        }
    }

    /**
     * 캘린더용 예약 목록 조회 (AJAX)
     */
    @GetMapping("/calendar/events")
    @ResponseBody
    public List<Map<String, Object>> getCalendarEvents(
            @RequestParam(required = false) String start,
            @RequestParam(required = false) String end,
            HttpSession session) {

        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                return new ArrayList<>();
            }

            // 해당 환자의 예약만 조회
            List<Appointment> appointments = appointmentService.getByPatientId(patient.getPatientId());

            // FullCalendar 형식으로 변환
            List<Map<String, Object>> events = new ArrayList<>();
            for (Appointment apt : appointments) {
                Map<String, Object> event = new HashMap<>();
                event.put("id", apt.getAppointmentId());
                event.put("title", "🏥 " + apt.getAppointmentTypeKr());
                event.put("start", apt.getFormattedDate() + "T" + apt.getFormattedTime());

                // 상태에 따른 색상
                String color = getColorByStatus(apt.getStatus());
                event.put("backgroundColor", color);
                event.put("borderColor", color);

                // 추가 정보
                Map<String, Object> extendedProps = new HashMap<>();
                extendedProps.put("status", apt.getStatus());
                extendedProps.put("statusKr", apt.getStatusKr());
                extendedProps.put("type", "appointment");
                extendedProps.put("time", apt.getFormattedTime());
                extendedProps.put("desc", apt.getNotes() != null ? apt.getNotes() : "");
                extendedProps.put("appointmentId", apt.getAppointmentId());
                extendedProps.put("dbRecord", true);
                extendedProps.put("appointmentType", apt.getAppointmentType());
                event.put("extendedProps", extendedProps);

                events.add(event);
            }

            return events;

        } catch (Exception e) {
            log.error("캘린더 이벤트 조회 실패", e);
            return new ArrayList<>();
        }
    }

    private String getColorByStatus(String status) {
        switch (status) {
            case "confirmed":
                return "#70ad47"; // 녹색
            case "pending":
                return "#ffc000";   // 노란색
            case "cancelled":
                return "#c0c0c0"; // 회색
            case "completed":
                return "#5b9bd5"; // 파란색
            default:
                return "#808080";
        }

    }
}