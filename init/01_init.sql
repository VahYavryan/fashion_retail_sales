CREATE SCHEMA IF NOT EXISTS fashion;

CREATE TABLE IF NOT EXISTS fashion.fashion_retail_sales (
    customer_id INT,
    item_purchased TEXT,
    purchase_amount NUMERIC,
    purchase_date DATE,
    review_rating NUMERIC,
    payment_method TEXT
);

COPY fashion.fashion_retail_sales(customer_id, item_purchased, purchase_amount, purchase_date, review_rating, payment_method)
FROM '/data/Fashion_Retail_Sales.csv'
DELIMITER ','
CSV HEADER;