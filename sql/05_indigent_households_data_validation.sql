-- Validation 1: Dataset dimensions

SELECT
    COUNT(*) AS total_records,
    COUNT(DISTINCT municipality_id) AS total_municipalities,
    COUNT(DISTINCT province) AS total_provinces,
    COUNT(DISTINCT year) AS total_years,
    COUNT(DISTINCT service_type) AS total_services,
    COUNT(DISTINCT municipality_category) AS total_categories
FROM public.indigent_households;

-- Validation 2: National totals by year and service

SELECT
    year,
    service_type,
    SUM(indigent_households) AS total_indigent_households,
    SUM(beneficiaries) AS total_beneficiaries
FROM public.indigent_households
GROUP BY year, service_type
ORDER BY year, service_type;

-- Validation 3: Duplicate record detection

SELECT
    municipality_id,
    year,
    service_type,
    COUNT(*) AS duplicate_count
FROM public.indigent_households
GROUP BY municipality_id, year, service_type
HAVING COUNT(*) > 1;

-- Validation 4: Missing values by municipality category

SELECT
    municipality_category,
    COUNT(*) AS total_records,
    COUNT(*) FILTER (
        WHERE district_area IS NULL
    ) AS missing_district_area,
    COUNT(*) FILTER (
        WHERE district_area IS NOT NULL
    ) AS assigned_district_area
FROM public.indigent_households
GROUP BY municipality_category
ORDER BY municipality_category;

-- Validation 5: Numerical data quality

SELECT
    COUNT(*) AS total_records,

    COUNT(*) FILTER (
        WHERE indigent_households < 0
    ) AS negative_households,

    COUNT(*) FILTER (
        WHERE beneficiaries < 0
    ) AS negative_beneficiaries,

    COUNT(*) FILTER (
        WHERE indigent_households = 0
    ) AS zero_households,

    COUNT(*) FILTER (
        WHERE beneficiaries = 0
    ) AS zero_beneficiaries,

    COUNT(*) FILTER (
        WHERE beneficiaries > indigent_households
    ) AS beneficiaries_exceed_households,

    COUNT(*) FILTER (
        WHERE indigent_households = 0
        AND beneficiaries > 0
    ) AS beneficiaries_without_households

FROM public.indigent_households;

-- Validation 6: Cross-dataset consistency

SELECT
    COUNT(*) FILTER (
        WHERE m.municipality_id IS NOT NULL
        AND i.municipality_id IS NOT NULL
    ) AS matched_records,

    COUNT(*) FILTER (
        WHERE i.municipality_id IS NULL
    ) AS missing_in_indigent_dataset,

    COUNT(*) FILTER (
        WHERE m.municipality_id IS NULL
    ) AS missing_in_service_dataset,

    COUNT(*) FILTER (
        WHERE m.municipality_id IS NOT NULL
        AND i.municipality_id IS NOT NULL
        AND (
            m.province IS DISTINCT FROM i.province
            OR m.district_area IS DISTINCT FROM i.district_area
            OR m.municipality_name IS DISTINCT FROM i.municipality_name
            OR m.municipality_category IS DISTINCT FROM i.municipality_category
        )
    ) AS geographic_mismatches

FROM public.municipal_service_delivery m

FULL OUTER JOIN public.indigent_households i
    ON m.municipality_id = i.municipality_id
    AND m.year = i.year
    AND m.service_type = i.service_type;

	-- Diagnostic 6.1: Compare service naming conventions

SELECT
    'Service Delivery' AS dataset,
    service_type,
    COUNT(*) AS total_records
FROM public.municipal_service_delivery
GROUP BY service_type

UNION ALL

SELECT
    'Indigent Households' AS dataset,
    service_type,
    COUNT(*) AS total_records
FROM public.indigent_households
GROUP BY service_type

ORDER BY service_type, dataset;

-- Diagnostic 6.2: Identify remaining unmatched records

SELECT
    m.municipality_id AS service_municipality_id,
    i.municipality_id AS indigent_municipality_id,
    m.year AS service_year,
    i.year AS indigent_year,
    m.service_type AS service_dataset_type,
    i.service_type AS indigent_dataset_type
FROM public.municipal_service_delivery m

FULL OUTER JOIN public.indigent_households i
    ON m.municipality_id = i.municipality_id
    AND m.year = i.year
    AND m.service_type = CASE
        WHEN i.service_type = 'solid_waste' THEN 'waste'
        ELSE i.service_type
    END

WHERE m.municipality_id IS NULL
   OR i.municipality_id IS NULL

ORDER BY
    COALESCE(m.municipality_id, i.municipality_id),
    COALESCE(m.year, i.year);


-- Diagnostic 6.3: Test standardised matching keys

WITH standardised_indigent AS (
    SELECT
        *,
        CASE
            WHEN municipality_name = 'Mbizana Local Municipality'
                AND province = 'Eastern Cape'
            THEN 'Eastern Cape | Winnie Madikizela-Mandela Local Municipality'
            ELSE municipality_id
        END AS corrected_municipality_id,

        CASE
            WHEN service_type = 'solid_waste' THEN 'waste'
            ELSE service_type
        END AS corrected_service_type

    FROM public.indigent_households
)

SELECT
    COUNT(*) FILTER (
        WHERE m.municipality_id IS NOT NULL
        AND i.municipality_id IS NOT NULL
    ) AS matched_records,

    COUNT(*) FILTER (
        WHERE i.municipality_id IS NULL
    ) AS missing_in_indigent_dataset,

    COUNT(*) FILTER (
        WHERE m.municipality_id IS NULL
    ) AS missing_in_service_dataset

FROM public.municipal_service_delivery m

FULL OUTER JOIN standardised_indigent i
    ON m.municipality_id = i.corrected_municipality_id
    AND m.year = i.year
    AND m.service_type = i.corrected_service_type;

-- Diagnostic 6.4: Inspect exact municipality names

SELECT DISTINCT
    'Service Delivery' AS dataset,
    municipality_name,
    municipality_id,
    district_area,
    LENGTH(municipality_name) AS name_length
FROM public.municipal_service_delivery
WHERE municipality_name ILIKE '%Madikizela%'

UNION ALL

SELECT DISTINCT
    'Indigent Households' AS dataset,
    municipality_name,
    municipality_id,
    district_area,
    LENGTH(municipality_name) AS name_length
FROM public.indigent_households
WHERE municipality_name ILIKE '%Mbizana%';

-- Diagnostic 6.5: Dynamic municipality standardisation

WITH standardised_indigent AS (
    SELECT
        *,
        CASE
            WHEN municipality_name ILIKE '%Mbizana%'
                AND province = 'Eastern Cape'
            THEN (
                SELECT DISTINCT municipality_id
                FROM public.municipal_service_delivery
                WHERE municipality_name ILIKE '%Madikizela%'
                    AND province = 'Eastern Cape'
            )
            ELSE municipality_id
        END AS corrected_municipality_id,

        CASE
            WHEN service_type = 'solid_waste' THEN 'waste'
            ELSE service_type
        END AS corrected_service_type

    FROM public.indigent_households
)

SELECT
    COUNT(*) FILTER (
        WHERE m.municipality_id IS NOT NULL
        AND i.municipality_id IS NOT NULL
    ) AS matched_records,

    COUNT(*) FILTER (
        WHERE i.municipality_id IS NULL
    ) AS missing_in_indigent_dataset,

    COUNT(*) FILTER (
        WHERE m.municipality_id IS NULL
    ) AS missing_in_service_dataset

FROM public.municipal_service_delivery m

FULL OUTER JOIN standardised_indigent i
    ON m.municipality_id = i.corrected_municipality_id
    AND m.year = i.year
    AND m.service_type = i.corrected_service_type;