package hello.hello_spring.domain.lunch;

import org.springframework.data.jpa.repository.JpaRepository;

public interface LunchRepository extends JpaRepository<LunchEntity, Long> {
    // Additional query methods can be defined here if needed
}