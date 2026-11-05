/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 05_customer_value_investigation.sql

PURPOSE:
Investigate whether the dataset-provided Customer Value metric can be treated as an independent
prioritization dimension or whether it substantially overlaps with observable customer usage behavior.

SOURCE TABLE:
iranian_churn_raw

ANALYTICAL NOTE:
- The original formula for Customer Value is undocumented.
- The objective is not to reconstruct the exact formula, but to evaluate whether Customer Value
provides information independent of engagement.
========================================================================================================
*/


-- Customer Value Correlation: to examine the relationship between
-- Customer Value and observable usage-related variables.
SELECT
    ROUND(
        CORR(customer_value, seconds_of_use)::numeric,
        4
    ) AS corr_seconds,

    ROUND(
        CORR(customer_value, frequency_of_use)::numeric,
        4
    ) AS corr_call_frequency,

    ROUND(
        CORR(customer_value, frequency_of_sms)::numeric,
        4
    ) AS corr_sms,

    ROUND(
        CORR(customer_value, distinct_called_numbers)::numeric,
        4
    ) AS corr_breadth,

    ROUND(
        CORR(customer_value, charge_amount)::numeric,
        4
    ) AS corr_charge

FROM iranian_churn_raw;


-- Individual R-Squared: to estimate how much variation in Customer Value
-- can be explained by each variable through a simple linear relationship.
SELECT
    REGR_R2(
        customer_value,
        seconds_of_use
    ) AS r2_seconds,

    REGR_R2(
        customer_value,
        frequency_of_use
    ) AS r2_call_frequency,

    REGR_R2(
        customer_value,
        frequency_of_sms
    ) AS r2_sms,

    REGR_R2(
        customer_value,
        distinct_called_numbers
    ) AS r2_breadth,

    REGR_R2(
        customer_value,
        charge_amount
    ) AS r2_charge

FROM iranian_churn_raw;


-- Customer Value Residual Analysis: to examine which variables remain
-- associated with unexplained Customer Value after removing the linear SMS component.
WITH sms_model AS (
    SELECT
        REGR_SLOPE(
            customer_value,
            frequency_of_sms
        ) AS slope,

        REGR_INTERCEPT(
            customer_value,
            frequency_of_sms
        ) AS intercept

    FROM iranian_churn_raw
),

residuals AS (
    SELECT
        r.*,

        r.customer_value
            - (
                model.intercept
                + model.slope * r.frequency_of_sms
            ) AS customer_value_residual

    FROM iranian_churn_raw AS r
    CROSS JOIN sms_model AS model
)

SELECT
    REGR_R2(
        customer_value_residual,
        seconds_of_use
    ) AS residual_r2_seconds,

    REGR_R2(
        customer_value_residual,
        frequency_of_use
    ) AS residual_r2_call_frequency,

    REGR_R2(
        customer_value_residual,
        distinct_called_numbers
    ) AS residual_r2_breadth,

    REGR_R2(
        customer_value_residual,
        charge_amount
    ) AS residual_r2_charge,

    REGR_R2(
        customer_value_residual,
        subscription_length
    ) AS residual_r2_subscription_length,

    REGR_R2(
        customer_value_residual,
        call_failure
    ) AS residual_r2_call_failure

FROM residuals;


-- Partial Relationship: Seconds of Use Given SMS.
-- Both Customer Value and Seconds of Use are residualized against SMS
-- to test whether call duration still carries additional information.
WITH sms_models AS (
    SELECT
        REGR_SLOPE(
            customer_value,
            frequency_of_sms
        ) AS y_slope,

        REGR_INTERCEPT(
            customer_value,
            frequency_of_sms
        ) AS y_intercept,

        REGR_SLOPE(
            seconds_of_use,
            frequency_of_sms
        ) AS x_slope,

        REGR_INTERCEPT(
            seconds_of_use,
            frequency_of_sms
        ) AS x_intercept

    FROM iranian_churn_raw
),

residuals AS (
    SELECT
        customer_value
            - (
                model.y_intercept
                + model.y_slope * frequency_of_sms
            ) AS value_residual,

        seconds_of_use
            - (
                model.x_intercept
                + model.x_slope * frequency_of_sms
            ) AS seconds_residual

    FROM iranian_churn_raw
    CROSS JOIN sms_models AS model
)

SELECT
    REGR_R2(
        value_residual,
        seconds_residual
    ) AS partial_r2_seconds_given_sms,

    CORR(
        value_residual,
        seconds_residual
    ) AS partial_corr_seconds_given_sms

FROM residuals;


-- Partial Relationship: Frequency of Use Given SMS.
-- This tests whether call frequency remains informative after controlling
-- for the linear relationship with SMS activity.
WITH sms_models AS (
    SELECT
        REGR_SLOPE(
            customer_value,
            frequency_of_sms
        ) AS y_slope,

        REGR_INTERCEPT(
            customer_value,
            frequency_of_sms
        ) AS y_intercept,

        REGR_SLOPE(
            frequency_of_use,
            frequency_of_sms
        ) AS x_slope,

        REGR_INTERCEPT(
            frequency_of_use,
            frequency_of_sms
        ) AS x_intercept

    FROM iranian_churn_raw
),

residuals AS (
    SELECT
        customer_value
            - (
                model.y_intercept
                + model.y_slope * frequency_of_sms
            ) AS value_residual,

        frequency_of_use
            - (
                model.x_intercept
                + model.x_slope * frequency_of_sms
            ) AS frequency_residual

    FROM iranian_churn_raw
    CROSS JOIN sms_models AS model
)

SELECT
    REGR_R2(
        value_residual,
        frequency_residual
    ) AS partial_r2_frequency_given_sms,

    CORR(
        value_residual,
        frequency_residual
    ) AS partial_corr_frequency_given_sms

FROM residuals;


-- Multivariate Model Comparison: to compare two simplified usage-based
-- explanations of Customer Value.
-- Model A = SMS Frequency + Seconds of Use.
-- Model B = SMS Frequency + Frequency of Use.
WITH correlations AS (
    SELECT
        CORR(
            customer_value,
            frequency_of_sms
        ) AS r_y_sms,

        CORR(
            customer_value,
            seconds_of_use
        ) AS r_y_seconds,

        CORR(
            frequency_of_sms,
            seconds_of_use
        ) AS r_sms_seconds,

        CORR(
            customer_value,
            frequency_of_use
        ) AS r_y_frequency,

        CORR(
            frequency_of_sms,
            frequency_of_use
        ) AS r_sms_frequency

    FROM iranian_churn_raw
),

model_a AS (
    SELECT
        (
            r_y_sms
            - r_y_seconds * r_sms_seconds
        )
        /
        (
            1 - POWER(r_sms_seconds, 2)
        ) AS beta_sms,

        (
            r_y_seconds
            - r_y_sms * r_sms_seconds
        )
        /
        (
            1 - POWER(r_sms_seconds, 2)
        ) AS beta_call_metric,

        r_y_sms,
        r_y_seconds

    FROM correlations
),

model_b AS (
    SELECT
        (
            r_y_sms
            - r_y_frequency * r_sms_frequency
        )
        /
        (
            1 - POWER(r_sms_frequency, 2)
        ) AS beta_sms,

        (
            r_y_frequency
            - r_y_sms * r_sms_frequency
        )
        /
        (
            1 - POWER(r_sms_frequency, 2)
        ) AS beta_call_metric,

        r_y_sms,
        r_y_frequency

    FROM correlations
)

SELECT
    'Model A: SMS + Seconds of Use' AS model,

    ROUND(
        beta_sms::numeric,
        4
    ) AS standardized_beta_sms,

    ROUND(
        beta_call_metric::numeric,
        4
    ) AS standardized_beta_call_metric,

    ROUND(
        (
            beta_sms * r_y_sms
            + beta_call_metric * r_y_seconds
        )::numeric,
        4
    ) AS multiple_r_squared

FROM model_a

UNION ALL

SELECT
    'Model B: SMS + Frequency of Use',

    ROUND(
        beta_sms::numeric,
        4
    ),

    ROUND(
        beta_call_metric::numeric,
        4
    ),

    ROUND(
        (
            beta_sms * r_y_sms
            + beta_call_metric * r_y_frequency
        )::numeric,
        4
    )

FROM model_b;


-- Customer Value Conclusion:
-- SMS Frequency and call activity jointly explain more than 95% of the observed
-- variation in Customer Value. Customer Value is therefore retained as a
-- behavioral-value proxy rather than interpreted as revenue, profitability,
-- Customer Lifetime Value, or another independent financial measure.