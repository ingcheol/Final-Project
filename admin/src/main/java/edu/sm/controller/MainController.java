package edu.sm.controller;

import edu.sm.app.dto.Adviser;
import edu.sm.app.dto.Patient;
import edu.sm.app.service.AdviserService;
import edu.sm.app.service.PatientService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.util.List;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MainController {
    private final PatientService patientService;
    private final AdviserService adviserService;

    @Value("${app.url.sse}")
    String sseUrl;
    @Value("${app.url.mainsse}")
    String mainsseUrl;
    @Value("${app.url.websocketurl}")
    String websocketurl;

    /**
     * 메인 페이지 (Welcome 화면)
     */
    @RequestMapping("/")
    public String main(Model model) {
        model.addAttribute("sseUrl", sseUrl);
        return "index";
    }

    /**
     * 화상 상담 페이지
     */
    @RequestMapping("/consultation")
    public String consultation(Model model) {
        model.addAttribute("websocketurl", websocketurl);
        model.addAttribute("sseUrl", sseUrl);
        model.addAttribute("center", "consultation");
        return "index";
    }

    /**
     * 환자 관리 메인 페이지 - 전체 목록
     */
    @GetMapping("/manage")
    public String manageList(Model model) {
        try {
            List<Patient> patients = patientService.getAllPatients();
            model.addAttribute("patients", patients);
            model.addAttribute("center", "manage");
            return "index";
        } catch (Exception e) {
            log.error("환자 목록 조회 실패", e);
            model.addAttribute("error", "환자 목록을 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 환자 검색
     */
    @GetMapping("/manage/search")
    public String searchPatients(@RequestParam(required = false) String keyword,
                                 @RequestParam(required = false) String status,
                                 Model model) {
        try {
            List<Patient> patients;

            if (status != null && !status.trim().isEmpty() && !status.equals("all")) {
                patients = patientService.getPatientsByStatus(status);
            } else if (keyword != null && !keyword.trim().isEmpty()) {
                patients = patientService.searchPatients(keyword);
            } else {
                patients = patientService.getAllPatients();
            }

            model.addAttribute("patients", patients);
            model.addAttribute("keyword", keyword);
            model.addAttribute("status", status);
            model.addAttribute("center", "manage");
            return "index";
        } catch (Exception e) {
            log.error("환자 검색 실패", e);
            model.addAttribute("error", "검색에 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 특정 환자 상세 관리 페이지
     */
    @GetMapping("/manage/{id}")
    public String managePatient(Model model, @PathVariable("id") Long id) {
        try {
            Patient patient = patientService.get(id);
            if (patient == null) {
                throw new Exception("환자를 찾을 수 없습니다.");
            }
            model.addAttribute("patient", patient);
            model.addAttribute("center", "manage_detail");
            return "index";
        } catch (Exception e) {
            log.error("환자 조회 실패: {}", id, e);
            model.addAttribute("error", "환자 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 환자 정보 수정 페이지
     */
    @GetMapping("/manage/edit/{id}")
    public String editPatientForm(Model model, @PathVariable("id") Long id) {
        try {
            Patient patient = patientService.get(id);
            if (patient == null) {
                throw new Exception("환자를 찾을 수 없습니다.");
            }
            model.addAttribute("patient", patient);
            model.addAttribute("center", "manage_edit");
            return "index";
        } catch (Exception e) {
            log.error("환자 수정 페이지 로드 실패: {}", id, e);
            model.addAttribute("error", "환자 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 환자 정보 수정 처리
     */
    @PostMapping("/manage/edit")
    public String updatePatient(@ModelAttribute Patient patient,
                                RedirectAttributes redirectAttributes) {
        try {
            patientService.modify(patient);
            redirectAttributes.addFlashAttribute("message", "환자 정보가 수정되었습니다.");
            return "redirect:/manage/" + patient.getPatientId();
        } catch (Exception e) {
            log.error("환자 정보 수정 실패: {}", patient.getPatientId(), e);
            redirectAttributes.addFlashAttribute("error", "환자 정보 수정에 실패했습니다.");
            return "redirect:/manage/edit/" + patient.getPatientId();
        }
    }

    /**
     * 계정 상태 변경
     */
    @PostMapping("/manage/status")
    public String changeStatus(@RequestParam Long patientId,
                               @RequestParam String status,
                               RedirectAttributes redirectAttributes) {
        try {
            patientService.changeAccountStatus(patientId, status);
            redirectAttributes.addFlashAttribute("message", "계정 상태가 변경되었습니다.");
            return "redirect:/manage/" + patientId;
        } catch (Exception e) {
            log.error("계정 상태 변경 실패: patientId={}, status={}", patientId, status, e);
            redirectAttributes.addFlashAttribute("error", "계정 상태 변경에 실패했습니다.");
            return "redirect:/manage/" + patientId;
        }
    }

    /**
     * 환자 삭제
     */
    @PostMapping("/manage/delete/{id}")
    public String deletePatient(@PathVariable("id") Long id,
                                RedirectAttributes redirectAttributes) {
        try {
            patientService.remove(id);
            redirectAttributes.addFlashAttribute("message", "환자 정보가 삭제되었습니다.");
            return "redirect:/manage";
        } catch (Exception e) {
            log.error("환자 삭제 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "환자 삭제에 실패했습니다.");
            return "redirect:/manage/" + id;
        }
    }
    // ========== 상담사 관리 ==========

    /**
     * 상담사 관리 메인 페이지 - 전체 목록
     */
    @GetMapping("/anage")
    public String adviserManageList(Model model) {
        try {
            List<Adviser> advisers = adviserService.getAllAdvisers();
            model.addAttribute("advisers", advisers);
            model.addAttribute("center", "anage");
            return "index";
        } catch (Exception e) {
            log.error("상담사 목록 조회 실패", e);
            model.addAttribute("error", "상담사 목록을 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 상담사 검색
     */
    @GetMapping("/anage/search")
    public String searchAdvisers(@RequestParam(required = false) String keyword,
                                 @RequestParam(required = false) String status,
                                 Model model) {
        try {
            List<Adviser> advisers;

            if (status != null && !status.trim().isEmpty() && !status.equals("all")) {
                advisers = adviserService.getAdvisersByStatus(status);
            } else if (keyword != null && !keyword.trim().isEmpty()) {
                advisers = adviserService.searchAdvisers(keyword);
            } else {
                advisers = adviserService.getAllAdvisers();
            }

            model.addAttribute("advisers", advisers);
            model.addAttribute("keyword", keyword);
            model.addAttribute("status", status);
            model.addAttribute("center", "anage");
            return "index";
        } catch (Exception e) {
            log.error("상담사 검색 실패", e);
            model.addAttribute("error", "검색에 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 특정 상담사 상세 관리 페이지
     */
    @GetMapping("/anage/{id}")
    public String manageAdviser(Model model, @PathVariable("id") Long id) {
        try {
            Adviser adviser = adviserService.get(id);
            if (adviser == null) {
                throw new Exception("상담사를 찾을 수 없습니다.");
            }
            model.addAttribute("adviser", adviser);
            model.addAttribute("center", "anage_detail");
            return "index";
        } catch (Exception e) {
            log.error("상담사 조회 실패: {}", id, e);
            model.addAttribute("error", "상담사 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 상담사 정보 수정 페이지
     */
    @GetMapping("/anage/edit/{id}")
    public String editAdviserForm(Model model, @PathVariable("id") Long id) {
        try {
            Adviser adviser = adviserService.get(id);
            if (adviser == null) {
                throw new Exception("상담사를 찾을 수 없습니다.");
            }
            model.addAttribute("adviser", adviser);
            model.addAttribute("center", "anage_edit");
            return "index";
        } catch (Exception e) {
            log.error("상담사 수정 페이지 로드 실패: {}", id, e);
            model.addAttribute("error", "상담사 정보를 불러오는데 실패했습니다.");
            model.addAttribute("center", "error");
            return "index";
        }
    }

    /**
     * 상담사 정보 수정 처리
     */
    @PostMapping("/anage/edit")
    public String updateAdviser(@ModelAttribute Adviser adviser,
                                RedirectAttributes redirectAttributes) {
        try {
            adviserService.modify(adviser);
            redirectAttributes.addFlashAttribute("message", "상담사 정보가 수정되었습니다.");
            return "redirect:/anage/" + adviser.getAdviserId();
        } catch (Exception e) {
            log.error("상담사 정보 수정 실패: {}", adviser.getAdviserId(), e);
            redirectAttributes.addFlashAttribute("error", "상담사 정보 수정에 실패했습니다.");
            return "redirect:/anage/edit/" + adviser.getAdviserId();
        }
    }

    /**
     * 상담사 계정 상태 변경
     */
    @PostMapping("/anage/status")
    public String changeAdviserStatus(@RequestParam Long adviserId,
                                      @RequestParam String status,
                                      RedirectAttributes redirectAttributes) {
        try {
            adviserService.changeAccountStatus(adviserId, status);
            redirectAttributes.addFlashAttribute("message", "계정 상태가 변경되었습니다.");
            return "redirect:/anage/" + adviserId;
        } catch (Exception e) {
            log.error("계정 상태 변경 실패: adviserId={}, status={}", adviserId, status, e);
            redirectAttributes.addFlashAttribute("error", "계정 상태 변경에 실패했습니다.");
            return "redirect:/anage/" + adviserId;
        }
    }

    /**
     * 상담사 삭제
     */
    @PostMapping("/anage/delete/{id}")
    public String deleteAdviser(@PathVariable("id") Long id,
                                RedirectAttributes redirectAttributes) {
        try {
            adviserService.remove(id);
            redirectAttributes.addFlashAttribute("message", "상담사 정보가 삭제되었습니다.");
            return "redirect:/anage";
        } catch (Exception e) {
            log.error("상담사 삭제 실패: {}", id, e);
            redirectAttributes.addFlashAttribute("error", "상담사 삭제에 실패했습니다.");
            return "redirect:/anage/" + id;
        }
    }
}
