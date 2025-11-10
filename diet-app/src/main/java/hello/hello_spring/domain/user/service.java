package hello.hello_spring.domain.user;

import java.util.List;

public interface service {
    entity registerUser(entity user); // 유저 생성

    List<entity> getAllUsers(); // 전체 유저 조회

    void deleteUser(Long id); // 유저 삭제

    entity updateUser(Long id, entity user); // 유저 정보 수정
}
