#!/bin/bash
echo "Create DB"
echo "=========="
while true; do
    read -p "Enter the database name and dont add any special characters or spaces: "  dbname
    
    if [[ -d ./Databases/$dbname ]]; then
        echo "Error: this database already exists please enter a new one"
        
    elif [[ $dbname =~ ^[a-zA-Z][a-zA-Z0-9]*$ ]]; then
        mkdir ./Databases/$dbname
        echo "Database $dbname created successfully"
        break
    else
        echo "Error: Enter a database name that starts with a character and contains no special characters or spaces."
    fi
done
./main.sh


