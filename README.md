# South African Municipal Service Delivery Gap Analysis

## 1. Project Overview

This project investigates differences in basic municipal service delivery across South African municipalities using data from Statistics South Africa's Non-Financial Census of Municipalities (P9115).

The project aims to identify service delivery disparities, examine historical trends, and highlight areas that may require further investigation and prioritisation.

SQL and PostgreSQL will be used for data management and analysis, while Microsoft Power BI will be used for data visualisation and dashboard development.

## 2. Project Objectives

- Examine municipal service delivery indicators across South Africa.
- Compare service delivery patterns across municipalities, districts and provinces, subject to available geographic detail.
- Analyse changes in municipal service delivery between 2022 and 2023.
- Investigate historical provincial service delivery trends from 2006 to 2023.
- Examine electricity, water, sanitation and solid waste management indicators.
- Develop a transparent Service Delivery Gap Index, subject to the availability of suitable indicators.
- Identify areas that warrant further investigation and possible intervention.

## 3. Tools and Technologies

- PostgreSQL
- pgAdmin 4
- SQL
- Visual Studio Code
- Microsoft Power BI Desktop
- Microsoft Excel
- Git and GitHub

## 4. Data Sources

Statistics South Africa: Non-Financial Census of Municipalities (P9115).

The project uses the following source files:

- `unit data by province and district_2022_2023.xlsx`
- `mainP91152023.PDF`
- `p9115_Time series 2006 - 2023_by province_final.xlsx`

The official statistical publication will be used to understand indicator definitions, methodology and data limitations.

## 5. Project Structure

```text
Municipal_Service_Delivery_Analysis/
-data
   raw       
     P9115
-sql
-results
-documentation
-powerbi
- README.md
```

## 6. Expected Deliverables

- Cleaned and documented municipal datasets.
- SQL scripts for data preparation and analysis.
- Municipal, district and provincial comparisons, where supported.
- Historical service delivery trend analysis.
- A documented Service Delivery Gap Index, where methodologically feasible.
- An interactive Power BI dashboard.
- Analytical findings and recommendations.
- Project documentation and methodology notes.

## 7. Methodological Considerations

All indicators will be assessed according to their definitions, units of measurement, geographic coverage and available denominators before comparisons are made.

P9115 measures municipal-reported service delivery statistics. Consumer units will not automatically be treated as equivalent to households or individuals.

The analysis will distinguish between reported service delivery quantities and actual household-level access.

Absolute service delivery quantities will not automatically be interpreted as measures of municipal performance, as municipalities differ in size and service responsibilities.

The 2022 P9115 figures are revised, while the 2023 figures are preliminary. These distinctions will be retained throughout the analysis.

Historical provincial data will be analysed separately from more geographically detailed data where appropriate.

The Service Delivery Gap Index will only be developed if the available indicators support meaningful and defensible comparisons.

All identified data limitations, assumptions and methodological decisions will be documented.

## 8. Project Status

Completed:

- Software installation and configuration.
- PostgreSQL database setup.
- Git and GitHub configuration.
- GitHub repository creation.
- Project folder structure.
- Initial data acquisition.
- Project scope definition.

Upcoming:

- Data inspection and validation.
- Data cleaning and preparation.
- PostgreSQL data import.
- Exploratory data analysis.
- Indicator development.
- Power BI dashboard development.
- Final findings and documentation.
