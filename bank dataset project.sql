use bank;

-- fixing the transaction date column
UPDATE bank_dataset
SET TransactionDate = DATE_FORMAT(STR_TO_DATE(TransactionDate, '%d-%m-%Y %H:%i:%s'), '%Y-%m-%d');

ALTER TABLE bank_dataset
MODIFY COLUMN TransactionDate DATE;

DESCRIBE bank_dataset;
SELECT TransactionDate FROM bank_dataset LIMIT 5;

use bank;

-- 1. Customer Lifetime Value and Engagement Pattern
SELECT 
    CustomerID,
    SUM(Amount) AS TotalAmount,
    COUNT(*) AS TransactionCount,
    RANK() OVER (ORDER BY SUM(Amount)DESC) AS RankByValue
FROM 
    bank_dataset
GROUP BY CustomerID;

-- 2. Monthly Trends and Seasonality
SELECT 
    DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
    TransactionType,
    COUNT(*) AS Transactions,
    SUM(Amount) AS TotalAmount
FROM 
    bank_dataset
GROUP BY 
    Month, TransactionType
ORDER BY 
    Month,Transactions, TransactionType;

--  3. Risk Flags – High Fees and Late Payments
WITH RiskyLatePayers AS (
    SELECT 
        CustomerID,
        COUNT(*) AS LateFeeCount,
        ROUND(SUM(LatePaymentAmount), 2) AS TotalLateFees,
        ROUND(AVG(MonthlyIncome), 2) AS AvgIncome
    FROM bank_dataset
    WHERE LatePaymentAmount > 50
    GROUP BY CustomerID
    HAVING COUNT(*) > 2
)
SELECT *
FROM RiskyLatePayers
ORDER BY TotalLateFees DESC;

-- 4. Channel Effectiveness and Customer Preference
SELECT 
    CustomerSegment,
    Channel,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalAmount
FROM 
    bank_dataset
GROUP BY 
    CustomerSegment, Channel
order by 
	CustomerSegment;
    
-- 5. Recommendation System Effectiveness
SELECT 
    RecommendedOffer,
    COUNT(*) AS OfferCount,
    SUM(CASE WHEN TransactionType = 'Card Payment' THEN Amount ELSE 0 END) AS TotalCardPayments,
    AVG(MonthlyIncome) AS AvgIncome
FROM 
    bank_dataset
GROUP BY 
    RecommendedOffer
ORDER BY 
    TotalCardPayments DESC;
    
-- 6. City-Level Profitability and Geographical Patterns
SELECT 
    BranchCity,
    COUNT(*) AS TotalTransactions,
    SUM(Amount) AS TotalTransactionAmount,
    SUM(CreditCardFees + InsuranceFees + LatePaymentAmount) AS TotalFees
FROM 
    bank_dataset
GROUP BY BranchCity
ORDER BY TotalFees DESC;

--  7. Customer Churn Signals
WITH ProductUsage AS (
    SELECT 
        CustomerID, 
        ProductCategory, 
        COUNT(*) AS UsageCount,
        RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(*) DESC) AS rnk
    FROM bank_dataset
    GROUP BY CustomerID, ProductCategory
),
TopProduct AS (
    SELECT CustomerID, ProductCategory AS MostUsedProduct
    FROM ProductUsage
    WHERE rnk = 1
),
OfferMapped AS (
    SELECT 
        CustomerID,
        RecommendedOffer,
        CASE
            WHEN RecommendedOffer LIKE '%Savings%' THEN 'Savings Account'
            WHEN RecommendedOffer LIKE '%Loan%' THEN 'Loan'
            WHEN RecommendedOffer LIKE '%Card%' THEN 'Credit Card'
            WHEN RecommendedOffer LIKE '%Investment%' THEN 'Savings Account'
            WHEN RecommendedOffer LIKE '%Account%' THEN 'Checking Account'
            ELSE 'Other'
        END AS MappedProduct
    FROM bank_dataset
),
Mismatch AS (
    SELECT 
        t.CustomerID,
        t.MostUsedProduct,
        o.MappedProduct,
        o.RecommendedOffer
    FROM TopProduct t
    JOIN OfferMapped o ON t.CustomerID = o.CustomerID
    GROUP BY t.CustomerID, t.MostUsedProduct, o.MappedProduct, o.RecommendedOffer
    HAVING t.MostUsedProduct != o.MappedProduct
)
SELECT * FROM Mismatch;


-- 8. Currency and FX Exposure Analysis
SELECT 
    Currency,
    ProductCategory,
    COUNT(*) AS TransactionCount,
    SUM(Amount) AS TotalAmount
FROM 
    bank_dataset
GROUP BY Currency, ProductCategory
order by ProductCategory;

-- 9. Product Category Profitability
SELECT 
    ProductCategory,
    ProductSubcategory,
    SUM(CreditCardFees + InsuranceFees + LatePaymentAmount) AS TotalFees
FROM 
    bank_dataset
GROUP BY 
    ProductCategory, ProductSubcategory
ORDER BY 
    TotalFees DESC;
-- Query 11: Detect Income vs Spending Mismatch (Potential Over-Leverage)
WITH Spending AS (
    SELECT 
        CustomerID,
        ROUND(SUM(CASE WHEN TransactionType IN ('Card Payment', 'Withdrawal', 'Transfer', 'Loan Payment') THEN Amount ELSE 0 END), 2) AS TotalSpending,
        ROUND(AVG(MonthlyIncome), 2) AS AvgIncome
    FROM bank_dataset
    GROUP BY CustomerID
)
SELECT *,
       ROUND(TotalSpending / AvgIncome, 2) AS SpendToIncomeRatio
FROM Spending
WHERE TotalSpending > AvgIncome * 2
ORDER BY SpendToIncomeRatio DESC;

-- Query 12: Geographical Trends in Fee Revenue
WITH CityFees AS (
    SELECT 
        BranchCity,
        ROUND(SUM(CreditCardFees + InsuranceFees + LatePaymentAmount), 2) AS TotalFees
    FROM bank_dataset
    GROUP BY BranchCity
),
TotalBankFees AS (
    SELECT ROUND(SUM(CreditCardFees + InsuranceFees + LatePaymentAmount), 2) AS BankTotalFees
    FROM bank_dataset
)
SELECT 
    c.BranchCity,
    c.TotalFees,
    CONCAT(ROUND(c.TotalFees / t.BankTotalFees * 100, 2), '%') AS FeeContribution
FROM CityFees c, TotalBankFees t
ORDER BY TotalFees DESC;

-- Query 13: Customer Retention Proxy (Months Active)
WITH CustomerActivity AS (
    SELECT 
        CustomerID,
        MIN(DATE(TransactionDate)) AS FirstTxn,
        MAX(DATE(TransactionDate)) AS LastTxn
    FROM bank_dataset
    GROUP BY CustomerID
)
SELECT 
    CustomerID,
    FirstTxn,
    LastTxn,
    TIMESTAMPDIFF(MONTH, FirstTxn, LastTxn) AS MonthsActive
FROM CustomerActivity
ORDER BY MonthsActive DESC;

--  Query 14: Product Cross-Sell Score
WITH ProductCounts AS (
    SELECT CustomerID, COUNT(DISTINCT ProductCategory) AS UniqueProducts
    FROM bank_dataset
    GROUP BY CustomerID
)
SELECT *
FROM ProductCounts
WHERE UniqueProducts >= 3
ORDER BY UniqueProducts DESC;

-- Query 15: First vs Last Channel Usage (Shift to Digital?)
WITH RankedTxn AS (
    SELECT 
        CustomerID,
        Channel,
        TransactionDate,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TransactionDate ASC) AS FirstUse,
        ROW_NUMBER() OVER (PARTITION BY CustomerID ORDER BY TransactionDate DESC) AS LastUse
    FROM bank_dataset
),
FirstLast AS (
    SELECT 
        CustomerID,
        MAX(CASE WHEN FirstUse = 1 THEN Channel END) AS FirstChannel,
        MAX(CASE WHEN LastUse = 1 THEN Channel END) AS LastChannel
    FROM RankedTxn
    GROUP BY CustomerID
)
SELECT *
FROM FirstLast
WHERE FirstChannel != LastChannel;

-- Query 16: Detect Monthly Growth/Decline in Card Payments
WITH MonthlyCardTxn AS (
    SELECT 
        DATE_FORMAT(TransactionDate, '%Y-%m') AS Month,
        COUNT(*) AS CardPaymentCount
    FROM bank_dataset
    WHERE TransactionType = 'Card Payment'
    GROUP BY Month
),
Growth AS (
    SELECT 
        Month,
        CardPaymentCount,
        LAG(CardPaymentCount) OVER (ORDER BY Month) AS PrevMonthCount,
        ROUND(
            (CardPaymentCount - LAG(CardPaymentCount) OVER (ORDER BY Month)) / 
            LAG(CardPaymentCount) OVER (ORDER BY Month) * 100, 2
        ) AS GrowthPct
    FROM MonthlyCardTxn
)
SELECT * FROM Growth;


-- CTE Process
WITH
-- 1. Count transaction types per customer
TransactionTypeRanked AS (
    SELECT
        CustomerID,
        TransactionType,
        COUNT(*) AS TxnTypeCount,
        RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(*) DESC) AS TxnTypeRank
    FROM bank_dataset
    GROUP BY CustomerID, TransactionType
),

-- 2. Count channel usage per customer
ChannelRanked AS (
    SELECT
        CustomerID,
        Channel,
        COUNT(*) AS ChannelCount,
        RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(*) DESC) AS ChannelRank
    FROM bank_dataset
    GROUP BY CustomerID, Channel
),

-- 3. Count most used city per customer
CityRanked AS (
    SELECT
        CustomerID,
        BranchCity,
        COUNT(*) AS CityCount,
        RANK() OVER (PARTITION BY CustomerID ORDER BY COUNT(*) DESC) AS CityRank
    FROM bank_dataset
    GROUP BY CustomerID, BranchCity
),

-- 4. Average transaction amount per customer
AvgAmount AS (
    SELECT
        CustomerID,
        ROUND(AVG(Amount), 2) AS AvgTransactionAmount
    FROM bank_dataset
    GROUP BY CustomerID
)

-- Final output: merge all
SELECT
    a.CustomerID,
    t.TransactionType AS MostUsedTransactionType,
    c.Channel AS PreferredChannel,
    a.AvgTransactionAmount,
    ci.BranchCity AS MostFrequentCity
FROM
    AvgAmount a
LEFT JOIN TransactionTypeRanked t
    ON a.CustomerID = t.CustomerID AND t.TxnTypeRank = 1
LEFT JOIN ChannelRanked c
    ON a.CustomerID = c.CustomerID AND c.ChannelRank = 1
LEFT JOIN CityRanked ci
    ON a.CustomerID = ci.CustomerID AND ci.CityRank = 1
ORDER BY a.CustomerID;












