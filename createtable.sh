#!/bin/bash

cd ./Databases/$db 
shopt -s extglob

# Function to insert metadata for a table
insert_metadata() {
    local db_name="$1"
    local table_name="$2"
    local num_columns="$3"
    local primary_key_chosen=false
    local metadata=""
    declare -a column_names  # Array to store column names
    declare -a column_types  # Array to store column types
    declare -a metadata_lines  # Array to store metadata lines for each column

    # Loop to gather metadata for each column
    for ((i = 1; i <= num_columns; i++)); 
    do
        echo "Column $i:"
        local column_name
        while true; do
            read -rp "Enter column name: " column_name

            # Validate column name
            while ! [[ "$column_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]; do
                echo "Invalid column name. Column name must start with a letter, followed by letters, digits, or underscores."
                read -rp "Enter column name: " column_name
            done

            # Check if column name already exists in column_names array
            if [[ " ${column_names[@]} " =~ " $column_name " ]]; then
                echo "Column '$column_name' already exists. Please enter a different name."
                continue
            else
                column_names+=("$column_name")
                break
            fi
        done

        read -rp "Enter column type (int/varchar): " column_type

        # Check if column type is valid
        while [[ "$column_type" != "int" && "$column_type" != "varchar" ]]; do
            echo "Invalid column type. Please enter 'int' or 'varchar'."
            read -rp "Enter column type (int/varchar): " column_type
            
        done
        column_types+=("$column_type")



     # Ask if the column is the primary key
        if [ "$primary_key_chosen" == false ]; 
        then

            while true;
            do
                read -rp "Is this column the primary key? (yes/no): " is_primary_key

                if [[ "$is_primary_key" == "yes" || "$is_primary_key" == "no" ]];
                then
                    echo ""

                    break;
                else
                    echo "Invalid input. Please enter 'yes' or 'no'."
                fi
            done

            if [ "$is_primary_key" = "yes" ]; 
            then
                primary_key_chosen=true
                pk="pk"
                nullable="notNull"
                is_nullable="no"  # Ensure primary key cannot be null
            else
                pk="notPk"
                read -rp "Is this column nullable? (yes/no): " is_nullable
                if [ "$is_nullable" = "yes" ]; 
                then
                     nullable="null"
                else
                    nullable="notNull"
                fi
            fi
        else
            pk="notPk"
            read -rp "Is this column nullable? (yes/no): " is_nullable
            if [ "$is_nullable" = "yes" ]; 
            then
                nullable="null"
            else
                nullable="notNull"
            fi
        fi

      
   


        # Validate the input
        while [[ "$is_nullable" != "yes" && "$is_nullable" != "no" ]]; do
            echo "Invalid input. Please enter 'yes' or 'no'."
            read -rp "Is this column nullable? (yes/no): " is_nullable
            if [ "$is_nullable" = "yes" ]; then
                nullable="null"
            else
                nullable="notNull"
            fi
        done

        # Append metadata line to the array
        metadata_lines+=("$column_name:$column_type:$pk:$nullable")
        
        # Display gathered metadata
        echo "-----------------------------------"
        echo "Column name: $column_name"
        echo "Column type: $column_type"
        echo "Primary key: $pk"
        echo "Nullable: $nullable"
        echo "-----------------------------------"
    done

    # Check if a primary key was chosen
    if [ "$primary_key_chosen" = false ]; then
        # Display available columns to choose from
        echo "Available columns:"
        for idx in "${!column_names[@]}"; do
            echo "$((idx + 1)): ${column_names[idx]}"
        done

        # Prompt user to choose a primary key column
        while true; do
            read -rp "Choose a primary key column (Enter column number): " primary_key_column

            # Validate the input
            if [[ ! "$primary_key_column" =~ ^[0-9]+$ ]]; then
                echo "Invalid input. Please enter a valid column number."
                continue
            fi

            # Check if the chosen column number is within range
            if (( primary_key_column < 1 || primary_key_column > num_columns )); then
                echo "Column number is out of range. Please choose a valid column number."
                continue
            fi

            # Ensure the chosen column is not nullable
            chosen_col_name="${column_names[primary_key_column - 1]}"
            chosen_col_type="${column_types[primary_key_column - 1]}"
            nullable="notNull"  # Ensure primary key cannot be null
            pk="pk"

            # Update metadata line for the chosen column
            metadata_lines[$((primary_key_column - 1))]="${chosen_col_name}:${chosen_col_type}:$pk:$nullable"

            # Exit the loop
            break
        done
    fi

    # Build metadata string
    for line in "${metadata_lines[@]}"; do
        metadata+="$line"$'\n'
    done

    # Save metadata into metadata file
    echo -n "$metadata" > ".$table_name-metadata.txt"

    # Display gathered metadata
    echo "Metadata saved for table '$table_name'."
    touch "$table_name.txt"
    chmod +x "$table_name.txt"  ".$table_name-metadata.txt"
    echo "Table '$table_name' created successfully in '$db_name'."
}






# Function to create a table
create_table() {
    local db_name="$1"
    local table_name
    local num_columns

    while true; do
        # Read table name from user input
        read -rp "Enter table name: " table_name

        # Check if table name is empty
        if [ -z "$table_name" ]; then
            echo "Table name cannot be empty."
            continue
        fi

        # Check for spaces in table name
        if [[ "$table_name" =~ [[:space:]] ]]; then
            echo "Table name cannot contain spaces."
            continue
        fi

        # Check for special characters in table name
        if [[ "$table_name" =~ [^a-zA-Z0-9_] ]]; then
            echo "Table name cannot contain special characters."
            continue
        fi

        # Check if table name starts with a number
        if [[ "$table_name" =~ ^[0-9] ]]; then
            echo "Table name cannot start with a number."
            continue
        fi

        # Check if table name starts with an underscore
        if [[ "$table_name" =~ ^_ ]]; then
            echo "Table name cannot start with an underscore."
            continue
        fi

        # Check if table already exists
        if [ -f "./$table_name.txt" ]; then
            echo "Table '$table_name' already exists in '$db_name'."
            continue
        fi

        # Collect metadata
        read -rp "Enter the number of columns: " num_columns

        # Validate column number
        while ! [[ "$num_columns" =~ ^[1-9][0-9]*$ ]]; do
            echo "Invalid input. Please enter a valid positive integer."
            read -rp "Enter the number of columns: " num_columns
        done

        # Insert metadata for the table
        insert_metadata "$db_name" "$table_name" "$num_columns"
        break
    done
}

# Main function
main() {
    db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name
    list_tables "$db_name"
    create_table "$db_name"
}

# Call main function
main
cd ../..
# ./connect.sh
echo "------------------------------"
echo "Back to Table Menu.."
echo "------------------------------"
perform_actions $db