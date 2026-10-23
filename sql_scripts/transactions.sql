USE retail_analysis;
Select * from transactions;

-- KPI's 
SELECT ROUND(SUM(sales), 0)                        AS total_sales,
       ROUND(SUM(profit), 0)                       AS total_profit,
       COUNT(DISTINCT order_id)                    AS total_orders,
       SUM(quantity)                               AS total_quantity,
       COUNT(DISTINCT customer_id)                 AS total_customers,
       ROUND(SUM(sales) / COUNT(DISTINCT order_id), 2) AS avg_order_value,
       ROUND(SUM(profit) / SUM(sales) * 100, 2)    AS profit_margin_pct
FROM transactions;

-- Q1. Which category earns the most, and what share of total sales does each hold?
SELECT category,
       ROUND(SUM(sales), 0)                     AS total_sales,
       ROUND(SUM(profit), 0)                    AS total_profit,
       ROUND(SUM(profit) / SUM(sales) * 100, 1) AS profit_margin_pct
FROM transactions
GROUP BY category
ORDER BY total_sales DESC;


-- Q3. Which sub-categories are loss-making?
SELECT
  category,
  sub_category,
  ROUND(SUM(sales), 0)                     AS sales,
  ROUND(SUM(profit), 0)                    AS profit,
  ROUND(SUM(profit) / SUM(sales) * 100, 2) AS margin_pct
FROM transactions
GROUP BY category, sub_category
HAVING SUM(profit) < 0
ORDER BY profit;


-- Q4. Does discounting hurt profit? Margin by discount band.
SELECT
  CASE
    WHEN discount = 0    THEN '0% (no discount)'
    WHEN discount <= 0.2 THEN '1-20%'
    WHEN discount <= 0.4 THEN '21-40%'
    ELSE '40%+'
  END                                        AS discount_band,
  COUNT(*)                                   AS line_items,
  ROUND(SUM(sales), 0)                       AS sales,
  ROUND(SUM(profit), 0)                      AS profit,
  ROUND(SUM(profit) / SUM(sales) * 100, 2)   AS margin_pct
FROM transactions
GROUP BY discount_band
ORDER BY MIN(discount);

-- Q5. Which regions perform best, and how do they rank on sales vs. margin?
-- (window functions: RANK)
SELECT
  region,
  ROUND(SUM(sales), 0)                                   AS sales,
  ROUND(SUM(profit), 0)                                  AS profit,
  ROUND(SUM(profit) / SUM(sales) * 100, 2)               AS margin_pct,
  RANK() OVER (ORDER BY SUM(sales) DESC)                 AS sales_rank,
  RANK() OVER (ORDER BY SUM(profit) / SUM(sales) DESC)   AS margin_rank
FROM transactions
GROUP BY region;


-- Q6. How are sales trending year over year? (CTE + LAG)
WITH yearly AS (
  SELECT
    YEAR(order_date)      AS yr,
    SUM(sales)            AS sales,
    SUM(profit)           AS profit
  FROM transactions
  GROUP BY YEAR(order_date)
)
SELECT
  yr,
  ROUND(sales, 0)  AS sales,
  ROUND(profit, 0) AS profit,
  ROUND((sales - LAG(sales) OVER (ORDER BY yr))
        / LAG(sales) OVER (ORDER BY yr) * 100, 1) AS sales_yoy_pct,
  ROUND((profit - LAG(profit) OVER (ORDER BY yr))
        / LAG(profit) OVER (ORDER BY yr) * 100, 1) AS profit_yoy_pct
FROM yearly
ORDER BY yr;


-- Q7. What is the month-over-month trend and cumulative sales? (CTE + LAG + running SUM)
WITH monthly AS (
  SELECT
    DATE_FORMAT(order_date, '%Y-%m') AS ym,
    SUM(sales)                       AS sales
  FROM transactions
  GROUP BY DATE_FORMAT(order_date, '%Y-%m')
)
SELECT
  ym,
  ROUND(sales, 0)                                              AS sales,
  ROUND((sales - LAG(sales) OVER (ORDER BY ym))
        / LAG(sales) OVER (ORDER BY ym) * 100, 1)              AS mom_growth_pct,
  ROUND(SUM(sales) OVER (ORDER BY ym), 0)                      AS cumulative_sales,
  ROUND(AVG(sales) OVER (ORDER BY ym ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 0) AS moving_avg_3m
FROM monthly
ORDER BY ym;


-- Q10. What are the top 3 products by sales in each category? (window: ROW_NUMBER)
SELECT category, product_name, total_sales, rn AS rank_in_category
FROM (
  SELECT
    category,
    product_name,
    ROUND(SUM(sales), 0) AS total_sales,
    ROW_NUMBER() OVER (PARTITION BY category ORDER BY SUM(sales) DESC) AS rn
  FROM transactions
  GROUP BY category, product_name
) t
WHERE rn <= 3
ORDER BY category, rn;


-- Q12. How many customers are repeat buyers vs. one-time buyers, and how do they spend? (CTE)
WITH cust_orders AS (
  SELECT
    customer_id,
    COUNT(DISTINCT order_id) AS orders,
    SUM(sales)               AS sales
  FROM transactions
  GROUP BY customer_id
)
SELECT
  CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END AS customer_type,
  COUNT(*)                                               AS customers,
  ROUND(AVG(orders), 1)                                  AS avg_orders,
  ROUND(AVG(sales), 0)                                   AS avg_spend,
  ROUND(SUM(sales) / SUM(SUM(sales)) OVER () * 100, 1)   AS pct_of_revenue
FROM cust_orders
GROUP BY CASE WHEN orders = 1 THEN 'One-time' ELSE 'Repeat' END;
 
 
 
 -- Q13. How fast do we ship, and which ship mode is slowest?
SELECT
  ship_mode,
  COUNT(DISTINCT order_id)                          AS orders,
  ROUND(AVG(DATEDIFF(ship_date, order_date)), 2)    AS avg_days_to_ship,
  MAX(DATEDIFF(ship_date, order_date))              AS max_days_to_ship
FROM transactions
GROUP BY ship_mode
ORDER BY avg_days_to_ship;


-- Q14. Which 10 states bring in the most sales, and which lose money?
SELECT
  state,
  ROUND(SUM(sales), 0)  AS sales,
  ROUND(SUM(profit), 0) AS profit,
  RANK() OVER (ORDER BY SUM(sales) DESC)  AS sales_rank,
  RANK() OVER (ORDER BY SUM(profit) ASC)  AS loss_rank   -- 1 = biggest loss
FROM transactions
GROUP BY state
ORDER BY sales DESC
LIMIT 10;


-- Q15. Which customers are at risk of churning? (CTE: days since last order vs. data end date)
WITH last_order AS (
  SELECT
    customer_id,
    customer_name,
    MAX(order_date)    AS last_order_date,
    SUM(sales)         AS lifetime_sales,
    COUNT(DISTINCT order_id) AS orders
  FROM transactions
  GROUP BY customer_id, customer_name
)
SELECT
  customer_name,
  last_order_date,
  DATEDIFF((SELECT MAX(order_date) FROM transactions), last_order_date) AS days_inactive,
  orders,
  ROUND(lifetime_sales, 0) AS lifetime_sales
FROM last_order
WHERE DATEDIFF((SELECT MAX(order_date) FROM transactions), last_order_date) >= 180
ORDER BY lifetime_sales DESC
LIMIT 20;
 