**# Iranian Churn Analysis**



![PostgreSQL]\(https\://img.shields.io/badge/PostgreSQL-Database-336791?logo=postgresql&logoColor=white)

![Power BI]\(https\://img.shields.io/badge/Power_BI-Dashboard-F2C811?logo=powerbi&logoColor=black)

![Status]\(https\://img.shields.io/badge/Status-Completed-success)



**## Overview**

This project analyzes the Iranian Churn Dataset using PostgreSQL for data validation, segmentation analysis, customer-health signal investigation, and retention-priority development, followed by Power BI to build an interactive customer churn and retention dashboard.



The analysis goes beyond descriptive churn reporting by organizing observed customer behavior into a practical Customer Health Framework that supports risk identification and retention prioritization.



**## Analytical Framework**

\`\`\`text

Customer Data

        │

        ▼

Customer Segmentation

        │

        ▼

Customer Health Signals

        │

        ▼

Risk Classification

        │

        ▼

Retention Prioritization

        │

        ▼

Observed Churn Outcome

\`\`\`



The project follows a decision-support approach:

\`\`\`text

Observed Customer Characteristics

        │

        ▼

Health Indicators

        │

        ▼

Risk Detection

        │

        ▼

Retention Prioritization

        │

        ▼

Operational Response

\`\`\`



**## Project Workflow**

\`\`\`text

UCI Iranian Churn Dataset

        │

        ▼

Data Understanding (PostgreSQL)

        │

        ▼

Data Cleaning & Validation

        │

        ▼

Segment & Churn Analysis

        │

        ▼

Customer Health Signal Analysis

        │

        ▼

Customer Value Investigation

        │

        ▼

Customer Health Framework

        │

        ▼

Retention Prioritization

        │

        ▼

Final Analytical View

        │

        ▼

Power BI Dashboard

        │

        ▼

Retention Insights & Actions

\`\`\`



**## Business Objectives**

The main analytical question is:

\> How can observed customer characteristics and behavior be used to identify elevated churn risk and support retention prioritization?



This question is divided into five analytical areas:

1\. Which customer segments show higher or lower observed churn rates?

2\. Which behavioral and service-friction signals are most strongly associated with churn?

3\. Can these signals be organized into a practical Customer Health Framework?

4\. How should churn risk and the available Customer Value measure support retention prioritization?

5\. What operational response is appropriate for each customer-health state?



**## Dataset**

\- Source: UCI Machine Learning Repository — Iranian Churn Dataset

\- Original downloaded file: \`Customer Churn.csv\`

\- Repository file: \`iranian_churn_raw\.csv\`

\- Total customer observations: 3,150

\- Total columns used: 14

\- Analytical grain: one customer observation per row

\- Dataset URL: \<https\://archive.ics.uci.edu/dataset/563/iranian+churn+dataset>



The original file downloaded from UCI was named \`Customer Churn.csv\`. It was renamed to \`iranian_churn_raw\.csv\` for consistent repository and database naming; the rename did not modify the dataset contents.



The source dataset contains customer characteristics and usage behavior aggregated over the first nine months. Churn status represents the customer outcome at the end of month 12, providing a three-month planning gap between the observed behavioral period and churn outcome.



**## Tools Used**

\- PostgreSQL

\- pgAdmin 4

\- Power BI

\- Git & GitHub



**## Project Status**

\- [x] Dataset imported into PostgreSQL

\- [x] Data understanding

\- [x] Data-quality validation

\- [x] Data cleaning decisions

\- [x] Customer segmentation analysis

\- [x] Customer-health signal analysis

\- [x] Customer Value investigation

\- [x] Customer Health Framework

\- [x] Retention-priority framework

\- [x] Final analytical SQL view

\- [x] Dashboard validation

\- [x] Power BI dashboard development

\- [x] Final dashboard documentation

\- [x] Repository finalization



**## Data Understanding**

The raw dataset was first reviewed to validate its analytical structure and determine whether the data was suitable for customer-health and retention analysis.



The validation included:

\- Dataset structure and column types

\- Record count

\- Missing values

\- Categorical domains

\- Numeric ranges

\- Duplicate-like observations

\- Potential semantic inconsistencies

\- Redundant variables



**### Record Validation**

The source dataset contains:

\- Total Customers: 3,150

\- Churned Customers: 495

\- Retained Customers: 2,655

\- Overall Churn Rate: 15.71%



Verification query:

\`\`\`sql

SELECT

    COUNT(\*) AS total_customers,

    SUM(churn) AS churned_customers,

    ROUND(

        100.0 \* SUM(churn) / COUNT(\*),

        2

    ) AS churn_rate_pct

FROM iranian_churn_raw;

\`\`\`



**### Missing Values**

No missing values were identified across the analytical variables.



As a result, no missing-value imputation was required.



**### Duplicate-Like Observations**

The dataset contains multiple records with identical combinations of analytical attributes.



However, the source CSV does not provide a usable unique customer identifier.



Therefore, identical rows were preserved rather than automatically removed, because they cannot be confirmed as duplicate customer records.



**### Charge Amount Validation**

Dataset documentation describes charge_amount as an ordinal variable ranging from 0 to 9.



However, several observations contain:

\`\`\`text

charge_amount = 10

\`\`\`



Because no evidence was available to determine the correct replacement value, these records were retained as undocumented source values rather than modified.



**### Age and Age Group**

The age field maps directly to the ordinal age_group variable:

\| Age Group     | Age       |

\|-----------|-----------|

\| 1     | 15 |

\| 2 | 25 |

\| 3     | 30 |

\| 4     | 45 |

\| 5 | 55 |



Because both variables represent the same underlying construct, age_group is primarily used for customer segmentation.



**## Data Cleaning**

The dataset required limited destructive cleaning.



Rather than modifying valid but ambiguous observations, the project follows a conservative data-quality approach:

\- No customer rows were removed.

\- No missing-value imputation was required.

\- Duplicate-like rows were preserved.

\- Undocumented charge_amount = 10 observations were retained.

\- Original raw variables were preserved.

\- Analytical transformations were implemented as derived features rather than overwriting source data.

This approach maintains traceability between the source dataset and the analytical output.



**## Segment & Churn Analysis**

Customer segmentation analysis was performed to examine how observed churn varies across demographic, commercial, and lifecycle dimensions.



The main dimensions analyzed were:

\- Age Group

\- Tariff Plan

\- Subscription Length

\- Tenure Band

\- Charge Amount

Interaction analyses were also performed across:

\- Tariff Plan × Tenure

\- Tariff Plan × Charge Amount

\- Tenure × Charge Amount



**### Tenure**

Customers were grouped into lifecycle-oriented tenure bands:

\`\`\`text

<12 months

12–23 months

24–35 months

36+ months

\`\`\`



Observed churn rates were:

\| Tenure Band   | Churn Rate |

\|---------------|------------|

\| <12 months    | 41.32%     |

\| 12–23 months  | 3.83%      |

\| 24–35 months  | 18.63%     |

\| 36+ months    | 13.95%     |



Customers with less than 12 months of tenure showed the highest churn rate.



However, churn rate and churn volume were considered separately because a smaller high-risk segment does not necessarily contribute the largest number of churned customers.



**### Tariff Plan**

Observed churn rates were:

\| Tariff Plan   | Churn Rate |

\|---------------|------------|

\| Pay as you go | 16.83%     |

\| Contractual   | 2.45%      |



Pay-as-you-go customers showed substantially higher observed churn than contractual customers.



This relationship is interpreted as an association rather than evidence that tariff structure itself causes churn.



**### Charge Amount**

Lower charge tiers showed substantially higher churn rates, particularly charge_amount = 0.



The variable is treated as an ordinal charge tier, not as a monetary value.



Differences across charge tiers may also reflect unobserved customer characteristics that are not available in the dataset.



**## Customer Health Signal Analysis**

Customer-health analysis focuses on three major dimensions:

\`\`\`text

Engagement Health

Service Friction

Activity State

\`\`\`



A severe-disengagement indicator was also introduced for customers with no observed usage activity.



**### Activity Status**

\| Status        | Churn Rate |

\|-----------|------------|

\| Active        | 5.28%      |

\| Non-Active|   47.31%   |



Non-active customers showed substantially higher observed churn.



**### Complaint Signal**

\| Complaint Status | Churn Rate |

\|------------------|------------|

\| No Complaint     | 10.14%     |

\| Complaint            | 82.99%     |



Customers with recorded complaints had substantially higher churn.



**### Activity Status × Complaint**

The interaction between activity state and complaints produced particularly strong risk separation:

\| Activity Status |     Complaint   |   Churn Rate |

\|-----------------|-------------|--------------|

\| Active              | No Complaint|   2.89%      |

\| Active              | Complaint       |   71.08%     |

\| Non-Active      | No Complaint|       36.70%     |

\| Non-Active      | Complaint   |   89.24%     |



This interaction became an important foundation for the Customer Health Framework.



**### Call Engagement**

\`frequency_of_use\` was selected as the primary call-engagement indicator.



Dataset-specific thresholds were derived from the observed distribution:

\`\`\`text

P25    = 27 calls

Median = 54 calls

P75    = 95 calls

\`\`\`



These thresholds were used to define:

\`\`\`text

No calls

Low

Medium-low

Medium-high

High

\`\`\`



Observed churn decreased considerably as call engagement increased:

\|   Call Engagement   | Churn Rate  |

\|---------------------|-------------|

\|   No calls          | 52.60%      |

\|   Low               | 27.30%      |

\|   Medium-low        | 22.10%      |

\|   Medium-high       | 6.31%       |

\|   High                  | 1.67%       |



**### Zero Usage**

A severe-disengagement flag was defined as:

\`\`\`text

frequency_of_use = 0

AND frequency_of_sms = 0

AND seconds_of_use = 0

\`\`\`



A total of 132 customers met this condition.



Their observed churn rate was:

\`\`\`text

52.27%

\`\`\`



**## Customer Value Investigation**

The dataset contains a calculated customer_value variable, but its exact formula is not documented.



Before using Customer Value as a retention-prioritization dimension, its relationship with observable behavioral variables was investigated.



**### Correlation Analysis**

Customer Value showed particularly strong association with SMS activity:

\`\`\`text

Customer Value × SMS Frequency       = 0.9249

Customer Value × Seconds of Use      = 0.4151

Customer Value × Call Frequency      = 0.4016

Customer Value × Distinct Numbers    = 0.2848

Customer Value × Charge Amount       = 0.1694

\`\`\`



**### Multivariate Investigation**

Two simplified models were examined:

\`\`\`text

Model A: Customer Value \~ SMS Frequency + Seconds of Use

Model B: Customer Value \~ SMS Frequency + Frequency of Use

\`\`\`



Both combinations explained more than 95% of the observed variation in Customer Value.



This suggests that Customer Value substantially overlaps with customer engagement behavior.



Therefore, Customer Value is treated as:

\> **\*\*a dataset-provided behavioral value proxy\*\***



rather than:

\- Revenue

\- Profitability

\- Customer Lifetime Value

\- Independent financial customer value



This distinction prevents engagement behavior from being unintentionally counted twice when determining retention urgency.



**## Customer Health Framework**

Validated customer-health signals were translated into five interpretable health classes:

Healthy

   │

   ▼

Stable

   │

   ▼

Watch

   │

   ▼

At Risk

   │

   ▼

Critical



**### Classification Logic**

The framework prioritizes severe conditions first.

\`\`\`text

Critical

→ Non-active + Complaint

→ Non-active + Zero Usage



At Risk

→ Remaining Complaint customers

→ Remaining Non-active customers



Watch

→ Active

→ No Complaint

→ No Calls / Low Call Engagement



Stable

→ Active

→ No Complaint

→ Medium-low / Medium-high Call Engagement



Healthy

→ Active

→ No Complaint

→ High Call Engagement

\`\`\`



**### Framework Validation**

\|   Health Class        |   Customers   |       Churn Rate  |

\|-------------------|---------------|---------------|

\|   Healthy             |   754         |       1.19%       |

\|   Stable          |   1,224       |   1.88%       |

\|   Watch           |   307             |   11.07%      |

\|   At Risk         |   620             |   38.55%      |

\|   Critical        |   245             |   77.55%      |



The health classes show a broadly monotonic increase in observed churn as customer health deteriorates.



This provides descriptive evidence that the framework meaningfully separates lower-risk and higher-risk customer groups.



However, this is an in-sample descriptive validation, not predictive or out-of-sample model validation.



**## Retention Prioritization**

Customer Health Class is used as the primary determinant of retention urgency.

\|   Health Class        |   Retention Priority  |   Operational Objective           |

\|-------------------|-----------------------|-----------------------------------|

\|   Healthy             |   Routine                 |   Maintain                        |

\|   Stable              |   Routine                 |   Sustain                         |

\|   Watch               |   Preventive          |   Prevent deterioration           |

\|   At Risk             |   High Priority           |   Targeted recovery               |

\|   Critical        |   Urgent              |   Immediate recovery / escalation |



Priority distribution:

\|   Retention Priority  |   Customers   |

\|-----------------------|---------------|

\|   Routine                 |   1,978       |

\|   Preventive          |   307         |

\|   High Priority           |   620         |

\|   Urgent                  |   245         |



Customer Value is retained only as a secondary within-priority ranking signal where operational capacity is limited.



It does not override customer-health severity.



**### CRM Follow-Up Segmentation**

Customer activity state and complaint status were also translated into operational follow-up segments.

\|   CRM Follow-Up Segment       |   Customers   |   Churn Rate  |

\|   Critical Complaint Risk     |       158         |   89.24%      |

\|   Complaint Risk                  |   83          |   71.08%      |

\|   Reactivation Risk           |   624         |   36.70%      |

\|   Routine / Engagement            |   2,285       |   2.89%       |



The corresponding operational objectives are:

\`\`\`text

Critical Complaint Risk

→ Urgent recovery and complaint resolution



Complaint Risk

→ Resolve customer friction



Reactivation Risk

→ Reactivate customer engagement



Routine / Engagement

→ Maintain engagement

\`\`\`



Historical churn is used to validate the risk framework and is not used directly to decide which current customers should be contacted.



**## Final Analytical View**

The final PostgreSQL view:

\`\`\`text

customer_health_analytics

\`\`\`



consolidates the raw customer variables with validated derived analytical features.



Derived variables include:

\`\`\`text

tenure_band

tenure_band_order



call_engagement_band

call_engagement_order



zero_usage_flag


