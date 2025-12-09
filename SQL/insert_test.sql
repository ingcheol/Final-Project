INSERT INTO patient (password, name, phone, email, dob, gender, address, medical_history, lifestyle_habits, account_status, language_preference, created_at) VALUES
    ('$2a$10$wr5kzCQSzfVibe/oHUrFVuUTOAtooXUDNTNNxjlApxk31srPO/ELW', '김민호', '010-1234-5678', 'minho.kim@email.com', '1985-03-15', 'male', '서울시 강남구 테헤란로 123', '고혈압, 당뇨', '규칙적인 운동, 비흡연', 'active', 'ko', NOW());

INSERT INTO emr (patient_statement, test_results, prescription_details, ai_generated_draft, final_record, created_at, updated_at, consultation_id) VALUES
    ('혈당이 높고 피로감을 느낌', '혈당: 180 mg/dL', 'Metformin 500mg 하루 2회', '환자는 2형 당뇨병으로 판단됨. 약물 치료와 생활습관 개선 필요.', '2형 당뇨병 진단. Metformin 처방 및 식이요법 권장.', NOW(), NOW(), 1);

INSERT INTO IOT (device_type, vital_type, value, is_abnormal, measured_at, patient_id) VALUES
                                                                                           ('혈압계', 'Blood Pressure', 140.00, false, NOW(), 1),
                                                                                           ('혈당계', 'Blood Glucose', 180.00, true, NOW(), 1);

INSERT INTO survey (survey_type, questions, answers, created_at, submitted_at, patient_id) VALUES
    ('생활습관 평가', '{"q1": "규칙적으로 운동하시나요?", "q2": "흡연하시나요?", "q3": "수면 시간은?"}', '{"a1": "주 3회", "a2": "아니오", "a3": "7시간"}', NOW(), NOW(), 1);

INSERT INTO admin (
    password,
    name,
    phone,
    email,
    account_status,
    created_at,
    patient_id  -- 7번째 컬럼
)
VALUES (
           '$2a$10$wr5kzCQSzfVibe/oHUrFVuUTOAtooXUDNTNNxjlApxk31srPO/ELW',
           'admin01',
           '010-1234-5678',
           'admin01@sm.edu',
           'ACTIVE',
           NOW(),
           1 -- patient_id에 명시적으로 1을 지정
       );

INSERT INTO adviser (
    password,
    name,
    phone,
    email,
    license_number,
    account_status,
    created_at
) VALUES (
             '$2a$10$wr5kzCQSzfVibe/oHUrFVuUTOAtooXUDNTNNxjlApxk31srPO/ELW',
             'adviser01',
             '010-9876-5432', -- 임의의 연락처
             'adviser01@sm.edu',
             'A12345B6789', -- 필수 입력 (NOT NULL)
             'ACTIVE',
             NOW()
         );


-- ==========================================
-- 5. 초기 데이터: 의료 PDF 10종 등록
-- ==========================================
INSERT INTO medical_documents (file_name, doc_title, file_path, file_size, created_at) VALUES
                                                                                           ('계절인플루엔자의항바이러스제사용지침.pdf', '계절 인플루엔자의 항바이러스제 사용지침', 'src/main/resources/medical-data/계절인플루엔자의항바이러스제사용지침.pdf', '984KB', NOW()),
                                                                                           ('대한감염학회권장성인예방접종개정안.pdf', '대한감염학회 권장 성인예방접종 개정안', 'src/main/resources/medical-data/대한감염학회권장성인예방접종개정안.pdf', '664KB', NOW()),
                                                                                           ('만성코로나19증후군.pdf', '만성 코로나19 증후군', 'src/main/resources/medical-data/만성코로나19증후군.pdf', '3,538KB', NOW()),
                                                                                           ('성인급성상기도감염 항생제사용지침권고안.pdf', '성인 급성 상기도 감염 항생제 사용지침 권고안', 'src/main/resources/medical-data/성인급성상기도감염 항생제사용지침권고안.pdf', '970KB', NOW()),
                                                                                           ('성인복강내감염.pdf', '성인 복강 내 감염', 'src/main/resources/medical-data/성인복강내감염.pdf', '2,496KB', NOW()),
                                                                                           ('성인지역사회획득폐렴항생제사용지침.pdf', '성인 지역사회획득 폐렴 항생제 사용지침', 'src/main/resources/medical-data/성인지역사회획득폐렴항생제사용지침.pdf', '643KB', NOW()),
                                                                                           ('의료관련감염.pdf', '의료관련감염', 'src/main/resources/medical-data/의료관련감염.pdf', '6,300KB', NOW()),
                                                                                           ('코로나19환자치료를위한 최신.pdf', '코로나19 환자 치료를 위한 최신', 'src/main/resources/medical-data/코로나19환자치료를위한 최신.pdf', '6,773KB', NOW()),
                                                                                           ('피부연조직감염항생제사용지침.pdf', '피부·연조직 감염 항생제 사용지침', 'src/main/resources/medical-data/피부연조직감염항생제사용지침.pdf', '842KB', NOW()),
                                                                                           ('한국에서의항생제스튜어드십프로그램 .pdf', '한국에서의 항생제 스튜어드십 프로그램', 'src/main/resources/medical-data/한국에서의항생제스튜어드십프로그램 .pdf', '2,779KB', NOW());