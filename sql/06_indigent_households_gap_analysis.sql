-- Question 1: National indigent household support coverage
-- Calculate coverage and support gaps by year and service

SELECT
    year,
    service_type,
    SUM(indigent_households) AS total_indigent_households,
    SUM(beneficiaries) AS total_beneficiaries,
    SUM(indigent_households) - SUM(beneficiaries)
        AS support_gap_households,
    ROUND(
        100.0 * SUM(beneficiaries) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS coverage_pct,
    ROUND(
        100.0 * (SUM(indigent_households) - SUM(beneficiaries)) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS support_gap_pct
FROM public.indigent_households
GROUP BY year, service_type
ORDER BY year, coverage_pct DESC;

--How does indigent household support coverage differ across South Africa's nine provinces?
-- Question 2: Provincial indigent household support coverage

SELECT
    province,
    year,
    service_type,
    SUM(indigent_households) AS total_indigent_households,
    SUM(beneficiaries) AS total_beneficiaries,
    SUM(indigent_households) - SUM(beneficiaries)
        AS support_gap_households,
    ROUND(
        100.0 * SUM(beneficiaries) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS coverage_pct,
    ROUND(
        100.0 * (SUM(indigent_households) - SUM(beneficiaries)) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS support_gap_pct
FROM public.indigent_households
GROUP BY province, year, service_type
ORDER BY year, service_type, coverage_pct DESC NULLS LAST;

--How did indigent household support coverage change between 2022 and 2023 for each service?
-- Question 3: National support coverage changes

WITH annual_coverage AS (
    SELECT
        year,
        service_type,
        100.0 * SUM(beneficiaries) /
            NULLIF(SUM(indigent_households), 0)
            AS coverage_pct
    FROM public.indigent_households
    GROUP BY year, service_type
)
SELECT
    service_type,
    ROUND(MAX(CASE WHEN year = 2022
        THEN coverage_pct END), 2) AS coverage_2022,
    ROUND(MAX(CASE WHEN year = 2023
        THEN coverage_pct END), 2) AS coverage_2023,
    ROUND(
        MAX(CASE WHEN year = 2023 THEN coverage_pct END) -
        MAX(CASE WHEN year = 2022 THEN coverage_pct END),
        2
    ) AS coverage_change_pp
FROM annual_coverage
GROUP BY service_type
ORDER BY coverage_change_pp ASC;

--Which provinces experienced the greatest improvements or declines in indigent household support coverage between 2022 and 2023?
-- Question 4: Provincial support coverage changes

WITH provincial_coverage AS (
    SELECT
        province,
        year,
        service_type,
        100.0 * SUM(beneficiaries) /
            NULLIF(SUM(indigent_households), 0)
            AS coverage_pct
    FROM public.indigent_households
    GROUP BY province, year, service_type
)
SELECT
    province,
    service_type,
    ROUND(MAX(CASE WHEN year = 2022
        THEN coverage_pct END), 2) AS coverage_2022,
    ROUND(MAX(CASE WHEN year = 2023
        THEN coverage_pct END), 2) AS coverage_2023,
    ROUND(
        MAX(CASE WHEN year = 2023 THEN coverage_pct END) -
        MAX(CASE WHEN year = 2022 THEN coverage_pct END),
        2
    ) AS coverage_change_pp
FROM provincial_coverage
GROUP BY province, service_type
ORDER BY coverage_change_pp ASC NULLS LAST;

--Which municipalities recorded the largest indigent household support gaps in 2023?
-- Question 5: Largest municipal support gaps in 2023

SELECT
    province,
    district_area,
    municipality_name,
    municipality_category,
    service_type,
    indigent_households,
    beneficiaries,
    indigent_households - beneficiaries
        AS support_gap_households,
    ROUND(
        100.0 * beneficiaries /
        NULLIF(indigent_households, 0), 2
    ) AS coverage_pct,
    ROUND(
        100.0 * (indigent_households - beneficiaries) /
        NULLIF(indigent_households, 0), 2
    ) AS support_gap_pct
FROM public.indigent_households
WHERE year = 2023
    AND indigent_households > 0
ORDER BY support_gap_households DESC
LIMIT 20;

--How many municipalities reported identified indigent households but zero beneficiaries in 2023?
-- Question 6: Municipalities with zero reported support

SELECT
    service_type,
    municipality_category,
    COUNT(*) AS municipalities_with_zero_support,
    SUM(indigent_households) AS identified_indigent_households
FROM public.indigent_households
WHERE year = 2023
    AND indigent_households > 0
    AND beneficiaries = 0
GROUP BY
    service_type,
    municipality_category
ORDER BY
    service_type,
    municipality_category;

    --How does indigent household support coverage differ between metropolitan, local and district municipalities?
    -- Question 7: Support coverage by municipal category

SELECT
    municipality_category,
    service_type,
    COUNT(DISTINCT municipality_id)
        AS total_municipalities,
    SUM(indigent_households)
        AS total_indigent_households,
    SUM(beneficiaries)
        AS total_beneficiaries,
    SUM(indigent_households - beneficiaries)
        AS support_gap_households,
    ROUND(
        100.0 * SUM(beneficiaries) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS coverage_pct,
    ROUND(
        100.0 * SUM(indigent_households - beneficiaries) /
        NULLIF(SUM(indigent_households), 0), 2
    ) AS support_gap_pct
FROM public.indigent_households
WHERE year = 2023
GROUP BY
    municipality_category,
    service_type
ORDER BY
    municipality_category,
    coverage_pct DESC NULLS LAST;

--Which provinces experienced the largest increases or decreases in identified indigent households between 2022 and 2023?
-- Question 8: Changes in identified indigent households

WITH municipal_households AS (
    SELECT
        province,
        municipality_id,
        year,
        MAX(indigent_households) AS households
    FROM public.indigent_households
    GROUP BY province, municipality_id, year
),
provincial_totals AS (
    SELECT
        province,
        SUM(CASE WHEN year = 2022
            THEN households ELSE 0 END) AS households_2022,
        SUM(CASE WHEN year = 2023
            THEN households ELSE 0 END) AS households_2023
    FROM municipal_households
    GROUP BY province
)
SELECT
    province,
    households_2022,
    households_2023,
    households_2023 - households_2022
        AS household_change,
    ROUND(
        100.0 * (households_2023 - households_2022) /
        NULLIF(households_2022, 0), 2
    ) AS household_change_pct
FROM provincial_totals
ORDER BY household_change DESC;

--Which provinces contribute the largest share of the national indigent household support gap for each service in 2023?
-- Question 9: Provincial contribution to national support gaps

WITH provincial_gaps AS (
    SELECT
        province,
        service_type,
        SUM(indigent_households - beneficiaries)
            AS provincial_support_gap
    FROM public.indigent_households
    WHERE year = 2023
    GROUP BY province, service_type
)
SELECT
    province,
    service_type,
    provincial_support_gap,
    SUM(provincial_support_gap) OVER (
        PARTITION BY service_type
    ) AS national_support_gap,
    ROUND(
        100.0 * provincial_support_gap /
        NULLIF(
            SUM(provincial_support_gap) OVER (
                PARTITION BY service_type
            ), 0
        ), 2
    ) AS contribution_pct,
    DENSE_RANK() OVER (
        PARTITION BY service_type
        ORDER BY provincial_support_gap DESC
    ) AS provincial_rank
FROM provincial_gaps
ORDER BY service_type, provincial_rank;


--Which provinces have free basic service coverage below the national average in 2023, and by how many percentage points?
-- Question 10: Provincial coverage vs national coverage (2023)

WITH national_coverage AS (
    SELECT
        service_type,
        100.0 * SUM(beneficiaries)
            / NULLIF(SUM(indigent_households), 0)
            AS national_coverage_pct
    FROM public.indigent_households
    WHERE year = 2023
    GROUP BY service_type
),

provincial_coverage AS (
    SELECT
        province,
        service_type,
        100.0 * SUM(beneficiaries)
            / NULLIF(SUM(indigent_households), 0)
            AS provincial_coverage_pct
    FROM public.indigent_households
    WHERE year = 2023
    GROUP BY province, service_type
)

SELECT
    p.province,
    p.service_type,
    ROUND(p.provincial_coverage_pct, 2)
        AS provincial_coverage_pct,
    ROUND(n.national_coverage_pct, 2)
        AS national_coverage_pct,
    ROUND(
        p.provincial_coverage_pct
        - n.national_coverage_pct, 2
    ) AS coverage_gap_pp,
    CASE
        WHEN p.provincial_coverage_pct IS NULL
            THEN 'Not Applicable'
        WHEN p.provincial_coverage_pct
            < n.national_coverage_pct
            THEN 'Below National'
        WHEN p.provincial_coverage_pct
            > n.national_coverage_pct
            THEN 'Above National'
        ELSE 'Equal to National'
    END AS coverage_status
FROM provincial_coverage p
JOIN national_coverage n
    ON p.service_type = n.service_type
ORDER BY coverage_gap_pp ASC NULLS LAST;

--Which municipalities experienced the largest decline in free basic service coverage between 2022 and 2023?
-- Question 11: Largest municipal coverage declines

WITH municipal_coverage AS (
    SELECT
        province,
        municipality_id,
        municipality_name,
        municipality_category,
        service_type,
        MAX(
            CASE WHEN year = 2022 THEN
                100.0 * beneficiaries
                / NULLIF(indigent_households, 0)
            END
        ) AS coverage_2022,
        MAX(
            CASE WHEN year = 2023 THEN
                100.0 * beneficiaries
                / NULLIF(indigent_households, 0)
            END
        ) AS coverage_2023
    FROM public.indigent_households
    GROUP BY
        province,
        municipality_id,
        municipality_name,
        municipality_category,
        service_type
)

SELECT
    province,
    municipality_name,
    municipality_category,
    service_type,
    ROUND(coverage_2022, 2) AS coverage_2022,
    ROUND(coverage_2023, 2) AS coverage_2023,
    ROUND(
        coverage_2023 - coverage_2022, 2
    ) AS coverage_change_pp
FROM municipal_coverage
WHERE coverage_2022 IS NOT NULL
    AND coverage_2023 IS NOT NULL
    AND coverage_2023 < coverage_2022
ORDER BY
    coverage_change_pp ASC,
    municipality_id,
    service_type
LIMIT 20;

--Which municipalities recorded growth in general service provision while experiencing declining free basic service coverage?
-- Question 12: Service provision growth vs
-- declining indigent support coverage

WITH integrated_data AS (
    SELECT
        s.province,
        s.municipality_id,
        s.municipality_name,
        s.municipality_category,
        s.service_type,
        s.year,
        s.consumer_units,
        100.0 * i.beneficiaries
            / NULLIF(i.indigent_households, 0)
            AS coverage_pct
    FROM public.municipal_service_delivery s
    INNER JOIN public.indigent_households i
        ON s.municipality_id = i.municipality_id
        AND s.year = i.year
        AND s.service_type =
            CASE
                WHEN i.service_type = 'solid_waste'
                    THEN 'waste'
                ELSE i.service_type
            END
),

yearly_comparison AS (
    SELECT
        province,
        municipality_id,
        municipality_name,
        municipality_category,
        service_type,
        MAX(consumer_units) FILTER (
            WHERE year = 2022
        ) AS units_2022,
        MAX(consumer_units) FILTER (
            WHERE year = 2023
        ) AS units_2023,
        MAX(coverage_pct) FILTER (
            WHERE year = 2022
        ) AS coverage_2022,
        MAX(coverage_pct) FILTER (
            WHERE year = 2023
        ) AS coverage_2023
    FROM integrated_data
    GROUP BY
        province,
        municipality_id,
        municipality_name,
        municipality_category,
        service_type
)

SELECT
    province,
    municipality_name,
    municipality_category,
    service_type,
    units_2022,
    units_2023,
    units_2023 - units_2022 AS consumer_unit_growth,
    ROUND(
        100.0 * (units_2023 - units_2022)
        / NULLIF(units_2022, 0), 2
    ) AS service_growth_pct,
    ROUND(coverage_2022, 2) AS coverage_2022,
    ROUND(coverage_2023, 2) AS coverage_2023,
    ROUND(
        coverage_2023 - coverage_2022, 2
    ) AS coverage_change_pp
FROM yearly_comparison
WHERE units_2023 > units_2022
    AND coverage_2023 < coverage_2022
ORDER BY
    coverage_change_pp ASC,
    municipality_id,
    service_type;
