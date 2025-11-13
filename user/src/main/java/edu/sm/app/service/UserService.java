package edu.sm.app.service;

import com.github.pagehelper.Page;
import com.github.pagehelper.PageHelper;
import edu.sm.app.dto.User;
import edu.sm.app.repository.UserRepository;
import edu.sm.common.frame.SmService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class UserService implements SmService<User, Integer> {

    final UserRepository userRepository;

  public User getByEmail(String email) throws Exception {
    return userRepository.findByUserEmail(email)
        .orElseThrow(() -> new Exception("사용자를 찾을 수 없습니다: " + email));
  }
  public void removeByEmail(String email) throws Exception {
    userRepository.deleteByEmail(email);
  }

//    public Page<User> getPage(int pageNo) throws Exception {
//        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
//        return userRepository.getpage();
//    }
//
//    public Page<User> getPageSearch(int pageNo, UserSearch userSearch) throws Exception {
//        PageHelper.startPage(pageNo, 3); // 3: 한화면에 출력되는 개수
//        return userRepository.getpageSearch(userSearch);
//    }
//
//    public List<User> searchUserList(UserSearch userSearch) throws Exception {
//        return userRepository.searchUserList(userSearch);
//    }

    @Override
    public void register(User user) throws Exception {
        userRepository.insert(user);
    }

    @Override
    public void modify(User user) throws Exception {
        userRepository.update(user);
    }

    @Override
    public void remove(Integer i) throws Exception {
        userRepository.delete(i);
    }

    @Override
    public List<User> get() throws Exception {
        return userRepository.selectAll();
    }

    @Override
    public User get(Integer i) throws Exception {
        return userRepository.select(i);
    }

}
