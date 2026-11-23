# South African Municipal Service Delivery Gap Analysis

## 1. Project Overview

This project investigates differences in basic municipal service delivery across South African municipalities.

It aims to analyse municipal service delivery indicators, identify potential service delivery gaps, and highlight municipalities that may require further investigation and prioritisation.

The analysis will use SQL and PostgreSQL for data management and analysis, and Microsoft Power BI for data visualisation and dashboard development.

## 2. Project Objectives

- Examine municipal service delivery indicators across South Africa.
- Compare service delivery patterns between municipalities and provinces.
- Investigate differences in household service access relative to population.
- Develop a transparent Service Delivery Gap Index using carefully defined indicators.
- Identify municipalities that warrant further investigation and possible intervention.

## 3. Tools and Technologies

- PostgreSQL
- pgAdmin 4
- SQL
- Visual Studio Code
- Microsoft Power BI Desktop
- Git and GitHub

## 4. Planned Data Sources

- Statistics South Africa: Non-Financial Census of Municipalities (P9115).
- Statistics South Africa: Census 2022 household and population data.
- Municipal Demarcation Board: municipality codes and reference information.

## 5. Project Structure

```text
Municipal_Service_Delivery_Analysis/

 data
 sql
 results
 documentation
 powerbi
README.md
```

## 6. Expected Deliverables

- Cleaned and documented municipal datasets.
- SQL scripts for data preparation and analysis.
- Municipal and provincial comparisons.
- A documented Service Delivery Gap Index.
- An interactive Power BI dashboard.
- Project documentation and methodology notes.

## 7. Methodological Considerations

All indicators will be assessed according to their definitions, units of measurement, and available denominators before comparisons are made.

Census 2022 household-based indicators will be the primary measures used to assess service delivery gaps, provided that the relevant definitions and denominators are suitable.

P9115 municipal statistics will provide additional context. Its consumer units or billing units will not be treated as directly equivalent to Census households or individuals, as the two sources use different statistical units and reporting methods.

Population size will be considered separately when identifying the potential scale of service delivery gaps. It will not automatically be incorporated into the Service Delivery Gap Index.

The analysis will distinguish between reported service delivery quantities and household-level access. Findings will be interpreted cautiously, and limitations in the available data will be documented.

The 2022 P9115 figures are revised, while the 2023 figures are preliminary. These distinctions will be retained in the analysis.

## 8. Project Status

Initial software installation, database setup, Git configuration, GitHub repository creation, and project folder structure have been completed.

Data acquisition, validation, preparation, analysis, and dashboard development are upcoming stages.