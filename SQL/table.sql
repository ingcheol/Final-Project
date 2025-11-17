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