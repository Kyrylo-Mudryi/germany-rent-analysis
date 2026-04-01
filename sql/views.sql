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
