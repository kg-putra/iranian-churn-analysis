/*
========================================================================================================
PROJECT: Customer Health & Retention Analytics
FILE: 01_data_understanding.sql

PURPOSE:
Review the dataset structure, row count, column data types, and observed categorical domains before
performing detailed data-quality validation and treatment decisions.

SOURCE TABLE:
iranian_churn_raw

ANALYTICAL GRAIN:
One row = one customer observation
========================================================================================================
*/


-- Dataset Preview: to review a sample of customer records and understand the overall dataset structure.
SELECT *
FROM iranian_churn_raw
LIMIT 10;


-- Data Count: to identify the total number of customer observations in the dataset.
-- The row count serves as a reference for subsequent data quality and validation checks.
SELECT COUNT(*) AS total_customers
FROM iranian_churn_raw;


-- Data Type Check: to review the data type assigned to each column after import.
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_name = 'iranian_churn_raw'
ORDER BY ordinal_position;

-- Categorical Domain Check: to review observed values and customer counts
-- across categorical and ordinal variables before downstream analysis.

SELECT complains, COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY complains
ORDER BY complains;

SELECT age_group, COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY age_group
ORDER BY age_group;

SELECT tariff_plan, COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY tariff_plan
ORDER BY tariff_plan;

SELECT status, COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY status
ORDER BY status;

SELECT churn, COUNT(*) AS total_customers
FROM iranian_churn_raw
GROUP BY churn
ORDER BY churn;