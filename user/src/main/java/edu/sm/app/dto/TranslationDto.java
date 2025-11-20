package edu.sm.app.dto;

import java.util.List;

public class TranslationDto {

    public static class Request {
        private String targetLang; // 목표 언어 (예: "English", "Japanese")
        private List<String> texts; // 번역할 텍스트 리스트

        // Getters & Setters
        public String getTargetLang() { return targetLang; }
        public void setTargetLang(String targetLang) { this.targetLang = targetLang; }
        public List<String> getTexts() { return texts; }
        public void setTexts(List<String> texts) { this.texts = texts; }
    }

    public static class Response {
        private List<String> translatedTexts;

        public Response(List<String> translatedTexts) {
            this.translatedTexts = translatedTexts;
        }

        public List<String> getTranslatedTexts() { return translatedTexts; }
    }
}