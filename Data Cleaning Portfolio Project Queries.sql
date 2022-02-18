select * from PortfolioProject..nashvillehousing; 

-- Standardize Date Format

Select saledate, CONVERT(date,saledate)
from PortfolioProject..nashvillehousing;

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate);


-- The above didn't work


ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date; 

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate);


---------------------------------------------------------------
-- Populate Property Address Data

Select *
from PortfolioProject..nashvillehousing
--WHERE PropertyAddress is null
ORDER BY ParcelID

-- Self Join to find duplicated addresses that are pulling in NULL in PropertyAddress column
-- Where parcel id is the same but it's not the new row


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress) -- When A is NULL, populate the Address from B
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null


Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
JOIN PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
	where a.PropertyAddress is null

------------------------------------------------------------------------------------

-- Breaking out Address into individual columns (Address, City, State) Using Substrings

Select PropertyAddress
from PortfolioProject..nashvillehousing
--WHERE PropertyAddress is null
--ORDER BY ParcelID

SELECT 
SUBSTRING(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address,
FROM PortfolioProject..nashvillehousing


ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(Propertyaddress, 1, CHARINDEX(',', PropertyAddress)-1);

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255); 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress));

Select * 
FROM PortfolioProject..nashvillehousing


--Breaking out Address into individual columns (Address, City, State) Using ParseName

Select OwnerAddress
FROM PortfolioProject..nashvillehousing

SELECT
PARSENAME(REPLACE(owneraddress,',', '.'),3),
PARSENAME(REPLACE(owneraddress,',', '.'),2),
PARSENAME(REPLACE(owneraddress,',', '.'),1)
from PortfolioProject..NashvilleHousing



ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress,',', '.'),3);


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress,',', '.'),2);


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255); 

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress,',', '.'),1);

Select * 
FROM PortfolioProject..nashvillehousing


---------------------------------------------------------------------------------

--Change Y and N to Yes and No in "Sold as Vacant' Field
-- Standardizing field

Select distinct(SoldAsVacant), COUNT(soldasvacant)
FROM PortfolioProject..nashvillehousing
Group by SoldAsVacant
Order by 2


Select SoldAsVacant,
Case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	Else soldasvacant
end
FROM PortfolioProject..nashvillehousing


Update NashvilleHousing
Set SoldAsVacant = Case
	when soldasvacant = 'Y' then 'Yes'
	when soldasvacant = 'N' then 'No'
	Else soldasvacant
end

------------------------------------------------------

-- Remove Duplicates 
-- Not standard practice to delete dupicates

WITH RowNumCTE AS(
SELECT * ,
	ROW_NUMBER() over (
	Partition BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					) row_num


FROM PortfolioProject..NashvilleHousing
--Order by ParcelID
)

DELETE
FROM RowNumCTE
Where row_num > 1
--order by PropertyAddress


--------------------------------------------

--Delete Unused Columns
--Best Practices, don't do this to your raw data

Select * 
FROM PortfolioProject..nashvillehousing

ALTER TABLE PortfolioProject..nashvillehousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
