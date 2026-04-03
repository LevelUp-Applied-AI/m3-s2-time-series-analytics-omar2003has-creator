WITH first_purchases AS (
    SELECT 
        customer_id, 
        order_date AS first_purchase_date,
        DATE_TRUNC('month', order_date) AS cohort_month,
        ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date ASC) AS rn
    FROM orders
),
cohort_definition AS (
    SELECT 
        customer_id, 
        first_purchase_date, 
        cohort_month
    FROM first_purchases
    WHERE rn = 1
),
retention_calc AS (
    SELECT 
        c.cohort_month,
        c.customer_id,
        (o.order_date - c.first_purchase_date) AS days_diff
    FROM cohort_definition c
    JOIN orders o ON c.customer_id = o.customer_id
)
SELECT 
    cohort_month,
    COUNT(DISTINCT customer_id) AS cohort_size,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 0 AND days_diff <= 30 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS retention_30d,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 0 AND days_diff <= 60 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS retention_60d,
    ROUND(COUNT(DISTINCT CASE WHEN days_diff > 0 AND days_diff <= 90 THEN customer_id END) * 100.0 / COUNT(DISTINCT customer_id), 2) AS retention_90d
FROM retention_calc
GROUP BY cohort_month
ORDER BY cohort_month;