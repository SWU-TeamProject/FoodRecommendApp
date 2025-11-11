package hello.hello_spring.service;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.HashMap;
import java.util.Map;
import java.util.List;

@Service
public class GoogleVisionClient {

    @Value("${google.vision.api-key}")
    private String apiKey;

    public List<String> analyzeImage(String imagePath) throws IOException {
        String url = "https://vision.googleapis.com/v1/images:annotate?key=" + apiKey;

        byte[] imageBytes = Files.readAllBytes(Path.of(imagePath));
        String base64Image = java.util.Base64.getEncoder().encodeToString(imageBytes);

        Map<String, Object> image = new HashMap<>();
        image.put("content", base64Image);

        Map<String, Object> feature = new HashMap<>();
        feature.put("type", "LABEL_DETECTION");

        Map<String, Object> request = new HashMap<>();
        request.put("image", image);
        request.put("features", new Map[]{feature});

        Map<String, Object> requestBody = new HashMap<>();
        requestBody.put("requests", new Map[]{request});

        HttpHeaders headers = new HttpHeaders();
        headers.set("Content-Type", "application/json");

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(requestBody, headers);

        RestTemplate restTemplate = new RestTemplate();
        ResponseEntity<String> response = restTemplate.postForEntity(url, entity, String.class);

        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Object> responseMap = objectMapper.readValue(response.getBody(), Map.class);

        // "responses"를 List<Map<String, Object>>로 캐스팅
        List<Map<String, Object>> responses = (List<Map<String, Object>>) responseMap.get("responses");

        // 첫 번째 응답에서 "labelAnnotations" 추출
        List<Map<String, Object>> labelAnnotations = (List<Map<String, Object>>) responses.get(0).get("labelAnnotations");

        return labelAnnotations.stream()
                .map(annotation -> (String) annotation.get("description"))
                .toList();
    }
}