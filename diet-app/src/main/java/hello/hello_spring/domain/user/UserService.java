package hello.hello_spring.domain.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Optional;
import java.util.List;

@Service
public class UserService {

    @Autowired
    private UserRepository userRepository;

    public boolean login(String name, String password) {
        Optional<UserEntity> user = userRepository.findByNameAndPassword(name, password);
        return user.isPresent(); // 일치하는 사용자가 있으면 true 반환
    }

    // 유저 생성
    public UserEntity registerUser(UserEntity user) {
        return userRepository.save(user);
    }

    // 전체 유저 조회
    public List<UserEntity> getAllUsers() {
        return userRepository.findAll();
    }

    // 유저 삭제
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }
}