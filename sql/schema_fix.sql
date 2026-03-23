ALTER TABLE rentals_cleaned
ALTER COLUMN date TYPE date
USING date::date;

ALTER TABLE rentals_cleaned
ALTER COLUMN year_constructed TYPE integer
USING year_constructed::integer;

ALTER TABLE rentals_cleaned
ALTER COLUMN listing_year TYPE integer
USING listing_year::integer;

ALTER TABLE rentals_cleaned
ALTER COLUMN postal_code TYPE text
USING postal_code::text;