-- 1. Create a new database
CREATE DATABASE banking_analytics;



-- 2. Create all required tables
CREATE TABLE customers (
  customer_id VARCHAR PRIMARY KEY,
  customer_name TEXT,
  contact_email TEXT,
  account_number VARCHAR,
  account_type VARCHAR,
  gender VARCHAR,
  acct_open_date DATE,
  products VARCHAR,
  state_of_residence VARCHAR
);

CREATE TABLE transactions (
  transaction_id VARCHAR PRIMARY KEY,
  customer_id VARCHAR REFERENCES customers(customer_id),
  transaction_date DATE,
  transaction_type VARCHAR,
  transaction_amount NUMERIC,
  channels VARCHAR,
  currency VARCHAR
);

CREATE TABLE channel_metadata (
  channel_name VARCHAR PRIMARY KEY,
  provider TEXT,
  channel_type TEXT,
  active_users INTEGER,
  fees_per_txn NUMERIC
);

CREATE TABLE support_tickets (
  ticket_id VARCHAR PRIMARY KEY,
  customer_id VARCHAR REFERENCES customers(customer_id),
  date_opened DATE,
  issue_type TEXT,
  resolution_time_days INTEGER,
  status VARCHAR
);

---  Stakeholder Question 1: Channel Fee Profitability
-- “Which transaction channel generates the most revenue in fees for the bank overall, 
-- and how does that break down by currency?”






SELECT * FROM channel_metadata
SELECT * FROM customers
SELECT * FROM support_tickets
SELECT * FROM transactions
SELECT * FROM currency_rates


CREATE TABLE currency_rates (
    currency VARCHAR PRIMARY KEY,
    exchange_rate_to_naira NUMERIC
);

-- Insert current rates (per 1 unit) 
INSERT INTO currency_rates (currency, exchange_rate_to_naira) VALUES
  ('Naira', 1.00),
  ('Dollar', 1528.04),   
  ('Pounds', 2073.01),   
  ('Euros', 1580.55),    
  ('Yen', 10.43);         



SELECT 
    t.channels,
    t.currency,
    COUNT(t.transaction_id) AS total_transactions,
    SUM(cm.fees_per_txn * cr.exchange_rate_to_naira) AS Total_Fee_Naira_Equivalent,
    SUM(SUM(cm.fees_per_txn * cr.exchange_rate_to_naira)) OVER (PARTITION BY t.channels) AS Channel_Total_Naira_Equivalent
FROM 
    transactions t
JOIN 
    channel_metadata cm ON t.channels = cm.channel_name
JOIN 
    currency_rates cr ON t.currency = cr.currency
GROUP BY 
    t.channels, t.currency
ORDER BY 
    Channel_Total_Naira_Equivalent DESC, t.currency;



-- 💡 Insights: Channel Fee Profitability (Naira Equivalent)

-- 1. Web is the most profitable channel overall, generating over 84.3 million in fee revenue (Naira equivalent).
--    It performs strongest in Pounds (33.9M), Euros (25.8M), and Dollars (24.3M), with minimal impact from Naira and Yen.
--    Recommendation: Prioritize Web-based infrastructure and cross-border optimization, especially in Europe and UK regions.

-- 2. USSD ranks second with 75.8 million in total fees.
--    Its strength lies in Pounds (30.6M) and Dollars (23.3M), followed by Euros (21.7M). Local currency impact is negligible.
--    Recommendation: USSD is high-performing for cross-currency mobile users. Optimize it for rural and mobile-first audiences.

-- 3. Cards generated 70.9 million, slightly behind USSD.
--    Pound transactions (29.3M) dominate, followed by Euros and Dollars. Local Naira activity remains very small.
--    Recommendation: Continue promoting cards for international spenders. Review potential fee tiering for high-value regions.

-- 4. POS brought in 60.7 million overall, with Pounds (23.5M), Euros (19.7M), and Dollars (17.1M) as top drivers.
--    Suggests strong use in physical or merchant-based cross-border transactions.
--    Recommendation: Maintain support for high-fee POS zones. Target merchant adoption in Pound and Euro regions.

-- 5. Apps generated the least — 34.3 million.
--    Pounds (14.1M), Euros (10.2M), and Dollars (9.7M) lead, but still far behind other channels.
--    Recommendation: Apps have volume but lower monetization. Evaluate fee strategy or focus on retention rather than revenue.

-- ⚠️ Note: Totals represent converted fee values across five currencies using current exchange rates.
--    This view reflects true financial impact in a unified currency (Naira equivalent), not just transaction count.

-- 🎯 Summary:
--    Web and USSD are the bank’s top revenue-generating platforms when normalized for currency.
--    Cards and POS follow closely, with Apps trailing. Currency mix shows heavy reliance on Pound and Euro activity.
--    Recommend focusing on digital channels (Web + USSD), optimizing fee structures, and exploring untapped fee potential in Apps.



-- 2 Who are the top 10 customers by total debit transaction amount in the last 12 months, and what account type and product do they use?

 
WITH recent_debits AS (
    SELECT
        t.customer_id,
        t.currency,
        c.customer_name,
        c.account_type,
        c.products,
        SUM(t.transaction_amount) AS total_original_amount,
        SUM(t.transaction_amount * cr.exchange_rate_to_naira) AS total_debit_amount_naira
    FROM transactions t
    JOIN currency_rates cr ON t.currency = cr.currency
    JOIN customers c ON t.customer_id = c.customer_id
    WHERE 
        t.transaction_type = 'Debit'
        AND t.transaction_date >= CURRENT_DATE - INTERVAL '12 months'
    GROUP BY 
        t.customer_id, t.currency, c.customer_name, c.account_type, c.products
)

SELECT 
    customer_id,
    customer_name,
    account_type,
    products,
    currency,
    total_original_amount,
    total_debit_amount_naira
FROM recent_debits
ORDER BY total_debit_amount_naira DESC
LIMIT 10;


---- Question 3: Channel Preference by Demographics
--- How do male and female customers differ in their usage of channels, especially digital vs physical ones?”


WITH channel_types AS (
    SELECT 'POS' AS channel, 'Physical' AS channel_category UNION
    SELECT 'Cards', 'Physical' UNION
    SELECT 'Web', 'Digital' UNION
    SELECT 'Apps', 'Digital' UNION
    SELECT 'USSD', 'Digital'
),
gender_channel_counts AS (
    SELECT 
        c.gender,
        ct.channel_category,
        COUNT(*) AS txn_count
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    JOIN channel_types ct ON t.channels = ct.channel
    GROUP BY c.gender, ct.channel_category
)

SELECT 
    gender,
    SUM(CASE WHEN channel_category = 'Digital' THEN txn_count ELSE 0 END) AS digital_txns,
    SUM(CASE WHEN channel_category = 'Physical' THEN txn_count ELSE 0 END) AS physical_txns,
    ROUND(100.0 * SUM(CASE WHEN channel_category = 'Digital' THEN txn_count ELSE 0 END) 
          / SUM(txn_count), 2) AS digital_pct,
    ROUND(100.0 * SUM(CASE WHEN channel_category = 'Physical' THEN txn_count ELSE 0 END) 
          / SUM(txn_count), 2) AS physical_pct
FROM gender_channel_counts
GROUP BY gender
ORDER BY gender;

-- 💡 Insights: Gender-Based Channel Preference (Digital vs Physical)

-- 1. Female customers completed 6,125 digital transactions and 4,018 physical transactions in the last period.
--    That means 60.39% of their activity was on digital platforms (Apps, Web, USSD).

-- 2. Male customers completed 5,954 digital transactions and 3,903 physical ones.
--    This gives them a nearly identical digital usage rate of 60.40%.

-- 🎯 Summary:
--    There is no significant gender difference in channel preference.
--    Both male and female customers are using digital platforms at nearly the same rate (~60%).



--- Question 4: Complaint Density by Customer Segment
--- “Which customer product and region combinations have the highest average number of complaints per customer?

SELECT
    c.products,
    c.state_of_residence,
    COUNT(st.ticket_id) AS total_complaints,
    COUNT(DISTINCT c.customer_id) AS total_customers,
    ROUND(COUNT(st.ticket_id) * 1.0 / COUNT(DISTINCT c.customer_id), 2) AS avg_complaints_per_customer
FROM support_tickets st
JOIN customers c ON st.customer_id = c.customer_id
GROUP BY c.products, c.state_of_residence
ORDER BY avg_complaints_per_customer DESC
LIMIT 10;

-- 💡 Insights: Complaint Density by Customer Segment (Product + State)

-- 1. BetterSave customers in Lagos have the highest complaint density at 3.57 complaints per customer.
--    This suggests either service delivery issues or feature mismatch for this product in Lagos.

-- 2. SaveEasy and FamFriends in Lagos also rank high, both above 3.4 complaints per customer.
--    Lagos appears repeatedly across products — indicating broader regional friction, not just product-specific.

-- 3. FamFriends complaints are consistently high across multiple states — Kano, Osun, and Abuja — suggesting a possible product-level problem across regions.

-- 4. FlexMore shows elevated complaint rates in Kaduna and Kano, averaging above 3.3 per customer.
--    Indicates region-specific dissatisfaction, possibly due to infrastructure or support issues.

-- 5. Overall, states like Lagos, Kano, and Delta appear frequently in high-complaint segments, regardless of product.

-- 🎯 Summary:
--    Complaint patterns are influenced by both product and region.
--    Lagos is the top hotspot, and FamFriends has high complaint rates across regions.



--- Question 5: Monthly Resolution Time Trend
--- “What is the monthly average complaint resolution time over the last 12 months? Has it improved?”
SELECT
    DATE_TRUNC('month', date_opened) AS month,
    ROUND(AVG(resolution_time_days), 2) AS avg_resolution_days,
    COUNT(*) AS total_tickets
FROM support_tickets
WHERE 
    date_opened >= CURRENT_DATE - INTERVAL '12 months'
    AND resolution_time_days IS NOT NULL
    AND status = 'Resolved'
GROUP BY month
ORDER BY month;

-- 💡 Insights: Monthly Complaint Resolution Trend

-- 1. The average resolution time fluctuates month by month, mostly staying between 7.5 and 8.7 days.

-- 2. November 2024 had the lowest average resolution time at 6.62 days — the best month for support performance.

-- 3. July 2025 (current month) shows the **worst average resolution time so far** at 9.78 days, although it's based on only 9 tickets. This might skew the average upward.

-- 4. No clear downward trend — average resolution times have remained mostly stable, with slight variation.

-- 📌 Recommendation:
--    - Monitor the spike in July 2025; determine if it's due to staffing, ticket volume, or ticket complexity.
--    - Consider adding target KPIs for resolution time and set alerts when averages exceed 9 days.



--- Question 6: Multi-Currency Risk Profile by Account Type
-- “What percentage of all debit transactions in foreign currencies (non-Naira) came from customers in each account type?”

WITH foreign_debits AS (
    SELECT 
        t.transaction_id,
        c.account_type
    FROM transactions t
    JOIN customers c ON t.customer_id = c.customer_id
    WHERE 
        t.transaction_type = 'Debit'
        AND t.currency <> 'Naira'
)

SELECT 
    account_type,
    COUNT(*) AS foreign_debit_count,
    ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM foreign_debits), 2) AS percentage_of_foreign_debits
FROM foreign_debits
GROUP BY account_type
ORDER BY percentage_of_foreign_debits DESC;


-- 💡 Insights: Foreign Currency Debit Risk by Account Type

-- 1. Current accounts are responsible for 50.91% of all foreign currency debit transactions — just slightly higher than Savings accounts.

-- 2. Savings accounts still contribute a substantial 49.09%, indicating that FX usage is nearly balanced between both account types.

-- 3. The tight margin between account types suggests that **FX-related risk and policy decisions** should be applied to both groups equally.


--- Question 7: Silent Customers
-- “Which customers have not made any transactions in the past 6 months but still have active accounts?”

WITH recent_activity AS (
    SELECT DISTINCT customer_id
    FROM transactions
    WHERE transaction_date >= CURRENT_DATE - INTERVAL '6 months'
)

SELECT 
    c.customer_id,
    c.customer_name,
    c.account_type,
    c.products,
    c.acct_open_date,
    c.state_of_residence
FROM customers c
WHERE c.customer_id NOT IN (SELECT customer_id FROM recent_activity)
ORDER BY acct_open_date;

--- Question 8: Complaint vs Transaction Volume Correlation
-- “Are the customers with the most complaints also among those with the highest number of transactions? Rank them.”

WITH complaint_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS total_complaints
    FROM support_tickets
    GROUP BY customer_id
),

transaction_counts AS (
    SELECT
        customer_id,
        COUNT(*) AS total_transactions
    FROM transactions
    GROUP BY customer_id
)

SELECT 
    c.customer_id,
    cu.customer_name,
    cu.account_type,
    cu.products,
    c.total_complaints,
    t.total_transactions,
    RANK() OVER (ORDER BY c.total_complaints DESC) AS complaint_rank,
    RANK() OVER (ORDER BY t.total_transactions DESC) AS transaction_rank
FROM complaint_counts c
JOIN transaction_counts t ON c.customer_id = t.customer_id
JOIN customers cu ON cu.customer_id = c.customer_id
ORDER BY complaint_rank
LIMIT 30;



-- 💡 Insights: Complaint vs Transaction Volume Correlation

-- 1. Top complaint generators like "Karen Wheeler" and "Natalie Hall" both have the **highest number of complaints (10 each)** 
--    but rank **very low in transaction volume** (#591 and #153 respectively).

-- 2. "Judy Mendoza" and "Crystal Morrow" also appear in the top complaint ranks but are similarly **not top transactors**.

-- 3. A few exceptions exist — e.g., "Jeffery Bennett" has a relatively high transaction count (31) with 7 complaints, 
--    but even that ranks him only #16 in volume.

-- 📉 Overall Trend:
--    The customers with the most complaints are **not the most active customers**.
--    This suggests complaints may not be strongly correlated with usage — other factors (e.g., frustration, complexity, or product experience) may be driving dissatisfaction.














