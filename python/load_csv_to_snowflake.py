import pandas as pd
from snowflake.connector import connect
from dotenv import load_dotenv
import os

load_dotenv()

# Snowflake connection
conn = connect(
    user=os.getenv("SNOWFLAKE_USER"),
    password=os.getenv("SNOWFLAKE_PASSWORD"),
    account=os.getenv("SNOWFLAKE_ACCOUNT"),
    warehouse=os.getenv("SNOWFLAKE_WAREHOUSE"),
    database="ANNE_LIQUOR_STORE",
    schema="PUBLIC"
)

def load_csv_to_snowflake(table_name, csv_path):
    cursor = conn.cursor()
    
    # Subir archivo a stage interno
    cursor.execute(f"PUT file://{csv_path} @%{table_name}")
    
    # Cargar datos
    cursor.execute(f"""
    COPY INTO {table_name}
    FROM @ANNE_LIQUOR_STORE.PUBLIC.MI_STAGE/{os.path.basename(csv_path)}
    FILE_FORMAT = (TYPE = 'CSV' FIELD_OPTIONALLY_ENCLOSED_BY = '"' SKIP_HEADER = 1)
    """)
    
    cursor.close()

# Cargar cada tabla
tables = {
    'BEG_INV': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/BegInvFINAL12312016.csv',
    'END_INV': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/EndInvFINAL12312016.csv',
    'INVOICE_PURCHASES': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/InvoicePurchases12312016.csv',
    'PURCHASES': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/PurchasesFINAL12312016.csv',
    'PURCHASE_PRICES': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/2017PurchasePricesDec.csv',
    'SALES': '/Users/ccteammember/Desktop/CC/Comvita/AMS_CSV/Fryett/SalesFINAL12312016.csv'
}

for table, path in tables.items():
    load_csv_to_snowflake(table, path)

conn.close()
