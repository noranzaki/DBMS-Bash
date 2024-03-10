#!/bin/bash
source functions.sh

# Main function
main() {
    echo "-----------------------------"
    check_if_databases_exist
    DataBase=($(ls -F ./Databases | grep / | sed 's|[/]||g'))  # Remove trailing slash from each directory name sed 's|[/]||g': Uses sed to remove the trailing slashes from each directory name. The s|[/]||g command replaces each occurrence of the slash / with nothing (| is used as a delimiter, and g means global replacement).
    PS3="Select Database: "
    select db_name in "${DataBase[@]}" "Back to Main Menu"
     do
        case $db_name in
            "Back to Main Menu")
                source ./main.sh
                ;;
            *)
                if [ -n "$db_name" ] #Checks if a valid option has been selected (if $db_name is not empty).
                    then
                        echo "Connected to database: $db_name"      
                        perform_actions "$db_name"
                    break
                else
                    echo "Invalid option"
                fi
        esac
    done
}

# Entry point
main
