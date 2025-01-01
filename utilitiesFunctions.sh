#!/bin/bash



#Show Options to the user
ShowOptionsToUsers(){
    echo "=============================="
    echo "     OUR DBMS Project IN Bash      "
    echo "=============================="
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Quit"

    echo "==============================="
    read -p "Enter your option: " option
}
CreateDatabase(){
    read -p "Which database Name you want to Create: " DbName
    if [ -z $DbName ]
    then
        echo "Database name can not be empty"
    elif [ -d ~/Our_Dbms_project/databases/$DbName ]
    then
        echo "Database $DbName is already exixsts"
    else
        mkdir -p ~/Our_Dbms_project/databases/$DbName
        echo "Database $DbName Created successfully" 

    fi

}

ListDatabase(){
    echo "The Available Databases are: "
    ls ~/Our_Dbms_project/databases
}

DatabaseConnect(){
  
    ls ~/Our_Dbms_project/databases
    read -p "These Are Available Databases Which one you need to Connect: " DbName

    if [ -d ~/Our_Dbms_project/databases/$DbName ] 
    then
        cd ~/Our_Dbms_project/databases/$DbName
        echo "Connected Successfully to '$DbName'"
        
        while true 
        do 
            ShowTableOperations
            case $SelectedChoice in
                1) CreateTable;;
                2) ListTables ;;
                3) DropTable ;;
                4) InsertIntoTable ;;
                5) SelectFromTable ;;
                6) DeleteFromTable ;;
                7) UpdateRow ;;
                8) break ;;#cd+break
                *) echo "Invalid choice. Please select from the menu." ;;
            esac
            read -p "Press Enter To Continue...."

        done
    else
        echo "Database $DbName not Exist"

        
    fi
}
DatabaseDrop(){
    read -p "Which Database name you want to Drop" DbName
    if [ -d /Our_Dbms_project/databases/$DbName ]
    then
        rm -rf /Our_Dbms_project/databases/$DbName
        echo "Database '$DbName' Deleted successfully"
    else
        "There is No Database called '$DbName' !: "


    fi
}


