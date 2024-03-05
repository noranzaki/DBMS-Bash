#!/bin/bash

# Function to list available databases
list_databases() {
    DataBase=($(ls -F | grep / )) #to get directories onlyy 
    if [ ${#DataBase[@]} -eq 0 ] #length of array 
    then
        echo "No databases found."
        exit 1
    else
        echo "Available databases:"
    fi
}


# Function to drop a database
drop_database() {
     list_databases
    DataBase=($(ls -F | grep / | sed 's|[/]||g'))  # Remove trailing slash from each directory name sed 's|[/]||g': Uses sed to remove the trailing slashes from each directory name. The s|[/]||g command replaces each occurrence of the slash / with nothing (| is used as a delimiter, and g means global replacement).
    
    select db_name in "${DataBase[@]}" "Main Menu"
     do
         case $db_name in
            "Main Menu")
                cd ..
                ./main.sh
                break
                ;;
            *)
              if [ -n "$db_name" ]; 
              then
                echo "Dropping database: $db_name"
                rm -rf "$db_name" # Remove the database directory
                echo "Database '$db_name' dropped successfully."
                drop_database
                
            else
                echo "Invalid option"
             fi
        esac
    done
}

# Entry point
drop_database
