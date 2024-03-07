#!/bin/bash
#pwd
#echo "list db"

list_databases
for Databases in "${Databases[@]}"; 
do
    echo "${Databases%'/'}"  # Remove trailing slash
done
source ./main.sh