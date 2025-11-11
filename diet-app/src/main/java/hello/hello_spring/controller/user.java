package hello.hello_spring.controller;

import hello.hello_spring.domain.user.entity;
import hello.hello_spring.domain.user.service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/user")
public class user {

    @Autowired
    private service userService;

    @PostMapping("/register") // 유저 생성
    public entity registerUser(@RequestBody entity user) {
        return userService.registerUser(user);
    }

    @GetMapping("/all") // 전체 유저 조회
    public List<entity> getAllUsers() {
        return userService.getAllUsers();
    }

    @DeleteMapping("/delete/{id}") // 유저 삭제
    public void deleteUser(@PathVariable("id") Long id) {
        userService.deleteUser(id);
    }

    @PutMapping("/update/{id}") // 유저 수정
    public entity updateUser(@PathVariable("id") Long id, @RequestBody entity user) {
        return userService.updateUser(id, user);
    }
}