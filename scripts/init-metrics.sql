CREATE USER postgres_exporter WITH PASSWORD 'exporter_password';
GRANT pg_monitor TO postgres_exporter;