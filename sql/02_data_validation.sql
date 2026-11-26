SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT municipality_id) AS total_municipalities,
    COUNT(DISTINCT province) AS total_provinces,
    COUNT(DISTINCT year) AS total_years,
    COUNT(DISTINCT service_type) AS total_services,
    COUNT(DISTINCT municipality_category) AS total_categories
FROM public.municipal_service_delivery;

-- Validate national service delivery totals

SELECT
    year,
    service_type,
    SUM(consumer_units) AS total_consumer_units
FROM public.municipal_service_delivery
GROUP BY year, service_type
ORDER BY year, service_type;

-- Check for duplicate primary key combinations

SELECT
    municipality_id,
    year,
    service_type,
    COUNT(*) AS duplicate_count
FROM public.municipal_service_delivery
GROUP BY municipality_id, year, service_type
HAVING COUNT(*) > 1;

-- Check for missing values in each column

SELECT
    COUNT(*) - COUNT(province) AS missing_province,
    COUNT(*) - COUNT(district_area) AS missing_district,
    COUNT(*) - COUNT(municipality_name) AS missing_name,
    COUNT(*) - COUNT(municipality_category) AS missing_category,
    COUNT(*) - COUNT(year) AS missing_year,
    COUNT(*) - COUNT(service_type) AS missing_service,
    COUNT(*) - COUNT(consumer_units) AS missing_units,
    COUNT(*) - COUNT(municipality_id) AS missing_id
FROM public.municipal_service_delivery;


-- Validate district assignments by municipality category

SELECT
    municipality_category,
    COUNT(*) AS total_records,
    COUNT(DISTINCT municipality_id) AS total_municipalities,
    COUNT(*) - COUNT(district_area) AS missing_districts
FROM public.municipal_service_delivery
GROUP BY municipality_category
ORDER BY municipality_category;

-- Validate numerical consumer unit values

SELECT
    MIN(consumer_units) AS minimum_units,
    MAX(consumer_units) AS maximum_units,
    COUNT(*) FILTER (WHERE consumer_units < 0) AS negative_values,
    COUNT(*) FILTER (WHERE consumer_units = 0) AS zero_values,
    COUNT(*) FILTER (WHERE consumer_units > 0) AS positive_values
FROM public.municipal_service_delivery;


-- Reconcile SQL totals against official Stats SA figures

WITH expected_totals (year, service_type, expected_units) AS (
    VALUES
        (2022, 'water', 15274302),
        (2022, 'electricity', 12857866),
        (2022, 'sanitation', 13496878),
        (2022, 'waste', 11113427),
        (2023, 'water', 15766721),
        (2023, 'electricity', 13261834),
        (2023, 'sanitation', 13990522),
        (2023, 'waste', 11761128)
),
actual_totals AS (
    SELECT
        year,
        service_type,
        SUM(consumer_units) AS actual_units
    FROM public.municipal_service_delivery
    GROUP BY year, service_type
)
SELECT
    e.year,
    e.service_type,
    e.expected_units,
    a.actual_units,
    a.actual_units - e.expected_units AS difference,
    CASE
        WHEN a.actual_units = e.expected_units THEN 'PASS'
        ELSE 'FAIL'
    END AS validation_status
FROM expected_totals e
LEFT JOIN actual_totals a
    ON e.year = a.year
    AND e.service_type = a.service_type
ORDER BY e.year, e.service_type;