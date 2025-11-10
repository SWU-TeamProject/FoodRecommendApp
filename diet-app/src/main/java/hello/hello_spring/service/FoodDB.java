package hello.hello_spring.service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class FoodDB {

    private static final Map<String, List<String>> foodDb = new HashMap<>();

    static {
        // 찌개, 국
        foodDb.put("김치찌개", List.of("Kimchi-jjigae", "Jjigae", "Stew", "Soup", "Kimchi stew"));
        foodDb.put("된장찌개", List.of("Doenjang-jjigae", "Soybean paste stew", "Jjigae", "Stew"));
        foodDb.put("부대찌개", List.of("Budae-jjigae", "Army stew", "Spicy stew", "Sausage stew"));
        foodDb.put("순두부찌개", List.of("Sundubu-jjigae", "Soft tofu stew", "Tofu soup", "Spicy stew"));
        foodDb.put("갈비탕", List.of("Galbitang", "Beef short rib soup", "Soup", "Korean soup"));
        foodDb.put("육개장", List.of("Yukgaejang", "Spicy beef soup", "Soup", "Korean soup"));
        foodDb.put("설렁탕", List.of("Seolleongtang", "Ox bone soup", "Milky soup", "Beef broth"));
        foodDb.put("미역국", List.of("Miyeok-guk", "Seaweed soup", "Soup", "Korean soup"));
        // 밥류
        foodDb.put("비빔밥", List.of("Bibimbap", "Mixed rice", "Korean rice bowl", "Rice with vegetables"));
        foodDb.put("김밥", List.of("Gimbap", "Kimbap", "Seaweed rice roll", "Korean sushi"));
        foodDb.put("볶음밥", List.of("Fried rice", "Bokkeumbap", "Korean fried rice"));
        foodDb.put("오므라이스", List.of("Omurice", "Omelet rice", "Fried rice with egg"));
        // 고기
        foodDb.put("양념치킨", List.of("Yangnyeom chicken", "Korean fried chicken", "Spicy chicken"));
        foodDb.put("후라이드치킨", List.of("Fried chicken", "Korean fried chicken", "Crispy chicken"));
        foodDb.put("닭강정", List.of("Dakgangjeong", "Sweet crispy chicken", "Korean popcorn chicken"));
        // 면류
        foodDb.put("라면", List.of("Ramen", "Instant noodles", "Spicy noodles", "Korean ramen"));
        foodDb.put("잔치국수", List.of("Janchi-guksu", "Korean noodle soup", "Thin noodles", "Soup"));
        foodDb.put("비빔국수", List.of("Bibim guksu", "Spicy cold noodles", "Mixed noodles"));
        foodDb.put("우동", List.of("Udon", "Thick noodles", "Japanese noodles"));
        // 기타
        foodDb.put("만두", List.of("Mandu", "Dumplings", "Korean dumplings", "Steamed dumplings"));
        foodDb.put("떡볶이", List.of("Tteokbokki", "Spicy rice cakes", "Rice cake dish", "Street food"));
        foodDb.put("순대", List.of("Sundae", "Korean blood sausage", "Korean sausage"));
        foodDb.put("잡채", List.of("Japchae", "Glass noodles", "Stir-fried noodles", "Sweet potato noodles"));
        foodDb.put("파전", List.of("Pajeon", "Korean pancake", "Green onion pancake", "Savory pancake"));
        foodDb.put("김치전", List.of("Kimchi jeon", "Kimchi pancake", "Savory pancake"));
    }

    public static String guessFood(List<String> labels) {
        String bestMatch = null;
        int maxScore = 0;

        for (Map.Entry<String, List<String>> entry : foodDb.entrySet()) {
            String food = entry.getKey();
            List<String> keywords = entry.getValue();

            int score = (int) labels.stream().filter(keywords::contains).count();
            if (score > maxScore) {
                maxScore = score;
                bestMatch = food;
            }
        }

        return bestMatch;
    }
}