package edu.sm.config;

import edu.sm.service.PdfRagService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.CommandLineRunner;
import org.springframework.stereotype.Component;

@Component
public class PdfIndexingRunner implements CommandLineRunner {

    @Autowired
    private PdfRagService pdfRagService;

    @Override
    public void run(String... args) throws Exception {
        System.out.println("\n");
        System.out.println("==============================================");
        System.out.println("  PDF 문서 인덱싱 시작");
        System.out.println("==============================================");

        try {
            pdfRagService.indexAllPdfDocuments();

            System.out.println("==============================================");
            System.out.println("  ✅ PDF 인덱싱 완료!");
            System.out.println("==============================================");
            System.out.println("\n");

        } catch (Exception e) {
            System.err.println("==============================================");
            System.err.println("  ❌ PDF 인덱싱 실패: " + e.getMessage());
            System.err.println("==============================================");
            e.printStackTrace();
        }
    }
}