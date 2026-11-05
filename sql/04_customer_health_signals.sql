/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 04_customer_health_signals.sql

PURPOSE:
Identify behavioral, service-friction, and activity-state signals that are meaningfully associated with
observed churn and can support the development of a practical Customer Health Framework.

SOURCE TABLE:
iranian_churn_raw

BUSINESS QUESTION:
Which customer behaviors and service-risk signals are most strongly associated with elevated churn?
========================================================================================================
*/


-- Activity Status: to compare observed churn between active and non-active customers.
-- Status is treated as a customer-state signal rather than a causal driver of churn.
SELECT
    status,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY status
ORDER BY status;


-- Complaint Signal: to examine whether customers with recorded complaints
-- show materially different churn outcomes from customers without complaints.
SELECT
    complains,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY complains
ORDER BY complains;


-- Activity Status × Complaint: to evaluate the combined relationship
-- between customer activity state, service friction, and churn.
-- This interaction later informs the At Risk and Critical health classifications.
SELECT
    status,
    complains,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM iranian_churn_raw
GROUP BY status, complains
ORDER BY status, complains;


-- Call Engagement Distribution: to identify empirical quartile thresholds
-- for Frequency of Use and create interpretable engagement bands.
-- These thresholds are dataset-specific analytical boundaries.
SELECT
    percentile_cont(0.25)
        WITHIN GROUP (ORDER BY frequency_of_use) AS p25,

    percentile_cont(0.50)
        WITHIN GROUP (ORDER BY frequency_of_use) AS median,

    percentile_cont(0.75)
        WITHIN GROUP (ORDER BY frequency_of_use) AS p75
		
FROM iranian_churn_raw;


-- Churn by Call Engagement Band: to examine whether lower call engagement
-- is associated with higher observed churn.
-- Thresholds are based on P25 = 27, Median = 54, and P75 = 95.
WITH engagement AS (
    SELECT
        *,
        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band
    FROM iranian_churn_raw
)

SELECT
    call_engagement_band,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM engagement
GROUP BY call_engagement_band
ORDER BY
    CASE call_engagement_band
        WHEN 'No calls' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium-low' THEN 3
        WHEN 'Medium-high' THEN 4
        WHEN 'High' THEN 5
    END;


-- Call Engagement × Activity Status: to test whether call engagement
-- continues to differentiate churn risk within active and non-active customers.
WITH engagement AS (
    SELECT
        *,
        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band
    FROM iranian_churn_raw
)

SELECT
    call_engagement_band,
    status,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM engagement
GROUP BY call_engagement_band, status
ORDER BY
    CASE call_engagement_band
        WHEN 'No calls' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium-low' THEN 3
        WHEN 'Medium-high' THEN 4
        WHEN 'High' THEN 5
    END,
    status;


-- Call Engagement × Complaint: to test whether complaints provide
-- additional risk information across different engagement levels.
WITH engagement AS (
    SELECT
        *,
        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band
    FROM iranian_churn_raw
)

SELECT
    complains,
    call_engagement_band,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM engagement
GROUP BY complains, call_engagement_band
ORDER BY
    complains,
    CASE call_engagement_band
        WHEN 'No calls' THEN 1
        WHEN 'Low' THEN 2
        WHEN 'Medium-low' THEN 3
        WHEN 'Medium-high' THEN 4
        WHEN 'High' THEN 5
    END;


-- Severe Disengagement: to identify customers with no observed call,
-- SMS, or call-duration activity and compare their churn outcomes.
WITH usage_state AS (
    SELECT
        *,
        CASE
            WHEN frequency_of_use = 0
             AND frequency_of_sms = 0
             AND seconds_of_use = 0
            THEN 1
            ELSE 0
        END AS zero_usage_flag
    FROM iranian_churn_raw
)

SELECT
    zero_usage_flag,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct
FROM usage_state
GROUP BY zero_usage_flag
ORDER BY zero_usage_flag;


-- Engagement Variable Correlation: to identify overlap among usage measures.
-- Strong correlation between Seconds of Use and Frequency of Use indicates
-- that both largely represent the same call-engagement construct.
SELECT
    ROUND(
        CORR(seconds_of_use, frequency_of_use)::numeric,
        4
    ) AS seconds_vs_calls,

    ROUND(
        CORR(seconds_of_use, distinct_called_numbers)::numeric,
        4
    ) AS seconds_vs_breadth,

    ROUND(
        CORR(frequency_of_use, distinct_called_numbers)::numeric,
        4
    ) AS calls_vs_breadth,

    ROUND(
        CORR(frequency_of_sms, frequency_of_use)::numeric,
        4
    ) AS sms_vs_calls

FROM iranian_churn_raw;


-- Call Failure Denominator Check: to assess whether raw call failures
-- can reasonably be interpreted relative to total call frequency.
-- Call Failure is retained only as a supporting service-friction signal.
SELECT
    COUNT(*) AS total_customers,

    COUNT(*) FILTER (
        WHERE frequency_of_use = 0
    ) AS zero_call_customers,

    COUNT(*) FILTER (
        WHERE frequency_of_use = 0
          AND call_failure > 0
    ) AS zero_calls_with_failures,

    COUNT(*) FILTER (
        WHERE call_failure > frequency_of_use
    ) AS failures_above_call_frequency

FROM iranian_churn_raw;