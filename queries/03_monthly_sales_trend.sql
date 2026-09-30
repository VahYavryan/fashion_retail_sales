WITH monthly AS(
	SELECT
		TO_CHAR(purchase_date, 'YYYY-MM') AS month,
		SUM(purchase_amount) AS total_sales
	FROM fashion.fashion_retail_sales
	GROUP BY month
	)
(SELECT * FROM monthly ORDER BY total_sales DESC LIMIT 1)
UNION ALL
(SELECT * FROM monthly ORDER BY total_sales ASC LIMIT 1)