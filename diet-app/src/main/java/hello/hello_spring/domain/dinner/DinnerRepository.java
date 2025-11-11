package hello.hello_spring.domain.dinner;

import org.springframework.data.jpa.repository.JpaRepository;

import java.time.LocalDate;
import java.util.List;

public interface DinnerRepository extends JpaRepository<DinnerEntity, Long> {
    List<DinnerEntity> findByUserIdAndMealDate(Long userId, LocalDate mealDate);
    void deleteByUserIdAndMealDate(Long userId, LocalDate mealDate);
}