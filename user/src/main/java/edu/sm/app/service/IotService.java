package edu.sm.app.service;

import edu.sm.app.dto.Iot;
import edu.sm.app.repository.IotRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class IotService implements SmService<Iot,Long> {

  final IotRepository iotRepository;

  // 환자별 최신 데이터 조회용
  public List<Iot> getByPatientId(Long patientId) throws Exception {
    return iotRepository.findByPatientId(patientId);
  }

  // 🆕 최근 N개 데이터 조회 (AI 분석용)
  public List<Iot> getRecentByPatientId(Long patientId, int limit) throws Exception {
    return iotRepository.findRecentByPatientId(patientId, limit);
  }

  // 🆕 특정 바이탈의 최근 데이터 조회 (추세 분석용)
  public List<Iot> getRecentByVitalType(Long patientId, String vitalType, int limit) throws Exception {
    return iotRepository.findRecentByPatientIdAndVitalType(patientId, vitalType, limit);
  }

  // 🆕 7일/30일/90일 데이터 조회 (그래프용)
  public List<Iot> getByDateRange(Long patientId, int days) throws Exception {
    LocalDateTime startDate = LocalDateTime.now().minusDays(days);
    return iotRepository.findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(patientId, startDate);
  }

  @Override
  public void register(Iot iot) throws Exception {
    iotRepository.insert(iot);
  }

  @Override
  public void modify(Iot iot) throws Exception {
    iotRepository.update(iot);
  }

  @Override
  public void remove(Long l) throws Exception {
    iotRepository.delete(l);
  }

  @Override
  public List<Iot> get() throws Exception {
    return null;
  }

  @Override
  public Iot get(Long l) throws Exception {
    return iotRepository.select(l);
  }
}
