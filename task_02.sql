-----------------------------------------------------------------------------------------------
-- 2. Заполнить базу данных тестовыми данными (порядка 10к вакансий и 100к резюме)
-----------------------------------------------------------------------------------------------

INSERT INTO area (area_name)
VALUES ('Moscow'),
       ('Saint Petersburg'),
       ('Vladivostok'),
       ('Krasnoyarsk'),
       ('Samara'),
       ('Saratov'),
       ('Perm'),
       ('Rostov-on-Don'),
       ('Tomsk'),
       ('Volgograd'),
       ('Kazan'),
       ('Omsk'),
       ('Yakutsk');

INSERT INTO specialization (specialization_name)
VALUES ('Automotive'),
       ('Security'),
       ('Pharmacy'),
       ('Marketing'),
       ('IT'),
       ('Tourism'),
       ('Science'),
       ('Manufacturing'),
       ('Agriculture'),
       ('Transport'),
       ('HR'),
       ('Other');

-- Функция для получения случайного значения из перечисления
CREATE OR REPLACE FUNCTION random_enum(relation_name ANYELEMENT, OUT result ANYENUM)
AS
$$
BEGIN
    EXECUTE FORMAT(
            $sql$
      select elem
      from unnest(enum_range(null::%1$I)) as elem
      order by random()
      limit 1;
    $sql$,
            PG_TYPEOF(relation_name)
        ) INTO result;
END;
$$ LANGUAGE plpgsql;

-- Добавляем 500 случайных работодателей
INSERT INTO employer(employer_name, employer_description, area_id)
SELECT MD5(RANDOM()::TEXT),
       MD5(RANDOM()::TEXT),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM area)) + 1)
FROM GENERATE_SERIES(1, 500);

-- Добавляем 50'000 случайных соискателей с датой рождения между 1980 и 2005 годами и опытом работы от 0 до 20 лет
INSERT INTO applicant(name, surname, area_id, birthdate, gender, education, experience, email)
SELECT MD5(RANDOM()::TEXT),
       MD5(RANDOM()::TEXT),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM area)) + 1),
       (date('1980-01-01') + ROUND(RANDOM() * 365 * 25)::INTEGER),
       random_enum(NULL::gender),
       random_enum(NULL::education),
       ROUND(RANDOM() * (20))::INTEGER,
       MD5(RANDOM()::TEXT)
FROM GENERATE_SERIES(1, 50000);

-- Добавляем 10'000 случайных вакансий, размещенных в 2021 году
INSERT INTO vacancy(employer_id, position_name, compensation_from, compensation_to, experience,
                    responsibility, requirements, work_conditions, area_id, address, publication_date, is_remote)
SELECT (FLOOR(RANDOM() * (SELECT COUNT(*) FROM employer)) + 1),
       MD5(RANDOM()::TEXT),
       ROUND(RANDOM() * (100000))::INTEGER,
       100000 + ROUND(RANDOM() * (50000))::INTEGER,
       ROUND(RANDOM() * (10))::INTEGER,
       MD5(RANDOM()::TEXT),
       MD5(RANDOM()::TEXT),
       MD5(RANDOM()::TEXT),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM area)) + 1),
       MD5(RANDOM()::TEXT),
       (date('2021-01-01') + ROUND(RANDOM() * 365)::INTEGER),
       RANDOM() < 0.5
FROM GENERATE_SERIES(1, 10000);

-- Добавляем 100'000 случайных резюме, размещенных в 2021 году
INSERT INTO resume(applicant_id, position_name, salary, area_id, publication_date, is_visible)
SELECT (FLOOR(RANDOM() * (SELECT COUNT(*) FROM applicant)) + 1),
       MD5(RANDOM()::TEXT),
       ROUND(RANDOM() * (150000))::INTEGER,
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM area)) + 1),
       (date('2021-01-01') + ROUND(RANDOM() * 365)::INTEGER),
       RANDOM() < 0.5
FROM GENERATE_SERIES(1, 100000);

-- Для каждой вакансии добавим одну случайную специализацию
WITH sequence(id) AS (SELECT GENERATE_SERIES(1, (SELECT COUNT(*) FROM vacancy)) AS id)
INSERT
INTO vacancy_specialization(vacancy_id, specialization_id)
SELECT (id),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM specialization)) + 1)
FROM sequence;

-- Для каждого резюме добавим одну случайную специализацию
WITH sequence(id) AS (SELECT GENERATE_SERIES(1, (SELECT COUNT(*) FROM resume)) AS id)
INSERT
INTO resume_specialization(resume_id, specialization_id)
SELECT (id),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM specialization)) + 1)
FROM sequence;

-- Сгенерируем 20'000 случайных окликов на вакансии
INSERT INTO respond(vacancy_id, resume_id, cover_letter, respond_status)
SELECT (FLOOR(RANDOM() * (SELECT COUNT(*) FROM vacancy)) + 1),
       (FLOOR(RANDOM() * (SELECT COUNT(*) FROM resume)) + 1),
       MD5(RANDOM()::TEXT),
       random_enum(NULL::respond_status)
FROM GENERATE_SERIES(1, 20000);

-- Удалим дубликаты откликов, которые могли получиться (считаем, что одним резюме можно откликнуться на вакансию только один раз)
DELETE
FROM respond a
    USING respond b
WHERE a.respond_id < b.respond_id
  AND a.vacancy_id = b.vacancy_id
  AND a.resume_id = b.resume_id;

-- Установим дату откликов в промежутке до месяца с наиболее позднего события (публикация вакансии или публикация резюме)
UPDATE respond
SET respond_date = CASE
                       WHEN resume.publication_date > vacancy.publication_date
                           THEN resume.publication_date + ROUND(RANDOM() * 30)::INTEGER
                       ELSE vacancy.publication_date + ROUND(RANDOM() * 30)::INTEGER
    END
FROM resume,
     vacancy
WHERE respond.resume_id = resume.resume_id
  AND respond.vacancy_id = vacancy.vacancy_id;
  