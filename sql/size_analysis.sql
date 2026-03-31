WITH rooms_segmented AS (
    SELECT
        *,
        CASE
            WHEN no_rooms < 1.5 THEN '1 room'
            WHEN no_rooms < 2.5 THEN '2 rooms'
            WHEN no_rooms < 3.5 THEN '3 rooms'
            WHEN no_rooms < 4.5 THEN '4 rooms'
            ELSE '5+ rooms'
        END AS rooms_group
    FROM rentals_cleaned
),
overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM rentals_cleaned
)
SELECT
    r.rooms_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM rooms_segmented r
CROSS JOIN overall_median o
GROUP BY r.rooms_group, o.overall_median_price_per_m2
ORDER BY
    CASE r.rooms_group
        WHEN '1 room' THEN 1
        WHEN '2 rooms' THEN 2
        WHEN '3 rooms' THEN 3
        WHEN '4 rooms' THEN 4
        WHEN '5+ rooms' THEN 5
    END;

WITH size_segmented AS (
    SELECT
        *,
        CASE
            WHEN living_space < 40 THEN 'Under 40 m²'
            WHEN living_space < 60 THEN '40-59 m²'
            WHEN living_space < 80 THEN '60-79 m²'
            WHEN living_space < 100 THEN '80-99 m²'
            ELSE '100+ m²'
        END AS size_bucket
    FROM rentals_cleaned
),
overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM rentals_cleaned
)
SELECT
    s.size_bucket,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY s.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM size_segmented s
CROSS JOIN overall_median o
GROUP BY s.size_bucket, o.overall_median_price_per_m2
ORDER BY
    CASE s.size_bucket
        WHEN 'Under 40 m²' THEN 1
        WHEN '40-59 m²' THEN 2
        WHEN '60-79 m²' THEN 3
        WHEN '80-99 m²' THEN 4
        WHEN '100+ m²' THEN 5
    END;