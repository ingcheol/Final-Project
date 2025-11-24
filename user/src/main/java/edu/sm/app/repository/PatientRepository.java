package edu.sm.app.repository;

import com.github.pagehelper.Page;
import edu.sm.app.dto.Patient;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@Mapper
public interface PatientRepository extends SmRepository<Patient,Long> {
  // OAuth
  Optional<Patient> findByPatientEmail(@Param("email") String email) throws Exception;
  Optional<Patient> findByProviderAndProviderId(@Param("provider") String provider,
                                                @Param("providerId") String providerId) throws Exception;
  void deleteByEmail(@Param("email") String email) throws Exception;

  Optional<Patient> findByPatientId(@Param("patientId") Long patientId) throws Exception;
//    Page<User> getpage() throws Exception;
//    Page<User> getpageSearch(UserSearch userSearch) throws Exception;
//    List<User> searchUserList(UserSearch userSearch) throws Exception;
}
