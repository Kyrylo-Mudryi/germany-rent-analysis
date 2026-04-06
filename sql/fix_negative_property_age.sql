SELECT COUNT(*) AS negative_property_age_before
FROM rentals_cleaned
WHERE property_age < 0;

UPDATE rentals_cleaned
SET property_age = CASE
    WHEN listing_year IS NULL OR year_constructed IS NULL THEN NULL
    WHEN listing_year - year_constructed < 0 THEN NULL
    ELSE listing_year - year_constructed
END;

SELECT COUNT(*) AS negative_property_age_after
FROM rentals_cleaned
WHERE property_age < 0;
