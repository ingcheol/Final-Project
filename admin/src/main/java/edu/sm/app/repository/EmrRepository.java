package edu.sm.app.repository;

import edu.sm.app.dto.Emr;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@Mapper
public interface EmrRepository extends SmRepository<Emr, Long> {
  Optional<Emr> findTopByPatientIdOrderByCreatedAtDesc(@Param("patientId") Long patientId) throws Exception;

  // 환자별 EMR 목록 조회
  List<Emr> findByPatientId(@Param("patientId") Long patientId) throws Exception;
}