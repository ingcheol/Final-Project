create table patient
(
    patient_id          bigserial
        primary key,
    email               varchar(255) not null
        unique,
    password            varchar(255) not null,
    name                varchar(100) not null,
    phone               varchar(20),
    dob                 date,
    gender              varchar(10),
    address             text,
    medical_history     text,
    lifestyle_habits    text,
    account_status      varchar(20) default 'active'::character varying,
    language_preference varchar(10) default 'ko'::character varying,
    provider            varchar(50),
    provider_id         varchar(255),
    user_role           varchar(20) default 'ROLE_USER'::character varying,
    created_at          timestamp   default now(),
    updated_at          timestamp
);

create table survey
(
    survey_id    bigserial
        primary key,
    survey_type  varchar(50),
    questions    jsonb,
    answers      jsonb,
    created_at   timestamp default now(),
    submitted_at timestamp,
    patient_id   bigint not null
);

create table emr
(
    emr_id               bigserial
        primary key,
    patient_statement    text,
    test_results         text,
    prescription_details text,
    ai_generated_draft   text,
    final_record         text,
    created_at           timestamp default now(),
    updated_at           timestamp,
    consultation_id      bigint,
    patient_id           bigint
);

create table iot
(
    data_id     bigserial
        primary key,
    device_type varchar(50),
    vital_type  varchar(50),
    value       numeric(10, 2),
    is_abnormal boolean   default false,
    measured_at timestamp default now(),
    patient_id  bigint not null
);

CREATE TABLE admin (
                       admin_id	BIGSERIAL	NOT NULL,
                       password	VARCHAR(255)	NOT NULL,
                       name	VARCHAR(100)	NOT NULL,
                       phone	VARCHAR(20)	NULL,
                       email	VARCHAR(100)	NOT NULL,
                       account_status	VARCHAR(20)	NULL	DEFAULT 'active',
                       created_at	TIMESTAMP	NULL,
                       patient_id	BIGSERIAL	NOT NULL
);

CREATE TABLE adviser (
                         adviser_id	BIGSERIAL	NOT NULL,
                         password	VARCHAR(255)	NOT NULL,
                         name	VARCHAR(100)	NOT NULL,
                         phone	VARCHAR(20)	NULL,
                         email	VARCHAR(100)	NOT NULL,
                         license_number	VARCHAR(50)	NOT NULL,
                         account_status	VARCHAR(20)	NULL	DEFAULT 'active',
                         created_at	TIMESTAMP	NULL
);
-- ==========================================
-- 1. 기존 테이블 초기화 (깨끗하게 다시 시작, 테이블 없을경우 선택 사항)
-- ==========================================
DROP TABLE IF EXISTS pdf_chunks CASCADE;
DROP TABLE IF EXISTS diagnosis_history CASCADE;
DROP TABLE IF EXISTS medical_documents CASCADE;
-- ==========================================
-- 2. 의료 문서 관리 (PDF 파일 목록)
-- ==========================================
CREATE TABLE medical_documents (
                                   doc_id SERIAL PRIMARY KEY,
                                   file_name VARCHAR(255) NOT NULL, -- 파일명
                                   doc_title VARCHAR(300) NOT NULL, -- 문서 제목
                                   file_path VARCHAR(500) NOT NULL, -- 파일 경로
                                   file_size VARCHAR(50), -- 파일 크기
                                   created_at TIMESTAMP DEFAULT NOW()
);
-- ==========================================
-- 3. AI 분석용 텍스트 청크 (RAG 핵심 테이블)
-- ==========================================
CREATE TABLE pdf_chunks (
                            chunk_id SERIAL PRIMARY KEY,
                            doc_id BIGINT NOT NULL,
                            file_name VARCHAR(255) NOT NULL,
                            content TEXT NOT NULL, -- ★ AI가 읽을 텍스트 조각
                            chunk_index INTEGER NOT NULL,
                            created_at TIMESTAMP DEFAULT NOW(),
                            FOREIGN KEY (doc_id) REFERENCES medical_documents(doc_id) ON DELETE CASCADE
);
-- 검색 속도 최적화 인덱스
CREATE INDEX idx_pdf_chunks_doc_id ON pdf_chunks(doc_id);
CREATE INDEX idx_pdf_chunks_content ON pdf_chunks(content);
-- ==========================================
-- 4. 사용자 진단 기록 (Dia 4 결과 저장용) ★ 추가됨!
-- ==========================================
CREATE TABLE diagnosis_history (
                                   history_id SERIAL PRIMARY KEY,
                                   user_id VARCHAR(50), -- 사용자 ID (비회원이면 NULL 가능)
                                   symptom_text TEXT NOT NULL, -- Dia 1: 사용자가 입력한 증상
                                   survey_answers TEXT, -- Dia 2: 설문조사 응답 (JSON 또는 콤마로 구분)
                                   ai_diagnosis TEXT, -- Dia 4: AI가 분석한 최종 결과 (HTML/Text)
                                   recommended_dept VARCHAR(100), -- 추천 진료과
                                   urgency_level VARCHAR(50), -- 시급성 (응급/비응급)
                                   created_at TIMESTAMP DEFAULT NOW() -- 진단 일시
);


















DROP TABLE IF EXISTS emr;
DROP TABLE IF EXISTS consultation;
DROP TABLE IF EXISTS statistics;
DROP TABLE IF EXISTS recommendation;

-- 2단계: patient 테이블을 직접 참조하는 테이블 (FK가 patient를 향함) 및 기타 자식 테이블 삭제
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS chatbotlog;
DROP TABLE IF EXISTS pre_diagnosis;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS admin_id; -- (patient 참조)
DROP TABLE IF EXISTS searchlog;
DROP TABLE IF EXISTS IOT;
DROP TABLE IF EXISTS survey;
DROP TABLE IF EXISTS notification;

-- 3단계: 부모 테이블 (patient, hospital, adviser) 삭제
DROP TABLE IF EXISTS patient;
DROP TABLE IF EXISTS hospital;
DROP TABLE IF EXISTS adviser;

-- 4단계: 나머지 외래 키 관계가 없거나 단순한 부모 테이블 삭제
DROP TABLE IF EXISTS vector_store;
DROP TABLE IF EXISTS map;
DROP TABLE IF EXISTS marker;
DROP TABLE IF EXISTS menu_item;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS product;
DROP TABLE IF EXISTS baccarat_game;
DROP TABLE IF EXISTS cart;
DROP TABLE IF EXISTS cate;
DROP TABLE IF EXISTS chat;
DROP TABLE IF EXISTS cust;
DROP TABLE IF EXISTS inquiry;
DROP TABLE IF EXISTS admin; -- admin_id 테이블이 삭제되었으므로 이제 삭제 가능합니다.


-- 상담

CREATE TABLE appointment (
                             appointment_id	BIGSERIAL	NOT NULL,
                             appointment_time	TIMESTAMP	NOT NULL,
                             appointment_type	VARCHAR(50)	NULL,
                             status	VARCHAR(20)	NULL	DEFAULT 'pending',
                             notes	TEXT	NULL,
                             patient_id	BIGSERIAL	NOT NULL
);