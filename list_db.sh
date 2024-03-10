#!/bin/bash
#pwd
#echo "list db"
echo "------------------------------"
list_databases
for Databases in "${Databases[@]}"; 
do
    echo "${Databases%'/'}"  # Remove trailing slash
done
source ./main.sh