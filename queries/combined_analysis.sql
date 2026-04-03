WITH category_monthly AS (
    SELECT 
        DATE_TRUNC('month', o.order_date) as month,
        p.category,
        SUM(oi.quantity * oi.unit_price) as cat_revenue
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN products p ON oi.product_id = p.product_id
    GROUP BY 1, 2
)
SELECT 
    month,
    category,
    cat_revenue,
    ROUND(cat_revenue * 100.0 / SUM(cat_revenue) OVER (PARTITION BY month), 2) as market_share_pct,
    ROUND((cat_revenue - LAG(cat_revenue) OVER (PARTITION BY category ORDER BY month)) * 100.0 / 
          NULLIF(LAG(cat_revenue) OVER (PARTITION BY category ORDER BY month), 0), 2) as cat_growth_pct
FROM category_monthly
ORDER BY month, market_share_pct DESC;