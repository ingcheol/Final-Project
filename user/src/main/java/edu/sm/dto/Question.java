package edu.sm.dto;

import java.util.List;

public class Question {
    private int id;
    private String question;
    private String type;
    private List<String> options;

    public Question() {}

    public Question(int id, String question, String type, List<String> options) {
        this.id = id;
        this.question = question;
        this.type = type;
        this.options = options;
    }

    // Getter & Setter
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public List<String> getOptions() {
        return options;
    }

    public void setOptions(List<String> options) {
        this.options = options;
    }
}