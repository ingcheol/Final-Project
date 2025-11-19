package edu.sm.app.repository;

import edu.sm.app.dto.Admin; // admin 테이블의 새 구조(password, name 등)를 반영하는 DTO여야 합니다.
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
@Mapper
// AdminRepository 인터페이스를 유지하고 Long 타입의 PK를 사용합니다.
public interface AdminRepository extends SmRepository<Admin, Long> {

    /**
     * 새로운 관리자 정보를 admin 테이블에 삽입합니다.
     * @param admin 관리자 DTO 객체 (Admin 타입)
     * @throws Exception 삽입 중 발생한 예외
     */
    @Override
    @Insert("INSERT INTO admin (password, name, phone, email, account_status, created_at, patient_id) " +
            "VALUES (#{password}, #{name}, #{phone}, #{email}, #{accountStatus}, #{createdAt}, #{patientId})")
    // 참고: admin_id가 BIGSERIAL(시퀀스)로 자동 생성되므로, INSERT 시에는 해당 필드를 제외했습니다.
    void insert(Admin admin) throws Exception;

    /**
     * 기존 관리자 정보를 admin 테이블에서 업데이트합니다.
     * @param admin 관리자 DTO 객체 (Admin 타입)
     * @throws Exception 업데이트 중 발생한 예외
     */
    @Override
    @Update("UPDATE admin SET " +
            "password=#{password}, " +
            "name=#{name}, " +
            "phone=#{phone}, " +
            "email=#{email}, " +
            "account_status=#{accountStatus}, " +
            "created_at=#{createdAt}, " +
            "patient_id=#{patientId} " +
            "WHERE admin_id=#{adminId}")
    void update(Admin admin) throws Exception;

    /**
     * admin 테이블에서 특정 ID의 관리자 정보를 삭제합니다.
     * @param id 삭제할 관리자 ID (Long 타입)
     * @throws Exception 삭제 중 발생한 예외
     */
    @Override
    @Delete("DELETE FROM admin WHERE admin_id=#{id}")
    void delete(Long id) throws Exception;

    /**
     * admin 테이블의 모든 관리자 정보를 조회합니다.
     * @return 모든 관리자 목록 (Admin 타입 반환)
     * @throws Exception 조회 중 발생한 예외
     */
    @Override
    @Select("SELECT admin_id, password, name, phone, email, account_status, created_at, patient_id FROM admin")
    List<Admin> selectAll() throws Exception;


    @Select("SELECT admin_id, password, name, phone, email, account_status, created_at, patient_id " +
            "FROM admin WHERE name=#{adminId}") // DTO의 name 필드가 로그인 ID라고 가정합니다.
    Admin selectByAdminId(String adminId) throws Exception;
}