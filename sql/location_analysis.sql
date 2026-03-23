SELECT
    city,
    COUNT(*) AS number_of_listings
FROM rentals_cleaned
GROUP BY city
ORDER BY number_of_listings DESC
LIMIT 10;

SELECT
    city,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM rentals_cleaned
GROUP BY city
HAVING COUNT(*) >= 30
ORDER BY median_price_per_m2 DESC;

SELECT
    state,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM rentals_cleaned
GROUP BY state
HAVING COUNT(*) >= 30
ORDER BY median_price_per_m2 DESC;


SELECT
    city,
    district,
    COUNT(*) AS number_of_listings,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY price_per_m2)::numeric, 2) AS median_price_per_m2
FROM rentals_cleaned
GROUP BY city, district
HAVING COUNT(*) >= 30
ORDER BY median_price_per_m2 DESC
LIMIT 20;