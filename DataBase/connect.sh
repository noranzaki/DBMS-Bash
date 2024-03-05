#!/bin/bash
echo "Testt nb2a nshelhaa lma nkhls.."

list_tables() {
    echo "Available tables in '$1':"
    tables=($(ls -F  | grep '.txt'))
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in '$1'."
    else
        for table in "${tables[@]}"; do
            echo "${table%'.txt'}"  # Remove trailing slash
        done
    fi
}
export -f list_tables


# Function to perform actions within a selected database
perform_actions() {
    database=$1
    cd ./$database

    actions=("Create table" "Insert data in table" "Drop data in table" "Select from table" "Delete from table" "Update" "List" "Exit")
    select action in "${actions[@]}"
    do
        case $REPLY in
            1) 
                db=$database
                export db
                 cd .. 
                . ./createtable.sh; break;;  

            2) echo "You selected: Insert data in table";;
            3) echo "You selected: Drop data in table";;
            4) echo "You selected: Select from table";;
            5) echo "You selected: Delete from table";;
            6) echo "You selected: Update";;
            7)  db=$database
                export db
                 cd .. 
                . ./listtable.sh; break;;
            8) 
                cd ../.. ;  ./main.sh ; break;;
            *) echo "Invalid option";;
        esac
    done
}

# Main function
main() {
    list_databases
    DataBase=($(ls -F | grep / | sed 's|[/]||g'))  # Remove trailing slash from each directory name sed 's|[/]||g': Uses sed to remove the trailing slashes from each directory name. The s|[/]||g command replaces each occurrence of the slash / with nothing (| is used as a delimiter, and g means global replacement).
    
    select db_name in "${DataBase[@]}" "Main Menu"
     do
        case $db_name in
            "Main Menu")
                cd ..
                ./main.sh
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
