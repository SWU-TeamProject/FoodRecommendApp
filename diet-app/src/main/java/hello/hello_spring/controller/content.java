package hello.hello_spring.controller;

import hello.hello_spring.domain.content.entity;
import hello.hello_spring.domain.content.service;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/content")
public class content {
    @Autowired
    private service postService;

    @PostMapping("/post")
    public entity createPost(@RequestBody entity post) {
        return postService.createPost(post);
    }
}