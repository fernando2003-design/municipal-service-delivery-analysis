--PROJECT: Municipal Service Delivery Gap Analysis
-- SOURCE: Statistics South Africa (P9115)
-- PERIOD: 2022-2023
-- PHASE: Exploratory Data Analysis (EDA)
 
-- Objective:
-- Analyse municipal service delivery patterns,
-- provincial differences, municipality categories,
-- and year-on-year changes in consumer units.

--How did municipal service provision change nationally between 2022 and 2023?

-- 1. National service delivery by year and service type

SELECT
    service_type,
    SUM(CASE WHEN year = 2022 THEN consumer_units ELSE 0 END) AS units_2022,
    SUM(CASE WHEN year = 2023 THEN consumer_units ELSE 0 END) AS units_2023
FROM public.municipal_service_delivery
GROUP BY service_type
ORDER BY service_type;

--Which municipal service experienced the highest growth between 2022 and 2023?
-- 2. National year-on-year service delivery growth

WITH annual_totals AS (
    SELECT
        service_type,
        SUM(CASE WHEN year = 2022 THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023 THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY service_type
)
SELECT
    service_type,
    units_2022,
    units_2023,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM annual_totals
ORDER BY growth_percentage DESC;-- 2. National year-on-year service delivery growth

WITH annual_totals AS (
    SELECT
        service_type,
        SUM(CASE WHEN year = 2022 THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023 THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY service_type
)
SELECT
    service_type,
    units_2022,
    units_2023,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM annual_totals
ORDER BY growth_percentage DESC;

--How did municipal service provision change across South Africa's nine provinces between 2022 and 2023?
-- 3. Provincial year-on-year service delivery growth

WITH provincial_totals AS (
    SELECT
        province,
        service_type,
        SUM(CASE WHEN year = 2022 THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023 THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
)
SELECT
    province,
    service_type,
    units_2022,
    units_2023,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM provincial_totals
ORDER BY province, growth_percentage DESC NULLS LAST;

--Which provinces recorded the highest and lowest growth for each municipal service?
-- 4. Rank provinces by service delivery growth

WITH provincial_totals AS (
    SELECT
        province,
        service_type,
        SUM(CASE WHEN year = 2022 THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023 THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
),
provincial_growth AS (
    SELECT
        province,
        service_type,
        units_2022,
        units_2023,
        units_2023 - units_2022 AS absolute_change,
        ROUND(
            (units_2023 - units_2022) * 100.0
            / NULLIF(units_2022, 0), 2
        ) AS growth_percentage
    FROM provincial_totals
)
SELECT
    *,
    DENSE_RANK() OVER (
        PARTITION BY service_type
        ORDER BY growth_percentage DESC NULLS LAST
    ) AS province_rank
FROM provincial_growth
ORDER BY service_type, province_rank;

--Which municipalities experienced increases or decreases in reported service delivery consumer units between 2022 and 2023?
-- 5. Municipality-level service delivery growth

WITH municipality_totals AS (
    SELECT
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type
)
SELECT
    *,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM municipality_totals
ORDER BY province, municipality_name, service_type;

--Which municipality-service combinations experienced growth, decline, no change, or changes involving zero reported provision?
-- 6. Classify municipality-level service delivery changes

WITH municipality_totals AS (
    SELECT
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type
)
SELECT
    *,
    units_2023 - units_2022 AS absolute_change,
    CASE
        WHEN units_2022 = 0 AND units_2023 = 0
            THEN 'No Reported Provision'
        WHEN units_2022 = 0 AND units_2023 > 0
            THEN 'New Reported Provision'
        WHEN units_2022 > 0 AND units_2023 = 0
            THEN 'Reported Provision Dropped to Zero'
        WHEN units_2023 > units_2022
            THEN 'Growth'
        WHEN units_2023 < units_2022
            THEN 'Decline'
        ELSE 'No Change'
    END AS delivery_status
FROM municipality_totals
ORDER BY province, municipality_name, service_type;

--How widespread are growth, decline and zero reported provision across South African municipalities?
-- 7. Summarise service delivery performance

WITH municipality_totals AS (
    SELECT
        municipality_id,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY municipality_id, service_type
),
classified_delivery AS (
    SELECT
        *,
        CASE
            WHEN units_2022 = 0 AND units_2023 = 0
                THEN 'No Reported Provision'
            WHEN units_2022 = 0 AND units_2023 > 0
                THEN 'New Reported Provision'
            WHEN units_2022 > 0 AND units_2023 = 0
                THEN 'Reported Provision Dropped to Zero'
            WHEN units_2023 > units_2022
                THEN 'Growth'
            WHEN units_2023 < units_2022
                THEN 'Decline'
            ELSE 'No Change'
        END AS delivery_status
    FROM municipality_totals
)
SELECT
    service_type,
    delivery_status,
    COUNT(*) AS municipality_count,
    ROUND(COUNT(*) * 100.0 / 257, 2)
        AS municipality_percentage
FROM classified_delivery
GROUP BY service_type, delivery_status
ORDER BY service_type, municipality_count DESC;

--Which municipalities reported declining consumer unit numbers, and how significant were those declines?
-- 8. Identify municipalities reporting service delivery declines

WITH municipality_totals AS (
    SELECT
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type
)
SELECT
    *,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM municipality_totals
WHERE units_2023 < units_2022
ORDER BY growth_percentage ASC;

--Which municipalities recorded the largest increases in consumer units for each service between 2022 and 2023?
-- 9. Top 5 municipalities by absolute growth per service

WITH municipality_totals AS (
    SELECT
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY
        municipality_id,
        municipality_name,
        province,
        municipality_category,
        service_type
),
ranked_municipalities AS (
    SELECT
        *,
        units_2023 - units_2022 AS absolute_change,
        ROW_NUMBER() OVER (
            PARTITION BY service_type
            ORDER BY units_2023 - units_2022 DESC,
                     municipality_id
        ) AS municipality_rank
    FROM municipality_totals
    WHERE units_2023 > units_2022
)
SELECT *
FROM ranked_municipalities
WHERE municipality_rank <= 5
ORDER BY service_type, municipality_rank;

--How does reported service delivery growth differ between metropolitan, local and district municipalities?
-- 10. Service delivery growth by municipality category

WITH category_totals AS (
    SELECT
        municipality_category,
        service_type,
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END) AS units_2022,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY municipality_category, service_type
)
SELECT
    municipality_category,
    CASE municipality_category
        WHEN 'A' THEN 'Metropolitan'
        WHEN 'B' THEN 'Local'
        WHEN 'C' THEN 'District'
    END AS category_name,
    service_type,
    units_2022,
    units_2023,
    units_2023 - units_2022 AS absolute_change,
    ROUND(
        (units_2023 - units_2022) * 100.0
        / NULLIF(units_2022, 0), 2
    ) AS growth_percentage
FROM category_totals
ORDER BY service_type, municipality_category;

--How many municipalities reported zero consumer units for each service in 2023, broken down by municipality category?
-- 11. Analyse zero reported service provision

SELECT
    municipality_category,
    service_type,
    COUNT(*) AS total_municipalities,
    COUNT(*) FILTER (
        WHERE consumer_units = 0
    ) AS zero_provision_count,
    COUNT(*) FILTER (
        WHERE consumer_units > 0
    ) AS positive_provision_count,
    ROUND(
        COUNT(*) FILTER (
            WHERE consumer_units = 0
        ) * 100.0 / COUNT(*), 2
    ) AS zero_provision_percentage
FROM public.municipal_service_delivery
WHERE year = 2023
GROUP BY municipality_category, service_type
ORDER BY service_type, municipality_category;

--Which provinces contributed the most to national consumer unit growth between 2022 and 2023?
-- 12. Provincial contribution to national growth

WITH provincial_growth AS (
    SELECT
        province,
        service_type,
        SUM(CASE WHEN year = 2023
            THEN consumer_units ELSE 0 END)
        -
        SUM(CASE WHEN year = 2022
            THEN consumer_units ELSE 0 END)
            AS absolute_change
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
)
SELECT
    province,
    service_type,
    absolute_change,
    SUM(absolute_change) OVER (
        PARTITION BY service_type
    ) AS national_growth,
    ROUND(
        absolute_change * 100.0 /
        NULLIF(
            SUM(absolute_change) OVER (
                PARTITION BY service_type
            ), 0
        ), 2
    ) AS contribution_percentage
FROM provincial_growth
ORDER BY service_type,
         contribution_percentage DESC NULLS LAST;

--Which provinces are growing more slowly than the national growth rate for each municipal service?
-- 13. Provincial growth against national benchmark

WITH provincial_totals AS (
    SELECT
        province,
        service_type,
        SUM(consumer_units) FILTER (
            WHERE year = 2022
        ) AS units_2022,
        SUM(consumer_units) FILTER (
            WHERE year = 2023
        ) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
),
growth_rates AS (
    SELECT
        province,
        service_type,
        (units_2023 - units_2022) * 100.0
            / NULLIF(units_2022, 0)
            AS provincial_growth,
        (
            SUM(units_2023) OVER (
                PARTITION BY service_type
            )
            -
            SUM(units_2022) OVER (
                PARTITION BY service_type
            )
        ) * 100.0 /
        NULLIF(
            SUM(units_2022) OVER (
                PARTITION BY service_type
            ), 0
        ) AS national_growth
    FROM provincial_totals
)
SELECT
    province,
    service_type,
    ROUND(provincial_growth, 2) AS provincial_growth,
    ROUND(national_growth, 2) AS national_growth,
    ROUND(
        provincial_growth - national_growth, 2
    ) AS growth_gap_pp,
    CASE
        WHEN provincial_growth IS NULL
            OR national_growth IS NULL
            THEN 'Not Comparable'
        WHEN provincial_growth < national_growth
            THEN 'Below National Growth'
        WHEN provincial_growth > national_growth
            THEN 'Above National Growth'
        ELSE 'Equal to National Growth'
    END AS performance_status
FROM growth_rates
ORDER BY service_type, growth_gap_pp ASC NULLS LAST;


--Which provinces recorded below-national growth across multiple municipal services?
-- 14. Identify consistent below-national growth

WITH provincial_totals AS (
    SELECT
        province,
        service_type,
        SUM(consumer_units) FILTER (
            WHERE year = 2022
        ) AS units_2022,
        SUM(consumer_units) FILTER (
            WHERE year = 2023
        ) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
),
growth_rates AS (
    SELECT
        province,
        service_type,
        (units_2023 - units_2022) * 100.0
            / NULLIF(units_2022, 0)
            AS provincial_growth,
        (
            SUM(units_2023) OVER (
                PARTITION BY service_type
            )
            -
            SUM(units_2022) OVER (
                PARTITION BY service_type
            )
        ) * 100.0 /
        NULLIF(
            SUM(units_2022) OVER (
                PARTITION BY service_type
            ), 0
        ) AS national_growth
    FROM provincial_totals
)
SELECT
    province,
    COUNT(*) AS total_services,
    COUNT(*) FILTER (
        WHERE provincial_growth < national_growth
    ) AS below_national,
    COUNT(*) FILTER (
        WHERE provincial_growth > national_growth
    ) AS above_national,
    COUNT(*) FILTER (
        WHERE provincial_growth = national_growth
    ) AS equal_to_national,
    COUNT(*) FILTER (
        WHERE provincial_growth IS NULL
           OR national_growth IS NULL
    ) AS not_comparable
FROM growth_rates
GROUP BY province
ORDER BY below_national DESC, province;

--Which provincial and service combinations should be prioritised for further investigation based on the largest negative growth gaps?
-- 15. Identify priority areas for further investigation

WITH provincial_totals AS (
    SELECT
        province,
        service_type,
        SUM(consumer_units) FILTER (
            WHERE year = 2022
        ) AS units_2022,
        SUM(consumer_units) FILTER (
            WHERE year = 2023
        ) AS units_2023
    FROM public.municipal_service_delivery
    GROUP BY province, service_type
),
growth_rates AS (
    SELECT
        province,
        service_type,
        units_2022,
        units_2023,
        (units_2023 - units_2022) * 100.0
            / NULLIF(units_2022, 0)
            AS provincial_growth,
        (
            SUM(units_2023) OVER (
                PARTITION BY service_type
            )
            -
            SUM(units_2022) OVER (
                PARTITION BY service_type
            )
        ) * 100.0 /
        NULLIF(
            SUM(units_2022) OVER (
                PARTITION BY service_type
            ), 0
        ) AS national_growth
    FROM provincial_totals
)
SELECT
    province,
    service_type,
    units_2022,
    units_2023,
    ROUND(provincial_growth, 2) AS provincial_growth,
    ROUND(national_growth, 2) AS national_growth,
    ROUND(
        provincial_growth - national_growth, 2
    ) AS growth_gap_pp,
    DENSE_RANK() OVER (
        ORDER BY provincial_growth - national_growth
    ) AS investigation_rank
FROM growth_rates
WHERE provincial_growth < national_growth
ORDER BY investigation_rank, province, service_type
LIMIT 10;