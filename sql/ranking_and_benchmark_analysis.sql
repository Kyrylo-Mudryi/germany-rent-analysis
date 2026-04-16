-- Window function analysis:
-- rank cities, districts, and listings by rental price,
-- and compare local price levels against city benchmarks.

-- Rank cities by median price per m²
-- Only cities with at least 30 listings
WITH city_medians AS (
    SELECT
        city,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS median_price_per_m2
    FROM rentals_cleaned
    GROUP BY city
    HAVING COUNT(*) >= 30
)
SELECT
    DENSE_RANK() OVER (ORDER BY median_price_per_m2 DESC) AS city_rank,
    city,
    number_of_listings,
    ROUND(median_price_per_m2::numeric, 2) AS median_price_per_m2
FROM city_medians
ORDER BY city_rank, city;

-- Rank districts within each city by median price per m²
-- Compare district-level average and median price vs city benchmarks
WITH district_summary AS (
    SELECT
        city,
        district,
        COUNT(*) AS number_of_listings,
        AVG(price_per_m2) AS district_avg_price_per_m2,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS district_median_price_per_m2
    FROM rentals_cleaned
    GROUP BY city, district
    HAVING COUNT(*) >= 20
),
city_summary AS (
    SELECT
        city,
        AVG(price_per_m2) AS city_avg_price_per_m2,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS city_median_price_per_m2
    FROM rentals_cleaned
    GROUP BY city
    HAVING COUNT(*) >= 30
)
SELECT
    ds.city,
    ds.district,
    ds.number_of_listings,
    ROUND(ds.district_avg_price_per_m2::numeric, 2) AS district_avg_price_per_m2,
    ROUND(cs.city_avg_price_per_m2::numeric, 2) AS city_avg_price_per_m2,
    ROUND((ds.district_avg_price_per_m2 - cs.city_avg_price_per_m2)::numeric, 2) AS avg_gap_district_vs_city,
    ROUND(ds.district_median_price_per_m2::numeric, 2) AS district_median_price_per_m2,
    ROUND(cs.city_median_price_per_m2::numeric, 2) AS city_median_price_per_m2,
    ROUND((ds.district_median_price_per_m2 - cs.city_median_price_per_m2)::numeric, 2) AS median_gap_district_vs_city,
    RANK() OVER (PARTITION BY ds.city ORDER BY ds.district_median_price_per_m2 DESC) AS district_rank_in_city
FROM district_summary ds
INNER JOIN city_summary cs
    ON ds.city = cs.city
ORDER BY ds.city, district_rank_in_city, ds.district;

-- Identify districts priced above their city average
-- Uses a window function to attach city average to each listing
WITH listing_base AS (
    SELECT
        city,
        district,
        price_per_m2,
        AVG(price_per_m2) OVER (PARTITION BY city) AS city_avg_price_per_m2
    FROM rentals_cleaned
),
district_vs_city AS (
    SELECT
        city,
        district,
        COUNT(*) AS number_of_listings,
        AVG(price_per_m2) AS district_avg_price_per_m2,
        MAX(city_avg_price_per_m2) AS city_avg_price_per_m2
    FROM listing_base
    GROUP BY city, district
    HAVING COUNT(*) >= 20
)
SELECT
    city,
    district,
    number_of_listings,
    ROUND(district_avg_price_per_m2::numeric, 2) AS district_avg_price_per_m2,
    ROUND(city_avg_price_per_m2::numeric, 2) AS city_avg_price_per_m2,
    ROUND((district_avg_price_per_m2 - city_avg_price_per_m2)::numeric, 2) AS price_gap_district_vs_city_avg,
    RANK() OVER (PARTITION BY city ORDER BY district_avg_price_per_m2 DESC) AS district_rank_by_avg_price
FROM district_vs_city
WHERE district_avg_price_per_m2 > city_avg_price_per_m2
ORDER BY city, district_rank_by_avg_price, district;

-- Rank listings within each city by price per m²
-- Keep only listings above the city median
WITH city_medians AS (
    SELECT
        city,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2) AS city_median_price_per_m2
    FROM rentals_cleaned
    GROUP BY city
    HAVING COUNT(*) >= 30
)
SELECT
    r.city,
    r.district,
    r.total_rent,
    r.living_space,
    ROUND(r.price_per_m2::numeric, 2) AS price_per_m2,
    ROUND(cm.city_median_price_per_m2::numeric, 2) AS city_median_price_per_m2,
    ROUND((r.price_per_m2 - cm.city_median_price_per_m2)::numeric, 2) AS price_gap_vs_city_median,
    RANK() OVER (PARTITION BY r.city ORDER BY r.price_per_m2 DESC) AS listing_rank_in_city
FROM rentals_cleaned r
INNER JOIN city_medians cm
    ON r.city = cm.city
WHERE r.price_per_m2 > cm.city_median_price_per_m2
ORDER BY r.city, listing_rank_in_city, r.price_per_m2 DESC;

-- Identify premium listings in each city
-- Premium = top price decile and total rent at or above city median
WITH city_thresholds AS (
    SELECT
        city,
        COUNT(*) AS number_of_listings,
        PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_rent) AS city_median_total_rent
    FROM rentals_cleaned
    GROUP BY city
    HAVING COUNT(*) >= 30
),
premium_candidates AS (
    SELECT
        r.city,
        r.district,
        r.total_rent,
        r.living_space,
        r.no_rooms,
        r.newly_const,
        r.has_kitchen,
        r.balcony,
        r.lift,
        r.garden,
        r.interior_qual,
        r.price_per_m2,
        ct.city_median_total_rent,
        NTILE(10) OVER (PARTITION BY r.city ORDER BY r.price_per_m2 DESC) AS price_decile,
        RANK() OVER (PARTITION BY r.city ORDER BY r.price_per_m2 DESC) AS listing_rank_in_city
    FROM rentals_cleaned r
    INNER JOIN city_thresholds ct
        ON r.city = ct.city
)
SELECT
    city,
    district,
    listing_rank_in_city,
    ROUND(price_per_m2::numeric, 2) AS price_per_m2,
    ROUND(total_rent::numeric, 2) AS total_rent,
    ROUND(city_median_total_rent::numeric, 2) AS city_median_total_rent,
    ROUND(living_space::numeric, 2) AS living_space,
    no_rooms,
    newly_const,
    has_kitchen,
    balcony,
    lift,
    garden,
    COALESCE(interior_qual, 'No data') AS interior_qual,
    'premium listing' AS listing_segment
FROM premium_candidates
WHERE price_decile = 1
  AND total_rent >= city_median_total_rent
ORDER BY city, listing_rank_in_city;
