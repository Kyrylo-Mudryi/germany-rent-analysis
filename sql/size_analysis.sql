WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.rooms_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.rooms_group, vr.rooms_group_order, o.overall_median_price_per_m2
ORDER BY vr.rooms_group_order;

WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.size_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.size_group, vr.size_group_order, o.overall_median_price_per_m2
ORDER BY vr.size_group_order;