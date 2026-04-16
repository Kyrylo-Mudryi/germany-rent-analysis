# Load cleaned rental dataset from CSV into PostgreSQL.

# Workflow:
# 1. Read connection settings from .env
# 2. Load cleaned CSV file
# 3. Replace target table in PostgreSQL
# 4. Upload all records to rentals_cleaned

import os
from pathlib import Path

import logging

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

# Configure basic logging for ETL progress messages
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Load environment variables from .env file
load_dotenv()

DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME')

# Validate required database credentials
if not all([DB_USER, DB_PASSWORD, DB_NAME]):
    raise ValueError('The environment variables for connecting to the database have not been set.')

# Build path to cleaned dataset
BASE_DIR = Path(__file__).resolve().parent.parent
csv_path = BASE_DIR / 'data' / 'rent_cleaned.csv'

logger.info('Loading CSV file...')
df = pd.read_csv(csv_path)

logger.info(f'Loaded {len(df)} rows')

# Create PostgreSQL connection
logger.info('Connecting to database...')
engine = create_engine(
    f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
)

# Replace table and load fresh dataset
logger.info('Writing to PostgreSQL...')
df.to_sql('rentals_cleaned', engine, if_exists='replace', index=False)

logger.info('Done.')