#!/bin/bash

sudo apt update
sudo apt install python3-pip
sudo apt install sqlite3
sudo apt install python3.8-venv
python3 -m venv venv
source venv/bin/activate

sudo apt-get install libpq-dev
pip install "apache-airflow[postgres]==2.8.0" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.0/constraints-3.8.txt"
airflow db init

sudo apt-get install postgresql postgresql-contrib
sudo -i -u postgres
psql

CREATE DATABASE airflow;
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;

cd airflow
sed -i 's#sqlite:////home/ubuntu/airflow/airflow.db#postgresql+psycopg2://airflow:airflow@localhost/airflow#g' airflow.cfg
grep sql_alchemy airflow.cfg
grep executor airflow.cfg
sed -i 's#SequentialExecutor#LocalExecutor#g' airflow.cfg

airflow db init
airflow users create -u airflow -f airflow -l airflow -r Admin -e airflow@gmail.com

# mdp : airflow 
# mdp : airflow

airflow webserver &
airflow scheduler

#http://your-ec2-public-ip:8080

echo "Installation complete."