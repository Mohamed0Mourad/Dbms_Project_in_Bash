#!/bin/bash

GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

ShowTableOperations(){
    echo "=========================="
    echo "1. Create Table"
    echo "2. List Tables"
    echo "3. Drop Table"
    echo "4. Insert into Table"
    echo "5. Select From Table"
    echo "6. Delete From Table"
    echo "7. Update Row"
    echo "8. Back to Main Menu"
    echo "=============================="
    
    read -p "What Do you want: " SelectedChoice
    
}

CreateTableMetaData(){
    local mateData=$1
    read -p "Enter number of columns: " NumberOfColumns
    if [ -z $NumberOfColumns ]
    then
        echo -e "$RED $BOLD Number of columns can not be empty $NC"
    else
        for (( i=1; i<=$NumberOfColumns; i++ ))
        do
            read -p "Enter Column Name: " ColumnName
            select ColumnType in "int" "varchar" "date" "float"  "char" "boolean" 
            do
                if  [ -n "$ColumnType" ]
                then
                    break
                fi
            done
            read -p "Enter Is Nullable (Y/N): " IsNullable
            if [ "$IsNullable" == "Y" ] || [ "$IsNullable" == "y" ]
            then
                IsNullable="Y"
            else
                IsNullable="N"
            fi
            read -p "Enter Is Primary Key (Y/N): " IsPrimaryKey
            
            if [ "$IsPrimaryKey" == "Y" ] || [ "$IsPrimaryKey" == "y" ]
            then
                echo -e "$BOLD Primary Key is set and it can not be nullable $NC"
                IsPrimaryKey="Y"
                IsNullable="N"
                DefaultValue="NULL"
            else
                IsPrimaryKey="N"
                read -p "Enter default value: " DefaultValue
            fi
            echo "$ColumnName:$ColumnType:$IsPrimaryKey:$IsNullable:$DefaultValue" >> "$mateData"
            
        done
    fi
}
CreateTable(){
    read -p "Enter Table Name: " TableName
    if [ -z $TableName ]
    then
        echo "Table Name can not be empty"
    elif [ -f $TableName ]
    then
        echo "Table $TableName is already exixsts"
    else
        mateData="mateData_$TableName"
        touch $TableName  $mateData
        CreateTableMetaData $mateData
        echo -e "$GREEN Table $TableName Created successfully $NC"
    fi
}

ListTables(){
    echo -e "$YELLOW $BOLD The Available Tables are: "
    echo -e "==========================="
    find . -type f ! -name "mateData*" | awk -F/ '{for (i=2; i<=NF; i++) printf "| %-25s |\n", $i}'
    echo -e "===========================$NC"
}

DropTable(){
    
    read -p "Enter Table Name: " TableName
    if [ -z $TableName ]
    then
        echo "Table Name can not be empty"
    elif [ ! -f $TableName ]
    then
        echo "$RED Table $TableName does not exixsts $NC"
    else
        rm -f $TableName mateData_$TableName
        echo -e "$GREEN Table $TableName Deleted successfully $NC"
    fi
}
InsertIntoTable(){
    ListTables
    read -p "Enter Table Name: " TableName
    if [ -z $TableName ]
    then
        echo "Table Name can not be empty"
    elif [ ! -f $TableName ]
    then
        echo "$RED Table $TableName does not exixsts $NC"
    else
        mateData="mateData_$TableName"
        if [ ! -f $mateData ]
        then
            echo "$RED Meta Data for Table $TableName does not exixsts $NC"
        else
            raw=""
            typeset -i flag=0
            while read  -u 3 line
            do
                IFS=':' read -r -a array <<< "$line"
                ColumnName=${array[0]}
                ColumnType=${array[1]}
                IsPrimaryKey=${array[2]}
                IsNullable=${array[3]}
                DefaultValue=${array[4]}
                if [ $IsPrimaryKey == "Y" ]
                then
                    read -p "Enter Your $ColumnName (PK): " ColumnValue
                    if [ -z $ColumnValue ]
                    then
                        echo -e "$RED $BOLD $ColumnName can not be empty $NC"
                        flag=1
                        break
                    fi
                    checkIfColumnRepeated $ColumnValue $TableName
                    if [ $? -eq 1 ]
                    then
                        echo -e "$RED $BOLD $ColumnName can not be repeated $NC"
                        flag=1
                        break
                    fi
                    checkType $ColumnType $ColumnValue
                    if [ $? -eq 1 ]
                    then
                        echo -e "$RED $BOLD $ColumnValue is not of type $ColumnType $NC"
                        flag=1
                        break
                    fi
                else
                    if [ $IsNullable == "Y" ]
                    then
                        read -p "Enter $ColumnName (Nullable): " ColumnValue
                        if [ -z $ColumnValue ]
                        then
                            ColumnValue="NULL"
                        fi
                    else
                        read -p "Enter $ColumnName (Not Nullable): " ColumnValue
                        if [ $DefaultValue != "NULL" ]
                        then
                            if [ -z $ColumnValue ]
                            then
                            ColumnValue=$DefaultValue
                            else
                                checkType $ColumnType $ColumnValue
                                if [ $? -eq 1 ]
                                then
                                    echo -e "$RED $BOLD $ColumnValue is not of type $ColumnType $NC"
                                    flag=1
                                    break
                                fi
                            
                            fi
                        fi
                    fi
                fi
                raw="$raw$ColumnValue:"
            done 3< "$mateData"
            if [ "$flag" -eq 0 ]
            then
                raw=${raw::-1}
                echo "$raw" >> "$TableName"
                echo -e "$GREEN $BOLD Insertion  $NC"
            fi
        fi
    fi
    
}
checkIfColumnRepeated(){
    local ColumnValue=$1
    local tableName=$2
    if grep -qw $ColumnValue $tableName
    then
        return 1
    else
        return 0
    fi
}

checkType()
{
    local ColumnType=$1
    local ColumnValue=$2
    case $ColumnType in
        int)
            if [[ $ColumnValue =~ ^[0-9]+$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
        varchar)
            if [[ $ColumnValue =~ ^[a-zA-Z]+$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
        date)
            if [[ $ColumnValue =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
        float)
            if [[ $ColumnValue =~ ^[0-9]+\.[0-9]+$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
        char)
            if [[ $ColumnValue =~ ^[a-zA-Z]{1}$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
        boolean)
            if [[ $ColumnValue =~ ^[0-1]{1}$ ]]
            then
                return 0
            else
                return 1
            fi
            ;;
    esac
}

SelectFromTable(){
    ListTables
    selectAll="N"
    read -p "Enter Table Name: " TableName
    if [ -z "$TableName" ]
    then
        echo "Table Name can not be empty"
    elif [ ! -f "$TableName" ]
    then
        echo "$RED Table $TableName does not exits $NC"
    else
        mateData="mateData_$TableName"
        if [ ! -f "$mateData" ]
        then
            echo "$RED Meta Data for Table $TableName does not exits $NC"
        else
            read -p "Do you want to see the table with meta data (Y/N): " showMetaData
            read -p " Do yoy want to select all columns (Y/N): " selectAll
            if [  "$selectAll" != "Y" ] && [  "$selectAll" != "y" ]
            then
                read -p "Enter Column Name:  " ColumnName_
                grep -qw "$ColumnName_" "$mateData"

                if [ $? -eq 1 ]
                then 
                    echo -e "$RED $BOLD $ColumnName_ is not found in table $NC"
                    return 1
                fi
                read -p "Enter Column Value: " ColumnValue_
            fi
            
            while read   line
            do
                IFS=':' read -r -a array <<< "$line"
                ColumnName=${array[0]}
                ColumnType=${array[1]}
                IsPrimaryKey=${array[2]}
                echo -e -n "$BLUE $BOLD"
                if [ "$showMetaData" == "Y" ] || [ "$showMetaData" == "y" ]
                then
                    if [  "$IsPrimaryKey" == "Y" ]
                    then
                        printf "%-10s (%s) (PK) | " "$ColumnName" "$ColumnType"
                    else
                        printf "%-10s (%s) | " "$ColumnName" "$ColumnType"
                    fi
                else
                    printf "%-17s | " "$ColumnName"
                fi
            done < "$mateData"
            line="---------------------------------------------"
            printf "\n %-17s\n" "$line"
            echo -e -n "$NC"
            typeset -i flag_to_print=0
            while read   line
            do
                IFS=':' read -r -a array <<< "$line"
                for i in "${array[@]}"
                do
                    if [ "$selectAll" == "Y" ] || [ "$selectAll" == "y" ]
                    then
                        flag_to_print=1      
                        if [ "$showMetaData" == "Y" ] || [ "$showMetaData" == "y" ]
                        then
                            printf "%-22s | " "$i"
                        else
                            printf "%-17s | " "$i"
                        fi
                    else
                        if [ "$i" == "$ColumnValue_" ]
                        then
                        for j in "${array[@]}"
                        do
                            flag_to_print=1
                            if [ "$showMetaData" == "Y" ] || [ "$showMetaData" == "y" ]
                            then
                                printf "%-22s | " "$j"
                            else
                                printf "%-17s | " "$j"
                            fi
                        done
                        fi
                    fi
            
                done
                if [ $flag_to_print -eq 1 ]
                then
                    echo ""
                    flag_to_print=0
                fi
            done < "$TableName"
        fi
    fi

}



DeleteFromTable(){
    ListTables
    read -p "Enter Table Name: " TableName
    if [ -z $TableName ]
    then
        echo "Table Name can not be empty"
    elif [ ! -f $TableName ]
    then
        echo "$RED Table $TableName does not exixsts $NC"
    else
        mateData="mateData_$TableName"
        if [ ! -f $mateData ]
        then
            echo "$RED Meta Data for Table $TableName does not exixsts $NC"
        else
            read -p "Enter Column Name: " ColumnName
            grep -qw "$ColumnName" "$mateData"
            if [ $? -eq 1 ]
            then 
                echo -e "$RED $BOLD $ColumnName is not found in table $NC"
                return 1
            fi
            IsPrimaryKey=$( awk -F: -v colName="$ColumnName" '$1 == colName {print $3}' "$mateData" )
            if [ "$IsPrimaryKey" == "Y" ]
            then
                read -p "Enter Column Value: " ColumnValue
                if [ -z $ColumnValue ]
                then
                    echo -e "$RED $BOLD Column Value can not be empty $NC"
                    return 1
                else
                    sed -i "/$ColumnValue/d" $TableName
                    if [ $? -eq 1 ]
                    then
                        echo -e "$RED $BOLD Row not found $NC"
                    else
                        echo -e "$GREEN $BOLD Row Deleted successfully $NC"
                    fi
                fi
            else
                echo " Please Select primary Key"
                echo -e "$RED $BOLD You can not delete from table without primary key $NC"
                return 1
            fi
        fi
    fi

}




UpdateRow(){
    ListTables
    read -p "Enter Table Name: " TableName
    if [ -z "$TableName" ]; then
        echo "Table Name cannot be empty"
        return 1
    elif [ ! -f "$TableName" ]; then
        echo -e "$RED Table $TableName does not exist $NC"
        return 1
    fi

    mateData="mateData_$TableName"
    if [ ! -f "$mateData" ]; then
        echo -e "$RED Metadata for Table $TableName does not exist $NC"
        return 1
    fi

    PrimaryKeyColumn=$(awk -F: '$3 == "Y" {print $1}' "$mateData")
    if [ -z "$PrimaryKeyColumn" ]; then
        echo -e "$RED $BOLD No primary key defined in the table $NC"
        return 1
    fi


    read -p "Enter the Primary Key value of the row to update: " PrimaryKeyValue
    if [ -z "$PrimaryKeyValue" ]; then
        echo "Primary Key value cannot be empty"
        return 1
    fi

    Row=$(grep "^$PrimaryKeyValue" "$TableName")
    if [ -z "$Row" ]; then
        echo -e "$RED $BOLD No row found with Primary Key $PrimaryKeyValue $NC"
        return 1
    fi
    Row=""
    while IFS=":" read -r -u 3 ColumnName ColumnType isPrimary _; do
        read -p "Enter new value for $ColumnName (leave empty to keep current): " ColumnValue
        
        if [ -n "$ColumnValue" ]; then
            if ! checkType "$ColumnType" "$ColumnValue"; then
                echo -e "$RED $BOLD Invalid value $ColumnValue for $ColumnType $NC"
                return 1
            fi
            if [ "$isPrimary" == "Y" ]
            then
                if ! checkIfColumnRepeated "$ColumnValue" "$TableName"; then
                echo -e "$RED $BOLD $ColumnName can not be repeated $NC"
                return 1
                fi
            fi


            
        Row="$Row$ColumnValue:"
        fi
    done 3< "$mateData"
    Row=${Row::-1}
    echo "$Row"
    sed -i "s/^$PrimaryKeyValue.*/$Row/" "$TableName"

    echo -e "$GREEN $BOLD Row updated successfully $NC"
}

