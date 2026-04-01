WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.age_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.age_group, vr.age_group_order, o.overall_median_price_per_m2
ORDER BY vr.age_group_order;

WITH large_cities AS (
    SELECT
        city,
        COUNT(*) AS city_total_listings
    FROM vw_rentals_enriched
    GROUP BY city
    ORDER BY city_total_listings DESC
    LIMIT 10
)
SELECT
    vr.city,
    vr.age_group,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2
FROM vw_rentals_enriched vr
INNER JOIN large_cities lc
    ON vr.city = lc.city
GROUP BY
    vr.city,
    vr.age_group,
    vr.age_group_order
HAVING COUNT(*) >= 20
ORDER BY
    vr.city,
    vr.age_group_order;