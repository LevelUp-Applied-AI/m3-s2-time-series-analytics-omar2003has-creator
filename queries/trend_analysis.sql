WITH daily_revenue AS (
    SELECT 
        order_date,
        SUM(oi.quantity * oi.unit_price) as daily_rev,
        COUNT(DISTINCT o.order_id) as daily_orders
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    GROUP BY 1
)
SELECT 
    order_date,
    daily_rev,
    AVG(daily_rev) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as moving_avg_7d,
    AVG(daily_rev) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW) as moving_avg_30d,
    daily_orders,
    AVG(daily_orders) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW) as order_avg_7d
FROM daily_revenue
ORDER BY order_date;