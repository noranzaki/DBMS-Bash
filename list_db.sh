#!/bin/bash
source functions.sh
echo "------------------------------"
check_if_databases_exist
for Databases in "${Databases[@]}"; 
do
    echo "${Databases%'/'}"  # Remove trailing slash
done
source ./main.sh