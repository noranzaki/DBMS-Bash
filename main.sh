#!/bin/bash
# Function to list available databases
list_databases() 
{
    Databases=($(ls -F ./Databases | grep / )) #to get directories onlyy 
    if [ ${#Databases[@]} -eq 0 ] #length of array 
    then
        echo "No databases found."
        source ./main.sh
        #exit 1
    else
        echo "Available databases:"
    fi
    echo "******************************"

}
export -f list_databases
if  [[ ! -d ./Databases ]]
then
  mkdir ./Databases
fi
#cd Databases || exit 1
echo "********* Welcome to Bash DBMS *********"
echo "Main Menu"
echo "-----------"
PS3="Enter your option: "
select option in "Create a new Database" "List all Databses" "Drop a Database" "Connect to a Database" "Exit"; 
do
  case $REPLY in
    1) source ./create_db.sh break;;
    2) source ./list_db.sh break;;
    3) source ./dropdb.sh break ;;
    4) source ./connect.sh break;;
    5) echo "Bye..."; exit 1;;
    *) echo "Invalid option";;
  esac
done