package edu.sm.app.repository;

import com.github.pagehelper.Page;
import edu.sm.app.dto.User;
import edu.sm.common.frame.SmRepository;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
@Mapper
public interface UserRepository extends SmRepository<User,Integer> {
  // OAuth
  Optional<User> findByUserEmail(@Param("email") String email) throws Exception;
  Optional<User> findByProviderAndProviderId(@Param("provider") String provider,@Param("providerId") String providerId) throws Exception;

  void deleteByEmail(@Param("email") String email) throws Exception;

//    Page<User> getpage() throws Exception;
//    Page<User> getpageSearch(UserSearch userSearch) throws Exception;
//    List<User> searchUserList(UserSearch userSearch) throws Exception;
}
