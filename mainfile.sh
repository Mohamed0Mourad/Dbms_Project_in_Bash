#!/bin/bash
./ShowOptionsToUsers
while true
do
    ShowOptionsToUsers
    case $option in 
        1) CreateDatabase ;;
        2) ListDatabase ;;
        3) DatabaseConnect ;;
        4) DatabaseDrop ;;
        5) echo "Exit"; exit 0 ;;
        *) echo "Invalid option. Please select from the menu." ;;
    esac
    read -p "Press Enter to continue..."
done