#!/bin/bash

echo "Starting PostgreSQL Restore Process..."

# Start second container and restore the database
docker run --name pg_container_restore -e POSTGRES_USER=tremend -e POSTGRES_PASSWORD=securepass -d -p 5433:5432 postgres
sleep 10
docker exec pg_container_restore psql -U tremend -c "CREATE DATABASE company_db_restore;"

docker exec pg_container_restore psql -U tremend -d company_db_restore -c "CREATE USER ps_cee WITH SUPERUSER PASSWORD 'adminpass';"

docker cp company_db_dump.sql pg_container_restore:/company_db_dump.sql
docker exec pg_container_restore psql -U ps_cee -d company_db_restore -c "ALTER DATABASE company_db_restore OWNER TO ps_cee;"
docker exec pg_container_restore pg_restore -U ps_cee -d company_db_restore -F c /company_db_dump.sql --no-owner --exit-on-error

# Execute queries on the restored database
mkdir -p logs
echo "Running SQL Queries on the Restored Database..."

docker exec pg_container_restore psql -U ps_cee -d company_db_restore -c "SELECT COUNT(*) FROM employees;" > logs/employee_count.log
echo "Employee count saved to logs/employee_count.log"

echo "Enter department name for query: "
read DEPARTMENT_NAME
docker exec pg_container_restore psql -U ps_cee -d company_db_restore -c "SELECT first_name, last_name FROM employees JOIN departments ON employees.department_id = departments.department_id WHERE department_name = '$DEPARTMENT_NAME';" > logs/employees_query.log
echo "Department query results saved to logs/employees_query.log"

docker exec pg_container_restore psql -U ps_cee -d company_db_restore -c "SELECT departments.department_name, MAX(salaries.salary), MIN(salaries.salary) FROM employees JOIN salaries ON employees.employee_id = salaries.employee_id JOIN departments ON employees.department_id = departments.department_id GROUP BY departments.department_name;" > logs/salary_query.log
echo "Salary query results saved to logs/salary_query.log"

echo "Restore setup complete. Logs saved in logs/"