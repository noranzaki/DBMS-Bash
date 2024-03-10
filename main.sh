#!/bin/bash

if  [[ ! -d ./Databases ]]
then
  mkdir ./Databases
fi

echo "********* Welcome to Bash DBMS *********"
echo "Main Menu"
echo "-----------"
PS3="Enter your option: "
select option in "Create a new Database" "List all Databses" "Drop a Database" "Connect to a Database" "Exit"; 
do
  case $REPLY in
    1) source ./create_db.sh ;;
    2) source ./list_db.sh ;;
    3) source ./dropdb.sh  ;;
    4) source ./connect.sh ;;
    5) echo "Bye..."; exit 1;;
    *) echo "Invalid option";;
  esac
done