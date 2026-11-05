/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 06_health_framework_validation.sql

PURPOSE:
Translate validated behavioral and service-risk signals into an interpretable Customer Health Framework
and evaluate whether the resulting classes meaningfully separate observed churn risk.

SOURCE TABLE:
iranian_churn_raw

CUSTOMER HEALTH FRAMEWORK:
Healthy -> Stable -> Watch -> At Risk -> Critical
========================================================================================================
*/

-- Customer Health Classification: to combine engagement, complaint,
-- activity-state, and severe-disengagement signals into ordinal health classes.
WITH customer_features AS (
    SELECT
        *,

        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band,

        CASE
            WHEN frequency_of_use = 0
             AND frequency_of_sms = 0
             AND seconds_of_use = 0
            THEN 1
            ELSE 0
        END AS zero_usage_flag

    FROM iranian_churn_raw
),

health_classified AS (
    SELECT
        *,

        CASE
            WHEN
                (complains = 1 AND status = 2)
                OR
                (zero_usage_flag = 1 AND status = 2)
            THEN 'Critical'

            WHEN
                complains = 1
                OR status = 2
            THEN 'At Risk'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band IN ('No calls', 'Low')
            THEN 'Watch'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band IN (
                    'Medium-low',
                    'Medium-high'
                )
            THEN 'Stable'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band = 'High'
            THEN 'Healthy'

            ELSE 'Unclassified'
        END AS health_class

    FROM customer_features
)

SELECT
    health_class,
    COUNT(*) AS total_customers,
    SUM(churn) AS churned_customers,

    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct

FROM health_classified

GROUP BY health_class

ORDER BY
    CASE health_class
        WHEN 'Healthy' THEN 1
        WHEN 'Stable' THEN 2
        WHEN 'Watch' THEN 3
        WHEN 'At Risk' THEN 4
        WHEN 'Critical' THEN 5
        ELSE 6
    END;


-- Health Signal Profile: to compare the behavioral and service-risk
-- characteristics of each proposed Customer Health Class.
WITH customer_features AS (
    SELECT
        *,

        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band,

        CASE
            WHEN frequency_of_use = 0
             AND frequency_of_sms = 0
             AND seconds_of_use = 0
            THEN 1
            ELSE 0
        END AS zero_usage_flag

    FROM iranian_churn_raw
),

health_classified AS (
    SELECT
        *,

        CASE
            WHEN
                (complains = 1 AND status = 2)
                OR
                (zero_usage_flag = 1 AND status = 2)
            THEN 'Critical'

            WHEN
                complains = 1
                OR status = 2
            THEN 'At Risk'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band IN ('No calls', 'Low')
            THEN 'Watch'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band IN (
                    'Medium-low',
                    'Medium-high'
                )
            THEN 'Stable'

            WHEN
                status = 1
                AND complains = 0
                AND call_engagement_band = 'High'
            THEN 'Healthy'

            ELSE 'Unclassified'
        END AS health_class

    FROM customer_features
)

SELECT
    health_class,
    COUNT(*) AS total_customers,

    ROUND(
        100.0 * SUM(churn) / COUNT(*),
        2
    ) AS churn_rate_pct,

    ROUND(
        100.0 * SUM(complains) / COUNT(*),
        2
    ) AS complaint_rate_pct,

    ROUND(
        100.0
        * COUNT(*) FILTER (WHERE status = 2)
        / COUNT(*),
        2
    ) AS non_active_rate_pct,

    ROUND(
        100.0 * SUM(zero_usage_flag) / COUNT(*),
        2
    ) AS zero_usage_rate_pct,

    ROUND(
        AVG(frequency_of_use)::numeric,
        2
    ) AS avg_call_frequency,

    ROUND(
        AVG(frequency_of_sms)::numeric,
        2
    ) AS avg_sms_frequency,

    ROUND(
        AVG(customer_value)::numeric,
        2
    ) AS avg_customer_value,

    ROUND(
        percentile_cont(0.50)
        WITHIN GROUP (ORDER BY customer_value)::numeric,
        2
    ) AS median_customer_value

FROM health_classified

GROUP BY health_class

ORDER BY
    CASE health_class
        WHEN 'Healthy' THEN 1
        WHEN 'Stable' THEN 2
        WHEN 'Watch' THEN 3
        WHEN 'At Risk' THEN 4
        WHEN 'Critical' THEN 5
        ELSE 6
    END;


-- Customer Health Validation:
-- A broadly monotonic increase in churn from Healthy to Critical provides
-- descriptive evidence that the framework meaningfully separates customer
-- groups with different observed risk levels.
--
-- This remains an in-sample descriptive validation and should not be
-- interpreted as predictive or out-of-sample model performance.