FROM apache/airflow:2.10.0

# Install sudo
USER root
RUN apt-get update && apt-get install -y sudo

# Allow the 'airflow' user to use sudo without a password
RUN echo "airflow ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Switch to the default airflow user
USER airflow

COPY requirements.txt .

COPY ./dags/ \${AIRFLOW_HOME}/dags/

RUN pip install apache-airflow==${AIRFLOW_VERSION} -r requirements.txt

RUN python -m venv dbt_venv && \
    . dbt_venv/bin/activate && \
    pip install --no-cache-dir -r requirements.txt && \
    deactivate