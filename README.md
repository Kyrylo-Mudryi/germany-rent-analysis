# Germany Rent Analysis

## Overview

This project is a portfolio case study focused on exploratory and SQL-based analysis of apartment rental listings in Germany.

The dataset comes from the Kaggle dataset [Apartment rental offers in Germany](https://www.kaggle.com/datasets/corrieaar/apartment-rental-offers-in-germany/data). It was last updated several years ago, so the results should not be treated as a current view of the German rental market. The goal of the project is to demonstrate data analytics skills rather than provide up-to-date market intelligence.

Potential users of this type of analysis could include renters comparing local price levels, landlords reviewing listing positions, or real-estate investors exploring rental market patterns.

## Project Goals

- Clean and standardize a real-world rental listings dataset
- Create reusable analytical features such as `price_per_m2` and `property_age`
- Explore pricing patterns across cities, states, apartment sizes, room counts, and amenities
- Load the cleaned dataset into PostgreSQL
- Build SQL queries and analytical views for repeatable analysis
- Validate SQL outputs against pandas calculations

## Tech Stack

- Python
- pandas
- NumPy
- SQLAlchemy
- PostgreSQL
- SQL
- Jupyter Notebook
- Power BI or dashboard layer planned for the next stage

## Dataset

- Source: [Kaggle - Apartment rental offers in Germany](https://www.kaggle.com/datasets/corrieaar/apartment-rental-offers-in-germany/data)
- Raw input file expected by the project: `data/raw_data.csv`
- Cleaned output created during preprocessing: `data/rent_cleaned.csv`

The repository currently uses a historical dataset. This is important context when interpreting prices, listing volumes, and regional comparisons.

## What Was Done

The project is organized as a compact analytics pipeline:

1. Raw rental listing data is cleaned in the notebook workflow.
2. New analytical features are created, including `listing_year`, `price_per_m2`, and `property_age`.
3. Invalid or inconsistent records are filtered out, including unrealistic price-per-square-meter values.
4. The cleaned dataset is exported to CSV and loaded into PostgreSQL.
5. SQL scripts and views are used for repeatable market analysis.
6. Validation checks confirm that SQL results match pandas-based calculations.

## Key Analytical Areas

- Data cleaning and feature engineering
- Exploratory data analysis in notebooks
- Location-based pricing analysis
- Apartment size and room-count analysis
- Property age analysis
- Amenity impact analysis
- Data quality checks
- SQL-to-pandas validation

## Repository Structure

```text
germany_rent_analysis/
|-- data/
|   |-- raw_data.csv
|   `-- rent_cleaned.csv
|-- notebooks/
|   |-- data_cleaning.ipynb
|   |-- EDA.ipynb
|   `-- validation.ipynb
|-- src/
|   `-- csv_to_sql.py
|-- sql/
|   |-- amenities_analysis.sql
|   |-- data_quality_checks.sql
|   |-- fix_negative_property_age.sql
|   |-- location_analysis.sql
|   |-- property_age_analysis.sql
|   |-- quality_analysis.sql
|   |-- schema_fix.sql
|   |-- size_analysis.sql
|   |-- views.sql
|   `-- window_functions.sql
|-- .env.example
`-- README.md
```

## Notebooks

### `notebooks/data_cleaning.ipynb`

Main preprocessing notebook. It:

- loads the raw dataset
- standardizes columns and types
- derives `listing_year` from the listing date
- creates `price_per_m2`
- calculates `property_age` as `listing_year - year_constructed`
- removes negative `property_age` values by converting them to missing values
- filters unrealistic observations such as extreme `price_per_m2`
- exports the cleaned dataset to `data/rent_cleaned.csv`

### `notebooks/EDA.ipynb`

Exploratory analysis notebook for identifying rental market patterns, including:

- price distributions
- regional comparisons
- state and city-level differences
- room-count and size effects
- condition and interior quality patterns
- amenity-related price differences

### `notebooks/validation.ipynb`

Validation notebook that checks consistency between pandas and PostgreSQL:

- cleaned CSV vs PostgreSQL table
- SQL quality checks vs pandas calculations
- SQL views vs equivalent pandas aggregations

## SQL Layer

The `sql/` folder contains reusable SQL scripts for analysis and validation.

Highlights:

- `views.sql` creates analytical views such as:
  - `vw_rentals_enriched`
  - `vw_city_price_summary`
  - `vw_rooms_group_summary`
  - `vw_amenities_summary`
  - `vw_property_age_summary`
- `data_quality_checks.sql` checks completeness and numeric ranges
- `schema_fix.sql` aligns PostgreSQL column types
- `fix_negative_property_age.sql` addresses the negative `property_age` issue found during validation

## Setup

### 1. Create and activate a virtual environment

```powershell
python -m venv .venv
.venv\Scripts\Activate.ps1
```

### 2. Install dependencies

This project uses Python notebooks and PostgreSQL connectivity. If you do not already have the required packages installed, install at least:

```powershell
pip install pandas numpy jupyter python-dotenv sqlalchemy psycopg2-binary
```

### 3. Configure environment variables

Create a local `.env` file based on `.env.example`:

```env
DB_USER=postgres
DB_PASSWORD=your_password_here
DB_HOST=localhost
DB_PORT=5432
DB_NAME=your_database_name
```

### 4. Prepare the data

Download the dataset from Kaggle and place the raw file at:

```text
data/raw_data.csv
```

Then run the cleaning notebook to produce:

```text
data/rent_cleaned.csv
```

## How to Run the Project

### Option 1. Notebook-first workflow

Recommended if you want to reproduce the full analytical process:

1. Run `notebooks/data_cleaning.ipynb`
2. Run `notebooks/EDA.ipynb`
3. Load the cleaned CSV into PostgreSQL using `src/csv_to_sql.py`
4. Execute `sql/schema_fix.sql` if needed
5. Execute `sql/views.sql`
6. Run analytical SQL scripts from the `sql/` folder
7. Run `notebooks/validation.ipynb`

### Option 2. Load cleaned data directly to PostgreSQL

If `data/rent_cleaned.csv` already exists:

```powershell
python src/csv_to_sql.py
```

This script loads the cleaned file into the PostgreSQL table `rentals_cleaned`.

## Important Modeling Note

`property_age` is calculated as:

```text
listing_year - year_constructed
```

This approach is intentional. It measures the age of the property at the time the listing was published, rather than using the current year. That makes the feature more analytically correct for historical listings.

## Validation Note

During validation, a data issue was identified where `property_age` could appear as a negative value in SQL outputs. A fix script was added in:

```text
sql/fix_negative_property_age.sql
```

Small differences between SQL and pandas median-based aggregates may still appear after rounding. This is expected because PostgreSQL uses `PERCENTILE_CONT`, while pandas uses `median()`. In borderline cases, differences around `0.01` are treated as acceptable numeric tolerance.

## Main Takeaways

- Rental prices vary significantly across German regions
- Location is one of the strongest drivers of rental price differences
- Apartment size, room count, and property age all affect pricing patterns
- Amenities such as balcony, lift, kitchen, garden, and cellar can be associated with price differences
- Validation is an important part of analytics work, especially when combining pandas and SQL logic

## Limitations

- The dataset is historical and not suitable for current market conclusions
- The project is analytical rather than predictive
- Some fields contain missing values that affect certain segments of analysis
- The dashboard layer is planned but not yet finalized in this repository

## Next Steps

- Build an interactive dashboard for key rental market views
- Add a more polished business-style summary of insights
- Document final conclusions from the dashboard stage
- Expand README visuals with charts or screenshots
