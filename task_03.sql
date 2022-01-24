-----------------------------------------------------------------------------------------------
-- 3. Написать запрос для получения средних значений по регионам (area_id) следующих величин:
-- compensation_from, compensation_to, среднее_арифметическое_from_и_to
-----------------------------------------------------------------------------------------------

-- LEFT JOIN потому что хотим посмотреть все регионы независимо от наличия в них вакансий
-- При этом я допускаю, что в результате запроса могут быть null'ы (если какому-то area_id не соотносится ни одна вакансия,
-- либо если compensation_from или compensation_to незаполнены
SELECT a.area_id,
       ROUND(AVG(compensation_from))                       AS average_minimum_salary,
       ROUND(AVG(compensation_to))                         AS average_maximum_salary,
       ROUND(AVG(compensation_from + compensation_to) / 2) AS average_salary
FROM area a
         LEFT JOIN vacancy v ON a.area_id = v.area_id
GROUP BY a.area_id;
