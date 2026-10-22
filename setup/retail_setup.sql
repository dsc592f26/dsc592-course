-- =====================================================================
-- DSC 592 · Data Engineering · Week 2 retail data setup
--
-- Creates the schema  <your catalog>.retail  with five tables:
--   dim_date      one row per day of 2026
--   dim_product   60 products in 6 categories
--   dim_customer  500 customers (a few have a NULL city on purpose)
--   fact_sales    ~40,000 sales lines, Jan 1 - Oct 10, 2026, with a few promotion spike days
--   stg_customer  tonight's customer file: 40 new, 25 changed, 3 duplicated keys
--
-- How to run (SQL Editor or a SQL notebook, on your SQL warehouse):
--   1. Change dsc592xc on the next line to YOUR catalog (dsc592<init>).
--   2. Run all statements (Ctrl/Cmd + Shift + Enter, or select all and run).
--   3. The last query should list all five tables with their row counts.
-- Safe to rerun: every table is recreated from scratch.
-- =====================================================================

USE CATALOG dsc592xc;                       -- <-- change to your catalog

CREATE SCHEMA IF NOT EXISTS retail
COMMENT 'DSC 592 Demo 2: retail star schema';
USE SCHEMA retail;

-- ---------------------------------------------------------------------
-- dim_date: one row per day, Jan 1 - Dec 31, 2026
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE dim_date AS
SELECT CAST(date_format(d, 'yyyyMMdd') AS INT) AS date_key,
       d                                       AS date,
       year(d)                                 AS year,
       month(d)                                AS month,
       date_format(d, 'EEE')                   AS day_of_week
FROM (SELECT explode(sequence(DATE'2026-01-01', DATE'2026-12-31', INTERVAL 1 DAY)) AS d);

-- ---------------------------------------------------------------------
-- dim_product: 60 products, 10 per category
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE dim_product AS
WITH p AS (
  SELECT id AS product_id,
         element_at(array('Electronics', 'Home', 'Grocery', 'Clothing', 'Sports', 'Toys'),
                    CAST((id - 1) % 6 + 1 AS INT))  AS category,
         CAST((id - 1) DIV 6 + 1 AS INT)            AS k
  FROM (SELECT explode(sequence(1, 60)) AS id)
)
SELECT product_id,
       CASE category
         WHEN 'Electronics' THEN element_at(array('Headphones', 'Phone Charger', 'Laptop Stand', 'Webcam', 'Bluetooth Speaker',
                                                  'USB Hub', 'Keyboard', 'Mouse', 'Monitor', 'Smartwatch'), k)
         WHEN 'Home'        THEN element_at(array('Coffee Maker', 'Desk Lamp', 'Throw Pillow', 'Bath Towel', 'Cookware Set',
                                                  'Blender', 'Wall Clock', 'Storage Bin', 'Area Rug', 'Candle'), k)
         WHEN 'Grocery'     THEN element_at(array('Coffee Beans', 'Olive Oil', 'Pasta', 'Granola', 'Green Tea',
                                                  'Dark Chocolate', 'Honey', 'Rice', 'Almonds', 'Sparkling Water'), k)
         WHEN 'Clothing'    THEN element_at(array('T-Shirt', 'Jeans', 'Hoodie', 'Rain Jacket', 'Sneakers',
                                                  'Socks', 'Baseball Cap', 'Sweater', 'Shorts', 'Scarf'), k)
         WHEN 'Sports'      THEN element_at(array('Yoga Mat', 'Dumbbells', 'Tennis Balls', 'Water Bottle', 'Bike Helmet',
                                                  'Running Shorts', 'Jump Rope', 'Basketball', 'Soccer Ball', 'Fitness Tracker'), k)
         ELSE                    element_at(array('Puzzle', 'Building Blocks', 'Board Game', 'Plush Bear', 'Toy Car',
                                                  'Art Kit', 'Kite', 'Card Game', 'Science Kit', 'Doll'), k)
       END AS product_name,
       category,
       CAST(CASE category
              WHEN 'Electronics' THEN 15 + pmod(hash(product_id, 'price'), 23500) / 100.0   -- 15 to 250
              WHEN 'Home'        THEN 10 + pmod(hash(product_id, 'price'), 14000) / 100.0   -- 10 to 150
              WHEN 'Grocery'     THEN  3 + pmod(hash(product_id, 'price'),  2200) / 100.0   --  3 to 25
              WHEN 'Clothing'    THEN 10 + pmod(hash(product_id, 'price'),  9000) / 100.0   -- 10 to 100
              WHEN 'Sports'      THEN  8 + pmod(hash(product_id, 'price'), 12000) / 100.0   --  8 to 128
              ELSE                     6 + pmod(hash(product_id, 'price'),  6000) / 100.0   --  6 to 66
            END AS DECIMAL(10, 2)) AS list_price
FROM p;

-- ---------------------------------------------------------------------
-- Helper view: generated customer attributes for ids 1-540
-- (1-500 become dim_customer, 501-540 are tonight's new customers)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TEMP VIEW cust_gen AS
WITH k AS (
  SELECT customer_id,
         pmod(hash(customer_id, 'first'), 20) + 1 AS fi,
         pmod(hash(customer_id, 'last'),  20) + 1 AS li,
         pmod(hash(customer_id, 'city'),  15) + 1 AS ci,
         pmod(hash(customer_id, 'seg'),    3) + 1 AS si
  FROM (SELECT explode(sequence(1, 540)) AS customer_id)
),
names AS (
  SELECT array('Ava', 'Ben', 'Chloe', 'Daniel', 'Emma', 'Felix', 'Grace', 'Henry', 'Isla', 'Jack',
               'Kira', 'Liam', 'Maya', 'Noah', 'Olivia', 'Owen', 'Priya', 'Ryan', 'Sofia', 'Zoe') AS firsts,
         array('Adams', 'Brown', 'Chen', 'Davis', 'Garcia', 'Hall', 'Johnson', 'Kim', 'Lee', 'Lopez',
               'Martin', 'Nguyen', 'Patel', 'Reed', 'Smith', 'Taylor', 'Turner', 'Walker', 'White', 'Young') AS lasts,
         array('Wilmington', 'Raleigh', 'Charlotte', 'Durham', 'Atlanta', 'Savannah', 'Charleston', 'Columbia',
               'Richmond', 'Norfolk', 'Nashville', 'Orlando', 'Miami', 'Austin', 'Houston') AS cities,
         array('NC', 'NC', 'NC', 'NC', 'GA', 'GA', 'SC', 'SC',
               'VA', 'VA', 'TN', 'FL', 'FL', 'TX', 'TX') AS states,
         array('Consumer', 'Corporate', 'SMB') AS segments
)
SELECT k.customer_id,
       concat(element_at(n.firsts, k.fi), ' ', element_at(n.lasts, k.li)) AS name,
       element_at(n.cities,   k.ci)          AS city,
       element_at(n.states,   k.ci)          AS state,
       element_at(n.cities,   k.ci % 15 + 1) AS city2,      -- a different city, used for "moved" customers
       element_at(n.states,   k.ci % 15 + 1) AS state2,
       element_at(n.segments, k.si)          AS segment,
       element_at(n.segments, k.si % 3 + 1)  AS segment2,   -- a different segment
       timestampadd(HOUR, pmod(hash(k.customer_id, 'upd'), 8760), TIMESTAMP'2025-01-01 00:00:00') AS updated_at
FROM k CROSS JOIN names n;

-- ---------------------------------------------------------------------
-- dim_customer: 500 customers; about 3% have a NULL city (realistic gaps)
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE dim_customer AS
SELECT customer_id,
       name,
       CASE WHEN pmod(hash(customer_id, 'nullcity'), 33) = 0 THEN NULL ELSE city END AS city,
       state,
       segment,
       updated_at
FROM cust_gen
WHERE customer_id <= 500;

-- ---------------------------------------------------------------------
-- fact_sales: 20,000 orders with 1-3 lines each, Jan 1 - Oct 10, 2026.
-- About 10% of orders fall on four promotion days, which show up as revenue spikes.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE fact_sales AS
WITH orders AS (
  SELECT order_id,
         1 + pmod(hash(order_id, 'cust'), 500) AS customer_id,
         CASE WHEN pmod(hash(order_id, 'promo'), 10) = 0
              THEN element_at(array(DATE'2026-02-14', DATE'2026-05-25', DATE'2026-07-04', DATE'2026-09-07'),
                              pmod(hash(order_id, 'pday'), 4) + 1)
              ELSE date_add(DATE'2026-01-01', pmod(hash(order_id, 'day'), 283))
         END AS order_date,
         1 + pmod(hash(order_id, 'lines'), 3) AS n_lines
  FROM (SELECT explode(sequence(1, 20000)) AS order_id)
),
lines AS (
  SELECT o.order_id, o.customer_id, o.order_date,
         explode(sequence(1, o.n_lines)) AS line_no
  FROM orders o
),
priced AS (
  SELECT l.*,
         1 + pmod(hash(l.order_id, l.line_no, 'prod'), 60) AS product_id,
         1 + pmod(hash(l.order_id, l.line_no, 'qty'),   4) AS quantity,
         pmod(hash(l.order_id, l.line_no, 'disc'), 4)      AS discount_steps   -- 0, 5, 10 or 15% off
  FROM lines l
)
SELECT CAST(x.order_id * 10 + x.line_no AS BIGINT)                      AS sale_id,
       x.order_id,
       x.customer_id,
       x.product_id,
       CAST(date_format(x.order_date, 'yyyyMMdd') AS INT)                AS date_key,
       x.quantity,
       CAST(p.list_price * (1 - 0.05 * x.discount_steps) AS DECIMAL(10, 2)) AS unit_price,
       CAST(x.quantity * p.list_price * (1 - 0.05 * x.discount_steps) AS DECIMAL(12, 2)) AS amount
FROM priced x
JOIN dim_product p ON x.product_id = p.product_id;

-- ---------------------------------------------------------------------
-- stg_customer: tonight's customer file (2026-10-06)
--   40 new customers (501-540), 25 changed customers (every 20th id: moved city,
--   some also changed segment), and 3 duplicated keys (20, 40, 60) with an older row.
-- ---------------------------------------------------------------------
CREATE OR REPLACE TABLE stg_customer AS
SELECT customer_id, name, city, state, segment,
       timestampadd(MINUTE, customer_id, TIMESTAMP'2026-10-06 06:00:00') AS updated_at
FROM cust_gen
WHERE customer_id BETWEEN 501 AND 540
UNION ALL
SELECT customer_id, name, city2 AS city, state2 AS state,
       CASE WHEN customer_id % 40 = 0 THEN segment2 ELSE segment END AS segment,
       timestampadd(MINUTE, customer_id, TIMESTAMP'2026-10-06 12:00:00') AS updated_at
FROM cust_gen
WHERE customer_id <= 500 AND customer_id % 20 = 0
UNION ALL
SELECT customer_id, name, city, state, segment2 AS segment,
       TIMESTAMP'2026-10-06 03:00:00' AS updated_at                    -- older duplicate row
FROM cust_gen
WHERE customer_id IN (20, 40, 60);

DROP VIEW IF EXISTS cust_gen;

-- ---------------------------------------------------------------------
-- Check: expected about 365 / 60 / 500 / ~40,000 / 68 rows
-- ---------------------------------------------------------------------
SELECT 'dim_date'     AS table_name, COUNT(*) AS n_rows FROM dim_date
UNION ALL SELECT 'dim_product',  COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'fact_sales',   COUNT(*) FROM fact_sales
UNION ALL SELECT 'stg_customer', COUNT(*) FROM stg_customer;
