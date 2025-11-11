package hello.hello_spring.domain.breakfast;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface BreakfastRepository extends JpaRepository<BreakfastEntity, Long> {
    List<BreakfastEntity> findByUserIdAndMealDate(Long userId, LocalDate mealDate);
    void deleteByUserIdAndMealDate(Long userId, LocalDate mealDate);
}