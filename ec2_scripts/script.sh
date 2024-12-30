#!/bin/bash

# Update and install dependencies
sudo yum update -y
#sudo yum install -y python3 python3-pip gcc libpq-devel
sudo yum install -y gcc libpq-devel make wget tar

# install python3
wget https://www.python.org/ftp/python/3.10.16/Python-3.10.16.tgz
tar -xzvf Python-3.10.16.tgz
cd Python-3.10.16
export LDFLAGS="-L/usr/local/lib"
export CPPFLAGS="-I/usr/local/include"

./configure --prefix=/usr/local
make
sudo make install

cd ../

#Install virtualenv
sudo /usr/local/bin/python3.10 -m ensurepip --upgrade
sudo /usr/local/bin/python3.10 -m pip install --upgrade pip
sudo /usr/local/bin/python3.10 -m pip install virtualenv

sudo pip3 install virtualenv
virtualenv ~/airflow_env
source ~/airflow_env/bin/activate

# Install Apache Airflow and necessary providers
pip install apache-airflow apache-airflow-providers-amazon apache-airflow-providers-postgres apache-airflow-providers-sqlite 


wget https://www.sqlite.org/2024/sqlite-autoconf-3470200.tar.gz
tar -xzvf sqlite-autoconf-3470200.tar.gz
cd sqlite-autoconf-3470200
./configure --prefix=/usr/local
make
make install

cd ../

# Set up Airflow Standalone
mkdir -p ~/airflow
export AIRFLOW_HOME=~/airflow
airflow db init
airflow users create --username admin --firstname Admin --lastname User --role Admin --email admin@example.com

# Configure DAGs folder
mkdir -p ~/airflow/dags
sed -i "s|dags_folder = .*|dags_folder = ~/airflow/dags|" ~/airflow/airflow.cfg

# Install dbt-core
pip install dbt-core

# Start Airflow webserver
nohup airflow webserver -p 8080 &
nohup airflow scheduler &

# Verify installations
echo "Verifying installations..."
airflow version
#dbt --version

echo "Installation complete."












