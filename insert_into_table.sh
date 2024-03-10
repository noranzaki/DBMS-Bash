#!/bin/bash
cd ./Databases/$db
# Function to insert values into a table
insertIntoTable() {
    db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name
    echo "******************************"
    list_tables "$db_name"
    tables=($(ls -F | grep '.txt*' | sed 's/\.txt\*$//' | sed 's/\.txt$//'))  # Remove trailing slash from each directory name
    PS3="Choose a Table to insert into or back to table menu: "
    echo "******************************"
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
                perform_actions $db_name
                ;;

            *)  if [ -n "$table_name" ]; then
                    metadata_file=".${table_name}-metadata.txt" 
                    fields=($(awk -F: '{print $1}' "${metadata_file}"))
                    num_fields=${#fields[@]}
                    line=""
                    types=($(awk -F: '{print $2}' "${metadata_file}"))
                    constraints=($(awk -F: '{print $3}' "${metadata_file}"))
                    nullabilities=($(awk -F: '{print $4}' "${metadata_file}"))
                    if [ -f "${metadata_file}" ]; then
                        for ((i=0; i<${num_fields}; i++)) 
                            do
                                field_name=${fields[i]}
                                field_type=${types[i]}
                                constraint=${constraints[i]}
                                nullable=${nullabilities[i]}
                                echo "data type: " $field_type
                                echo "constraint: " $constraint
                                echo "nullable: " $nullable
                                while true;
                                do
                                    read -p "Please enter the value for ${field_name}: " value
                                    if [[ "${nullable}" == "notNull" && -z "${value}" ]]; then
                                        echo "Error: ${field_name} cannot be null."
                                        continue
                                    fi
                                    if [[ -z "${value}" && "${nullable}" == "null" ]]; then
                                        value="null"
                                       
                                    fi
                                    if [[ "${field_type}" == "int" && ! "${value}" =~ ^[0-9]+$ ]]; then
                                        echo "Error: ${field_name} must be an integer."
                                        continue
                                    elif [[ "${field_type}" == "varchar" && ! "${value}" =~ ^[a-zA-Z0-9[:space:]_.@-]+$  ]]; then
                                        echo "Error: ${field_name} must be a string and does not contain special characters except ., @, _ and -"
                                        continue
                                    fi
                                    if [[ "${constraint}" == "pk" ]]; then
                                        pk_index=$(awk -F: '{if ($3 == "pk") {print NR}}' "${metadata_file}")
                                        allValues=($(awk -F: '{print $'"$pk_index"'}' "${table_name}.txt"))
                                        # num=${#allValues[@]}
                                        for val in "${allValues[@]}"; do
                                                if [ "$val" = "$value" ]; then
                                                    echo "Error: ${field_name} must be unique."
                                                    continue 2  # Continue the outer loop (for the next column)
                                                fi
                                            done
                                    fi
                                    break
                                done
                                line+=":${value}"
                            done
                        line=${line:1}
                        echo "${line}" >> "${table_name}.txt"
                        echo "======================================================"
                        echo "congratulations! data is entered successfully."
                        echo "******************************************************"
                        echo "Back to table Menu..."
                        echo "******************************************************"
                        cd ../..
                        perform_actions $db
                    else
                        echo "===================================="
                        echo "something went wrong"
                        echo "===================================="
                        perform_actions $db
                    fi
                   
                else
                    echo "Invalid option"
                fi 
            ;;
        esac
    done
}

# Entry point
insertIntoTable
