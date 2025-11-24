package edu.sm.service;

import edu.sm.entity.MedicalDocument;
import edu.sm.repository.MedicalDocumentRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class MedicalDocumentService {

    @Autowired
    private MedicalDocumentRepository repository;

    public List<MedicalDocument> getAllDocuments() {
        return repository.findAll();
    }

    public List<MedicalDocument> searchByTitle(String keyword) {
        return repository.findByDocTitleContaining(keyword);
    }

    public MedicalDocument getDocumentById(Long id) {
        return repository.findById(id).orElse(null);
    }
}