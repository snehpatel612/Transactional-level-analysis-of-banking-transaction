# 💳 Banking Analytics Project: Enhancing Customer Profitability, Risk Management & Digital Engagement

## 📌 Project Title
**Improving Customer Profitability, Risk Management, and Digital Engagement through Transaction-Level Analysis in Banking**

---

## 🧠 Overview

This project focuses on leveraging transactional data from a retail bank in Spain (2023–2025) to uncover valuable customer insights and business opportunities. Through comprehensive SQL-based analysis, the project delivers strategic intelligence for optimizing customer engagement, cross-sell initiatives, risk mitigation, and digital adoption.

---

## 🎯 Objectives

- Identify **high-value** and **at-risk** customers using behavioral and financial metrics
- Improve the **accuracy of product recommendations** and marketing alignment
- Analyze **fee revenue patterns** across geographies and segments
- Understand **channel usage trends** to measure digital transformation
- Detect **churn signals** and inactive customers using retention proxies
- Quantify **product diversification** to assess cross-sell potential

---

## 🧾 Dataset Description

- **Source:** Synthetic bank transaction records (2023–2025)
- **Total Records:** 20,000+
- **Stored In:** MySQL database under `bank` schema (`bank_dataset` table)

### 📊 Key Columns

| Column Name           | Description                                               |
|-----------------------|-----------------------------------------------------------|
| TransactionID         | Unique ID for each transaction                            |
| CustomerID            | Unique customer identifier                                |
| TransactionDate       | Timestamp for each transaction                            |
| TransactionType       | Deposit, Withdrawal, Card Payment, Loan Payment, etc.     |
| Amount                | Value of the transaction                                  |
| ProductCategory       | Checking, Savings, Credit Card, Loan, Mortgage, etc.      |
| BranchCity, Lat/Long  | City and location of the transaction                      |
| Channel               | Online, Mobile, ATM, Branch                               |
| CreditCardFees        | Fees from credit card usage                               |
| InsuranceFees         | Insurance-related charges                                 |
| LatePaymentAmount     | Penalties for late payments                               |
| MonthlyIncome         | Customer’s reported income                                |
| CustomerSegment       | Low, Middle, or High-income classification                |
| RecommendedOffer      | Product suggested by bank                                 |

---

## ⚙️ Tools & Technologies

- **Database:** MySQL
- **Language:** SQL (Window Functions, CTEs, Aggregates, Joins)
- **Analytics Techniques:** Customer Segmentation, CLV, Retention, Risk Profiling, Channel Analysis

---

## 🔍 Key SQL Queries & Business Use Cases

| Query No. | Description                                                                                   |
|-----------|-----------------------------------------------------------------------------------------------|
| 1         | Customer Lifetime Value and Transaction Engagement                                            |
| 2         | Monthly Trends & Seasonality by Transaction Type                                              |
| 3         | High Late Fees & Risk Identification                                                          |
| 4         | Channel Preferences across Customer Segments                                                  |
| 5         | Recommendation System vs Actual Product Usage                                                 |
| 6         | City-Level Profitability & Fee Revenue Mapping                                                |
| 7         | Product Usage Mismatch (Churn Signals)                                                        |
| 8         | Foreign Currency Exposure by Product                                                          |
| 9         | Product Category Profitability (Fees Breakdown)                                               |
| 10        | Income vs Spending Ratio (Over-Leverage Detection)                                            |
| 11        | Geographic Fee Contribution Analysis                                                          |
| 12        | Customer Retention Proxy (Tenure in Months)                                                   |
| 14        | Cross-Sell Score: Distinct Product Categories Used by Customer                               |
| 15        | First vs Last Channel Used: Shift from Branch to Digital Channels                            |

---

## 💡 Key Insights

- Identified over 300 customers spending **more than 2x their income**, raising potential credit risks.
- Mapped **regional fee revenue**, revealing top-performing cities.
- Detected **misaligned product offers**, pointing to a need for better recommendation logic.
- Tracked a clear **shift from physical to digital banking channels** over time.
- Quantified **customer retention windows**, highlighting dormant accounts.
- Found **cross-sell opportunities** among customers with single-product usage.



