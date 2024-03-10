#!/bin/bash

# Function to list available databases
check_if_databases_exist() 
{
    Databases=($(ls -F ./Databases | grep / )) #to get directories onlyy 
    if [ ${#Databases[@]} -eq 0 ] #length of array 
    then
        echo "No databases found."
        source ./main.sh
    else
        echo "Available databases:"
    fi
    echo "******************************"
}

check_if_tables_exist() {
    echo "Available tables in '$1':"
    echo "******************************"
    tables=($(ls -F  | grep '.txt'))
    if [ ${#tables[@]} -eq 0 ]; then
        echo "No tables found in '$1'."
    fi
}

display_table_fields() {
    echo "----------"
    echo "| Table: |"
    echo "----------"
    fields=$(awk -F: '{printf ":%s", $1}' ".${table_name}-metadata.txt")
    echo "${fields:1}"
    echo "---------------------------------"
}

select_field(){
    PS3="Select a field: "
    select field in "${fields[@]}"; do
        if [ -n "$field" ]; then
            selected_field="$field"
            break
        else
            echo "Invalid selection. Please try again."
        fi
    done
    echo "You selected: $selected_field"
    selected_index=$(awk -F: -v name="$selected_field" '$1 == name {print NR}' ".${table_name}-metadata.txt")
}

# Function to perform actions within a selected database
perform_actions() {
    db=$1
    cd ./Databases/$db
    PS3="Enter your option for tables: "
    actions=("Create table" "Insert data in table" "Drop Table" "Select from table" "Delete from table" "Update" "List" "Exit")
    select action in "${actions[@]}"
    do
        case $REPLY in
            1) 
                cd ../..
                 source ./createtable.sh; break;;  

            2) 
                cd ../..
               source insert_into_table.sh; break;;

            3) cd ../..
               source ./drop_table.sh ; break;;

            4) cd ../..
               source ./select_table.sh ; break;;

            5) cd ../..
               source ./delete_from_table.sh ; break;;

            6) cd ../..
               source ./update_table.sh; break;;
               
            7) cd ../..
               source ./listtable.sh; break;;

            8) cd ../..
               source ./connect.sh ; break;;

            *) echo "Invalid option";;
        esac
    done
}

back_table_menu(){
    db=$1
    echo "******************************************************"
    echo "Back to table Menu..."
    echo "******************************************************"
    cd ../..
    perform_actions $db 
}