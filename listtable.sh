#!/bin/bash
cd ./Databases/$db 
db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name

list_tables "$db_name"
for table in "${tables[@]}"; 
do
    echo "${table%'.txt'}"  # Remove trailing slash
done
echo "------------------------------"
echo "Back to Table Menu.."
echo "------------------------------"
cd ../..
perform_actions $db