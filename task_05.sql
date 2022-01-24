-----------------------------------------------------------------------------------------------
-- 5. Написать запрос для получения id и title вакансий, которые собрали больше 5 откликов в первую неделю после публикации
-----------------------------------------------------------------------------------------------
SELECT vacancy.vacancy_id, position_name
FROM respond
         INNER JOIN vacancy ON respond.vacancy_id = vacancy.vacancy_id
WHERE respond_date - publication_date <= 7
GROUP BY vacancy.vacancy_id, position_name
HAVING COUNT(*) > 5;
