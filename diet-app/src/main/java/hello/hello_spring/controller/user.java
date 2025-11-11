package hello.hello_spring.controller;

import hello.hello_spring.domain.user.UserEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;
import hello.hello_spring.domain.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/user")
public class user {

    @Autowired
    private UserService userService;

    @PostMapping("/register") // 유저 생성
    public UserEntity registerUser(@RequestBody UserEntity user) {
        return userService.registerUser(user);
    }

    @GetMapping("/all") // 전체 유저 조회
    public List<UserEntity> getAllUsers() {
        return userService.getAllUsers();
    }

    @DeleteMapping("/delete/{id}") // 유저 삭제
    public void deleteUser(@PathVariable("id") Long id) {
        userService.deleteUser(id);
    }

    @PostMapping("/login")
    public String login(@RequestBody UserEntity user) {
        boolean success = userService.login(user.getName(), user.getPassword());
        return success ? "로그인 성공" : "로그인 실패: 이름 또는 비밀번호가 일치하지 않습니다.";
    }


    /*@PutMapping("/update/{id}") // 유저 수정
    public UserEntity updateUser(@PathVariable("id") Long id, @RequestBody UserEntity user) {
        return userService.updateUser(id, user);
    }*/
}