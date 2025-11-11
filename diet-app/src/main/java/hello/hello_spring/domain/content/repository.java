package hello.hello_spring.domain.content;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository("contentRepository")
public interface repository extends JpaRepository<entity, Long> {
}