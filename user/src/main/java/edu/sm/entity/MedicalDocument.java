package edu.sm.entity;

import jakarta.persistence.*;
import lombok.Data;
import java.time.LocalDateTime;

@Entity
@Table(name = "medical_documents")
@Data
public class MedicalDocument {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "doc_id")
    private Long docId;

    @Column(name = "file_name", nullable = false, length = 200)
    private String fileName;

    @Column(name = "doc_title", nullable = false, length = 300)
    private String docTitle;

    @Column(name = "file_path", nullable = false, length = 500)
    private String filePath;

    @Column(name = "file_size", length = 20)
    private String fileSize;

    @Column(name = "created_at")
    private LocalDateTime createdAt;
}