/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 02_data_cleaning.sql

PURPOSE:
Document data-quality treatment decisions and prepare the raw dataset for downstream analysis while
preserving source information.

SOURCE TABLE:
iranian_churn_raw

CLEANING APPROACH:
- Apply only transformations supported by the available evidence.
- Ambiguous or undocumented values are preserved rather than corrected without justification.
========================================================================================================
*/

-- Missing Value Review: to verify whether missing values require treatment.
-- No missing values were identified, so no imputation or row removal is required.
SELECT
    COUNT(*) FILTER (WHERE call_failure IS NULL) AS null_call_failure,
    COUNT(*) FILTER (WHERE complains IS NULL) AS null_complains,
    COUNT(*) FILTER (WHERE subscription_length IS NULL) AS null_subscription_length,
    COUNT(*) FILTER (WHERE charge_amount IS NULL) AS null_charge_amount,
    COUNT(*) FILTER (WHERE seconds_of_use IS NULL) AS null_seconds_of_use,
    COUNT(*) FILTER (WHERE frequency_of_use IS NULL) AS null_frequency_of_use,
    COUNT(*) FILTER (WHERE frequency_of_sms IS NULL) AS null_frequency_of_sms,
    COUNT(*) FILTER (WHERE distinct_called_numbers IS NULL) AS null_distinct_called_numbers,
    COUNT(*) FILTER (WHERE age_group IS NULL) AS null_age_group,
    COUNT(*) FILTER (WHERE tariff_plan IS NULL) AS null_tariff_plan,
    COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
    COUNT(*) FILTER (WHERE age IS NULL) AS null_age,
    COUNT(*) FILTER (WHERE customer_value IS NULL) AS null_customer_value,
    COUNT(*) FILTER (WHERE churn IS NULL) AS null_churn
FROM iranian_churn_raw;


-- Duplicate-Like Records: exact duplicate feature combinations are reviewed but preserved.
-- Without a unique customer identifier, identical rows cannot be confirmed as duplicate customers.
WITH duplicate_groups AS (
    SELECT
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
        COUNT(*) AS duplicate_count
    FROM iranian_churn_raw
    GROUP BY
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
        churn
    HAVING COUNT(*) > 1
)

SELECT
    COUNT(*) AS duplicate_groups,
    SUM(duplicate_count) AS rows_in_duplicate_groups,
    SUM(duplicate_count - 1) AS excess_duplicate_rows
FROM duplicate_groups;


-- Charge Amount Validation: value 10 is retained even though source metadata describes a 0–9 range.
-- The value is treated as an undocumented source category rather than corrected or removed.
SELECT
    charge_amount,
    COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY charge_amount
ORDER BY charge_amount;


-- Age Redundancy Check: Age maps directly to Age Group in the source dataset.
-- Age Group is therefore preferred for segmentation, while the original Age field is preserved.
SELECT
    age_group,
    age,
    COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY age_group, age
ORDER BY age_group, age;


-- Numeric Range Validation: to confirm that continuous/count variables contain no obvious invalid negative values.
SELECT
    MIN(call_failure) AS min_call_failure,
    MAX(call_failure) AS max_call_failure,

    MIN(subscription_length) AS min_subscription_length,
    MAX(subscription_length) AS max_subscription_length,

    MIN(seconds_of_use) AS min_seconds_of_use,
    MAX(seconds_of_use) AS max_seconds_of_use,

    MIN(frequency_of_use) AS min_frequency_of_use,
    MAX(frequency_of_use) AS max_frequency_of_use,

    MIN(frequency_of_sms) AS min_frequency_of_sms,
    MAX(frequency_of_sms) AS max_frequency_of_sms,

    MIN(distinct_called_numbers) AS min_distinct_called_numbers,
    MAX(distinct_called_numbers) AS max_distinct_called_numbers,

    MIN(customer_value) AS min_customer_value,
    MAX(customer_value) AS max_customer_value
FROM iranian_churn_raw;


-- Cleaning Decision:
-- No rows are removed and no source values are overwritten.
-- The raw table remains unchanged and downstream transformations are implemented
-- as derived analytical features rather than destructive data cleaning.