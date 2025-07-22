# SQL Retail Sales Analysis

This repository contains SQL scripts for analyzing retail sales data using PostgreSQL. The project covers table creation, data validation, and various analytical queries to extract insights from the `retail_sales` table.

## Table Schema

The `retail_sales` table is designed to store transactional sales data:

```sql
DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
  transactions_id     INT PRIMARY KEY,
  sale_date           DATE,
  sale_time           TIME,
  customer_id         INT,
  gender              VARCHAR(15),
  age                 INT,
  category            VARCHAR(18),
  quantiy             INT,
  price_per_unit      FLOAT,
  cogs                FLOAT,
  total_sale          INT
);
```

## Prerequisites

- PostgreSQL 12 or above
- psql command‑line tool or any SQL client (e.g., pgAdmin, DBeaver)
- Sample data loaded into the `retail_sales` table

## Data Validation

1. **Row Count**

   ```sql
   SELECT COUNT(*) FROM retail_sales;
   ```

2. **Null Check for Each Column**

   ```sql
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
   ```

## Analytical Queries

### 1. Sales on a Specific Date

```sql
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';
```

### 2. Monthly Quantity Sold for Clothing

```sql
SELECT
  category,
  SUM(quantiy) AS total_quantity
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
GROUP BY category;
```

### 3. Total Sales per Category

```sql
SELECT
  category,
  SUM(quantiy) AS total_sales
FROM retail_sales
GROUP BY category;
```

### 4. Average Age of Beauty Customers

```sql
SELECT
  category,
  ROUND(AVG(age)) AS average_age
FROM retail_sales
WHERE category = 'Beauty'
GROUP BY category;
```

### 5. High-Value Transactions

```sql
SELECT *
FROM retail_sales
WHERE total_sale > 1000;
```

### 6. Transactions by Category and Gender

```sql
SELECT
  COUNT(*)      AS total_transactions,
  category,
  gender
FROM retail_sales
GROUP BY category, gender
ORDER BY category;
```

### 7. Best Month by Average Sales (CTE + Window Function)

```sql
WITH monthly_avg AS (
  SELECT
    EXTRACT(YEAR FROM sale_date)  AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    ROUND(AVG(total_sale), 2)     AS avg_sales,
    RANK() OVER (PARTITION BY EXTRACT(YEAR FROM sale_date)
                 ORDER BY AVG(total_sale) DESC) AS sales_rank
  FROM retail_sales
  GROUP BY year, month
)
SELECT year, month, avg_sales
FROM monthly_avg
WHERE sales_rank = 1;
```

### 8. Top 5 Customers by Total Sales

```sql
SELECT
  customer_id,
  SUM(total_sale) AS total_sales
FROM retail_sales
GROUP BY customer_id
ORDER BY total_sales DESC
LIMIT 5;
```

### 9. Unique Customers per Category

```sql
SELECT
  category,
  COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category;
```

### 10. Orders by Shift (CTE + CASE)

```sql
WITH Hourly AS (
  SELECT *,
    CASE
      WHEN EXTRACT(HOUR FROM sale_time) < 17 THEN 'Morning'
      WHEN EXTRACT(HOUR FROM sale_time) >= 17 OR EXTRACT(HOUR FROM sale_time) <= 1 THEN 'Night'
      ELSE 'No idea'
    END AS shift
  FROM retail_sales
)
SELECT
  shift,
  COUNT(*) AS total_orders
FROM Hourly
GROUP BY shift;
```

## Usage

1. Clone the repository:
   ```bash
   git clone https://github.com/yourusername/sql-retail-sales-analysis.git
   cd sql-retail-sales-analysis
   ```
2. Open the SQL scripts in your preferred client and run them in order.
3. Review the output of each query for insights.

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.

---

*Happy querying!*
