WITH amenity_summary AS (
    SELECT
        'balcony' AS amenity,
        balcony AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY balcony

    UNION ALL

    SELECT
        'lift' AS amenity,
        lift AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY lift

    UNION ALL

    SELECT
        'has_kitchen' AS amenity,
        has_kitchen AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY has_kitchen

    UNION ALL

    SELECT
        'garden' AS amenity,
        garden AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY garden

    UNION ALL

    SELECT
        'cellar' AS amenity,
        cellar AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY cellar
)

SELECT
    amenity,
    MAX(CASE WHEN availability = true THEN number_of_listings END) AS listings_with_amenity,
    MAX(CASE WHEN availability = false THEN number_of_listings END) AS listings_without_amenity,
    ROUND(MAX(CASE WHEN availability = true THEN median_price_per_m2 END)::numeric, 2) AS median_price_with_amenity,
    ROUND(MAX(CASE WHEN availability = false THEN median_price_per_m2 END)::numeric, 2) AS median_price_without_amenity,
    ROUND((MAX(CASE WHEN availability = true THEN median_price_per_m2 END) - MAX(CASE WHEN availability = false THEN median_price_per_m2 END))::numeric, 2) AS amenity_price_gap
FROM amenity_summary
GROUP BY amenity
ORDER BY amenity_price_gap DESC;