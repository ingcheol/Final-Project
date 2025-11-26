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
     * 예약 상세 조회
     */
    @GetMapping("/{id}")
    public String appointmentDetail(@PathVariable Long id, Model model, HttpSession session) {
        try {
            Patient patient = (Patient) session.getAttribute("loginuser");
            if (patient == null) {
                return "redirect:/login";
            }

            Appointment appointment = appointmentService.get(id);

            // 본인 예약만 조회 가능
            if (!appointment.getPatientId().equals(patient.getPatientId())) {
                model.addAttribute("error", "권한이 없습니다.");
                model.addAttribute("center", "error");
                return "index";
            }

            model.addAttribute("appointment", appointment);
            model.addAttribute("center", "appointment/detail");
            return "index";

        } catch (Exception e) {
            log.error("예약 상세 조회 실패", e);
            model.addAttribute("error", "예약 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
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
}