package hello.hello_spring.controller;

import hello.hello_spring.config.OpenAIClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import hello.hello_spring.service.GoogleVisionClient;
import hello.hello_spring.service.FoodDB;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.databind.JsonNode;

import java.io.IOException;
import java.util.Map;
import java.util.List;
import java.io.File;

@RestController
@RequestMapping("/api/diet")
public class DietController {

    @Autowired
    private OpenAIClient openAIClient;

    @PostMapping("/recommend")
    public String recommendDiet(@RequestBody Map<String, Object> nutrition) throws IOException {
        int calories = (int) nutrition.get("calories");
        int carbs = (int) nutrition.get("carbohydrates");
        int protein = (int) nutrition.get("protein");
        int fat = (int) nutrition.get("fat");

        String prompt = String.format(
                "다음은 어떤 사람이 하루 동안 섭취한 영양소입니다:\n" +
                        "- 칼로리: %d kcal\n" +
                        "- 탄수화물: %d g\n" +
                        "- 단백질: %d g\n" +
                        "- 지방: %d g\n\n" +
                        "이 사람의 하루 영양 섭취를 간단히 분석한 후, 부족하거나 과잉된 부분을 고려해 다음 식사(예: 점심 또는 저녁)에서 어떻게 보완해야 할지 간단히 설명한 문장을 먼저 작성해주세요.\n" +
                        "\n" +
                        "그 다음, 아래와 같은 형식으로 추천 식단을 최대 3개까지만(1,2개만 제시해도 됩니다.) 제시해주세요. 반드시 아래 포맷을 그대로 따르세요:\n" +
                        "\n" +
                        "★★이 자리에 추천 메뉴(예: 훈제 연어 아보카도 샐러드, 메뉴는 예시와 상관 없이 영양소 기반으로 추천해주세요.)★★\n" +
                        "- **주요 식재료**: (예: 현미밥, 연어, 아보카도 등, 메뉴는 예시와 상관 없이 영양소 기반으로 추천해주세요.)\n" +
                        "- **설명**: (간단한 설명. 예: 이 식단은 단백질과 건강한 지방이 풍부하여 부족한 영양을 보충해줍니다.)\n" +
                        "\n" +
                        "※ 주의: 이모지, 마크다운, 번호, 다른 형식 등을 사용하지 말고 위 포맷을 정확히 따르세요.",
                calories, carbs, protein, fat
        );

        String response = openAIClient.getDietRecommendation(prompt);

        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode root = objectMapper.readTree(response);
        String content = root.path("choices").get(0).path("message").path("content").asText();


        return content;
    }

    @PostMapping("/analyze")
    public String analyzeFood(@RequestBody Map<String, String> request) throws IOException {
        String foodItem = request.get("food");

        // JSON 예제를 이스케이프 처리
        String prompt = String.format(
                "Analyze the nutritional values of the following food item: %s. " +
                        "Provide the values only for calories, carbohydrates, protein, and fat in JSON format, " +
                        "like this: {\\\"calories\\\": \\\"350 kcal\\\", \\\"carbohydrates\\\": \\\"40 g\\\", \\\"protein\\\": \\\"30 g\\\", \\\"fat\\\": \\\"10 g\\\"}.",
                foodItem
        );

        // OpenAI API 호출
        String response = openAIClient.getDietRecommendation(prompt);

        // JSON 응답 파싱
        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Object> responseMap = objectMapper.readValue(response, Map.class);

        // content 필드 추출 및 정리
        Map<String, Object> choice = ((List<Map<String, Object>>) responseMap.get("choices")).get(0);
        Map<String, Object> message = (Map<String, Object>) choice.get("message");
        String content = (String) message.get("content");

        // 백틱과 줄바꿈 문자 제거
        content = content.replace("```json", "").replace("```", "").replace("\n", "").trim();

        return content;
    }

    @Autowired
    private GoogleVisionClient googleVisionClient;

    @PostMapping("/analyze-image")
    public String analyzeImage(@RequestParam("file") MultipartFile file) throws IOException {
        // 업로드된 파일을 임시 디렉토리에 저장
        File tempFile = File.createTempFile("upload-", file.getOriginalFilename());
        file.transferTo(tempFile);

        // Vision API 호출
        List<String> labels = googleVisionClient.analyzeImage(tempFile.getAbsolutePath());
        tempFile.delete();

        // FoodDB와 매칭
        String bestMatch = FoodDB.guessFood(labels);

        return bestMatch != null ? "예측 음식: " + bestMatch : "음식을 추정할 수 없습니다.";
    }
}

