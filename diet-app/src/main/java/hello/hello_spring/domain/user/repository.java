package hello.hello_spring.domain.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository("userRepository")
public interface repository extends JpaRepository<entity, Long> {
    List<entity> findAll(); // 전체 유저 조회

    void deleteById(Long id); // 유저 삭제
    Optional<entity> findById(Long id);
}