# DBMS Project in Bash

## Overview
This project is a Database Management System (DBMS) developed in Bash scripting, aimed at providing a lightweight and intuitive interface for managing databases.

## Features
- **Lightweight**: Runs entirely on Bash without any external dependencies.
- **User-friendly**: Simplified command syntax for ease of use.
- **Support for basic CRUD operations**: Create, Read, Update, Delete data.
- **Table management**: Create and delete tables, and view table structures.
- **Data type validation**: Supports various data types for data integrity.

## Architecture
The architecture follows a modular approach:
- **Command Handler**: Interprets user commands and calls relevant modules.
- **Database Engine**: Handles the core operations such as data storage and retrieval.
- **User Interface**: Command-line interface for user interactions.

## Database Operations
1. **Create Database**: Initialize a new database.
2. **Delete Database**: Remove an existing database.
3. **List Databases**: Display available databases.
4. **Use Database**: Select a database for operations.

## Table Operations
1. **Create Table**: Define a new table along with its schema.
2. **Delete Table**: Remove a specified table from the database.
3. **Show Tables**: List all tables in the selected database.
4. **Insert Data**: Add new records to a table.
5. **Update Data**: Modify existing records in the table.
6. **Delete Data**: Remove records from a table.
7. **Select Data**: Retrieve records from a table based on conditions.

## Data Types Supported
- **Integer**: Whole numbers.
- **String**: Text data.
- **Float**: Decimal numbers.
- **Boolean**: True or false values.

## Usage Instructions
1. Clone the repository: 
   ```bash
   git clone https://github.com/Mohamed0Mourad/Dbms_Project_in_Bash.git
