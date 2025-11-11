package hello.hello_spring.domain.breakfast;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BreakfastRepository extends JpaRepository<BreakfastEntity, Long> {
    // Additional query methods can be defined here if needed
}