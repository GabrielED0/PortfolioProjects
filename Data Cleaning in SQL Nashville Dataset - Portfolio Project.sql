/* 

Cleaning Data in SQL Queries

*/

Select *
From [Portfolio Project].dbo.[Nashville Housing]

---------------------------------------------------------------------------------------------------------------------------------------------------------------

--Standardize Data Format

Select SaleDate, CONVERT(DATE, SaleDate)
From [Portfolio Project].dbo.[Nashville Housing]

ALTER TABLE [Nashville Housing]
ALTER COLUMN SaleDate DATE NOT NULL

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.[Nashville Housing] a
Join [Portfolio Project].dbo.[Nashville Housing] b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From [Portfolio Project].dbo.[Nashville Housing] a
Join [Portfolio Project].dbo.[Nashville Housing] b
  ON a.ParcelID = b.ParcelID
  AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is Null

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

Select PropertyAddress
From [Portfolio Project].dbo.[Nashville Housing]

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address
From [Portfolio Project].dbo.[Nashville Housing]


ALTER TABLE [Nashville Housing]
ADD PropertySplitAddress Nvarchar(255)

UPDATE [Nashville Housing]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )

ALTER TABLE [Nashville Housing]
ADD PropertySplitCity Nvarchar(255)

UPDATE [Nashville Housing]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

Select *
From [Portfolio Project].dbo.[Nashville Housing]

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Breaking out OwnerAddress into Individual Columns (Address, City, State)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitAddress Nvarchar(255)

UPDATE [Nashville Housing]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitCity Nvarchar(255)

UPDATE [Nashville Housing]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE [Nashville Housing]
ADD OwnerSplitState Nvarchar(255)

UPDATE [Nashville Housing]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

Select DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
From [Portfolio Project].dbo.[Nashville Housing]
Group By SoldAsVacant
Order by 2

UPDATE [Nashville Housing]
SET SoldAsVacant = CASE
  WHEN SoldAsVacant = 'Y' THEN 'Yes'
  WHEN SoldASVacant = 'N' THEN 'No'
  ELSE SoldAsVacant
  END

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates(!) - 

WITH ROWNUMCTE AS (
Select *,
   ROW_NUMBER() OVER (
   PARTITION BY ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
                ORDER BY 
				   UniqueID
				   ) row_num
From [Portfolio Project].dbo.[Nashville Housing]
)
Select *
From ROWNUMCTE
Where row_num > 1

---------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Unused Columns(!)

ALTER TABLE [Portfolio Project].dbo.[Nashville Housing]
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE [Portfolio Project].dbo.[Nashville Housing]
DROP COLUMN SaleDateConverted

Select *
From [Portfolio Project].dbo.[Nashville Housing]

-- END