
Select *
From NashvilleHousingDataset

							        /* Cleaning Date */

-----------------------------------------------------------------------------------------------------------

-- Standardize date format


Select SaleDate, CONVERT(date,SaleDate) as Date
From NashvilleHousingDataset

Update NashvilleHousingDataset
Set SaleDate = CONVERT(date, SaleDate) 

-- It was not working so I used another approach

Alter Table NashvilleHousingDataset
Add SaleDateConverted Date;

Update NashvilleHousingDataset
Set SaleDateConverted = CONVERT(date, SaleDate) 


------------------------------------------------------------------------------------------------------------

							/* Populate Property Address data (NULL Values) */

-- ParcelID column is the id of the property, and I can base my cleaning on this

Select *
From NashvilleHousingDataset
--Where PropertyAddress is Null
Order by ParcelID

-- Because UniqueID column is unique I use it to eliminate duplicates

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
From NashvilleHousingDataset a
Join NashvilleHousingDataset b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousingDataset a
Join NashvilleHousingDataset b
	On a.ParcelID = b.ParcelID
	And a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

------------------------------------------------------------------------------------------------------------

					/* Separating Address columns into individual columns (Address, City, State) */

Select PropertyAddress
From NashvilleHousingDataset

Select 
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) As Address,
Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress)) As City 
From NashvilleHousingDataset

--CHARINDEX(',', PropertyAddress) = length until the ',' 
--The LEN() function returns the length of a string.

Alter Table NashvilleHousingDataset
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousingDataset
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

Alter Table NashvilleHousingDataset
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousingDataset
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, Len(PropertyAddress))

-- Checking

Select *
From NashvilleHousingDataset



-- Separating OwnerAddress column into individual columns (Address, City) --

Select OwnerAddress
From NashvilleHousingDataset

Select
PARSENAME(OwnerAddress, 1) -- Note the PARSENAME is working for separate just with '.'
From NashvilleHousingDataset

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3) As Address,
PARSENAME(Replace(OwnerAddress, ',', '.'), 2) As City,
PARSENAME(Replace(OwnerAddress, ',', '.'), 1) As State
From NashvilleHousingDataset


-- Updating the Dataset

Alter Table NashvilleHousingDataset
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousingDataset
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

Alter Table NashvilleHousingDataset
Add OwnerCity Nvarchar(255);

Update NashvilleHousingDataset
Set OwnerCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

Alter Table NashvilleHousingDataset
Add OwnerState Nvarchar(255);

Update NashvilleHousingDataset
Set OwnerState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1) 

-- Checking

Select *
From NashvilleHousingDataset

------------------------------------------------------------------------------------------------------------

						/* SoldAsVacant column has 4 options but I need it to have just 2 */

Select Distinct(SoldAsVacant)
From NashvilleHousingDataset

-- I want to use just 'Y' and 'N'

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingDataset
Group by SoldAsVacant
Order by 2


-- In order changing content columns I use "Case"

Select SoldAsVacant
, Case When SoldAsVacant = 'Yes' Then 'Y'
	   When SoldAsVacant = 'No' Then 'N'
	   Else SoldAsVacant
	   End			
From NashvilleHousingDataset

Update NashvilleHousingDataset
Set SoldAsVacant = Case When SoldAsVacant = 'Yes' Then 'Y'
	   When SoldAsVacant = 'No' Then 'N'
	   Else SoldAsVacant
	   End		 


-- Double check

Select Distinct(SoldAsVacant)
From NashvilleHousingDataset

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousingDataset
Group by SoldAsVacant
Order by 2

------------------------------------------------------------------------------------------------------------

							/* Remove Duplicates */

/* Using CTE (temporal table) to identify duplicates, 
   "ROW_NUMBER() Over (Partition By" to distinct duplicates */

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum
From NashvilleHousingDataset
)
Select *
From RowNumCTE
Where RowNum > 1


-- Delete duplicates

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum
From NashvilleHousingDataset
)
Delete
From RowNumCTE
Where RowNum > 1


-- Double check

With RowNumCTE As(
Select *, 
	ROW_NUMBER() Over (
	Partition By ParcelID,
				 PropertyAddress,
				 SalePrice,
				 LegalReference,
				 OwnerName
				 Order by
					UniqueID
					) RowNum
From NashvilleHousingDataset
)
Select *
From RowNumCTE
Where RowNum > 1

------------------------------------------------------------------------------------------------------------

							/* Delete Unused Columns */

Select *
From NashvilleHousingDataset

Alter Table NashvilleHousingDataset
Drop column SaleDate, PropertyAddress, OwnerAddress, TaxDistrict
