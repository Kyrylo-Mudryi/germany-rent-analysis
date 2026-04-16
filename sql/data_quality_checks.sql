-- Basic data quality check:
-- evaluate completeness of key categorical columns.
SELECT
    COUNT(*) AS total_rows,
    COUNT(heating_type) AS heating_type_not_null,
    COUNT(condition) AS condition_not_null,
    COUNT(interior_qual) AS interior_qual_not_null,
    COUNT(type_of_flat) AS type_of_flat_not_null
FROM rentals_cleaned;


-- Range check for core numeric features:
-- detect impossible or suspicious min / max values.
SELECT
    MIN(total_rent) AS min_total_rent,
    MAX(total_rent) AS max_total_rent,
    MIN(living_space) AS min_living_space,
    MAX(living_space) AS max_living_space,
    MIN(price_per_m2) AS min_price_per_m2,
    MAX(price_per_m2) AS max_price_per_m2
FROM rentals_cleaned;