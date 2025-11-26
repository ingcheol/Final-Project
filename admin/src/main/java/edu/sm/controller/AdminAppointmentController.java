package edu.sm.controller;

import edu.sm.app.dto.Appointment;
import edu.sm.app.service.AppointmentService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@RequestMapping("/admin/appointments")
@RequiredArgsConstructor
@Slf4j
public class AdminAppointmentController {

    private final AppointmentService appointmentService;

    /**
     * 예약 관리 메인 페이지 (전체 목록)
     */
    @GetMapping
    public String appointmentList(Model model, HttpSession session) {
        try {
            // 관리자 권한 체크
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                log.warn("인증되지 않은 접근 시도");
                return "redirect:/login";
            }

            // 전체 예약 목록 조회
            List<Appointment> appointments = appointmentService.get();
            log.info("예약 목록 조회 완료: {} 건", appointments.size());

            // 상태별 카운트
            int pendingCount = appointmentService.countPendingAppointments();
            long confirmedCount = appointments.stream().filter(a -> "confirmed".equals(a.getStatus())).count();
            long completedCount = appointments.stream().filter(a -> "completed".equals(a.getStatus())).count();
            long cancelledCount = appointments.stream().filter(a -> "cancelled".equals(a.getStatus())).count();

            model.addAttribute("appointments", appointments);
            model.addAttribute("pendingCount", pendingCount);
            model.addAttribute("confirmedCount", confirmedCount);
            model.addAttribute("completedCount", completedCount);
            model.addAttribute("cancelledCount", cancelledCount);
            model.addAttribute("center", "appointments/list");  // admin/ 제거!

            log.info("모델 설정 완료 - center: appointments/list");

            return "index";

        } catch (Exception e) {
            log.error("예약 목록 조회 실패", e);
            model.addAttribute("error", "예약 목록을 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * /list 경로로 접근해도 목록 표시
     */
    @GetMapping("/list")
    public String appointmentListAlias(Model model, HttpSession session) {
        return appointmentList(model, session);
    }

    /**
     * detail 단어만으로 접근 시 목록으로 리다이렉트
     */
    @GetMapping("/detail")
    public String redirectToList() {
        return "redirect:/admin/appointments";
    }

    /**
     * 승인 대기 목록만 조회
     */
    @GetMapping("/pending")
    public String pendingAppointments(Model model, HttpSession session) {
        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            List<Appointment> pendingAppointments = appointmentService.getByStatus("pending");

            model.addAttribute("appointments", pendingAppointments);
            model.addAttribute("pageTitle", "승인 대기 중인 예약");
            model.addAttribute("center", "appointments/list");  // admin/ 제거!

            return "index";

        } catch (Exception e) {
            log.error("승인 대기 목록 조회 실패", e);
            model.addAttribute("error", "목록을 불러오는데 실패했습니다.");
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
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            Appointment appointment = appointmentService.get(id);

            if (appointment == null) {
                model.addAttribute("error", "예약을 찾을 수 없습니다.");
                model.addAttribute("center", "error");
                return "index";
            }

            model.addAttribute("appointment", appointment);
            model.addAttribute("center", "appointments/detail");  // admin/ 제거!

            return "index";

        } catch (Exception e) {
            log.error("예약 상세 조회 실패: {}", id, e);
            model.addAttribute("error", "예약 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 예약 승인
     */
    @PostMapping("/{id}/confirm")
    public String confirmAppointment(
            @PathVariable Long id,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            appointmentService.confirmAppointment(id);

            log.info("예약 승인 완료 - ID: {}, 승인자: {}",
                    id, admin != null ? "Admin" : "Adviser");

            redirectAttributes.addFlashAttribute("message", "예약이 승인되었습니다. 환자에게 알림이 전송됩니다.");
            return "redirect:/admin/appointments/" + id;

        } catch (Exception e) {
            log.error("예약 승인 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "예약 승인 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/admin/appointments/" + id;
        }
    }

    /**
     * 예약 거절
     */
    @PostMapping("/{id}/reject")
    public String rejectAppointment(
            @PathVariable Long id,
            @RequestParam(required = false) String reason,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            String rejectReason = reason != null && !reason.trim().isEmpty()
                    ? reason
                    : "관리자 거절";

            appointmentService.cancelAppointment(id, rejectReason);

            log.info("예약 거절 완료 - ID: {}, 사유: {}", id, rejectReason);

            redirectAttributes.addFlashAttribute("message", "예약이 거절되었습니다.");
            return "redirect:/admin/appointments";

        } catch (Exception e) {
            log.error("예약 거절 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "예약 거절 중 오류가 발생했습니다: " + e.getMessage());
            return "redirect:/admin/appointments/" + id;
        }
    }

    /**
     * 예약 완료 처리
     */
    @PostMapping("/{id}/complete")
    public String completeAppointment(
            @PathVariable Long id,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            appointmentService.completeAppointment(id);

            log.info("상담 완료 처리 - ID: {}", id);

            redirectAttributes.addFlashAttribute("message", "상담이 완료 처리되었습니다.");
            return "redirect:/admin/appointments/" + id;

        } catch (Exception e) {
            log.error("상담 완료 처리 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "상담 완료 처리 중 오류가 발생했습니다.");
            return "redirect:/admin/appointments/" + id;
        }
    }

    /**
     * 예약 수정 페이지
     */
    @GetMapping("/{id}/edit")
    public String editAppointmentForm(@PathVariable Long id, Model model, HttpSession session) {
        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            Appointment appointment = appointmentService.get(id);

            if (appointment == null) {
                model.addAttribute("error", "예약을 찾을 수 없습니다.");
                model.addAttribute("center", "error");
                return "index";
            }

            model.addAttribute("appointment", appointment);
            model.addAttribute("center", "appointments/edit");  // admin/ 제거!

            return "index";

        } catch (Exception e) {
            log.error("예약 수정 페이지 로드 실패: {}", id, e);
            model.addAttribute("error", "예약 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 예약 수정 처리
     */
    @PostMapping("/{id}/edit")
    public String updateAppointment(
            @PathVariable Long id,
            @ModelAttribute Appointment appointment,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Object admin = session.getAttribute("admin");
            Object adviser = session.getAttribute("adviser");

            if (admin == null && adviser == null) {
                return "redirect:/login";
            }

            appointment.setAppointmentId(id);
            appointmentService.modify(appointment);

            log.info("예약 정보 수정 완료 - ID: {}", id);

            redirectAttributes.addFlashAttribute("message", "예약 정보가 수정되었습니다.");
            return "redirect:/admin/appointments/" + id;

        } catch (Exception e) {
            log.error("예약 수정 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "예약 수정 중 오류가 발생했습니다.");
            return "redirect:/admin/appointments/" + id + "/edit";
        }
    }

    /**
     * 예약 삭제
     */
    @PostMapping("/{id}/delete")
    public String deleteAppointment(
            @PathVariable Long id,
            HttpSession session,
            RedirectAttributes redirectAttributes) {

        try {
            Object admin = session.getAttribute("admin");

            if (admin == null) {
                redirectAttributes.addFlashAttribute("error", "관리자 권한이 필요합니다.");
                return "redirect:/admin/appointments";
            }

            appointmentService.remove(id);

            log.info("예약 삭제 완료 - ID: {}", id);

            redirectAttributes.addFlashAttribute("message", "예약이 삭제되었습니다.");
            return "redirect:/admin/appointments";

        } catch (Exception e) {
            log.error("예약 삭제 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "예약 삭제 중 오류가 발생했습니다.");
            return "redirect:/admin/appointments";
        }
    }
}