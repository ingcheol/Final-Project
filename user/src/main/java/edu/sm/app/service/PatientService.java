package edu.sm.app.service;

import edu.sm.app.dto.Patient;
import edu.sm.app.repository.PatientRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class PatientService implements SmService<Patient, Long> {

    final PatientRepository patientRepository;

  public Patient getByEmail(String email) throws Exception {
    return patientRepository.findByPatientEmail(email)
        .orElse(null);
  }
  public void removeByEmail(String email) throws Exception {
    patientRepository.deleteByEmail(email);
  }

  // OAuth용 메서드 추가
  public Optional<Patient> findByProviderAndProviderId(String provider, String providerId) throws Exception {
    return patientRepository.findByProviderAndProviderId(provider, providerId);
  }

  // AI 건강관리용 추가
  public Optional<Patient> findById(Long patientId) throws Exception {
    return patientRepository.findByPatientId(patientId);
  }

  // add 메서드 추가
  public void add(Patient patient) throws Exception {
    register(patient);
  }

//    public Page<Patient> getPage(int pageNo) throws Exception {
//        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
//        return patientRepository.getpage();
//    }
//
//    public Page<Patient> getPageSearch(int pageNo, PatientSearch patientSearch) throws Exception {
//        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
//        return patientRepository.getpageSearch(patientSearch);
//    }
//
//    public List<Patient> searchPatientList(PatientSearch patientSearch) throws Exception {
//        return patientRepository.searchPatientList(patientSearch);
//    }

    @Override
    public void register(Patient patient) throws Exception {
        patientRepository.insert(patient);
    }

    @Override
    public void modify(Patient patient) throws Exception {
        patientRepository.update(patient);
    }

    @Override
    public void remove(Long i) throws Exception {
        patientRepository.delete(i);
    }

    @Override
    public List<Patient> get() throws Exception {
        return patientRepository.selectAll();
    }

    @Override
    public Patient get(Long i) throws Exception {
        return patientRepository.select(i);
    }

}
