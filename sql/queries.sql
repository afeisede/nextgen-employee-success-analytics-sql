-- NextGen Corp: Employee Retention, Performance, and Remuneration Analysis
-- Author: Hamzat Afe Isede

-- =========================
-- Preview Base Tables
-- =========================
SELECT * FROM employee;
SELECT * FROM department;
SELECT * FROM attendance;
SELECT * FROM performance;
SELECT * FROM salary;
SELECT * FROM turnover;

-- =========================
-- 1. Top 10 longest-serving employees
-- =========================
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    e.hire_date AS start_date,
    COALESCE(t.turnover_date, CURRENT_DATE) AS end_date,
    ROUND((COALESCE(t.turnover_date, CURRENT_DATE) - e.hire_date) / 365.0, 2) AS years_of_service
FROM employee e
LEFT JOIN turnover t
    ON e.employee_id = t.employee_id
ORDER BY years_of_service DESC
LIMIT 10;

-- =========================
-- 2. Turnover rate by department
-- =========================
SELECT 
    d.department_name AS department,
    COUNT(DISTINCT e.employee_id) AS total_employees,
    COUNT(DISTINCT t.employee_id) AS employees_who_left,
    ROUND(COUNT(DISTINCT t.employee_id) * 100.0 / COUNT(DISTINCT e.employee_id), 2) AS turnover_rate
FROM department d
JOIN employee e 
    ON e.department_id = d.department_id
LEFT JOIN turnover t 
    ON t.employee_id = e.employee_id
GROUP BY d.department_name
ORDER BY turnover_rate DESC;

-- =========================
-- 3. Employees at risk of leaving based on performance
-- Lowest average performance scores
-- =========================
SELECT 
    e.first_name || ' ' || e.last_name AS employee_name,
    ROUND(AVG(p.performance_score), 2) AS average_performance_score
FROM employee e
JOIN performance p
    ON e.employee_id = p.employee_id
GROUP BY e.employee_id, employee_name
ORDER BY average_performance_score ASC
LIMIT 10;

-- =========================
-- 4. Main reasons employees are leaving
-- =========================
SELECT 
    t.reason_for_leaving AS reason_for_leaving,
    COUNT(*) AS reason_count
FROM turnover t
GROUP BY t.reason_for_leaving
ORDER BY reason_count DESC;

-- =========================
-- 5. Total employees who left the company
-- =========================
SELECT 
    COUNT(*) AS total_employees_who_left
FROM turnover;

-- Employees who left by department
SELECT 
    d.department_name AS department,
    COUNT(t.employee_id) AS employees_who_left
FROM department d
LEFT JOIN turnover t
    ON d.department_id = t.department_id
GROUP BY d.department_name
ORDER BY employees_who_left DESC;

-- =========================
-- 6. Performance score distribution
-- =========================
-- Employees with a performance score of 5.0
SELECT 
    performance_score,
    COUNT(*) AS employee_count
FROM performance
WHERE performance_score = 5.0
GROUP BY performance_score;

-- Employees with a performance score below 3.5
SELECT 
    COUNT(*) AS employees_below_3_5
FROM performance
WHERE performance_score < 3.5;

-- Detailed view of employees below 3.5
SELECT 
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    p.performance_score
FROM employee e
JOIN performance p
    ON e.employee_id = p.employee_id
WHERE p.performance_score < 3.5
ORDER BY p.performance_score ASC, e.employee_id;

-- =========================
-- 7a. Department with the most employees scoring 5.0
-- =========================
SELECT 
    d.department_name AS department,
    COUNT(p.employee_id) AS employees_with_score_5
FROM department d
JOIN performance p
    ON d.department_id = p.department_id
WHERE p.performance_score = 5.0
GROUP BY d.department_name
ORDER BY employees_with_score_5 DESC;

-- =========================
-- 7b. Department with the most employees scoring below 3.5
-- =========================
SELECT 
    d.department_name AS department,
    COUNT(p.employee_id) AS employees_below_3_5
FROM department d
JOIN performance p
    ON d.department_id = p.department_id
WHERE p.performance_score < 3.5
GROUP BY d.department_name
ORDER BY employees_below_3_5 DESC;

-- =========================
-- 8. Average performance score by department
-- =========================
SELECT 
    d.department_name AS department,
    ROUND(AVG(p.performance_score), 2) AS average_performance_score
FROM department d
JOIN performance p
    ON d.department_id = p.department_id
GROUP BY d.department_name
ORDER BY average_performance_score DESC;

-- =========================
-- 9. Total salary expense for the company
-- =========================
SELECT 
    SUM(s.salary_amount) AS total_salary_expense
FROM salary s;

-- =========================
-- 10. Average salary by job title
-- =========================
SELECT 
    e.job_title AS job_title,
    ROUND(AVG(s.salary_amount), 2) AS average_salary
FROM employee e
LEFT JOIN salary s
    ON e.employee_id = s.employee_id
GROUP BY e.job_title
ORDER BY average_salary ASC;

-- =========================
-- 11. Employees earning above 80,000
-- =========================
SELECT 
    COUNT(*) AS employees_earning_above_80000
FROM salary
WHERE salary_amount > 80000;

-- By department
SELECT 
    d.department_name AS department,
    COUNT(s.employee_id) AS employees_earning_above_80000
FROM department d
LEFT JOIN salary s
    ON d.department_id = s.department_id
WHERE s.salary_amount > 80000
GROUP BY d.department_name
ORDER BY employees_earning_above_80000 DESC;

-- By job title
SELECT 
    e.job_title AS job_title,
    COUNT(s.employee_id) AS employees_earning_above_80000
FROM employee e
LEFT JOIN salary s
    ON e.employee_id = s.employee_id
WHERE s.salary_amount > 80000
GROUP BY e.job_title
ORDER BY employees_earning_above_80000 DESC;

-- =========================
-- 12. Performance and salary relationship across departments
-- =========================
SELECT 
    d.department_name AS department,
    ROUND(AVG(p.performance_score), 2) AS average_performance_score,
    ROUND(AVG(s.salary_amount), 2) AS average_salary
FROM department d
JOIN performance p
    ON d.department_id = p.department_id
JOIN salary s
    ON p.employee_id = s.employee_id
GROUP BY d.department_name
ORDER BY average_salary DESC, average_performance_score DESC;
