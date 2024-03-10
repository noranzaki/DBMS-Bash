#!/bin/bash
cd ./Databases/$db

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

main (){
   list_tables "$db_name"
    tables=($(ls -F | grep '.txt*' | sed 's/\.txt\*$//' | sed 's/\.txt$//'))  # Remove trailing slash from each directory name
    PS3="Choose a Table to Delete from or go back to table menu: "
    echo "******************************"
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
            cd ../..
            perform_actions $db_name
            ;;

            *)  if [ -n "$table_name" ]; then
                    if [ ! -s "${table_name}.txt" ]; then
                        echo "Error: Table '${table_name}' is empty. No rows to delete."
                        echo "---------------------------------------------"
                        cd ../..
                        perform_actions $db_name
                        break
                    fi
                    while true; do
                        PS3="Choose what to delete from table: "
                        actions=("delete all rows" "delete row by a condition" "Exit")
                        fields=($(awk -F: '{print $1}' ".${table_name}-metadata.txt"))
                        select action in "${actions[@]}"
                        do
                            case $REPLY in
                                1)  display_table_fields
                                    truncate -s 0 "${table_name}.txt"
                                    cat ${table_name}.txt
                                    echo "All rows deleted successfully."
                                    echo "---------------------------------------------"
                                    break;;  
                            
                                2)  select_field
                                    read -p "Enter ${selected_field} value : " value
                                    output=$(awk -v idx="$selected_index" -v val="$value" -F: '$idx == val {print $0}' "${table_name}.txt")
                                    if [ -z "$output" ]; then
                                        echo "---------------------------------------------"
                                        echo "value ${output} doesn't exist in ${selected_field}."
                                    else
                                        awk -v idx="$selected_index" -v val="$value" -F: '$idx != val' "${table_name}.txt" > tmpfile && mv tmpfile "${table_name}.txt"
                                        echo "Row with ${selected_field} ${value} deleted successfully."
                                    fi
                                    echo "---------------------------------------------"
                                    break;;
                   
                                3)  echo "******************************************************"
                                    echo "Back to table Menu..."
                                    echo "******************************************************"
                                    cd ../..
                                    perform_actions $db 
                                    break ;;
                                    
                                *) echo "Invalid option";;
                            esac
                        done
                    done
                else
                    echo "Error: Table does not exist. Please choose a valid table or create a new one."
                fi 
            break;;
        esac
    done    
}

#ENTRY POINT
main