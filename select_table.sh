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
    PS3="Choose a Table to SELECT from or go back to table menu: "
    echo "******************************"
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
            cd ../..
            perform_actions $db_name
            ;;

            *)  if [ -n "$table_name" ]; then
                    while true; do
                    PS3="Choose what to select from table: "
                    actions=("select all" "select rows by anyfield" "select columns" "Exit")
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
                                
                            4)  echo "******************************************************"
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
                echo "Invalid option"
            fi 
            ;;
        esac
    done      
}

#ENTRY POINT
main