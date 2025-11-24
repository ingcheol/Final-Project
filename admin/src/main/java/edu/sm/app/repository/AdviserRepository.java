package edu.sm.app.repository;

import edu.sm.app.dto.Adviser;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.*;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.List;

@Repository
@Mapper
// PK는 adviser_id (BIGSERIAL -> Long)를 사용합니다.
public interface AdviserRepository extends SmRepository<Adviser, Long> {

    // --- SmRepository<Adviser, Long> 구현 ---

    /**
     * 새로운 상담사 정보를 adviser 테이블에 삽입합니다. (register/insert 역할)
     * @param adviser 상담사 DTO 객체 (Adviser 타입)
     */
    @Override
    @Insert("INSERT INTO adviser (password, name, phone, email, license_number, account_status, created_at) " +
            "VALUES (#{password}, #{name}, #{phone}, #{email}, #{licenseNumber}, #{accountStatus}, #{createdAt})")
    void insert(Adviser adviser) throws Exception;

    /**
     * 기존 상담사 정보를 adviser 테이블에서 업데이트합니다. (modify/update 역할)
     * @param adviser 상담사 DTO 객체 (Adviser 타입)
     */
    @Override
    @Update("UPDATE adviser SET " +
            "password=#{password}, " +
            "name=#{name}, " +
            "phone=#{phone}, " +
            "email=#{email}, " +
            "license_number=#{licenseNumber}, " +
            "account_status=#{accountStatus} " +
            "WHERE adviser_id=#{adviserId}")
    void update(Adviser adviser) throws Exception;

    /**
     * adviser 테이블에서 특정 ID의 상담사 정보를 삭제합니다. (remove/delete 역할)
     * @param id 삭제할 상담사 ID (Long 타입)
     */
    @Override
    @Delete("DELETE FROM adviser WHERE adviser_id=#{id}")
    void delete(Long id) throws Exception;

    /**
     * adviser 테이블의 모든 상담사 정보를 조회합니다. (selectAll 역할)
     * @return 모든 상담사 목록 (Adviser 타입 반환)
     */
    @Override
    @Select("SELECT adviser_id, password, name, phone, email, license_number, account_status, created_at FROM adviser")
    List<Adviser> selectAll() throws Exception;

    /**
     * adviser 테이블에서 특정 ID의 상담사 정보를 조회합니다. (select 역할)
     * @param id 조회할 상담사 ID (Long 타입)
     * @return 특정 상담사 DTO 객체 (Adviser 타입 반환)
     */
    @Override
    @Select("SELECT adviser_id, password, name, phone, email, license_number, account_status, created_at FROM adviser WHERE adviser_id=#{id}")
    Adviser select(Long id) throws Exception;

    // --- 로그인 기능을 위한 사용자 정의 메서드 ---

    /**
     * adviser 테이블에서 특정 상담사 ID(로그인 ID)로 정보를 조회합니다.
     * AdminService 때와 마찬가지로 DTO의 'name' 필드를 로그인 ID로 사용한다고 가정합니다.
     * @param adviserId 조회할 상담사 로그인 ID (String 타입)
     * @return 특정 상담사 DTO 객체
     */
    @Select("SELECT adviser_id, password, name, phone, email, license_number, account_status, created_at " +
            "FROM adviser WHERE name=#{adviserId}")
    Adviser selectByAdviserId(String adviserId) throws Exception;

    // ===== 관리자 기능 추가 =====

    /**
     * 전체 상담사 목록 조회
     */
    List<Adviser> selectAllAdvisers() throws Exception;

    /**
     * 계정 상태별 상담사 조회
     * @param status active, inactive 등
     */
    List<Adviser> selectByAccountStatus(@Param("status") String status) throws Exception;

    /**
     * 계정 상태 변경
     * @param adviserId 상담사 ID
     * @param status 변경할 상태
     */
    void updateAccountStatus(@Param("adviserId") Long adviserId,
                             @Param("status") String status) throws Exception;

    /**
     * 상담사 검색 (이름, 이메일, 전화번호, 자격증 번호)
     * @param keyword 검색 키워드
     */
    List<Adviser> searchAdvisers(@Param("keyword") String keyword) throws Exception;

    /**
     * 상담사 상세 정보 조회
     * @param adviserId 상담사 ID
     */
    Adviser selectAdviserDetail(@Param("adviserId") Long adviserId) throws Exception;

    /**
     * 복합 조건 검색
     */
    List<Adviser> searchAdvisersAdvanced(
            @Param("keyword") String keyword,
            @Param("status") String status,
            @Param("startDate") Timestamp startDate,
            @Param("endDate") Timestamp endDate
    ) throws Exception;

    /**
     * 통계 정보 - 계정 상태별 카운트
     */
    int countByAccountStatus(@Param("status") String status) throws Exception;

    /**
     * 통계 정보 - 전체 상담사 수
     */
    int countTotalAdvisers() throws Exception;
}