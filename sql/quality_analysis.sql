WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    construction_status,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY v.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched v
CROSS JOIN overall_median o
GROUP BY v.construction_status, o.overall_median_price_per_m2
ORDER BY median_price_per_m2 DESC;

SELECT
    condition_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM vw_rentals_enriched
GROUP BY condition_group
ORDER BY median_price_per_m2 DESC;

SELECT
    interior_qual_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM vw_rentals_enriched
GROUP BY interior_qual_group
ORDER BY median_price_per_m2 DESC;

WITH quality_combinations AS (
    SELECT
        construction_status,
        condition_group,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
    GROUP BY construction_status, condition_group
    HAVING COUNT(*) >= 30
)
SELECT
    construction_status,
    condition_group,
    number_of_listings,
    ROUND(median_price_per_m2::numeric, 2) AS median_price_per_m2
FROM quality_combinations
ORDER BY median_price_per_m2 DESC;
