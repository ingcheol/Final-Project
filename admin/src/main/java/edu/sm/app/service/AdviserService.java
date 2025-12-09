package edu.sm.app.service;

import edu.sm.app.dto.Adviser;
import edu.sm.app.repository.AdviserRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.sql.Timestamp;
import java.util.List;

@Service
@RequiredArgsConstructor
public class AdviserService implements SmService<Adviser, Long> {

    private final AdviserRepository adviserRepository;

    // --- SmService<Adviser, Long> 구현 ---

    /**
     * 새로운 상담사 정보를 등록합니다. (SmService의 register 메서드 구현)
     * Repository의 insert 메서드를 호출하여 작업을 위임합니다.
     * @param adviser 등록할 Adviser DTO 객체
     * @throws Exception 데이터베이스 삽입 오류
     */
    @Override
    public void register(Adviser adviser) throws Exception {
        adviserRepository.insert(adviser);
    }

    /**
     * 기존 상담사 정보를 수정/업데이트합니다. (SmService의 modify 메서드 구현)
     * Repository의 update 메서드를 호출하여 작업을 위임합니다.
     * @param adviser 업데이트할 Adviser DTO 객체
     * @throws Exception 데이터베이스 업데이트 오류
     */
    @Override
    public void modify(Adviser adviser) throws Exception {
        adviserRepository.update(adviser);
    }

    /**
     * 특정 ID의 상담사 정보를 삭제합니다. (SmService의 remove 메서드 구현)
     * Repository의 delete 메서드를 호출하여 작업을 위임합니다.
     * @param id 삭제할 상담사 ID (Long 타입)
     * @throws Exception 데이터베이스 삭제 오류
     */
    @Override
    public void remove(Long id) throws Exception {
        adviserRepository.delete(id);
    }

    /**
     * 모든 상담사 목록을 조회합니다. (SmService의 get() 메서드 구현)
     * Repository의 selectAll 메서드를 호출하여 작업을 위임합니다.
     * @return 모든 Adviser DTO 목록
     * @throws Exception 데이터베이스 조회 오류
     */
    @Override
    public List<Adviser> get() throws Exception {
        return adviserRepository.selectAll();
    }

    /**
     * 특정 ID의 상담사 정보를 조회합니다. (SmService의 get(K k) 메서드 구현)
     * Repository의 select 메서드를 호출하여 작업을 위임합니다.
     * @param id 조회할 상담사 ID (Long 타입)
     * @return 조회된 Adviser DTO 객체
     * @throws Exception 데이터베이스 조회 오류
     */
    @Override
    public Adviser get(Long id) throws Exception {
        return adviserRepository.select(id);
    }

    // --- 로그인 기능을 위한 사용자 정의 메서드 (AdminService와 동일 패턴 적용) ---

    /**
     * 상담사 로그인 ID(String)를 사용하여 상담사 정보를 조회합니다.
     * Repository의 selectByAdviserId 메서드를 호출하여 작업을 위임합니다.
     * @param adviserId 조회할 상담사 로그인 ID (String)
     * @return 조회된 Adviser DTO 객체
     * @throws Exception 데이터베이스 조회 오류
     */
    public Adviser getByAdviserId(String adviserId) throws Exception {
        return adviserRepository.selectByAdviserId(adviserId);
    }

    // ===== 관리자 기능 추가 =====

    /**
     * 전체 상담사 목록 조회
     */
    public List<Adviser> getAllAdvisers() throws Exception {
        return adviserRepository.selectAllAdvisers();
    }

    /**
     * 계정 상태별 상담사 조회
     * @param status active, inactive 등
     */
    public List<Adviser> getAdvisersByStatus(String status) throws Exception {
        return adviserRepository.selectByAccountStatus(status);
    }

    /**
     * 계정 상태 변경
     * @param adviserId 상담사 ID
     * @param status 변경할 상태 (active, inactive 등)
     */
    @Transactional
    public void changeAccountStatus(Long adviserId, String status) throws Exception {
        // 상태 유효성 검증
        if (!isValidStatus(status)) {
            throw new IllegalArgumentException("유효하지 않은 계정 상태입니다: " + status);
        }

        // 상담사 존재 여부 확인
        Adviser adviser = adviserRepository.select(adviserId);
        if (adviser == null) {
            throw new Exception("상담사를 찾을 수 없습니다: " + adviserId);
        }

        adviserRepository.updateAccountStatus(adviserId, status);
    }

    /**
     * 상담사 검색 (이름, 이메일, 전화번호, 자격증 번호)
     */
    public List<Adviser> searchAdvisers(String keyword) throws Exception {
        if (keyword == null || keyword.trim().isEmpty()) {
            return getAllAdvisers();
        }
        return adviserRepository.searchAdvisers(keyword.trim());
    }

    /**
     * 상담사 상세 정보 조회
     */
    public Adviser getAdviserDetail(Long adviserId) throws Exception {
        Adviser adviser = adviserRepository.selectAdviserDetail(adviserId);
        if (adviser == null) {
            throw new Exception("상담사를 찾을 수 없습니다: " + adviserId);
        }
        return adviser;
    }

    /**
     * 복합 조건 검색
     */
    public List<Adviser> searchAdvisersAdvanced(String keyword, String status,
                                                Timestamp startDate, Timestamp endDate) throws Exception {
        return adviserRepository.searchAdvisersAdvanced(keyword, status, startDate, endDate);
    }

    /**
     * 상담사 정보 수정 (관리자용)
     */
    @Transactional
    public void updateAdviser(Adviser adviser) throws Exception {
        Adviser existing = get(adviser.getAdviserId());
        if (existing == null) {
            throw new Exception("상담사를 찾을 수 없습니다: " + adviser.getAdviserId());
        }
        modify(adviser);
    }

    /**
     * 상담사 삭제 (관리자용)
     */
    @Transactional
    public void deleteAdviser(Long adviserId) throws Exception {
        Adviser adviser = get(adviserId);
        if (adviser == null) {
            throw new Exception("상담사를 찾을 수 없습니다: " + adviserId);
        }
        remove(adviserId);
    }

    /**
     * 통계 정보 조회
     */
    public int countByStatus(String status) throws Exception {
        return adviserRepository.countByAccountStatus(status);
    }

    public int countTotalAdvisers() throws Exception {
        return adviserRepository.countTotalAdvisers();
    }

    // 상태 유효성 검증
    private boolean isValidStatus(String status) {
        return status != null &&
                (status.equals("active") || status.equals("inactive"));
    }
}