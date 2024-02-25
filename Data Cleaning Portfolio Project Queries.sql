/*

Cleaning Data in SQL Queries

*/


Select *
From PortfolioProject.dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, CONVERT(Date,SaleDate) 
From PortfolioProject.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate) 

-- If it doesn't Update properly

ALTER TABLE NashvilleHousing --Adding new column named 'SaleDateConverted' 
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate) -- Converting the added column into Date


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data
-- ISNULL(a.PropertyAddress,b.PropertyAddress) -- If a.PropertyAddress is NULL then populate b.PropertyAdress in those NULL values 
SELECT a.ParcelID, a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]

WHERE b.PropertyAddress IS NULL

-- Updating Tables with above querries we've just done!

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM NashvilleHousing a
Join NashvilleHousing b
ON a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]


--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

SELECT PropertyAddress
FROM NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS ADDRESS, -- Looking for the positon of comma in PropertyAddress
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress)) AS ADDRESS
FROM NashvilleHousing

ALTER TABLE NashvilleHousing --Adding new column named 'PropertySplitAddress' 
ADD PropertySplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE NashvilleHousing --Adding new column named 'PropertySplitCity' 
ADD PropertySplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
from NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing

-- Note: Parsename gives the output in backward direction
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) -- Replacing ',' with '.' in OwnerAddress in 1st index(i.e Position of ','
, PARSENAME(REPLACE(OwnerAddress,',','.'),2)
, PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM NashvilleHousing

ALTER TABLE NashvilleHousing --Adding new column named 'OwnerSplitAddress' 
ADD OwnerSplitAddress Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3) 

ALTER TABLE NashvilleHousing --Adding new column named 'OwnerSplitCity' 
ADD OwnerSplitCity Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashvilleHousing --Adding new column named 'OwnerSplitState' 
ADD OwnerSplitState Nvarchar(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- CASE # Similar LIKE 'IF-ELSE-ELSEIF'
SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'N' THEN 'NO'
     WHEN SoldAsVacant = 'Y' THEN 'YES'
     ELSE SoldAsVacant
	 END
FROM NashvilleHousing


UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'N' THEN 'NO'
     WHEN SoldAsVacant = 'Y' THEN 'YES'
     ELSE SoldAsVacant
	 END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
WITH  RowNumCTE AS(
SELECT *,
     ROW_NUMBER() OVER (
	 PARTITION BY ParcelID,
	            PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
	 ORDER BY UniqueID) row_num
FROM NashvilleHousing
)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress


-- Deleting the duplicates values. MOst of the values whise row > 1 has duplicates. So, we delete it
--DELETE 
--From RowNumCTE
--Where row_num > 1



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


SELECT *
from NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate