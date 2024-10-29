import json
import os
import psycopg2
import boto3

REDSHIFT_HOST = os.environ['REDSHIFT_HOST']
REDSHIFT_DB = os.environ['REDSHIFT_DB']
REDSHIFT_USER = os.environ['REDSHIFT_USER']
REDSHIFT_PASSWORD = os.environ['REDSHIFT_PASSWORD']
REDSHIFT_ROLE_ARN = os.environ['REDSHIFT_ROLE_ARN']

def lambda_handler(event, context):
    try:
        conn = psycopg2.connect(
            dbname=REDSHIFT_DB,
            user=REDSHIFT_USER,
            password=REDSHIFT_PASSWORD,
            host=REDSHIFT_HOST,
            port='5439'
        )