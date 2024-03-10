#!/bin/bash
source functions.sh
# Function to drop a database
drop_database() {
    while true; do
        echo "------------------------------"
        check_if_databases_exist
        DataBase=($(ls -F ./Databases | grep / | sed 's|[/]||g'))  # Remove trailing slash from each directory name sed 's|[/]||g': Uses sed to remove the trailing slashes from each directory name. The s|[/]||g command replaces each occurrence of the slash / with nothing (| is used as a delimiter, and g means global replacement).
        PS3="Choose db to drop or go back to Main Menu: "
        select db_name in "${DataBase[@]}" "Back to Main Menu"
        do
            case $db_name in
                "Back to Main Menu")
                    source ./main.sh 
                    ;;
                *)
                    if [ -n "$db_name" ]; 
                    then
                        echo "Dropping database: $db_name"
                        echo "-----------------------------"
                        rm -rf "./Databases/$db_name" # Remove the database directory
                        echo "Database '$db_name' dropped successfully."
                        break
                    else
                        echo "Invalid option"
                    fi
                    ;;
            esac
        done
    done
}

# Entry point
drop_database

