-- Dataset: The construction of affordable housing in NYC (2014-2021)
-- Source: Department of Housing Preservation and Development (HPD) - Affordable Housing Production by Building
	-- Published online at Data World
	-- Retrieved from: 'https://data.world/city-of-ny/hg8x-zxpr' [Online Resource] 
-- Queried using: MySQL Workbench


/* 
In the subsequent query, we will be cleaning the data. This will include:
	- renaming the table and columns
    - changing data types for particular columns
	- adjusting the date format
    - changing Y/N to Yes/No
    - removing duplicate data
    - removing blanks and unusual symbols and replacing with NULL
 */


USE NYC_housing;    -- database name

SELECT * FROM NYC_housing.`housing-new-york-units-by-building`;

-- Change table name

RENAME TABLE `housing-new-york-units-by-building` TO nyc_housing_units;

-- Change column names to more usable format

SHOW COLUMNS FROM nyc_housing_units;

ALTER TABLE nyc_housing_units
	RENAME COLUMN `Project ID` TO project_ID,
	RENAME COLUMN `Project Name` TO project_name,
	RENAME COLUMN `Project Start Date` TO start_date,
	RENAME COLUMN `Project Completion Date` TO project_end_date,
	RENAME COLUMN `Building ID` TO building_ID,
	RENAME COLUMN `Number` TO building_number,
	RENAME COLUMN Street TO street,
	RENAME COLUMN Borough TO borough,
	RENAME COLUMN Postcode TO postcode,
	RENAME COLUMN `Community Board` TO community_board,
	RENAME COLUMN `Council District` TO counsil_district,
	RENAME COLUMN `Census Tract` TO census_tract,
	RENAME COLUMN `NTA - Neighborhood Tabulation Area` TO NTA,
	RENAME COLUMN `Latitude` TO latitude,
	RENAME COLUMN `Longitude` TO longitude,
	RENAME COLUMN `Latitude (Internal)` TO latitude_int,
	RENAME COLUMN `Longitude (Internal)` TO longitude_int,
	RENAME COLUMN `Building Completion Date` TO building_finish_date,
	RENAME COLUMN `Reporting Construction Type` TO rep_construction_type,
	RENAME COLUMN `Extended Affordability Only` TO only_ext_affordability,
	RENAME COLUMN `Prevailing Wage Status` TO prev_wage_status,
	RENAME COLUMN `Very Low Income Units` TO v_low_income_units,
	RENAME COLUMN `Low Income Units` TO low_income_units,
	RENAME COLUMN `Moderate Income Units` TO moderate_income_units,
	RENAME COLUMN `Middle Income Units` TO middle_income_units,
	RENAME COLUMN `Other Income Units` TO other_income_units,
	RENAME COLUMN `Studio Units` TO studio_units,
	RENAME COLUMN `1-BR Units` TO one_BR,
	RENAME COLUMN `2-BR Units` TO two_BR,
	RENAME COLUMN `3-BR Units` TO three_BR,
	RENAME COLUMN `4-BR Units` TO four_BR,
	RENAME COLUMN `5-BR Units` TO five_BR,
	RENAME COLUMN `6-BR+ Units` TO six_plus_BR,
	RENAME COLUMN `Unknown-BR Units` TO unknown_BR,
	RENAME COLUMN `Counted Rental Units` TO rental_unit_count,
	RENAME COLUMN `Counted Homeownership Units` TO owned_unit_count,
	RENAME COLUMN `All Counted Units` TO all_counted_units,
	RENAME COLUMN `Total Units` TO total_units
;

-- Reformat dates

SELECT
	start_date,
    project_end_date,
    building_finish_date
FROM
	NYC_housing_units
;

	# start_ date is formatted: '%c/%e/%y %H:%i'
	# project_end_date is formatted: '%c/%e/%y %H:%i'
	# and building_finish_date is formatted: '%c/%e/%y %l:%i%p'

-- we want to change them to mm/dd/yy


UPDATE NYC_housing_units
SET 
	start_date = DATE_FORMAT(STR_TO_DATE(start_date, '%c/%e/%y %H:%i'), '%m/%d/%y')
WHERE start_date IS NOT NULL ;


UPDATE NYC_housing_units
SET 
    project_end_date = DATE_FORMAT(STR_TO_DATE(project_end_date, '%c/%e/%y %H:%i'), '%m/%d/%y')
WHERE project_end_date LIKE '%0:00';


UPDATE NYC_housing_units
SET 
    building_finish_date = DATE_FORMAT(STR_TO_DATE(building_finish_date, '%c/%e/%y %l:%i%p'), '%m/%d/%y')
WHERE building_finish_date LIKE '%AM' OR  building_finish_date LIKE '%PM'
;


# Check changes

SELECT
	start_date,
    project_end_date,
    building_finish_date
FROM
	NYC_housing_units
;


SELECT * FROM NYC_housing_units;


/* 
Now lets change the data types for particular columns to better fit the data
*/

SELECT
	*
FROM
	NYC_housing_units
;

SHOW COLUMNS FROM nyc_housing_units;

-- Now we have an idea of what columns should have their data type changed

ALTER TABLE NYC_housing_units
	MODIFY COLUMN project_ID VARCHAR(15),
	MODIFY COLUMN building_ID VARCHAR(15),
	MODIFY COLUMN building_number VARCHAR(15),
	MODIFY COLUMN postcode VARCHAR(15)
;

-- Now check

SHOW COLUMNS FROM nyc_housing_units;


-- Change Y/N to Yes/Non in only_ext_affordability column

SELECT 
	DISTINCT(only_ext_affordability),
    COUNT(only_ext_affordability)
FROM	
	NYC_housing_units
GROUP BY only_ext_affordability
;


SELECT
	only_ext_affordability,
    CASE
		WHEN only_ext_affordability = 'Y' THEN 'Yes'
        WHEN only_ext_affordability = 'N' THEN 'No'
        ELSE only_ext_affordability
        END
FROM	
	NYC_housing_units
;

UPDATE NYC_housing_units
SET only_ext_affordability = 
	CASE
		WHEN only_ext_affordability = 'Y' THEN 'Yes'
        WHEN only_ext_affordability = 'N' THEN 'No'
        ELSE only_ext_affordability
        END
;

-- See if it worked

SELECT 
	DISTINCT(only_ext_affordability),
    COUNT(only_ext_affordability)
FROM	
	NYC_housing_units
GROUP BY only_ext_affordability
;


-- Remove duplicates (I wouldn't do this in SQL normally, but this is just a demonstration)


SELECT
	*
FROM
	nyc_housing_units
;


SELECT 
	*,
	ROW_NUMBER() OVER(
		PARTITION BY 
			project_ID,
			BBL,
			building_number
		ORDER BY 
			project_ID) AS row_num
FROM
	nyc_housing_units
;

# Now lets make it a CTE

WITH row_CTE AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(
			PARTITION BY 
				project_ID,
				BBL,
				building_number
			ORDER BY 
				project_ID) AS row_num
	FROM
		nyc_housing_units
)
SELECT 
	*
FROM 
	row_CTE
WHERE row_num >1
ORDER BY project_ID
;

-- Based on this, we have 26 duplicate columns
-- Lets delete them

COMMIT;  # Just in case of bad delete

WITH row_CTE AS(
	SELECT 
		*,
		ROW_NUMBER() OVER(
			PARTITION BY 
				project_ID,
				BBL,
				building_number
			ORDER BY 
				project_ID) AS row_num
	FROM
		nyc_housing_units
)
DELETE 
FROM 
	NYC_housing_units
WHERE EXISTS (
	SELECT 
		*
	FROM
		row_CTE
	WHERE nyc_housing_units.project_ID = row_CTE.project_ID
		AND nyc_housing_units.BBL = row_CTE.BBL
		AND nyc_housing_units.building_number = row_CTE.building_number
		AND row_CTE.row_num > 1
);

ROLLBACK; # Just in case of bad delete


-- Now lets make blank spaces into NULL


SELECT
	*
FROM
	nyc_housing_units
;



UPDATE NYC_housing_units
SET 
	project_end_date = 
		CASE
			WHEN project_end_date = '' THEN NULL
			ELSE project_end_date
			END,
	 building_ID = 
		CASE
			WHEN building_ID = '' THEN NULL
			ELSE building_ID
			END,
	postcode = 
		CASE
			WHEN postcode = '' THEN NULL
			ELSE postcode
			END,
	BBL = 
		CASE
			WHEN BBL = '' THEN NULL
			ELSE BBL
			END,
	BIN = 
		CASE
			WHEN BIN = '' THEN NULL
			ELSE BIN
			END,
	census_tract = 
		CASE
			WHEN census_tract = '' THEN NULL
			ELSE census_tract
			END,
	NTA = 
		CASE
			WHEN NTA = '' THEN NULL
			ELSE NTA
			END,
	latitude = 
		CASE
			WHEN latitude = '' THEN NULL
			ELSE latitude
			END,
	longitude = 
		CASE
			WHEN longitude = '' THEN NULL
			ELSE longitude
			END,
	latitiude_int = 
		CASE
			WHEN latitiude_int = '' THEN NULL
			ELSE latitiude_int
			END,
	longitude_int = 
		CASE
			WHEN longitude_int = '' THEN NULL
			ELSE longitude_int
			END,
	building_finish_date =
		CASE
			WHEN building_finish_date = '' THEN NULL
			ELSE building_finish_date
            END
;

-- Now check

SELECT
	*
FROM
	nyc_housing_units
;


-- Lastly, the columns building_number and street have '----' instead of NULL
-- Let's replace '----' with NULL


SELECT
	building_number,
    street
FROM 
	nyc_housing_units
WHERE building_number = '----' or street = '----'
;


UPDATE NYC_housing_units
SET 
	building_number = 
		CASE
			WHEN building_number = '----' THEN NULL
			ELSE building_number
			END,
	 street = 
		CASE
			WHEN street = '----' THEN NULL
			ELSE street
			END
;


-- Check if it worked

SELECT
	building_number,
    street
FROM 
	nyc_housing_units
WHERE building_number = '----' or street = '----'
;

