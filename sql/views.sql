CREATE OR REPLACE VIEW vw_rentals_enriched AS
SELECT
    r.*,
    CASE
        WHEN r.no_rooms < 1.5 THEN '1 room'
        WHEN r.no_rooms < 2.5 THEN '2 rooms'
        WHEN r.no_rooms < 3.5 THEN '3 rooms'
        WHEN r.no_rooms < 4.5 THEN '4 rooms'
        ELSE '5+ rooms'
    END AS rooms_group,
    CASE
        WHEN r.no_rooms < 1.5 THEN 1
        WHEN r.no_rooms < 2.5 THEN 2
        WHEN r.no_rooms < 3.5 THEN 3
        WHEN r.no_rooms < 4.5 THEN 4
        ELSE 5
    END AS rooms_group_order,
    CASE
        WHEN r.living_space < 40 THEN 'Under 40 m2'
        WHEN r.living_space < 60 THEN '40-59 m2'
        WHEN r.living_space < 80 THEN '60-79 m2'
        WHEN r.living_space < 100 THEN '80-99 m2'
        ELSE '100+ m2'
    END AS size_group,
    CASE
        WHEN r.living_space < 40 THEN 1
        WHEN r.living_space < 60 THEN 2
        WHEN r.living_space < 80 THEN 3
        WHEN r.living_space < 100 THEN 4
        ELSE 5
    END AS size_group_order,
    CASE
        WHEN r.property_age <= 5 THEN '0-5 years'
        WHEN r.property_age <= 10 THEN '6-10 years'
        WHEN r.property_age <= 20 THEN '11-20 years'
        WHEN r.property_age <= 40 THEN '21-40 years'
        ELSE '41+ years'
    END AS age_group,
    CASE
        WHEN r.property_age <= 5 THEN 1
        WHEN r.property_age <= 10 THEN 2
        WHEN r.property_age <= 20 THEN 3
        WHEN r.property_age <= 40 THEN 4
        ELSE 5
    END AS age_group_order,
    COALESCE(r.condition, 'No data') AS condition_group,
    COALESCE(r.interior_qual, 'No data') AS interior_qual_group,
    CASE
        WHEN r.newly_const THEN 'New build'
        ELSE 'Existing stock'
    END AS construction_status,
    CASE
        WHEN r.price_per_m2 >= 25 THEN 'Very high price'
        WHEN r.price_per_m2 >= 15 THEN 'High price'
        WHEN r.price_per_m2 >= 10 THEN 'Mid price'
        ELSE 'Affordable'
    END AS price_segment
FROM rentals_cleaned r;

CREATE OR REPLACE VIEW vw_city_price_summary AS
SELECT
    city,
    COUNT(*) AS number_of_listings,
    ROUND(AVG(price_per_m2)::numeric, 2) AS avg_price_per_m2,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(MIN(price_per_m2)::numeric, 2) AS min_price_per_m2,
    ROUND(MAX(price_per_m2)::numeric, 2) AS max_price_per_m2,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_rent)::numeric, 2) AS median_total_rent
FROM vw_rentals_enriched
GROUP BY city
HAVING COUNT(*) >= 30;

CREATE OR REPLACE VIEW vw_rooms_group_summary AS
WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.rooms_group,
    vr.rooms_group_order,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.rooms_group, vr.rooms_group_order, o.overall_median_price_per_m2;

CREATE OR REPLACE VIEW vw_amenities_summary AS
WITH amenity_summary AS (
    SELECT
        'balcony' AS amenity,
        balcony AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
    GROUP BY balcony

    UNION ALL

    SELECT
        'lift' AS amenity,
        lift AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
    GROUP BY lift

    UNION ALL

    SELECT
        'has_kitchen' AS amenity,
        has_kitchen AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
    GROUP BY has_kitchen

    UNION ALL

    SELECT
        'garden' AS amenity,
        garden AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
    GROUP BY garden

    UNION ALL

    SELECT
        'cellar' AS amenity,
        cellar AS availability,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM vw_rentals_enriched
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
GROUP BY amenity;

CREATE OR REPLACE VIEW vw_property_age_summary AS
WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.age_group,
    vr.age_group_order,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.age_group, vr.age_group_order, o.overall_median_price_per_m2;


CREATE OR REPLACE VIEW vw_size_group_summary AS
WITH overall_median AS (
    SELECT
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS overall_median_price_per_m2
    FROM vw_rentals_enriched
)
SELECT
    vr.size_group,
    vr.size_group_order,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.total_rent)::numeric, 2) AS median_total_rent,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2)::numeric, 2) AS median_price_per_m2,
    ROUND(o.overall_median_price_per_m2::numeric, 2) AS overall_median_price_per_m2,
    ROUND((PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY vr.price_per_m2) - o.overall_median_price_per_m2)::numeric, 2) AS price_gap_vs_overall
FROM vw_rentals_enriched vr
CROSS JOIN overall_median o
GROUP BY vr.size_group, vr.size_group_order, o.overall_median_price_per_m2;