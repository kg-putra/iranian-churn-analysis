/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 08_dashboard_validation.sql

PURPOSE:
Validate the final analytical view before and after connection to Power BI and confirm that customer
counts, classifications, churn metrics, and retention-priority outputs remain consistent.

SOURCE VIEW:
customer_health_analytics
========================================================================================================
*/


-- Final Row Count: to verify that the analytical view preserves
-- the complete customer population.
SELECT
    COUNT(*) AS total_customers
FROM customer_health_analytics;


-- Overall Churn Validation: to verify that the analytical view
-- reproduces the expected overall churn profile.
SELECT
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,
    COUNT(*) - SUM(churn) AS retained_customers,

    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM customer_health_analytics;


-- Customer Health Validation: to verify customer counts and churn rates
-- across the final health-class hierarchy.
SELECT
    health_class,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,

    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM customer_health_analytics

GROUP BY
    health_class,
    health_class_order

ORDER BY health_class_order;


-- Retention Priority Validation: to confirm the final operational
-- priority distribution used by the Power BI dashboard.

SELECT
    retention_priority,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,

    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM customer_health_analytics

GROUP BY
    retention_priority,
    retention_priority_order

ORDER BY retention_priority_order;


-- Classification Completeness: to verify that every customer receives
-- a valid Customer Health Class and Retention Priority.

SELECT
    COUNT(*) AS invalid_classifications

FROM customer_health_analytics

WHERE
    health_class = 'Unclassified'
    OR retention_priority = 'Review';


-- Derived Feature Completeness: to verify that all analytical
-- classification fields are populated.

SELECT
    COUNT(*) FILTER (
        WHERE tenure_band IS NULL
    ) AS missing_tenure_band,

    COUNT(*) FILTER (
        WHERE call_engagement_band IS NULL
    ) AS missing_engagement_band,

    COUNT(*) FILTER (
        WHERE health_class IS NULL
    ) AS missing_health_class,

    COUNT(*) FILTER (
        WHERE retention_priority IS NULL
    ) AS missing_retention_priority

FROM customer_health_analytics;


-- Dashboard Reference Values:
-- Total Customers         = 3,150
-- Churned Customers       = 495
-- Overall Churn Rate      = 15.71%
--
-- Healthy                 = 754
-- Stable                  = 1,224
-- Watch                   = 307
-- At Risk                 = 620
-- Critical                = 245
--
-- Routine                 = 1,978
-- Preventive              = 307
-- High Priority           = 620
-- Urgent                  = 245
--
-- Invalid Classifications = 0