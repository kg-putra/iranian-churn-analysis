/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 03_segment_churn_analysis.sql

PURPOSE:
Examine how observed churn varies across customer demographic, commercial, and lifecycle segments.

SOURCE TABLE:
iranian_churn_raw

BUSINESS QUESTION:
Which customer segments show higher or lower observed churn risk?
========================================================================================================
*/


-- Overall Churn Profile: to establish the baseline churn rate for the full customer population.
-- This serves as the reference point when comparing churn across individual customer segments.
SELECT
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw;


-- Churn by Age Group: to compare observed churn across ordinal customer age segments.
SELECT
    age_group,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY age_group
ORDER BY age_group;


-- Churn by Tariff Plan: to compare observed churn between pay-as-you-go and contractual customers.
-- This helps assess whether commercial plan structure is associated with materially different churn outcomes.
SELECT
    tariff_plan,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY tariff_plan
ORDER BY tariff_plan;


-- Churn by Exact Subscription Length: to examine customer volume and churn at each observed tenure value.
-- Exact tenure is useful for understanding customer-base distribution but may be noisy for risk interpretation.
SELECT
    subscription_length,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY subscription_length
ORDER BY subscription_length;


-- Churn by Tenure Band: to compare broader churn patterns across customer lifecycle stages.
-- Grouping tenure reduces month-level noise and makes risk differences easier to interpret.
WITH tenure_segment AS (
    SELECT
        *,
        CASE
            WHEN subscription_length < 12 THEN '<12 months'
            WHEN subscription_length BETWEEN 12 AND 23 THEN '12–23 months'
            WHEN subscription_length BETWEEN 24 AND 35 THEN '24–35 months'
            ELSE '36+ months'
        END AS tenure_band
    FROM iranian_churn_raw
)

SELECT
    tenure_band,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM tenure_segment
GROUP BY tenure_band
ORDER BY
    CASE tenure_band
        WHEN '<12 months' THEN 1
        WHEN '12–23 months' THEN 2
        WHEN '24–35 months' THEN 3
        WHEN '36+ months' THEN 4
    END;


-- Churn by Charge Amount: to examine how churn varies across ordinal charge tiers.
-- Charge Amount is treated as a tier rather than a monetary amount because the dataset does not provide currency values.
SELECT
    charge_amount,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY charge_amount
ORDER BY charge_amount;


-- Tariff Plan × Tenure: to assess whether tenure-related churn patterns differ across commercial plan types.
WITH tenure_segment AS (
    SELECT
        *,
        CASE
            WHEN subscription_length < 12 THEN '<12 months'
            WHEN subscription_length BETWEEN 12 AND 23 THEN '12–23 months'
            WHEN subscription_length BETWEEN 24 AND 35 THEN '24–35 months'
            ELSE '36+ months'
        END AS tenure_band
    FROM iranian_churn_raw
)

SELECT
    tariff_plan,
    tenure_band,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM tenure_segment
GROUP BY tariff_plan, tenure_band
ORDER BY
    tariff_plan,
    CASE tenure_band
        WHEN '<12 months' THEN 1
        WHEN '12–23 months' THEN 2
        WHEN '24–35 months' THEN 3
        WHEN '36+ months' THEN 4
    END;


-- Tariff Plan × Charge Amount: to examine whether charge-tier churn patterns differ between tariff plans.
SELECT
    tariff_plan,
    charge_amount,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY tariff_plan, charge_amount
ORDER BY tariff_plan, charge_amount;


-- Tenure × Charge Amount: to examine interaction between lifecycle stage and charge tier.
-- This helps identify whether the association between charge tier and churn changes across tenure groups.
WITH tenure_segment AS (
    SELECT
        *,
        CASE
            WHEN subscription_length < 12 THEN '<12 months'
            WHEN subscription_length BETWEEN 12 AND 23 THEN '12–23 months'
            WHEN subscription_length BETWEEN 24 AND 35 THEN '24–35 months'
            ELSE '36+ months'
        END AS tenure_band
    FROM iranian_churn_raw
)

SELECT
    tenure_band,
    charge_amount,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM tenure_segment
GROUP BY tenure_band, charge_amount
ORDER BY
    CASE tenure_band
        WHEN '<12 months' THEN 1
        WHEN '12–23 months' THEN 2
        WHEN '24–35 months' THEN 3
        WHEN '36+ months' THEN 4
    END,
    charge_amount;