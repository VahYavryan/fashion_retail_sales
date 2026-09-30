SELECT
	DISTINCT COUNT(customer_id)
FROM fashion.fashion_retail_sales
LIMIT 10;

WITH customer_agg AS(
SELECT
	customer_id,
	COUNT(*) AS count_purchase,
	SUM(purchase_amount) AS amount_purchase
FROM fashion.fashion_retail_sales
GROUP BY customer_id
)
SELECT
	AVG(amount_purchase),
	CASE 
		WHEN count_purchase BETWEEN 1 AND 14 THEN '1-14 purchases'
		WHEN count_purchase BETWEEN 15 AND 29 THEN '15-29 purchases'
		ELSE '30+ purchases'
	END AS segment
FROM customer_agg
GROUP BY segment
ORDER BY segment;