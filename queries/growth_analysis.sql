WITH monthly_metrics AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) AS month,
        SUM(oi.quantity * oi.unit_price) AS revenue,
        COUNT(DISTINCT o.order_id) AS order_volume,
        COUNT(DISTINCT o.customer_id) AS customer_count,
        SUM(oi.quantity * oi.unit_price) / NULLIF(COUNT(DISTINCT o.order_id), 0) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    month,
    revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY month)) * 100.0 / NULLIF(LAG(revenue) OVER (ORDER BY month), 0), 2) AS rev_growth_pct,
    order_volume,
    ROUND((order_volume - LAG(order_volume) OVER (ORDER BY month)) * 100.0 / NULLIF(LAG(order_volume) OVER (ORDER BY month), 0), 2) AS vol_growth_pct,
    customer_count,
    ROUND(avg_order_value, 2) AS avg_order_value
FROM monthly_metrics
ORDER BY month;

WITH quarterly_metrics AS (
    SELECT 
        DATE_TRUNC('quarter', o.order_date) AS quarter,
        SUM(oi.quantity * oi.unit_price) AS revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    quarter,
    revenue,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY quarter)) * 100.0 / NULLIF(LAG(revenue) OVER (ORDER BY quarter), 0), 2) AS qoq_growth_pct
FROM quarterly_metrics
ORDER BY quarter;