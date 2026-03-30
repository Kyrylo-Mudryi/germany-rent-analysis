WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM rentals_cleaned
)
SELECT
    newly_const,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY r.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM rentals_cleaned r
CROSS JOIN overall_median o
GROUP BY r.newly_const, o.overall_median_price_per_m2
ORDER BY median_price_per_m2 DESC;

SELECT
    COALESCE(condition, 'No data') AS condition_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM rentals_cleaned
GROUP BY condition_group
ORDER BY median_price_per_m2 DESC;

SELECT
    COALESCE(interior_qual, 'No data') AS interior_qual_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM rentals_cleaned
GROUP BY interior_qual_group
ORDER BY median_price_per_m2 DESC;

WITH quality_combinations AS (
    SELECT
        newly_const,
        COALESCE(condition, 'No data') AS condition_group,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY newly_const, COALESCE(condition, 'No data')
    HAVING COUNT(*) >= 30
)
SELECT
    newly_const,
    condition_group,
    number_of_listings,
    ROUND(median_price_per_m2::numeric, 2) AS median_price_per_m2
FROM quality_combinations
ORDER BY median_price_per_m2 DESC;