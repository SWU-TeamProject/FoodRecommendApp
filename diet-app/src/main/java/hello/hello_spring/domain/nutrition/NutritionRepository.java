package hello.hello_spring.domain.nutrition;

import org.springframework.data.jpa.repository.JpaRepository;
import java.time.LocalDate;
import java.util.List;

public interface NutritionRepository extends JpaRepository<NutritionEntity, Long> {
    List<NutritionEntity> findByUserIdAndNutritionDate(Long userId, LocalDate nutritionDate);
}