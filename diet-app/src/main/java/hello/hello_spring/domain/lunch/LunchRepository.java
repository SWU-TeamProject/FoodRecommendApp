package hello.hello_spring.domain.lunch;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface LunchRepository extends JpaRepository<LunchEntity, Long> {
    List<LunchEntity> findByUserIdAndMealDate(Long userId, LocalDate mealDate);
    void deleteByUserIdAndMealDate(Long userId, LocalDate mealDate);
}