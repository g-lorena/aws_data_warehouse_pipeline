#!/bin/bash

set -e  # Exit on error
set -x  # Print commands as they are executed

echo "Starting script..."

# Update and install required packages
sudo apt update
sudo apt install -y python3-pip sqlite3 python3.8-venv libpq-dev

# Add PostgreSQL repository and install PostgreSQL 12
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt update
sudo apt install -y postgresql-12 postgresql-contrib-12

# Start and enable PostgreSQL service
sudo systemctl start postgresql
sudo systemctl enable postgresql

# Configure PostgreSQL to allow password-based authentication for the airflow user
sudo sed -i 's/local   all             all                                     peer/local   all             all                                     md5/g' /etc/postgresql/12/main/pg_hba.conf
sudo systemctl restart postgresql

# Create a virtual environment
python3 -m venv /home/ubuntu/venv
source /home/ubuntu/venv/bin/activate

# Install Apache Airflow with PostgreSQL support
pip install "apache-airflow[postgres]==2.8.0" --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-2.8.0/constraints-3.8.txt"

# Set Airflow home directory
export AIRFLOW_HOME=/home/ubuntu/airflow
mkdir -p $AIRFLOW_HOME

# Create the dags directory and set permissions
mkdir -p /home/ubuntu/airflow/dags/
mkdir -p /home/ubuntu/airflow/logs/
sudo chown -R ubuntu:ubuntu /home/ubuntu/airflow/
sudo chmod -R 775 /home/ubuntu/airflow/dags/
sudo chmod -R 755 /home/ubuntu/airflow/logs/


# Configure PostgreSQL for Airflow
sudo -u postgres psql <<EOF
CREATE DATABASE airflow;
CREATE USER airflow WITH PASSWORD 'airflow';
GRANT ALL PRIVILEGES ON DATABASE airflow TO airflow;
ALTER ROLE airflow SET search_path = public;
EOF

# Update Airflow configuration to use PostgreSQL
cat <<EOL > $AIRFLOW_HOME/airflow.cfg
[core]
dags_folder = /home/ubuntu/airflow/dags
executor = LocalExecutor
sql_alchemy_conn = postgresql+psycopg2://airflow:airflow@localhost/airflow
load_examples = False
fernet_key = $(python3 -c "from cryptography.fernet import Fernet; print(Fernet.generate_key().decode())")

[webserver]
web_server_port = 8080
EOL

# Initialize the Airflow database with PostgreSQL
airflow db init

# Create an Airflow user
airflow users create \
    --username airflow \
    --firstname airflow \
    --lastname airflow \
    --role Admin \
    --email airflow@gmail.com \
    --password airflow

# Create systemd services for Airflow webserver and scheduler
sudo tee /etc/systemd/system/airflow-webserver.service > /dev/null <<EOF
[Unit]
Description=Airflow webserver
After=network.target postgresql.service

[Service]
User=ubuntu
Group=ubuntu
Environment=AIRFLOW_HOME=/home/ubuntu/airflow
Environment=AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost/airflow
ExecStart=/home/ubuntu/venv/bin/airflow webserver
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

sudo tee /etc/systemd/system/airflow-scheduler.service > /dev/null <<EOF
[Unit]
Description=Airflow scheduler
After=network.target postgresql.service

[Service]
User=ubuntu
Group=ubuntu
Environment=AIRFLOW_HOME=/home/ubuntu/airflow
Environment=AIRFLOW__CORE__SQL_ALCHEMY_CONN=postgresql+psycopg2://airflow:airflow@localhost/airflow
ExecStart=/home/ubuntu/venv/bin/airflow scheduler
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd and start the services
sudo systemctl daemon-reload
sudo systemctl start airflow-webserver
sudo systemctl start airflow-scheduler
sudo systemctl enable airflow-webserver
sudo systemctl enable airflow-scheduler

echo "Installation complete. Access Airflow at http://$(curl -s ifconfig.me):8080"

# Explicitly exit the script
exit 0