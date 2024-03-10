#!/bin/bash
source functions.sh
cd ./Databases/$db 

update_specific_value() {
    table_name=$1
    column_name=$2

    pwd

    # Read metadata for the specified table name
    metadata_file="./.$table_name-metadata.txt"

    
    column_metadata=$(awk -F: -v col="$column_name" '$1 == col {print $2,$3,$4}' "$metadata_file")

    # Extract column metadata
    IFS=' ' read -r column_type pk constraints <<< "$column_metadata"
   
    # Check if the metadata file exists
    if [ ! -f "$metadata_file" ]; then
        echo "Error: Metadata file not found: $metadata_file"
        return
    fi

    # Check if the column exists in the table metadata
    if [ -z "$column_name" ]; then
        echo "Error: Column '$column_name' does not exist in the metadata for table '$table_name'."
        return
    fi

    # Read column values from the table file for the specified column
    table_file="./$table_name.txt"
    if [ ! -f "$table_file" ]; then
        echo "Error: Table file '$table_file' not found."
        return
    fi
# Get the column number for the specified column name
    column_numbers=$(awk -F: -v col="$column_name" '$1 == col { print NR }' "$metadata_file")

# Check if the column exists in the metadata
    if [ -z "$column_numbers" ]; then
        echo "Error: Column '$column_name' does not exist in the metadata for table '$table_name'."
        return
    fi


    # Read column values from the table file for the specified column
    column_values=$(cut -d: -f"$column_numbers" "$table_file")
    if [[ -z $column_values ]]
    then
        echo "$table_name has no data"
        return
    fi

    #Display column values to the user
    echo "----------------------------"
    echo "Existing values in the '$column_name' column:"
    echo "----------------------------"

    select old_value in $column_values; 
    do
        if [ -n "$old_value" ]; 
        then
             # Get the index of the selected value
            index=$((REPLY))
            break
        else
            echo "Invalid selection. Please choose a valid value."
        fi
    done

    while true; 
    do
        echo "----------------------------"
        read -p "Enter the new value: " new_value
         # If the column is a primary key, check if the new value already exists in the column values
        if [[ $pk == 'pk' ]]; then
            duplicate_found=false
            for value in $column_values; do
                if [ "$value" = "$new_value" ]; then
                    echo "Error: The new value already exists in the specified column '$column_name' of the table."
                    duplicate_found=true
                    break   # Exit the loop
                fi
            done
            if [ "$duplicate_found" = true ]; then
                continue   # Prompt the user again
            fi
        fi

        if [[ $constraints == *'null'* ]] && [ -z "$new_value" ]; then
            break;
        fi

        # If the column is not null, check if the new value is empty
        if [[ $constraints == *'notNull'* ]] && [ -z "$new_value" ]; then
            echo "Error: The new value cannot be empty as the column does not allow null values."
            continue  # Prompt the user again
        fi

    # If the column is of type int, check if the new value is an integer
        if [[ $column_type == 'int' ]] && ! [[ "$new_value" =~ ^[0-9]+$ ]]; then
            echo "Error: The new value must be an integer."
            continue  # Prompt the user again
        fi
        if [[ $column_type == "varchar" ]] && ! [[ "$new_value" =~ ^[a-zA-Z0-9[:space:]_.@-]+$ ]]; then
        echo "Error: The new value must be a string and cannot contain special characters except ., @, _, and -"
        continue
        fi


        # If all validation checks pass, break out of the loop
        break
    done

    if [[ -z "$new_value" ]]; 
    then
        new_value="null"
    fi  

    # Use awk to update the value at the specified index in the specified column
    
    # awk -i inplace -v indx="$index" -v new_value="$new_value" -v col="$column_numbers" -F':' 'BEGIN{OFS=":"} { for (i=1; i<=NF; i++) { if (i == col) { if (NR == indx) $i = new_value } } print }' "$table_file"
    awk -v indx="$index" -v new_value="$new_value" -v col="$column_numbers" -F':' 'BEGIN{OFS=":"} { if (NR == indx) $col = new_value; print }' "$table_file" > temp && mv temp "$table_file"
    echo "***************************"
    echo "Value updated successfully."
    echo "***************************"
}





list_columns_from_metadata() {
    table_name=$1
    metadata_file="./.$table_name-metadata.txt"

    # Check if the metadata file exists
    if [ ! -f "$metadata_file" ]; then
        echo "Metadata file not found: $metadata_file"
        return
    fi
    # Use awk to extract column names from the metadata file
    column_names=$(awk -F: '{print $1}' "$metadata_file")
    echo "$column_names"
}

update_table() {
    table_name=$1

    # List column names from metadata
    metadata_columns=$(list_columns_from_metadata "$table_name")
    echo "----------------------------"
    echo "Columns in $table_name metadata:"
    # echo "$metadata_columns"
    # Get the column number for the specified column name
    PS3="Enter the number corresponding to the column you want to update: "
    echo "----------------------------"
    select column_name in $metadata_columns; do
        if [ -n "$column_name" ]; then
            break
        else
            echo "Invalid selection. Please choose a valid column number."
        fi
    done
    update_specific_value "$table_name" "$column_name"

}




choose_table() {
    db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name
    check_if_tables_exist "$db_name"
    tables=($(ls -F | grep '.txt*' | sed 's/\.txt\*$//' | sed 's/\.txt$//'))  # Remove trailing slash from each directory name
    PS3="Choose a Table to update: "
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
                cd ../.. #3shan fi mshkla fl path bykon hena gwa db w fl function by3ml cd tany 
                perform_actions $db 
                ;;
            *)
                if [ -n "$table_name" ]; 
                then
                    echo "Updating Table: $table_name"
                    # Read column values from the table file for the specified column
                    if [[ ! -s "./$table_name.txt" ]]; then
                        echo "$table_name has no data. Try inserting data first."
                        cd ../..
                        perform_actions "$db"
                    else
                    update_table $table_name
                    cd ../..
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
choose_table