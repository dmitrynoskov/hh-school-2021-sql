-----------------------------------------------------------------------------------------------
-- 4. Написать запрос для получения месяца с наибольшим количеством вакансий и месяца с наибольшим количеством резюме
-----------------------------------------------------------------------------------------------
SELECT (
           SELECT TO_CHAR((publication_date), 'Month')
           FROM vacancy
           GROUP BY TO_CHAR((publication_date), 'Month')
           ORDER BY COUNT(*) DESC
           LIMIT 1
       ) AS month_with_max_vacancies,
       (
           SELECT TO_CHAR((publication_date), 'Month')
           FROM resume
           GROUP BY TO_CHAR((publication_date), 'Month')
           ORDER BY COUNT(*) DESC
           LIMIT 1
       ) AS month_with_max_resumes;
