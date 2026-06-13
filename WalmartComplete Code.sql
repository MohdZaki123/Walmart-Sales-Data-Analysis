SELECT COUNT(*) FROM walmart;
SELECT DISTINCT(payment_method) ,COUNT(*)
FROM walmart
GROUP BY payment_method;

---Bussiness Problem 
---1. Find different payment methods and   no of Transaction , number of qty sold

SELECT payment_method,COUNT(*) AS no_payments, sum(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method

---2.Identify the  highest Rated Category  in Each Branch , Displaying the branch , Category
-- AvG Rating

SELECT *
FROM (
    SELECT
        "Branch",
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (
            PARTITION BY "Branch"
            ORDER BY AVG(rating) DESC
        ) AS rnk
    FROM walmart
    GROUP BY "Branch", category
) t
WHERE rnk = 1;

-- 3.Identify the  busiest  day for  each branch based  on the  no of  Transactions 

SELECT *
FROM (
    SELECT
        "Branch",
        TO_CHAR(TO_DATE(date, 'DD/MM/YY'), 'Day') AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (
            PARTITION BY "Branch"
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM walmart
    GROUP BY 1, 2
) AS t
WHERE rnk = 1;


-- 4. Determine  the  Avg , min and  max Rating of  Category  for  each city.
-- List the  city , avg_rating , min_rating and  max_rating .

SELECT 
	"City",
	category,
	MIN(rating) as min_rating,
	MAX(rating) as max_rating,
	AVG(rating) as avg_rating
FROM walmart
GROUP BY 1,2

-- 5.Calculate  the  total profit for  each Category  By Considering total_profit s (unit_price * quality * profit * profit_margin). List Category and Total_profit , Ordered from highest to Lowest Profit 
SELECT 
	category,
	SUM(total) as total_revenue,
	SUM(total * profit_margin) as profit
FROM walmart
GROUP BY 1 

-- --6 Determine the  most common paymnet method  for  each  branch
-- display branch and the preferred  payment method

WITH cte AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER (
            PARTIT ION BY branch
            ORDER BY COUNT(*) DESC
        ) AS rnk
    FROM walmart
    GROUP BY branch, payment_method
)

SELECT *
FROM cte;

--7 Categorize Sales  into 3 Group Morning , afternoon , evening .find  out each of the shift and number of invoices
SELECT
    branch,
    CASE
        WHEN EXTRACT(HOUR FROM (time::time)) < 12 THEN 'Morning'
        WHEN EXTRACT(HOUR FROM (time::time)) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
    END day_time,
    COUNT(*)
FROM walmart
GROUP BY 1, 2
ORDER BY 1, 3 DESC;


--  8 Identify 5 branch with highest decrese ratio in 
-- revevenue compare to last year(current year 2023 and last year 2022)


WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2022
    GROUP BY branch
),

revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE EXTRACT(YEAR FROM TO_DATE(date, 'DD/MM/YY')) = 2023
    GROUP BY branch
)

SELECT
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue) / ls.revenue * 100)::numeric,
        2
    ) AS rev_dec_ratio
FROM revenue_2022 ls
JOIN revenue_2023 cs
    ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;