-- Problem 1: Department Highest Salary (LC #184)
-- Difficulty: Medium
-- Approach: CTE to get max salary per department, then join back to Employee
-- e is the employee side, dm holds the max salary benchmark per dept
-- Key insight: joining on both departmentId AND salary filters to top earners only

WITH dept_max AS (
    SELECT departmentId, MAX(salary) AS max_salary
    FROM Employee
    GROUP BY departmentId
)
SELECT d.name  AS Department, e.name  AS Employee, e.salary AS Salary
FROM Employee e
INNER JOIN Department d ON e.departmentId = d.id
INNER JOIN dept_max dm  ON e.departmentId = dm.departmentId AND e.salary = dm.max_salary;


-- Problem 2: Monthly Transactions I (LC #1193)
-- Difficulty: Medium
-- Approach: Group by month + country using DATE_FORMAT to strip the day
-- Use CASE WHEN inside SUM to split approved vs total in one pass
-- Key insight: no subquery needed, conditional aggregation handles both counts

SELECT DATE_FORMAT(trans_date, '%Y-%m') AS month, country, COUNT(*) AS trans_count, 
    SUM(CASE WHEN state = 'approved' THEN 1 ELSE 0 END) AS approved_count, 
    SUM(amount) AS trans_total_amount,
    SUM(CASE WHEN state = 'approved' THEN amount ELSE 0 END) AS approved_total_amount
FROM Transactions
GROUP BY DATE_FORMAT(trans_date, '%Y-%m'), country;


-- Problem 3: Immediate Food Delivery II (LC #1174)
-- Difficulty: Medium
-- Approach: CTE isolates each customer's first order date, then join back
-- immediate means order_date matches customer_pref_delivery_date
-- Key insight: year filter in JOIN condition, not WHERE, preserves the left join behavior

WITH first_orders AS (
    SELECT customer_id, MIN(order_date) AS first_order_date
    FROM Delivery
    GROUP BY customer_id
)
SELECT ROUND(100 * SUM(CASE WHEN d.order_date = d.customer_pref_delivery_date THEN 1 ELSE 0 END) / COUNT(*), 2) AS immediate_percentage
FROM Delivery d
INNER JOIN first_orders fo ON d.customer_id = fo.customer_id AND d.order_date = fo.first_order_date;


-- Problem 4: Consecutive Numbers (LC #180)
-- Difficulty: Medium
-- Approach: Self join Logs table 3 times on consecutive id values
-- l1 is the anchor row, l2 and l3 follow immediately after
-- Key insight: DISTINCT handles cases where the same number repeats more than 3 times

SELECT DISTINCT l1.num AS ConsecutiveNums
FROM Logs l1
INNER JOIN Logs l2 ON l2.id = l1.id + 1 AND l2.num = l1.num
INNER JOIN Logs l3 ON l3.id = l1.id + 2 AND l3.num = l1.num;


-- Problem 5: Market Analysis I (LC #1158)
-- Difficulty: Medium
-- Approach: LEFT JOIN Orders onto Users so zero-order users still appear
-- Year filter goes in JOIN condition not WHERE to avoid turning left join into inner join
-- Key insight: COUNT(o.order_id) returns 0 for NULLs, COUNT(*) would not

SELECT u.user_id AS buyer_id, u.join_date, COUNT(o.order_id) AS orders_in_2019
FROM Users u
LEFT JOIN Orders o ON u.user_id = o.buyer_id AND YEAR(o.order_date) = 2019
GROUP BY u.user_id, u.join_date;