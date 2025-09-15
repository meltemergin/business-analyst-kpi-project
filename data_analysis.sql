--- Calculating Total Revenue

SELECT SUM(Revenue) AS total_revenue
FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
WHERE Quantity > 0;

--- Total Revenue: 8911407.904003216

--- Average Order Value (AOV)

SELECT SUM(Quantity * UnitPrice) / COUNT(DISTINCT InvoiceNo) AS avg_order_value
FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
WHERE Quantity > 0;

--- AOV : 480.76218731135174

--- Month-over-Month Growth %

SELECT Month,
       SUM(Quantity * UnitPrice) AS monthly_revenue,
       (SUM(Quantity * UnitPrice) - 
        LAG(SUM(Quantity * UnitPrice)) OVER (ORDER BY Month)) 
        / LAG(SUM(Quantity * UnitPrice)) OVER (ORDER BY Month) * 100 AS growth_rate
FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
WHERE Quantity > 0
GROUP BY Month
ORDER BY Month;

--- Repeat Purchase Rate

SELECT 
  COUNT(DISTINCT CASE WHEN order_count > 1 THEN CustomerID END) * 1.0 /
  COUNT(DISTINCT CustomerID) AS repeat_purchase_rate
FROM (
  SELECT CustomerID, COUNT(DISTINCT InvoiceNo) AS order_count
  FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
  GROUP BY CustomerID
) t;

--- Repeat Purchase Rate : 0.65568103249596676

--- Repeat Purchase Revenue Share

WITH cust_stats AS (
  SELECT
    CustomerID,
    COUNT(DISTINCT InvoiceNo) AS order_count,
    SUM(Quantity * UnitPrice) AS total_revenue
  FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
  GROUP BY CustomerID
)
SELECT
  SAFE_DIVIDE(
    SUM(CASE WHEN order_count > 1 THEN total_revenue ELSE 0 END),
    SUM(total_revenue)
  ) AS repeat_revenue_share   -- fraction (0-1)
FROM cust_stats;

--- Repeat Purchase Revenue Share : 0.93084013910715668

--- Return Rate
SELECT 
  (SELECT COUNT(DISTINCT InvoiceNo) 
   FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-returns`) * 1.0
  /
  (SELECT COUNT(DISTINCT InvoiceNo) 
   FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`) AS return_rate;

--- Return Rate : 0.19712990936555891

--- Top 5 Products by Revenue

SELECT 
  Description AS product_name,
  SUM(Quantity * UnitPrice) AS total_revenue
FROM `capstone-project-371607.e_commerce_dataset_20102011.ecommerce-cleaned`
WHERE Quantity > 0
GROUP BY product_name
ORDER BY total_revenue DESC
LIMIT 5;
