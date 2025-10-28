package hello.hello_spring.domain.user;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service("userServiceImpl")
public class serviceImpl implements service {

    @Autowired
    private repository userRepository;

    @Override // 유저 생성
    public entity registerUser(entity user) {
        return userRepository.save(user);
    }

    @Override //전체 유저 조회
    public List<entity> getAllUsers() {
        return userRepository.findAll();
    }

    @Override // 유저 삭제
    public void deleteUser(Long id) {
        userRepository.deleteById(id);
    }

    @Override // 유저 수정
    public entity updateUser(Long id, entity user) {
        Optional<entity> existingUser = userRepository.findById(id);
        if (existingUser.isPresent()) {
            entity updatedUser = existingUser.get();
            updatedUser.setName(user.getName());
            updatedUser.setPassword(user.getPassword());
            return userRepository.save(updatedUser);
        } else {
            throw new RuntimeException("User not found with id " + id);
        }
    }
}