package hello.hello_spring.domain.nutrition;

import jakarta.persistence.*;
import hello.hello_spring.domain.user.UserEntity;
import java.time.LocalDate;

@Entity
@Table(name = "nutrition")
public class NutritionEntity {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private LocalDate nutritionDate;
    private float kcal;
    private float carbohydrate;
    private float protein;
    private float fat;

    @ManyToOne
    @JoinColumn(name = "user_id", nullable = false)
    private UserEntity user;

    // Getters and Setters
    public Long getId() {
        return id;
    }

    public void setId(Long id) {
        this.id = id;
    }

    public LocalDate getNutritionDate() {
        return nutritionDate;
    }

    public void setNutritionDate(LocalDate nutritionDate) {
        this.nutritionDate = nutritionDate;
    }

    public float getKcal() {
        return kcal;
    }

    public void setKcal(float kcal) {
        this.kcal = kcal;
    }

    public float getCarbohydrate() {
        return carbohydrate;
    }

    public void setCarbohydrate(float carbohydrate) {
        this.carbohydrate = carbohydrate;
    }

    public float getProtein() {
        return protein;
    }

    public void setProtein(float protein) {
        this.protein = protein;
    }

    public float getFat() {
        return fat;
    }

    public void setFat(float fat) {
        this.fat = fat;
    }

    public UserEntity getUser() {
        return user;
    }

    public void setUser(UserEntity user) {
        this.user = user;
    }
}