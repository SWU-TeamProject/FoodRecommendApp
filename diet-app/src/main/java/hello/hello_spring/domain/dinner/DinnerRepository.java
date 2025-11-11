package hello.hello_spring.domain.dinner;

import org.springframework.data.jpa.repository.JpaRepository;

public interface DinnerRepository extends JpaRepository<DinnerEntity, Long> {
    // Additional query methods can be defined here if needed
}