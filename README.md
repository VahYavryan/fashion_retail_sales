# Fashion Retail Sales: SQL Customer Behavior Analysis

A SQL practice project that answers six business questions for a fashion retailer using PostgreSQL, Docker and pgAdmin.

## Business context

A fashion retailer wants to know who its best customers are, what drives their spend, and which customers may be drifting away. The data covers **3,400 transactions from 166 customers** between **2022-10-02 and 2023-10-01**.

## Dataset

`Fashion_Retail_Sales.csv`, one row per purchase:

| Column | Description |

|---|---|
| `customer_id` | Customer reference ID (166 unique customers) |
| `item_purchased` | Item type (50 distinct items) |
| `purchase_amount` | Purchase amount in USD |
| `purchase_date` | Date of purchase |
| `review_rating` | Rating from 1 to 5 |
| `payment_method` | Credit Card or Cash |

## **Data quality notes**

- 650 rows (about 19%) have a missing `purchase_amount`.
- 324 rows (about 10%) have a missing `review_rating`.
- Both were handled explicitly in the queries: aggregates skip NULLs, missing ratings get their own `No Rating` group, and rows without an amount are excluded when classifying purchases by price.

## Tech stack

- PostgreSQL 17 (`postgis/postgis:17-3.4` image) in Docker
- pgAdmin 4 in Docker
- Docker Compose
- Data loaded automatically at first start from `init/`

## Project structure

```text
fashion_retail_sales/
├── Data/                        # CSV dataset (not committed)
├── init/
│   └── 01_init.sql              # schema, table, CSV load
├── queries/
│   ├── 01_top_customers_pareto.sql
│   ├── 02_purchase_frequency_segments.sql
│   ├── 03_monthly_sales_trend.sql
│   ├── 04_payment_method_comparison.sql
│   ├── 05_rating_vs_spend.sql
│   └── 06_recency_churn_risk.sql
├── docker-compose.yaml
└── README.md
```

## How to run

1. Create a `.env` file next to `docker-compose.yaml`:

   ```dotenv
   DB_USER=postgres
   DB_PASSWORD=your_password
   DB_NAME=fashion_sales
   PGADMIN_EMAIL=admin@example.com
   PGADMIN_PASSWORD=your_password
   ```

2. Put `Fashion_Retail_Sales.csv` into the `Data/` folder.
3. Start the containers:

4. ```bash
   docker compose up -d
   ```

5. Open pgAdmin at `http://localhost:5051` and register a server with host `db`, port `5432` and the credentials from `.env`.
6. The data is in the `fashion.fashion_retail_sales` table. Run the files from `queries/`.

## Business questions and findings

### 1. Who are the top spenders, and how concentrated is revenue?

`01_top_customers_pareto.sql`

The top 10 customers (6% of 166) generated **$74,430, or 17.27% of total revenue**. Revenue is spread fairly evenly across customers. There is no 80/20 effect, so the business has low dependence on a few big customers, but VIP-only strategies would also reach only a small share of revenue.

### 2. Does buying more often mean spending more?

`02_purchase_frequency_segments.sql`

| Purchase frequency | Avg total spend per customer |

|---|---|

| 1-15 purchases | $1,594 |
| 15-30 purchases | $2,689 |
| 30+ purchases | $3,741 |

Total spend grows steadily with purchase frequency, so frequency is a direct lever on revenue.

### 3. What does monthly sales look like?

`03_monthly_sales_trend.sql`

- **Strongest month:** December 2022 ($46,851).
- **Weakest full month:** September 2023 ($24,492). October 2023 shows only $423 because the dataset ends on 2023-10-01, so it is a partial month and is excluded from the comparison.
- Sales peak in December 2022, dip in January, then build to a second peak in spring (March $39.4k, April $40.2k, May $45.4k) before declining through the summer.

### 4. Does the payment method depend on how expensive the purchase is?

`04_payment_method_comparison.sql`

Purchases with a known amount are split at the median amount into `cheap` and `expensive`, and the share of expensive purchases is compared between Cash and Credit Card.

| Payment method | Purchases with amount | Avg amount | % expensive (median = $110) |

|---|---|---|---|
| Cash | 1,312 | $152.70 | 50.23% |
| Credit Card | 1,438 | $160.37 | 50.14% |

Both methods have almost exactly the same share of expensive purchases, so the **payment method does not depend on the purchase price**. Credit Card purchases are about 5% larger on average, but that is not explained by a shift toward expensive items. There is no data-driven basis for price-based Cash or Card promotions.

### 5. Is there a link between ratings and spend?

`05_rating_vs_spend.sql`

| Rating group | Avg purchase | Purchases with amount |

|---|---|---|
| Bad (< 2.5) | $133.0 | 909 |
| Normal (2.5 to < 3.5) | $139.5 | 635 |
| Good (3.5+) | $172.4 | 943 |
| No rating | $223.8 | 263 |

- Good-rated purchases are about 30% larger than Bad-rated ones. The jump happens mainly in the Good group.
- Purchases with **no rating** have the highest average amount, so the most expensive purchases are the least reviewed. The reason is unknown and worth asking the marketing team.

### 6. Which customers are at risk of churning?

`06_recency_churn_risk.sql`

Recency is measured against the last date in the dataset (2023-10-01).

| Risk group | Days since last purchase | Customers | Avg total purchases |

|---|---|---|---|
| Low | < 20 | 107 | 20.9 |
| Medium | 20-49 | 48 | 20.5 |
| High | 50-79 | 8 | 17.6 |
| Critical | 80+ | 3 | 14.0 |

93% of customers bought within the last 50 days. Only **11 customers (6.6%)** are at risk, so churn is a small, targetable problem rather than a broad one.

## Recommendations

1. **Reward frequency.** Spend rises with purchase count, so loyalty mechanics that encourage repeat visits (for example a reward at a purchase-count milestone) should translate into revenue.
2. **Win back the 11 at-risk customers individually.** The list is small enough for personal outreach, and it can be pulled directly with the recency query.
3. **Improve review collection and data capture.** The biggest purchases are the least reviewed, and about 19% of transactions have no recorded amount. Fixing both would make future revenue and satisfaction analysis more reliable.

## Limitations

- Revenue figures exclude the 650 transactions with a missing amount, so true revenue is higher.
- The at-risk groups are tiny (8 and 3 customers), so their averages are unstable.
- Recency is relative to the dataset end date, not today.
- Rating and payment comparisons are descriptive; no statistical significance tests were run.
- Only 166 customers over one year, so seasonality cannot be separated from a single year's pattern.

## SQL techniques used

CTEs, aggregations with `GROUP BY`, `CASE` bucketing, `COUNT(*) FILTER`, scalar subqueries, median-based thresholds, date arithmetic, explicit NULL handling.
