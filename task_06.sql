-----------------------------------------------------------------------------------------------
-- 6. Создать необходимые индексы (обосновать выбор столбцов)
-----------------------------------------------------------------------------------------------

-- При поиске вакансий соискатель вводит имя или приблизительное имя вакансии и настраивает ряд фильтров,
-- для ускорения отбора могут быть полезны следующие индексы:
CREATE INDEX vacancy_area_id_index ON vacancy (area_id);
CREATE INDEX vacancy_specialization_index ON vacancy_specialization (specialization_id);
CREATE INDEX vacancy_experience_index ON vacancy (experience);

-- При этом можно ввести индекс для наименования позиции (так как они в большинстве своём не сильно уникальны
-- и при этом могут быть использованы в некоторых регулярных выражениях при вводе начала названия позиции)
-- также, скорее всего в запросах будет встречаться фильтрация / сортировка по минимальной заработной плате и дате размещения:
CREATE INDEX vacancy_position_name_index ON vacancy (position_name);
CREATE INDEX vacancy_compensation_from_index ON vacancy (compensation_from DESC);
CREATE INDEX vacancy_date_published_index ON vacancy (publication_date DESC);

-- Удобно иметь поиск по названиям компаний:
CREATE INDEX employer_employer_name_index ON employer (employer_name);

-- Для работодателя могут быть актуальны следующие индексы:
CREATE INDEX resume_area_id_index ON resume (area_id);
CREATE INDEX resume_position_name_index ON resume (position_name);
CREATE INDEX resume_salary_index ON resume (salary ASC);
CREATE INDEX resume_publication_date_index ON resume (publication_date DESC);
CREATE INDEX resume_specialization_id_index ON resume_specialization (specialization_id);