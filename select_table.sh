#!/bin/bash
source functions.sh
cd ./Databases/$db

main (){
   check_if_tables_exist "$db"
    tables=($(ls -F | grep '.txt*' | sed 's/\.txt\*$//' | sed 's/\.txt$//'))  # Remove trailing slash from each directory name
    PS3="Choose a Table to SELECT from or go back to table menu: "
    echo "******************************"
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
            cd ../..
            perform_actions $db
            ;;

            *)  if [ -n "$table_name" ]; then
                    while true; do
                        PS3="Choose what to select from table: "
                        actions=("select all" "select rows by anyfield" "select by a column" "Exit")
                        fields=($(awk -F: '{print $1}' ".${table_name}-metadata.txt"))
                        select action in "${actions[@]}"
                        do
                            case $REPLY in
                                1)  display_table_fields
                                    cat ${table_name}.txt
                                    echo "---------------------------------------------"
                                    break;;  
                            
                                2)  select_field
                                    read -p "Enter ${selected_field} value : " value
                                    output=$(awk -v idx="$selected_index" -v val="$value" -F: '$idx == val {print $0}' "${table_name}.txt")
                                    if [ -z "$output" ]; then
                                        echo "---------------------------------------------"
                                        echo "No rows found with the specified ${selected_field}."
                                    else
                                        display_table_fields
                                        echo "$output"
                                    fi
                                    echo "---------------------------------------------"
                                    break;;

                                3)  select_field
                                    output=$(cut -d: -f$selected_index "${table_name}.txt")
                                    if [ -z "$output" ]; then
                                        echo "---------------------------------------------"
                                        echo "No rows found with the specified ${selected_field}."
                                        
                                    else
                                        echo ${selected_field}
                                        echo "-----------------------------"
                                        echo "$output"
                                    fi
                                    echo "---------------------------------------------"
                                    break;;
                                    
                                4)  
                                    back_table_menu $db
                                    break ;;
                                    
                                *) echo "Invalid option";;
                            esac
                        done
                    done
                else
                    echo "Error: Table does not exist. Please choose a valid table or create a new one."
                fi 
            ;;
        esac
    done      
}

#ENTRY POINT
main