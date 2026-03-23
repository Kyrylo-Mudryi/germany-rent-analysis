import os
from pathlib import Path

import logging

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

load_dotenv()

DB_USER = os.getenv('DB_USER')
DB_PASSWORD = os.getenv('DB_PASSWORD')
DB_HOST = os.getenv('DB_HOST', 'localhost')
DB_PORT = os.getenv('DB_PORT', '5432')
DB_NAME = os.getenv('DB_NAME')

if not all([DB_USER, DB_PASSWORD, DB_NAME]):
    raise ValueError('The environment variables for connecting to the database have not been set.')

BASE_DIR = Path(__file__).resolve().parent.parent
csv_path = BASE_DIR / 'data' / 'rent_cleaned.csv'

logger.info('Loading CSV file...')
df = pd.read_csv(csv_path)

logger.info(f'Loaded {len(df)} rows')

logger.info('Connecting to database...')
engine = create_engine(
    f'postgresql://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}'
)

logger.info('Writing to PostgreSQL...')
df.to_sql('rentals_cleaned', engine, if_exists='replace', index=False)

logger.info('Done.')