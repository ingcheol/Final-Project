package edu.sm.app.repository;

import edu.sm.app.dto.Survey;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@Mapper
public interface SurveyRepository extends SmRepository<Survey, Long> {
  // 최근 설문 조회 5개
  Optional<Survey> findTopByPatientIdOrderBySubmittedAtDesc(@Param("patientId") Long patientId) throws Exception;

  // 환자별 설문 목록 조회
  List<Survey> findByPatientId(@Param("patientId") Long patientId) throws Exception;

  // 설문 유형별 조회
  List<Survey> findByPatientIdAndSurveyType(@Param("patientId") Long patientId,
                                            @Param("surveyType") String surveyType) throws Exception;
}