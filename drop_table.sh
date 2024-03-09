#!/bin/bash
cd ./Databases/$db 

drop_table() {
    db_name=$(basename "$(pwd)")  # Get the name of the current directory as the database name
    list_tables "$db_name"
    tables=($(ls -F | grep '.txt*' | sed 's/\.txt\*$//' | sed 's/\.txt$//'))  # Remove trailing slash from each directory name
    PS3="Choose a Table to drop: "
    select table_name in "${tables[@]}" "Back to Table Menu"; do
        case $table_name in
            "Back to Table Menu")
                cd ../.. #3shan fi mshkla fl path bykon hena gwa db w fl function by3ml cd tany 
                perform_actions $db 
                ;;
            *)
                if [ -n "$table_name" ]; then
                    echo "Dropping Table: $table_name"
                    rm -f "$table_name.txt" ".$table_name-metadata.txt"  # Remove the table and metadata files
                    echo "Table '$table_name' dropped successfully."
                    drop_table  
                else
                    echo "Invalid option"
                fi
                ;;
        esac
    done
}


# Entry point
drop_table
