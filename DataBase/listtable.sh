#!/bin/bash
cd ./$db 
db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name

list_tables "$db_name"
