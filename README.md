# 📊 SQL Case Study: Multi-Channel Banking Analysis

## 🏦 Project Overview  
This project analyzes transactional and operational data from a fictional multi-channel bank. The goal is to extract insights that inform business decisions on revenue optimization, customer behavior, complaint resolution, and risk management. The case study uses PostgreSQL and covers advanced SQL techniques including joins, CTEs, subqueries, and window functions.

---

## 🔍 Business Context  
The bank offers services via various channels like POS, Cards, Web, USSD, and Apps. Customers hold either Savings or Current accounts, and use various financial products. Additionally, customers file complaints, and transactions occur in multiple currencies.

With increasing transaction volumes, support requests, and currency risk exposure, stakeholders need actionable insights to:

- Improve revenue through better fee tracking  
- Understand demographic behaviors  
- Monitor service performance  
- Detect silent customers and product issues  

---

## 🛠️ What I Did  

Simulated a realistic banking dataset with:

- `customers` table (demographics, account/product info)  
- `transactions` table (multi-channel, multi-currency logs)  
- `channel_metadata` (fee mapping by channel)  
- `support_tickets` (customer complaints)  
- `currency_rates` (real-time conversion to Naira)

Created a PostgreSQL database, loaded all tables, and wrote 8 stakeholder-driven SQL queries from intermediate to advanced complexity.

**SQL concepts used:**

- Common Table Expressions (CTEs)  
- Window functions (`RANK()`, `PARTITION BY`)  
- Subqueries  
- Joins (inner joins, anti-joins)  
- Grouping and filtering  
- Date logic with `INTERVAL`

---

## 🚧 Problems Faced  

- **Currency Normalization:** Summarizing fees across multiple currencies distorted insights. Solved using a `currency_rates` conversion table to normalize all values to Naira equivalents.  
- **Channel classification overlap:** Used CTEs to categorize digital vs physical channels consistently.  
- **Insights only from real data:** Ensured all insights were based on actual query results, not assumptions.  
- **Join and data integrity:** Validated all foreign key relationships and cross-table joins.

---

## ✅ Questions Answered  

1. Which channel generates the most revenue in fees (converted to Naira)?  
2. Who are the top 10 customers by total debit amount in the past 12 months?  
3. How do male and female customers differ in digital vs physical channel usage?  
4. Which product and region combinations have the highest complaint density?  
5. What is the monthly average complaint resolution time over the last 12 months?  
6. What percentage of foreign currency debits come from each account type?  
7. Which customers have not made any transactions in the past 6 months?  
8. Are the customers with the most complaints also the highest in transactions?

---

## 💡 Key Insights  

- **Web and USSD** are the most profitable channels (in Naira equivalent), largely due to foreign currency usage (especially Pounds and Euros).  
- **FX transaction risk** is nearly balanced across **Savings** and **Current accounts**.  
- Both **male and female customers** have a ~60% preference for **digital channels**.  
- **Lagos** has the highest complaint density across products, especially **BetterSave**.  
- **Resolution time spiked** in July 2025 — a performance red flag.  
- Most **high-complaint customers are not frequent transactors**, pointing to deeper UX or onboarding issues.  
- Several **silent customers exist** despite active accounts — indicating re-engagement opportunities.

---

## 📌 Recommendations  

- Prioritize **Web and USSD optimization** for fee growth.  
- Introduce **FX usage alerts or limits** for both account types.  
- Strengthen **customer support SLAs**, especially in Lagos.  
- Investigate high-complaint products like **FamFriends** in affected regions.  
- Launch **targeted reactivation campaigns** for dormant customers.  
- Establish **KPIs** for complaint resolution time and transaction activity.
