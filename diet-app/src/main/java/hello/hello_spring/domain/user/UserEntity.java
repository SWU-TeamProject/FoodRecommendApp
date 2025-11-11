package hello.hello_spring.domain.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user")
@Getter
@Setter
public class UserEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @Column(nullable = false)
    private String name;

    @Column(nullable = false)
    private String password;

    @Column(nullable = true)
    private Float height; // 키 (cm)

    @Column(nullable = true)
    private Float weight; // 몸무게 (kg)

    @Column(nullable = true)
    private String gender; // 성별 (예: "male", "female")
}