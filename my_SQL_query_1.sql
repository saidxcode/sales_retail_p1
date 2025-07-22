15--SQL RETAIL Sales analysis
--Creating the table after checking 
DROP TABLE IF EXISTS 
CREATE TABLE retail_sales(
transactions_id INT PRIMARY KEY,
sale_date DATE ,
sale_time TIME,
customer_id INT,
gender VARCHAR(15),
age INT,
category VARCHAR(18),
quantiy INT,
price_per_unit FLOAT,
cogs FLOAT,
total_sale INT
)
--finding the numbers of rows 
SELECT COUNT(*)
FROM retail_sales
--Dynamic SQL to count NULLs in each column
DO $$
DECLARE
    col TEXT;
    result BIGINT;
BEGIN
    FOR col IN
        SELECT column_name
        FROM information_schema.columns
        WHERE table_name = 'retail_sales'
          AND table_schema = 'public'
    LOOP
        EXECUTE format('SELECT COUNT(*) FROM retail_sales WHERE %I IS NULL', col)
        INTO result;

        RAISE NOTICE 'Column "%" has % NULL values', col, result;
    END LOOP;
END $$;
--Data manipulation 
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05'
--RETRIEVING THE DATA WHERE CAT IS CLOTHING AND 
SELECT 
  category,
  SUM(quantiy)
FROM retail_sales
WHERE category='Clothing'
AND TO_CHAR(sale_date,'YYYY-MM')='2022-11'
GROUP BY 1
--TOTAL SALES FOR EACH CATEGORY
SELECT 
    category,
	sum(quantiy) AS total_sales
FROM retail_sales
GROUP BY category
--AVERAGE AGE OF CUSTOMERS THTA BOUGHT FROM BEAUTY CAT
SELECT 
    category,
	ROUND(AVG(age))
FROM retail_sales
WHERE category='Beauty'
GROUP BY 1
--total_sales above 1000
SELECT *
FROM retail_sales
WHERE total_sale>1000
--total number of transactions made by each category for each gender
SELECT
COUNT(*) as total_trans,
category,
gender
FROM retail_sales
GROUP BY category,gender
ORDER BY category
--AVG sales for each month and Best Month of the year ?
--Using sub Queries Or CTE
SELECT * FROM (
SELECT 
  EXTRACT(YEAR FROM sale_date) as Year,
  EXTRACT (MONTH FROM sale_date) as Month,
  ROUND(AVG(total_sale),2) as avg_sales,
  RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY EXTRACT (MONTH FROM sale_date)) AS Rank
 FROM retail_sales
GROUP BY 1,2 ) AS Tb1
--ORDER BY 1,3 DESC
WHERE Tb1.Rank = 1
--Top 5 Customers Based on the Total_sale
SELECT 
retail_sales.customer_id,
SUM(total_sale) as Sales
FROM retail_sales
GROUP BY customer_id
ORDER BY Sales 
LIMIT 5;
--Number of Unique Customers That Who purchased from each Category 
SELECT 
   category,
   Count(DISTINCT customer_id) AS Unique_cust
FROM retail_sales
GROUP BY 1
--Creat Each Shitft And the Number Of Orders using CASE(IF STATEMENTS)
WITH Hourly
AS (
SELECT *,
  CASE 
     WHEN EXTRACT(HOUR FROM sale_time) <17 Then 'Morning'
     WHEN EXTRACT(HOUR FROM sale_time) >= 17 OR EXTRACT(HOUR FROM sale_time) <= 1 THEN 'Night'

   ELSE 'No idea'
   END as Shift
FROM retail_sales
)
SELECT 
   COUNT(*) as total_sale_shift,
   Shift
FROM Hourly 
GROUP BY Shift
--END