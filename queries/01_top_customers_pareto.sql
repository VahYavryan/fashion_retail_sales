WITH top_10 AS (
	SELECT
		customer_id,
		SUM(purchase_amount) AS revenue
	FROM fashion.fashion_retail_sales
		GROUP BY customer_id
		ORDER BY revenue DESC
		LIMIT 10
	),
total AS (SELECT
	SUM(purchase_amount) AS total_revenue
FROM fashion.fashion_retail_sales)

SELECT
	SUM(top_10.revenue) AS top_10_revenue,
	ROUND(SUM(top_10.revenue) * 100.0 / total.total_revenue, 2) AS top_10_percentage
FROM top_10, total
GROUP BY total.total_revenue;