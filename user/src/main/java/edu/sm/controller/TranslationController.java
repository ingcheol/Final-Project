package edu.sm.controller;

import edu.sm.app.dto.TranslationDto;
import edu.sm.app.service.AiTranslationService;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/translate")
public class TranslationController {

    private final AiTranslationService translationService;

    public TranslationController(AiTranslationService translationService) {
        this.translationService = translationService;
    }

    @PostMapping
    public TranslationDto.Response translate(@RequestBody TranslationDto.Request request) {
        // 서비스 호출
        List<String> result = translationService.translateBatch(request.getTexts(), request.getTargetLang());
        return new TranslationDto.Response(result);
    }
}