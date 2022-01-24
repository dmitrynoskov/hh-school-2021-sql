-----------------------------------------------------------------------------------------------
-- 1. Спроектировать базу данных hh (основные таблицы: вакансии, резюме, отклики, специализации)
-----------------------------------------------------------------------------------------------

DROP TABLE IF EXISTS area CASCADE;
CREATE TABLE IF NOT EXISTS area
(
    area_id   SERIAL PRIMARY KEY,
    area_name TEXT NOT NULL
);

DROP TABLE IF EXISTS employer CASCADE;
CREATE TABLE IF NOT EXISTS employer
(
    employer_id          SERIAL PRIMARY KEY,
    employer_name        TEXT    NOT NULL,
    employer_description TEXT,
    area_id              INTEGER NOT NULL REFERENCES area (area_id)
);

DROP TABLE IF EXISTS specialization CASCADE;
CREATE TABLE IF NOT EXISTS specialization
(
    specialization_id   SERIAL PRIMARY KEY,
    specialization_name TEXT NOT NULL
);

DROP TABLE IF EXISTS vacancy CASCADE;
CREATE TABLE IF NOT EXISTS vacancy
(
    vacancy_id        SERIAL PRIMARY KEY,
    employer_id       INTEGER NOT NULL REFERENCES employer (employer_id),
    position_name     TEXT    NOT NULL,
    compensation_from INTEGER,
    compensation_to   INTEGER,
    experience        INTEGER,
    responsibility    TEXT,
    requirements      TEXT,
    work_conditions   TEXT,
    area_id           INTEGER NOT NULL REFERENCES area (area_id),
    address           TEXT,
    publication_date  DATE    NOT NULL,
    is_remote         BOOLEAN DEFAULT FALSE
);

-- Так как таблица вакансий и таблица специализаций имеют отношения "многие-ко-многим", для их связи используем третью таблицу
-- Отдельный ключ можно было не создавать, так как сочетания vacancy_id + specialization_id уникальны, но мне так привычнее
DROP TABLE IF EXISTS vacancy_specialization CASCADE;
CREATE TABLE IF NOT EXISTS vacancy_specialization
(
    vacancy_specialization_id SERIAL PRIMARY KEY,
    vacancy_id                INTEGER NOT NULL REFERENCES vacancy (vacancy_id),
    specialization_id         INTEGER NOT NULL REFERENCES specialization (specialization_id)
);

DROP TYPE IF EXISTS gender CASCADE;
CREATE TYPE gender AS ENUM ('Male', 'Female');

DROP TYPE IF EXISTS education CASCADE;
CREATE TYPE education AS ENUM ('Secondary', 'Incomplete higher', 'Bachelor', 'Master', 'Candidate of science', 'Doctor of science');

DROP TABLE IF EXISTS applicant CASCADE;
CREATE TABLE IF NOT EXISTS applicant
(
    applicant_id SERIAL PRIMARY KEY,
    name         TEXT   NOT NULL,
    surname      TEXT   NOT NULL,
    area_id      INTEGER REFERENCES area (area_id),
    birthdate    DATE   NOT NULL,
    gender       gender NOT NULL,
    education    education,
    experience   INTEGER DEFAULT 0,
    email        TEXT   NOT NULL
);

DROP TABLE IF EXISTS resume CASCADE;
CREATE TABLE IF NOT EXISTS resume
(
    resume_id        SERIAL PRIMARY KEY,
    applicant_id     INTEGER NOT NULL REFERENCES applicant (applicant_id),
    position_name    TEXT    NOT NULL,
    salary           INTEGER,
    area_id          INTEGER NOT NULL REFERENCES area (area_id),
    publication_date DATE    NOT NULL,
    is_visible       BOOLEAN DEFAULT TRUE
);

-- Так как таблица резюме и таблица специализаций имеют отношения "многие-ко-многим", для их связи используем третью таблицу
-- Отдельный ключ можно было не создавать, так как сочетания resume_id + specialization_id уникальны, но мне так привычнее
DROP TABLE IF EXISTS resume_specialization CASCADE;
CREATE TABLE IF NOT EXISTS resume_specialization
(
    resume_specialization_id SERIAL PRIMARY KEY,
    resume_id                INTEGER NOT NULL REFERENCES resume (resume_id),
    specialization_id        INTEGER NOT NULL REFERENCES specialization (specialization_id)
);

DROP TYPE IF EXISTS respond_status CASCADE;
CREATE TYPE respond_status AS ENUM ('Not viewed', 'Viewed' , 'Invited for an interview', 'Denied');

-- Можно было не заводить отдельный ключ, если считать, что одним резюме можно откликнуться на вакансию только один раз
DROP TABLE IF EXISTS respond CASCADE;
CREATE TABLE IF NOT EXISTS respond
(
    respond_id     SERIAL PRIMARY KEY,
    vacancy_id     INTEGER NOT NULL REFERENCES vacancy (vacancy_id),
    resume_id      INTEGER NOT NULL REFERENCES resume (resume_id),
    cover_letter   TEXT,
    respond_date   DATE    NOT NULL DEFAULT NOW(),
    respond_status respond_status   DEFAULT 'Not viewed'
);
