SELECT
	*
FROM fashion.fashion_retail_sales
LIMIT 10;

-- 6_A: At-risk customers list
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(purchase_date) AS last_purchase_date,
        (SELECT MAX(purchase_date) FROM fashion.fashion_retail_sales)
            - MAX(purchase_date) AS days_since_last_purchase,
        COUNT(*) AS total_purchase
    FROM fashion.fashion_retail_sales
    GROUP BY customer_id
)
SELECT customer_id, last_purchase_date, days_since_last_purchase, total_purchase
FROM last_purchase
WHERE days_since_last_purchase >= 50
ORDER BY days_since_last_purchase DESC;

-- 6_B: Risk group summary
WITH last_purchase AS (
    SELECT
        customer_id,
        MAX(purchase_date) AS last_purchase_date,
        (SELECT MAX(purchase_date) FROM fashion.fashion_retail_sales)
            - MAX(purchase_date) AS days_since_last_purchase,
        COUNT(*) AS total_purchase
    FROM fashion.fashion_retail_sales
    GROUP BY customer_id
)
SELECT
    CASE
        WHEN days_since_last_purchase < 20 THEN 'low_risk'
        WHEN days_since_last_purchase < 50 THEN 'medium_risk'
        WHEN days_since_last_purchase < 80 THEN 'high_risk'
        ELSE 'critical'
    END AS risk_group,
    COUNT(*) AS customers,
    ROUND(AVG(total_purchase), 1) AS avg_total_purchases
FROM last_purchase
GROUP BY risk_group
ORDER BY MIN(days_since_last_purchase);