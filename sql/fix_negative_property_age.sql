-- Correct invalid negative property age values.
-- Negative ages may appear when construction year is later than listing year
-- or when source data contains inconsistent dates.

-- Check number of invalid rows before correction.
SELECT COUNT(*) AS negative_property_age_before
FROM rentals_cleaned
WHERE property_age < 0;

-- Recalculate property age:
-- - return NULL if required dates are missing
-- - return NULL if computed age is negative
-- - otherwise keep valid difference in years
UPDATE rentals_cleaned
SET property_age = CASE
    WHEN listing_year IS NULL OR year_constructed IS NULL THEN NULL
    WHEN listing_year - year_constructed < 0 THEN NULL
    ELSE listing_year - year_constructed
END;

-- Verify that no negative values remain after correction.
SELECT COUNT(*) AS negative_property_age_after
FROM rentals_cleaned
WHERE property_age < 0;