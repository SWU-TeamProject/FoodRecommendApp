package hello.hello_spring.config;

import okhttp3.*;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import java.io.IOException;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.util.*;
import java.util.concurrent.TimeUnit;

@Component
public class OpenAIClient {
    private static final String API_URL = "https://api.openai.com/v1/chat/completions";

    @Value("${openai.api-key}")
    private String apiKey;

    public String getDietRecommendation(String prompt) throws IOException {
        OkHttpClient client = new OkHttpClient.Builder()
                .connectTimeout(30, TimeUnit.SECONDS)
                .writeTimeout(30, TimeUnit.SECONDS)
                .readTimeout(60, TimeUnit.SECONDS)
                .build();

        Map<String, Object> json = new HashMap<>();
        json.put("model", "gpt-4o");

        List<Map<String, String>> messages = new ArrayList<>();
        Map<String, String> userMessage = new HashMap<>();
        userMessage.put("role", "user");
        userMessage.put("content", prompt);
        messages.add(userMessage);

        json.put("messages", messages);
        json.put("max_tokens", 500);

        ObjectMapper mapper = new ObjectMapper();
        String requestBody = mapper.writeValueAsString(json);

        MediaType mediaType = MediaType.get("application/json; charset=utf-8");
        Request request = new Request.Builder()
                .url(API_URL)
                .post(RequestBody.create(requestBody, mediaType))
                .addHeader("Authorization", "Bearer " + apiKey)
                .build();

        System.out.println("Request Body: " + requestBody);

        try (Response response = client.newCall(request).execute()) {
            System.out.println("Response Code: " + response.code());
            String responseBody = response.body().string();
            System.out.println("Response Body: " + responseBody);

            if (!response.isSuccessful()) {
                throw new IOException("Unexpected code " + response + "\nBody: " + responseBody);
            }

            // Validate if the response is JSON
            if (!responseBody.trim().startsWith("{")) {
                throw new IOException("Invalid JSON response: " + responseBody);
            }

            return responseBody;
        }
    }
}