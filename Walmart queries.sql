USE walmart_db;
SELECT COUNT(*) FROM walmart;
 SELECT * FROM walmart LIMIT 10;
SELECT DISTINCT payment_method FROM walmart;
SELECT payment_method,
COUNT(*)
FROM walmart group by payment_method;

SELECT 
COUNT(DISTINCT branch)
FROM WALMART;

SELECT MAX(quantity) as MAXQUANTITY FROM walmart;
 SELECT MIN(quantity) as MINQUANTITY FROM walmart;
 
-- BUSINESS PROBLEMS
-- Q.1 Find different payment methods and number of transactions, number of quantity sold

SELECT payment_method,
COUNT(*) as number_payments ,
SUM(quantity) as  number_quantity_sold
FROM walmart 
group by payment_method;

-- Q.2 Identity the hightest rated category in each branch, displaying the branch, category, AVG Rating

SELECT *
FROM
(  SELECT 
     branch,
     category,
     AVG(rating) as Average_rating,
	RANK() OVER(PARTITION BY branch ORDER BY AVG(rating) DESC) AS Highest
    FROM walmart
	GROUP BY branch, category 
 ) AS ranked
 WHERE Highest = 1;
 
-- 	Q.3 Identify the busiest day for each branch based on number of transactions

SELECT 
 date ,
DATE_FORMAT(date, '%d/%m/%y') AS formatted_date
 FROM  walmart;


SELECT *
FROM 
 (SELECT 
  branch,
  DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
  COUNT(*) AS number_transactions,
  RANK() OVER (
    PARTITION BY branch 
    ORDER BY COUNT(*) DESC
  ) AS ran
FROM walmart
GROUP BY branch, day_name
ORDER BY branch , number_transactions DESC
 )as ranked
 WHERE ran = 1;
 
 -- Q.4 Calculate the total quantity of items sold per payment method. list payment_method and total_quantity.
 
SELECT  
payment_method,
-- COUNT(*) as number_payments ,
SUM(quantity) as  number_quantity_sold
FROM walmart 
group by payment_method;

-- Q.5 
-- Determine the average , minimum , and maximum rating of product for each city.
-- List the city, average_rating, min_rating, and max_rating

SELECT 
city, 
AVG(rating) as average_rating,
MAX(rating) as max_rating,
MIN(rating) as min_rating
FROM walmart
GROUP BY city;

-- Q.6 Calculate the total profit for each category by considering total_profit as 
-- (unit_price * quantity *profit_margin). List category and total_profit, ordered from highest to lowest prices

SELECT 
category,
sum(total * profit_margin) as margin
From walmart 
GROUP BY Category
ORDER BY margin DESC;

-- Q.7 
-- Determine the most common payment method for each Branch
-- Display Branch and the preferred_payment method.
with cte 
as
(SELECT 
branch,
payment_method,
COUNT(*) as total_trans,
RANK() OVER(PARTITION BY branch ORDER BY COUNT(*) DESC) AS ran
FROM walmart
GROUP BY branch, payment_method)

SELECT *
FROM cte 
where ran =1;

-- Q.8 
-- Categorize sales into 3 group MORING, AFTERNOON , EVENING 
-- Find out each of the shift and number of invoices

SELECT
branch, 
  CASE 
    WHEN EXTRACT(HOUR FROM TIME(time)) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM TIME(time)) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS day_time,
  COUNT(*) AS num_transactions
FROM walmart
GROUP BY 1,2
ORDER BY 1,3 DESC;


-- Q.9 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)
-- rdr = (last_yearrev-current year_rev )/lastyear_rev *100
SELECT *,
YEAR(STR_TO_DATE(date, '%d/%m/%y')) AS year
FROM walmart;

-- YEAR 2022 revenue
WITH revenue_2022 AS (
  SELECT 
    branch,
    SUM(total) AS revenue 
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
  GROUP BY branch
),
revenue_2023 AS (
  SELECT 
    branch,
    SUM(total) AS revenue 
  FROM walmart
  WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
  GROUP BY branch
)

SELECT 
  r22.branch,
  r22.revenue AS last_year_revenue,
  r23.revenue AS current_year_revenue,
  ROUND((r22.revenue - r23.revenue) / r22.revenue * 100, 2) AS rev_dec_ratio
FROM revenue_2022 r22
JOIN revenue_2023 r23 ON r22.branch = r23.branch
WHERE r22.revenue > r23.revenue
ORDER BY r22.branch LIMIT 5;
