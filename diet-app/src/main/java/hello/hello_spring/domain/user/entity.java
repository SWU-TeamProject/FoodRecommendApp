package hello.hello_spring.domain.user;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity(name = "userEntity")
@Table(name = "user")
@Getter
@Setter
public class entity {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private String name;
    private String password;
}
