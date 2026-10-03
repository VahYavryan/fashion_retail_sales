SELECT
	COUNT(*) AS item_purchased,
	payment_method,
	AVG(purchase_amount) AS AVG_amount
FROM fashion.fashion_retail_sales
GROUP BY payment_method;


WITH tiered AS (
    SELECT
        payment_method,
        CASE
            WHEN purchase_amount < 2500 THEN 'cheap'
            ELSE 'expensive'
        END AS price_tier
    FROM fashion.fashion_retail_sales
)
SELECT
	COUNT(*),
	payment_method,
	price_tier
FROM tiered
GROUP BY payment_method, price_tier