# Dataset Cleaning: NYC Affordable Housing

This repository contains an SQL script designed to clean and prepare the NYC Affordable Housing dataset obtained from the Department of Housing Preservation and Development (HPD). The dataset covers the construction of affordable housing units in New York City from 2014 to 2021. 

*The dataset was artificially edited from its original version so that there would be errors to fix.

## Dataset Information

- **Dataset Name**: NYC Affordable Housing Production by Building
- **Source**: Department of Housing Preservation and Development (HPD)
- **Access**: Available online at Data World
- **Retrieved from**: https://data.world/city-of-ny/hg8x-zxpr

## Query Overview

The SQL script (`NYC_affordable_housing.sql`) in this repository performs the following operations on the dataset:

  &nbsp;&nbsp;&nbsp;&nbsp;**-Renaming**: Renames table and column names to more usable formats.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;-**Reformatting**: Includes tasks such as changing data types, formatting dates, and converting 'Y/N' to 'Yes/No.’<br>
  &nbsp;&nbsp;&nbsp;&nbsp;-**Duplicate Removal**: Identifies and removes duplicate records.<br>
  &nbsp;&nbsp;&nbsp;&nbsp;-**Null Handling**: Converts empty fields ('') to NULL where applicable.<br>

## How To Use

```bash
#1) Clone the repository
git clone https://github.com/jolbinsk1/data_cleaning_in_sql.git
cd data_cleaning_in_sql/NYC_affordable_housing

#2) Create the database
mysql -u your_username -p 

  # Using SQL query:
CREATE DATABASE NYC_housing_db;

#3) Import the CSV file using import/export wizard, or with the following:
mysqlimport -u your_username -p --local NYC_housing_db housing-new-york-units-by-building.csv

```

## Files

- `NYC_affordable_housing.sql`: The main SQL script for cleaning and preparing the data
- `Housing-new-york-units-by-building.csv`: Contains the data relating to affordable housing construction in NYC from 2014 – 2021.

