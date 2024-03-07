#!/bin/bash
cd ./Databases/$db 
db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name

list_tables "$db_name"
cd ../.. 
echo "------------------------------"
echo "Back to Table Menu.."
echo "------------------------------"
perform_actions $db