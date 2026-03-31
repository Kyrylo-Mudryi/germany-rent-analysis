WITH age_segmented AS (
    SELECT
        *,
        CASE
            WHEN property_age <= 5 THEN '0-5 years'
            WHEN property_age <= 10 THEN '6-10 years'
            WHEN property_age <= 20 THEN '11-20 years'
            WHEN property_age <= 40 THEN '21-40 years'
            ELSE '41+ years'
        END AS age_group
    FROM rentals_cleaned
),
overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM rentals_cleaned
)
SELECT
    a.age_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND(
        (
            PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY a.price_per_m2)
            - o.overall_median_price_per_m2
        )::numeric,
        2
    ) AS price_gap_vs_overall
FROM age_segmented a
CROSS JOIN overall_median o
GROUP BY a.age_group, o.overall_median_price_per_m2
ORDER BY
    CASE a.age_group
        WHEN '0-5 years' THEN 1
        WHEN '6-10 years' THEN 2
        WHEN '11-20 years' THEN 3
        WHEN '21-40 years' THEN 4
        WHEN '41+ years' THEN 5
    END;

WITH large_cities AS (
    SELECT
        city,
        COUNT(*) AS city_total_listings
    FROM rentals_cleaned
    GROUP BY city
    ORDER BY city_total_listings DESC
    LIMIT 10
),
age_segmented AS (
    SELECT
        r.city,
        CASE
            WHEN r.property_age <= 5 THEN '0-5 years'
            WHEN r.property_age <= 10 THEN '6-10 years'
            WHEN r.property_age <= 20 THEN '11-20 years'
            WHEN r.property_age <= 40 THEN '21-40 years'
            ELSE '41+ years'
        END AS age_group,
        r.total_rent,
        r.price_per_m2
    FROM rentals_cleaned r
    INNER JOIN large_cities lc
        ON r.city = lc.city
)
SELECT
    city,
    age_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM age_segmented
GROUP BY city, age_group
HAVING COUNT(*) >= 20
ORDER BY
    city,
    CASE age_group
        WHEN '0-5 years' THEN 1
        WHEN '6-10 years' THEN 2
        WHEN '11-20 years' THEN 3
        WHEN '21-40 years' THEN 4
        WHEN '41+ years' THEN 5
    END;