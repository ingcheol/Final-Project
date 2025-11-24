package edu.sm.repository;

import edu.sm.entity.MedicalDocument;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface MedicalDocumentRepository extends JpaRepository<MedicalDocument, Long> {
    List<MedicalDocument> findByFileNameContaining(String keyword);
    List<MedicalDocument> findByDocTitleContaining(String keyword);
}