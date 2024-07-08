/* -- Intial information -- */

/* This project involves processing raw housing data from Nashville houses by cleaning and transforming it 
	into a structured format in SQL Server. This transformation involved organizing and standardizing the data 
	to enhance its usability for comprehensive analysis and insights.
	
	Tasks:
	1. Data Preprocessing:
	   - Data Cleaning: Ensuring the dataset is accurate and reliable by handling missing data, correcting errors, 
	     removing duplicates, and converting data types. This step is crucial to ensure the quality of the analysis.

	   - Data Transformation: Preparing raw data for analysis by transforming or encoding it into a suitable format 
		 for modelling. This includes normalization, scaling, encoding categorical variables, and dealing with missing 
		 values to make the data more usable for machine learning algorithms.*/
	
USE Datasets

Select *
From df_housing

--- Describe columns of a specific table:
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'df_housing'

--- Count rows in a table:
SELECT COUNT(*)
FROM df_housing

--- View table properties:
EXEC sp_spaceused 'df_housing'

--- View column names:
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'df_housing'  


/* -- Data Preprocessing -- */

--- Remove duplicates 
--- UniquelID represents every unique home

Select UniqueID, Count(ParcelID) as Count
From df_housing
Group By UniqueID
Order By Count(ParcelID) Desc;

--- Checks how many times each real estate has sold for accuracy that I don't have duplicates

Select UniqueID, Sum(SoldAsVacant)
From df_housing
Group By UniqueID
Order By Sum(SoldAsVacant) Desc

--- Okay for now

--- Correcting Data types for further easier analysis

ALTER TABLE df_housing ALTER COLUMN SoldAsVacant VARCHAR(5) --- changes the datatype of a table’s column
ALTER TABLE df_housing ALTER COLUMN Acreage DECIMAL(10, 2); --- changes the datatype of a table’s column (10 digits, round 2)

--- /// Feature Engineering /// ---

---Separating Address columns into individual columns (Address, City, State) */

Select PropertyAddress
From df_housing

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address, --- (-1) indicating everything that comes before the comma
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) As City --- (+1) indicating everything that comes after the comma
From df_housing

--- After I see that it work, I need to add this to the original table ---

Alter Table df_housing Add PropertySplitAddress Nvarchar(255);
Update df_housing Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table df_housing Add PropertySplitCity Nvarchar(255);
Update df_housing Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

/*
Usage Notes:
CHARINDEX: Finds the starting position of a substring within a string.
SUBSTRING: Extracts a substring from a string based on a specified starting position and length.
LEN: Returns the length of a string.
*/

-- Checking result - it works

Select *
From df_housing


-- Separating OwnerAddress column into individual columns (Address, City) --

Select OwnerAddress
From df_housing

--- Trying another method for separating
--- 'PARSENAME' works only with '.' not ',' (this is why the following doesn't work)
--- Numbers at the end position (1, 2 or 3) return the last part (rightmost segment) after replacing commas with periods.
Select
PARSENAME(OwnerAddress, 1) 
From df_housing

--- This works
SELECT 
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3) AS Address,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2) AS City,
    PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1) AS State
FROM df_housing;

--- Updating the dataset

Alter Table df_housing Add OwnerSplitAddress Nvarchar(255);
Update df_housing Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter Table df_housing Add OwnerCity Nvarchar(255);
Update df_housing Set OwnerCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter Table df_housing Add OwnerState Nvarchar(255);
Update df_housing Set OwnerState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

-- Checking - ot works

Select *
From df_housing

--- SoldAsVacant column has 2 options

Select Distinct(SoldAsVacant)
From df_housing

--- Changing the content of the columns from 1 and 0 to 'Y' and 'N'

Select SoldAsVacant,
	   CASE 
		 WHEN SoldAsVacant = '1' THEN 'Y' 
		 WHEN SoldAsVacant = '0' THEN 'N'
		 ELSE SoldAsVacant  -- Keeps the original value if it's neither '1' nor '0'
		 END			
From df_housing

--- Updating the dataset

Update df_housing Set SoldAsVacant = Case When SoldAsVacant = '1' Then 'Y' When SoldAsVacant = '0' Then 'N' ELSE SoldAsVacant End		 

--- Double-check

Select Distinct(SoldAsVacant)
From df_housing


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From df_housing
Group by SoldAsVacant
Order by 2

--- 4,675 houses have sold as vacant
--- 51,802 houses have sold with tenants

--- Extracting year and month from the Saledate column

SELECT YEAR(SaleDate) AS SaleYear
FROM df_housing;

SELECT MONTH(SaleDate) AS SaleMonth
FROM df_housing;

--- Updating the dataset

--- Add new columns
ALTER TABLE df_housing ADD SaleYear NVARCHAR(255);
ALTER TABLE df_housing ADD SaleMonth NVARCHAR(255);

--- Update the new columns with extracted year and month
UPDATE df_housing SET SaleYear = CAST(YEAR(SaleDate) AS NVARCHAR(255));
UPDATE df_housing SET SaleMonth = CAST(MONTH(SaleDate) AS NVARCHAR(255));
	
--- Double-check

Select *
From df_housing

--- Delete Unused Columns

Alter Table df_housing Drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict

Select *
From df_housing


--- Remove Duplicates based on some conditions ---

Select *
From df_housing

---Objective:
/* The goal is to identify and delete duplicate records from the df_housing table based on specific columns 
   (ParcelID, PropertyAddress, SalePrice, LegalReference, OwnerName), while retaining only one instance of 
   each unique combination of these columns. 

   Using CTE (temporal table) to identify duplicates, 
   "ROW_NUMBER() Over (Partition By" to distinct duplicates 
   *** Important is to choose the right columns which distinguish the sales, in this case: 
					ParcelID, PropertyAddress, SalePrice, LegalReference, OwnerName*/

With RowNumCTE As(
Select  
	ROW_NUMBER() Over (				--- assigns a sequential integer to each row within a partition of rows
	Partition By ParcelID,			--- The 'PARTITION BY' clause divides the result set into partitions based on the specified columns
				 PropertySplitCity,
				 PropertySplitAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum,
					*				---  (*) 
From df_housing
)
Select *
From RowNumCTE
Where RowNum > 1


/* --- Delete duplicates --- */

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertySplitCity,
				 PropertySplitAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum
From df_housing
)
Delete
From RowNumCTE
Where RowNum > 1


-- Double-check

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertySplitCity,
				 PropertySplitAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum
From df_housing
)
Select *
From RowNumCTE
Where RowNum > 1

--- Duplicate data was effectively removed from the dataset, and it is ready for further analysis.

--- Thanks for your attention!

