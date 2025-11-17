INSERT INTO patient (password, name, phone, email, dob, gender, address, medical_history, lifestyle_habits, account_status, language_preference, created_at) VALUES
    ('$2a$10$wr5kzCQSzfVibe/oHUrFVuUTOAtooXUDNTNNxjlApxk31srPO/ELW', '김민호', '010-1234-5678', 'minho.kim@email.com', '1985-03-15', 'male', '서울시 강남구 테헤란로 123', '고혈압, 당뇨', '규칙적인 운동, 비흡연', 'active', 'ko', NOW());

INSERT INTO emr (patient_statement, test_results, prescription_details, ai_generated_draft, final_record, created_at, updated_at, consultation_id) VALUES
    ('혈당이 높고 피로감을 느낌', '혈당: 180 mg/dL', 'Metformin 500mg 하루 2회', '환자는 2형 당뇨병으로 판단됨. 약물 치료와 생활습관 개선 필요.', '2형 당뇨병 진단. Metformin 처방 및 식이요법 권장.', NOW(), NOW(), 1);

INSERT INTO IOT (device_type, vital_type, value, is_abnormal, measured_at, patient_id) VALUES
                                                                                           ('혈압계', 'Blood Pressure', 140.00, false, NOW(), 1),
                                                                                           ('혈당계', 'Blood Glucose', 180.00, true, NOW(), 1);

INSERT INTO survey (survey_type, questions, answers, created_at, submitted_at, patient_id) VALUES
    ('생활습관 평가', '{"q1": "규칙적으로 운동하시나요?", "q2": "흡연하시나요?", "q3": "수면 시간은?"}', '{"a1": "주 3회", "a2": "아니오", "a3": "7시간"}', NOW(), NOW(), 1);