/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 07_final_analytical_view.sql

PURPOSE:
Consolidate validated segmentation, engagement, customer-health, and retention-priority logic into a
reusable customer-level view for downstream Power BI reporting.

SOURCE TABLE:
iranian_churn_raw

OUTPUT VIEW:
customer_health_analytics

ANALYTICAL GRAIN:
One row = one customer observation
========================================================================================================
*/

-- Final Analytical View: to centralize all validated analytical features
-- required for Customer Health, Retention Prioritization, and dashboard reporting.
CREATE OR REPLACE VIEW customer_health_analytics AS

WITH customer_features AS (
    SELECT
        *,

        -- Tenure Band: customer lifecycle grouping used in segmentation analysis.

        CASE
            WHEN subscription_length < 12 THEN '<12 months'
            WHEN subscription_length BETWEEN 12 AND 23 THEN '12–23 months'
            WHEN subscription_length BETWEEN 24 AND 35 THEN '24–35 months'
            ELSE '36+ months'
        END AS tenure_band,

        CASE
            WHEN subscription_length < 12 THEN 1
            WHEN subscription_length BETWEEN 12 AND 23 THEN 2
            WHEN subscription_length BETWEEN 24 AND 35 THEN 3
            ELSE 4
        END AS tenure_band_order,


        -- Call Engagement Band: dataset-specific engagement classification
        -- based on observed Frequency of Use quartiles.

        CASE
            WHEN frequency_of_use = 0 THEN 'No calls'
            WHEN frequency_of_use <= 27 THEN 'Low'
            WHEN frequency_of_use <= 54 THEN 'Medium-low'
            WHEN frequency_of_use <= 95 THEN 'Medium-high'
            ELSE 'High'
        END AS call_engagement_band,

        CASE
            WHEN frequency_of_use = 0 THEN 1
            WHEN frequency_of_use <= 27 THEN 2
            WHEN frequency_of_use <= 54 THEN 3
            WHEN frequency_of_use <= 95 THEN 4
            ELSE 5
        END AS call_engagement_order,


        -- Zero Usage Flag: identifies severe disengagement across call,
        -- SMS, and call-duration activity.

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

        -- Customer Health Classification:
        -- CASE order is intentional because severe conditions are evaluated first.

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
),

prioritized AS (
    SELECT
        *,

        CASE health_class
            WHEN 'Healthy' THEN 1
            WHEN 'Stable' THEN 2
            WHEN 'Watch' THEN 3
            WHEN 'At Risk' THEN 4
            WHEN 'Critical' THEN 5
            ELSE 99
        END AS health_class_order,


        -- Retention Priority: customer-health severity determines
        -- the primary level of operational urgency.

        CASE
            WHEN health_class = 'Critical' THEN 'Urgent'
            WHEN health_class = 'At Risk' THEN 'High Priority'
            WHEN health_class = 'Watch' THEN 'Preventive'
            WHEN health_class IN ('Stable', 'Healthy') THEN 'Routine'
            ELSE 'Review'
        END AS retention_priority

    FROM health_classified
)

SELECT

    -- Raw Customer Attributes

    call_failure,
    complains,
    subscription_length,
    charge_amount,
    seconds_of_use,
    frequency_of_use,
    frequency_of_sms,
    distinct_called_numbers,
    age_group,
    tariff_plan,
    status,
    age,
    customer_value,
    churn,


    -- Derived Analytical Features

    tenure_band,
    tenure_band_order,

    call_engagement_band,
    call_engagement_order,

    zero_usage_flag,

    health_class,
    health_class_order,

    retention_priority,

    CASE retention_priority
        WHEN 'Routine' THEN 1
        WHEN 'Preventive' THEN 2
        WHEN 'High Priority' THEN 3
        WHEN 'Urgent' THEN 4
        ELSE 99
    END AS retention_priority_order

FROM prioritized;