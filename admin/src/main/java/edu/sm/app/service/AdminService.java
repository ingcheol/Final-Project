package edu.sm.app.service;

import edu.sm.app.dto.Admin;
import edu.sm.app.repository.AdminRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class AdminService implements SmService<Admin, Long> {

    // final 키워드와 @RequiredArgsConstructor를 사용하여 AdminRepository를 주입받습니다.
    final AdminRepository adminRepository;

    /**
     * 새로운 관리자 정보를 등록합니다. (SmService의 register 메서드 구현)
     * Repository의 insert 메서드를 호출하여 작업을 위임합니다.
     * @param admin 등록할 Admin DTO 객체
     * @throws Exception 데이터베이스 삽입 오류
     */
    @Override
    public void register(Admin admin) throws Exception {
        // 기존 register/insert 역할
        adminRepository.insert(admin);
    }

    /**
     * 기존 관리자 정보를 수정/업데이트합니다. (SmService의 modify 메서드 구현)
     * Repository의 update 메서드를 호출하여 작업을 위임합니다.
     * @param admin 업데이트할 Admin DTO 객체
     * @throws Exception 데이터베이스 업데이트 오류
     */
    @Override
    public void modify(Admin admin) throws Exception {
        // 기존 update 역할
        adminRepository.update(admin);
    }

    /**
     * 특정 ID의 관리자 정보를 삭제합니다. (SmService의 remove 메서드 구현)
     * Repository의 delete 메서드를 호출하여 작업을 위임합니다.
     * @param id 삭제할 관리자 ID (Long 타입)
     * @throws Exception 데이터베이스 삭제 오류
     */
    @Override
    public void remove(Long id) throws Exception {
        // 기존 delete 역할
        adminRepository.delete(id);
    }

    /**
     * 모든 관리자 목록을 조회합니다. (SmService의 get() 메서드 구현)
     * Repository의 selectAll 메서드를 호출하여 작업을 위임합니다.
     * @return 모든 Admin DTO 목록
     * @throws Exception 데이터베이스 조회 오류
     */
    @Override
    public List<Admin> get() throws Exception {
        // 기존 selectAll 역할
        return adminRepository.selectAll();
    }

    /**
     * 특정 ID의 관리자 정보를 조회합니다. (SmService의 get(K k) 메서드 구현)
     * Repository의 select 메서드를 호출하여 작업을 위임합니다.
     * @param id 조회할 관리자 ID (Long 타입)
     * @return 조회된 Admin DTO 객체
     * @throws Exception 데이터베이스 조회 오류
     */
    @Override
    public Admin get(Long id) throws Exception {
        // 기존 select 역할
        return adminRepository.select(id);
    }
    public Admin getByAdminId(String adminId) throws Exception {
        return adminRepository.selectByAdminId(adminId);
    }
}