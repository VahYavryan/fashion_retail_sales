SELECT 
	*
FROM fashion.fashion_retail_sales;

SELECT
	AVG(purchase_amount) AS average_amount,
	COUNT(purchase_amount) AS priced_count, 
	CASE 
		WHEN review_rating IS NULL THEN 'No Rating'
		WHEN review_rating < 2.5 THEN 'Bad Rating'
		WHEN review_rating < 3.5 THEN 'Normal Rating'
		ELSE 'Good Rating'
	END AS rating_group
FROM fashion.fashion_retail_sales
	GROUP BY rating_group
	ORDER BY rating_group;