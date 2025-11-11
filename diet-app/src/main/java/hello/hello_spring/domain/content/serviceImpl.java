package hello.hello_spring.domain.content;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service("contentServiceImpl")
public class serviceImpl implements service {

    @Autowired
    private repository contentRepository;

    @Override
    public entity createPost(entity post) {
        return contentRepository.save(post);
    }
}