package hello.hello_spring.controller;

import hello.hello_spring.config.OpenAIClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import hello.hello_spring.service.GoogleVisionClient;
import hello.hello_spring.service.FoodDB;
import org.springframework.web.multipart.MultipartFile;
import com.fasterxml.jackson.databind.JsonNode;
import hello.hello_spring.domain.nutrition.NutritionEntity;
import hello.hello_spring.domain.nutrition.NutritionService;
import hello.hello_spring.domain.user.UserEntity;
import hello.hello_spring.domain.nutrition.NutritionRepository;
import hello.hello_spring.domain.user.UserRepository;
import hello.hello_spring.domain.breakfast.BreakfastEntity;
import hello.hello_spring.domain.breakfast.BreakfastRepository;
import hello.hello_spring.domain.lunch.LunchEntity;
import hello.hello_spring.domain.lunch.LunchRepository;
import hello.hello_spring.domain.dinner.DinnerEntity;
import hello.hello_spring.domain.dinner.DinnerRepository;
import hello.hello_spring.domain.nutrition.NutritionEntity;
import hello.hello_spring.domain.nutrition.NutritionService;
import org.springframework.transaction.annotation.Transactional;

import java.io.IOException;
import java.util.Map;
import java.util.List;
import java.io.File;
import java.time.LocalDate;
import java.util.HashMap;

@RestController
@RequestMapping("/api/diet")
public class DietController {

    @Autowired
    private OpenAIClient openAIClient;

    @PostMapping("/{userId}/recommend")
    public String recommendDiet(@PathVariable("userId") Long userId,
                                @RequestParam("date") String date) throws IOException {
        LocalDate targetDate = LocalDate.parse(date);

        // nutrition 테이블에서 userId와 date로 데이터 검색
        List<NutritionEntity> nutritionList = nutritionRepository.findByUserIdAndNutritionDate(userId, targetDate);

        // 각 속성 합산
        float totalCalories = (float) nutritionList.stream().mapToDouble(NutritionEntity::getKcal).sum();
        float totalCarbs = (float) nutritionList.stream().mapToDouble(NutritionEntity::getCarbohydrate).sum();
        float totalProtein = (float) nutritionList.stream().mapToDouble(NutritionEntity::getProtein).sum();
        float totalFat = (float) nutritionList.stream().mapToDouble(NutritionEntity::getFat).sum();

        // OpenAI API에 전달할 프롬프트 생성
        String prompt = String.format(
                "다음은 어떤 사람이 하루 동안 섭취한 영양소입니다:\n" +
                        "- 칼로리: %.1f kcal\n" +
                        "- 탄수화물: %.1f g\n" +
                        "- 단백질: %.1f g\n" +
                        "- 지방: %.1f g\n\n" +
                        "이 사람의 하루 영양 섭취를 간단히 분석한 후, 부족하거나 과잉된 부분을 고려해 다음 식사(예: 점심 또는 저녁)에서 어떻게 보완해야 할지 간단히 설명한 문장을 먼저 작성해주세요.\n" +
                        "\n" +
                        "그 다음, 아래와 같은 형식으로 추천 식단을 최대 3개까지만(1,2개만 제시해도 됩니다.) 제시해주세요. 반드시 아래 포맷을 그대로 따르세요:\n" +
                        "\n" +
                        "★★이 자리에 추천 메뉴(예: 훈제 연어 아보카도 샐러드, 메뉴는 예시와 상관 없이 영양소 기반으로 추천해주세요.)★★\n" +
                        "- **주요 식재료**: (예: 현미밥, 연어, 아보카도 등, 메뉴는 예시와 상관 없이 영양소 기반으로 추천해주세요.)\n" +
                        "- **설명**: (간단한 설명. 예: 이 식단은 단백질과 건강한 지방이 풍부하여 부족한 영양을 보충해줍니다.)\n" +
                        "\n" +
                        "※ 주의: 이모지, 마크다운, 번호, 다른 형식 등을 사용하지 말고 위 포맷을 정확히 따르세요.",
                totalCalories, totalCarbs, totalProtein, totalFat
        );

        // OpenAI API 호출
        String response = openAIClient.getDietRecommendation(prompt);

        ObjectMapper objectMapper = new ObjectMapper();
        JsonNode root = objectMapper.readTree(response);
        String content = root.path("choices").get(0).path("message").path("content").asText();

        return content;
    }

    @PostMapping("/{userId}/analyze")
    public String analyzeFood(@PathVariable("userId") Long userId, @RequestBody Map<String, String> request) throws IOException {
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

    @PostMapping("/{userId}/analyze-image")
    public String analyzeImage(@PathVariable("userId") Long userId, @RequestParam("file") MultipartFile file) throws IOException {
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


    @Autowired
    private NutritionRepository nutritionRepository;

    @Autowired
    private UserRepository userRepository;

    // ==========================
    // 음식 이름으로 영양 분석 + DB 저장
    // ==========================
    @PostMapping("/breakfast-analyze/{userId}")
    public String analyzeFood2(@PathVariable("userId") Long userId, @RequestBody Map<String, String> request) throws IOException {
        String foodItem = request.get("food");

        // AI에게 영양 분석 요청
        String prompt = String.format(
                "Analyze the nutritional values of the following food item: %s. " +
                        "Provide the values only for calories, carbohydrates, protein, and fat in JSON format, " +
                        "like this: {\\\"calories\\\": \\\"350 kcal\\\", \\\"carbohydrates\\\": \\\"40 g\\\", \\\"protein\\\": \\\"30 g\\\", \\\"fat\\\": \\\"10 g\\\"}.",
                foodItem
        );

        String response = openAIClient.getDietRecommendation(prompt);

        // 응답 파싱
        ObjectMapper objectMapper = new ObjectMapper();
        Map<String, Object> responseMap = objectMapper.readValue(response, Map.class);
        Map<String, Object> choice = ((List<Map<String, Object>>) responseMap.get("choices")).get(0);
        Map<String, Object> message = (Map<String, Object>) choice.get("message");
        String content = (String) message.get("content");

        // 불필요한 포맷 제거
        content = content.replace("```json", "").replace("```", "").trim();

        // JSON 문자열을 실제 Map으로 변환
        Map<String, String> nutritionMap = objectMapper.readValue(content, Map.class);

        // 단위 제거 후 float 변환
        float kcal = parseNumber(nutritionMap.get("calories"));
        float carbs = parseNumber(nutritionMap.get("carbohydrates"));
        float protein = parseNumber(nutritionMap.get("protein"));
        float fat = parseNumber(nutritionMap.get("fat"));

        // ======================
        // NutritionEntity 저장
        // ======================
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + userId));

        NutritionEntity nutrition = new NutritionEntity();
        nutrition.setNutritionDate(LocalDate.now());
        nutrition.setKcal(kcal);
        nutrition.setCarbohydrate(carbs);
        nutrition.setProtein(protein);
        nutrition.setFat(fat);
        nutrition.setUser(user);

        nutritionRepository.save(nutrition);

        // ======================
        // 결과 반환
        // ======================
        return String.format(
                "영양 정보가 저장되었습니다. (칼로리: %.1f kcal, 탄수화물: %.1f g, 단백질: %.1f g, 지방: %.1f g)",
                kcal, carbs, protein, fat
        );
    }

    // 단위(예: "350 kcal")에서 숫자만 추출하는 유틸 메서드
    private float parseNumber(String str) {
        if (str == null) return 0f;
        return Float.parseFloat(str.replaceAll("[^0-9.]", ""));
    }

    @Autowired
    private BreakfastRepository breakfastRepository;

    @Autowired
    private LunchRepository lunchRepository;

    @Autowired
    private DinnerRepository dinnerRepository;

    /**
     * 이미지 분석 후 예측된 음식을 breakfast 테이블에 저장
     */
    @PostMapping("/breakfast-analyze-image/{userId}")
    public String analyzeImage2(
            @PathVariable("userId") Long userId,
            @RequestParam("file") MultipartFile file
    ) throws IOException {

        // ✅ 임시 파일로 저장
        File tempFile = File.createTempFile("upload-", file.getOriginalFilename());
        file.transferTo(tempFile);

        // ✅ Vision API로 이미지 분석
        List<String> labels = googleVisionClient.analyzeImage(tempFile.getAbsolutePath());
        tempFile.delete();

        // ✅ FoodDB와 매칭
        String bestMatch = FoodDB.guessFood(labels);

        // ✅ 매칭 실패 시
        if (bestMatch == null) {
            return "❌ 음식을 추정할 수 없습니다. 저장되지 않았습니다.";
        }

        // ✅ userId로 사용자 조회
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("해당 ID의 사용자를 찾을 수 없습니다."));

        // ✅ BreakfastEntity 생성 및 저장
        BreakfastEntity breakfast = new BreakfastEntity();
        breakfast.setUser(user);
        breakfast.setFoodName(bestMatch);
        breakfast.setMealDate(LocalDate.now()); // ✅ 필드 이름 수정

        breakfastRepository.save(breakfast);

        return "✅ 예측 음식 '" + bestMatch + "'이(가) breakfast 테이블에 저장되었습니다.";
    }

    @Autowired
    private NutritionService nutritionService;

    @GetMapping("/{userId}/summary")
    public Map<String, Object> getSummaryByUserIdAndDate(
            @PathVariable("userId") Long userId,
            @RequestParam("date") String date
    ) {
        LocalDate nutritionDate = LocalDate.parse(date);

        // 조건에 맞는 NutritionEntity 리스트 가져오기
        List<NutritionEntity> nutritionList = nutritionService.getNutritionByUserIdAndDate(userId, nutritionDate);

        // 각 속성 합산
        float totalCalories = (float) nutritionList.stream().mapToDouble(NutritionEntity::getKcal).sum();
        float totalCarbs = (float) nutritionList.stream().mapToDouble(NutritionEntity::getCarbohydrate).sum();
        float totalProtein = (float) nutritionList.stream().mapToDouble(NutritionEntity::getProtein).sum();
        float totalFat = (float) nutritionList.stream().mapToDouble(NutritionEntity::getFat).sum();

        // 결과를 Map으로 반환
        Map<String, Object> result = new HashMap<>();
        result.put("totalCalories", totalCalories);
        result.put("totalCarbs", totalCarbs);
        result.put("totalProtein", totalProtein);
        result.put("totalFat", totalFat);

        return result;
    }

    @PostMapping("/{userId}/eatfood")
    public String saveFoodAndNutrition(
            @PathVariable("userId") Long userId,
            @RequestParam("date") String date,
            @RequestParam("time") String time,
            @RequestBody Map<String, String> request) {

        // 요청 데이터 추출
        String foodName = request.get("food_name");
        String kcalStr = request.get("kcal");
        String carbsStr = request.get("carbohydrate");
        String proteinStr = request.get("protein");
        String fatStr = request.get("fat");

        // null 체크 및 기본값 설정
        if (foodName == null || foodName.trim().isEmpty()) {
            throw new IllegalArgumentException("food_name 값이 비어 있습니다.");
        }
        float kcal = (kcalStr != null && !kcalStr.trim().isEmpty()) ? Float.parseFloat(kcalStr) : 0f;
        float carbs = (carbsStr != null && !carbsStr.trim().isEmpty()) ? Float.parseFloat(carbsStr) : 0f;
        float protein = (proteinStr != null && !proteinStr.trim().isEmpty()) ? Float.parseFloat(proteinStr) : 0f;
        float fat = (fatStr != null && !fatStr.trim().isEmpty()) ? Float.parseFloat(fatStr) : 0f;

        // 사용자 조회
        UserEntity user = userRepository.findById(userId)
                .orElseThrow(() -> new IllegalArgumentException("Invalid user ID: " + userId));

        // 날짜 파싱
        LocalDate nutritionDate = LocalDate.parse(date);

        // ======================
        // NutritionEntity 저장
        // ======================
        NutritionEntity nutrition = new NutritionEntity();
        nutrition.setNutritionDate(nutritionDate);
        nutrition.setKcal(kcal);
        nutrition.setCarbohydrate(carbs);
        nutrition.setProtein(protein);
        nutrition.setFat(fat);
        nutrition.setUser(user);

        nutritionRepository.save(nutrition);

        // ======================
        // time 값에 따라 테이블 저장
        // ======================
        if ("breakfast".equalsIgnoreCase(time)) {
            BreakfastEntity breakfast = new BreakfastEntity();
            breakfast.setUser(user);
            breakfast.setFoodName(foodName);
            breakfast.setMealDate(nutritionDate);
            breakfastRepository.save(breakfast);
        } else if ("lunch".equalsIgnoreCase(time)) {
            LunchEntity lunch = new LunchEntity();
            lunch.setUser(user);
            lunch.setFoodName(foodName);
            lunch.setMealDate(nutritionDate);
            lunchRepository.save(lunch);
        } else if ("dinner".equalsIgnoreCase(time)) {
            DinnerEntity dinner = new DinnerEntity();
            dinner.setUser(user);
            dinner.setFoodName(foodName);
            dinner.setMealDate(nutritionDate);
            dinnerRepository.save(dinner);
        } else {
            throw new IllegalArgumentException("Invalid time value: " + time);
        }

        return "음식과 영양 정보가 저장되었습니다.";
    }

    @DeleteMapping("/{userId}/delfood")
    @Transactional
    public String deleteFoodByTimeAndDate(
            @PathVariable("userId") Long userId,
            @RequestParam("date") String date,
            @RequestParam("time") String time
    ) {
        LocalDate targetDate = LocalDate.parse(date);

        switch (time.toLowerCase()) {
            case "breakfast":
                breakfastRepository.deleteByUserIdAndMealDate(userId, targetDate);
                break;

            case "lunch":
                lunchRepository.deleteByUserIdAndMealDate(userId, targetDate);
                break;

            case "dinner":
                dinnerRepository.deleteByUserIdAndMealDate(userId, targetDate);
                break;

            default:
                throw new IllegalArgumentException("Invalid time parameter: " + time);
        }

        return "해당 날짜의 " + time + " 데이터가 삭제되었습니다.";
    }
}

