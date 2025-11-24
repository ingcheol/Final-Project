package edu.sm.app.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class NewsDto {
    private String title;       // 기사 제목
    private String originLink;  // 기사 원문 링크
    private String description; // AI가 요약한 내용
    private String pubDate;     // 발행일
}