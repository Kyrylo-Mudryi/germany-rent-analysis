# Germany Rent Analysis

## Stack
- Python (pandas, SQLAlchemy)
- PostgreSQL
- SQL
- Power BI (planned)

## Project structure
- data/ — datasets
- notebooks/ — EDA
- scripts/ — data loading
- sql/ — queries

## Data

Raw data is not included in the repository.

To run the project:
1. Download dataset from [https://www.kaggle.com/datasets/corrieaar/apartment-rental-offers-in-germany/data]
2. Place it in /data/raw_data.csv

## Setup

property_age was recalculated as listing_year - year_constructed to align property age with the actual listing date rather than the current year. This avoids artificially aging the properties and improves the validity of age-based analysis.