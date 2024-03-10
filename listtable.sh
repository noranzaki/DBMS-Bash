#!/bin/bash
source functions.sh
cd ./Databases/$db 
db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name
echo "------------------------------"
check_if_tables_exist "$db_name"
for table in "${tables[@]}"; 
do
    echo "${table%'.txt'}"  # Remove trailing slash
done
back_table_menu $db