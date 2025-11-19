package edu.sm.app.service;

import edu.sm.app.dto.Adviser;
import edu.sm.app.repository.AdviserRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdviserService implements SmService<Adviser, Long> {

    // final 키워드와 @RequiredArgsConstructor를 사용하여 AdviserRepository를 주입받습니다.
    final AdviserRepository adviserRepository;

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
}