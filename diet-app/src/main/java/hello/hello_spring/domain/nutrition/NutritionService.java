package hello.hello_spring.domain.nutrition;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.time.LocalDate;
import java.util.List;

@Service
public class NutritionService {

    @Autowired
    private NutritionRepository nutritionRepository;

    public List<NutritionEntity> getNutritionByUserIdAndDate(Long userId, LocalDate date) {
        return nutritionRepository.findByUserIdAndNutritionDate(userId, date);
    }
}