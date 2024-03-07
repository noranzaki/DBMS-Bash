#!/bin/bash

cd ./Databases/$db 
shopt -s extglob
pwd 
insert_metadata() {
    local db_name="$1"
    local table_name="$2"
    local num_columns="$3"
    local primary_key_chosen=false

    # Loop to gather metadata for each column
    for ((i = 1; i <= num_columns; i++)); do
        echo "Column $i:"
        read -rp "Enter column name: " column_name
        
        # Validate column name
    while ! [[ "$column_name" =~ ^[a-zA-Z][a-zA-Z0-9_]*$ ]]
     do
        echo "Invalid column name. Column name must start with a letter, followed by letters, digits, or underscores."
        read -rp "Enter column name: " column_name
    done


        read -rp "Enter column type (int/varchar): " column_type

        # Check if column type is valid
        while [[ "$column_type" != "int" && "$column_type" != "varchar" ]]; do
            echo "Invalid column type. Please enter 'int' or 'varchar'."
            read -rp "Enter column type (int/varchar): " column_type
        done

        # Ask if the column is nullable
        read -rp "Is this column nullable? (yes/no): " is_nullable

        # Validate the input
        while [[ "$is_nullable" != "yes" && "$is_nullable" != "no" ]]; do
            echo "Invalid input. Please enter 'yes' or 'no'."
            read -rp "Is this column nullable? (yes/no): " is_nullable
        done

        # Ask if the column is the primary key (if not chosen yet)
        if [ "$primary_key_chosen" = false ]; then
            read -rp "Is this column the primary key? (yes/no): " is_primary_key

            case "$is_primary_key" in
                [Yy][Ee][Ss])
                    primary_key_chosen=true
                    is_primary_key=true
                    is_nullable=false  # Ensure primary key cannot be null
                    ;;
                *)
                    is_primary_key=false
                    ;;
            esac
        else
            is_primary_key=false
        fi

        # Save metadata into metadata file
        echo "$column_name:$column_type:PK=$is_primary_key:NULL=$is_nullable" >> ".$table_name-metadata.txt"

        # Display gathered metadata
        echo "Column name: $column_name"
        echo "Column type: $column_type"
        echo "Primary key: $is_primary_key"
        echo "Nullable: $is_nullable"
    done

    # Check if a primary key was chosen
    if [ "$primary_key_chosen" = false ]; then
        while true; do
            echo "Available columns:"
            awk -F ':' '{print NR, $1}' ".$table_name-metadata.txt"

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

            # Save the primary key status into the metadata file
            sed -i "${primary_key_column}s/:PK=false/:PK=true/" ".$table_name-metadata.txt"
            sed -i "${primary_key_column}s/:NULL=yes/:NULL=no/" ".$table_name-metadata.txt"  # Ensure primary key cannot be null
            break
        done
    fi
}

# Function to create a table
create_table() {
    local db_name="$1"
    local table_name
    
    while true; 
    do
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

        # Create table file
        touch "$table_name.txt"
        touch ".$table_name-metadata.txt"
        chmod +x "$table_name.txt"  ".$table_name-metadata.txt"
        echo "Table '$table_name' created successfully in '$db_name'."
        # cd ..
        # ./connect.sh
        break 
    done
    read -rp "Enter the number of columns: " num_columns
      # Validate column number
    # Validate column number
    while ! [[ "$num_columns" =~ ^[1-9][0-9]*$ ]]
     do
        echo "Invalid input. Please enter a valid positive integer."
        read -rp "Enter the number of columns: " num_columns
    done

    insert_metadata "$db" "$table_name" "$num_columns"

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