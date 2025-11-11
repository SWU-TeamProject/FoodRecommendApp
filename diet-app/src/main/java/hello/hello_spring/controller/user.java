package hello.hello_spring.controller;

import hello.hello_spring.domain.breakfast.BreakfastEntity;
import hello.hello_spring.domain.dinner.DinnerEntity;
import hello.hello_spring.domain.lunch.LunchEntity;
import hello.hello_spring.domain.user.UserEntity;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.http.HttpStatus;
import org.springframework.web.server.ResponseStatusException;
import java.time.LocalDate;
import java.util.List;
import java.util.stream.Collectors;

import hello.hello_spring.domain.user.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import hello.hello_spring.domain.breakfast.BreakfastRepository;
import hello.hello_spring.domain.lunch.LunchRepository;
import hello.hello_spring.domain.dinner.DinnerRepository;
import java.util.Map;
import java.util.HashMap;

@RestController
@RequestMapping("/api/user")
public class user {

    @Autowired
    private UserService userService;

    @Autowired
    private BreakfastRepository breakfastRepository;

    @Autowired
    private LunchRepository lunchRepository;

    @Autowired
    private DinnerRepository dinnerRepository;

    @PostMapping("/register") // 유저 생성
    public UserEntity registerUser(@RequestBody UserEntity user) {
        // 같은 name 속성이 있는지 확인
        if (userService.existsByName(user.getName())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "이미 존재하는 이름입니다: " + user.getName());
        }
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
    public Map<String, Object> login(@RequestBody UserEntity user) {
        boolean success = userService.login(user.getName(), user.getPassword());
        if (success) {
            Long userId = userService.findByName(user.getName())
                    .orElseThrow(() -> new ResponseStatusException(HttpStatus.NOT_FOUND, "사용자를 찾을 수 없습니다."))
                    .getId();

            // 성공 메시지와 ID를 포함한 응답 생성
            Map<String, Object> response = new HashMap<>();
            response.put("message", "로그인 성공");
            response.put("id", userId);

            return response;
        } else {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "로그인 실패: 이름 또는 비밀번호가 일치하지 않습니다.");
        }
    }

    @GetMapping("/{userId}/detail")
    public List<String> getFoodByTimeAndDate(
            @PathVariable("userId") Long userId,
            @RequestParam("date") String date,
            @RequestParam("time") String time) {
        LocalDate targetDate = LocalDate.parse(date);

        switch (time.toLowerCase()) {
            case "breakfast":
                return breakfastRepository.findByUserIdAndMealDate(userId, targetDate)
                        .stream()
                        .map(BreakfastEntity::getFoodName)
                        .collect(Collectors.toList());

            case "lunch":
                return lunchRepository.findByUserIdAndMealDate(userId, targetDate)
                        .stream()
                        .map(LunchEntity::getFoodName)
                        .collect(Collectors.toList());

            case "dinner":
                return dinnerRepository.findByUserIdAndMealDate(userId, targetDate)
                        .stream()
                        .map(DinnerEntity::getFoodName)
                        .collect(Collectors.toList());

            default:
                throw new IllegalArgumentException("Invalid time parameter: " + time);
        }
    }

    /*
     * @PutMapping("/update/{id}") // 유저 수정
     * public UserEntity updateUser(@PathVariable("id") Long id, @RequestBody
     * UserEntity user) {
     * return userService.updateUser(id, user);
     * }
     */
}