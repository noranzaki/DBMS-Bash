#!/bin/bash

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
