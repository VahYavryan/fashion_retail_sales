SELECT
    payment_method,
    COUNT(*) AS all_purchases,
    COUNT(purchase_amount) AS priced_purchases,
    ROUND(AVG(purchase_amount), 2) AS avg_amount
FROM fashion.fashion_retail_sales
GROUP BY payment_method
ORDER BY payment_method;


WITH threshold AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY purchase_amount) AS median_amount
    FROM fashion.fashion_retail_sales
    WHERE purchase_amount IS NOT NULL
),
tiered AS (
    SELECT
        s.payment_method,
        CASE
            WHEN s.purchase_amount < t.median_amount THEN 'cheap'
            ELSE 'expensive'
        END AS price_tier
    FROM fashion.fashion_retail_sales s
    CROSS JOIN threshold t
    WHERE s.purchase_amount IS NOT NULL
)
SELECT
    payment_method,
    COUNT(*) AS priced_purchases,
    COUNT(*) FILTER (WHERE price_tier = 'expensive') AS expensive_count,
    ROUND(
        100.0 * COUNT(*) FILTER (WHERE price_tier = 'expensive') / COUNT(*),
        2
    ) AS pct_expensive
FROM tiered
GROUP BY payment_method
ORDER BY payment_method;