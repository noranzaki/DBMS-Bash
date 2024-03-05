#!/bin/bash
# Function to list available databases
list_databases() {
    DataBase=($(ls -F | grep / )) #to get directories onlyy 
    if [ ${#DataBase[@]} -eq 0 ] #length of array 
    then
        echo "No databases found."
        exit 1
    else
        echo "Available databases:"
    fi
}
export -f list_databases

if ! [[ -d ./DataBase ]]
then
  mkdir ./DataBase
fi

cd ./DataBase || exit 1

select option in "Create" "List" "Drop" "Connect" "Exit"; 
do
  case $REPLY in
    1) echo "Create";;
    2) echo "List";;
    3) ./dropdb.sh break;;
    4) ./connect.sh ; break;;
    5) echo "Bye..."; break;;
    *) echo "Invalid option";;
  esac
done
