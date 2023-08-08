

--Cleaning Data in A Data Set for Housing in Nashville



SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing



--Standardize Date Format 

SELECT SaleDate, CONVERT (Date,SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing



--Update SaleDate to SaleDateConverted
SELECT SaleDateConverted, CONVERT (Date,SaleDate)
FROM Portfolio_Project.dbo.NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate =CONVERT (Date,SaleDate)



ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;
--Adding the Column SaleDateConverted


UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT (Date,SaleDate)



--------------------------------------------------------------------------------

--Populate Property Address Data

SELECT * 
From Portfolio_Project.dbo.NashvilleHousing
--Where PropertyAddress is null 

ORDER BY ParcelID



-- If Parcel ID 1 has an address and Parcel ID 2 does not have an address, Populate the matching address.

-- Join the table to it's self to make sure that each cell holds and equal value throughout the table.



SELECT *
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID

--Join 2 NashvilleHousing tables.
-- If there are 2 matching ParcelIds, where one ParcelId does not have an address, populate the address from the matching ParcelId.


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
-- Select and JOIN ParcelID and PropertyAddress from both tables and show where propertyAdress has 2 parcel IDs and the Poperty Address is Null in one of them
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
--When the ParcelID matches but the UniqueID does not
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null


--When updating a join, you must call the table by the alias
Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Portfolio_Project.dbo.NashvilleHousing a
JOIN Portfolio_Project.dbo.NashvilleHousing b
--When the ParcelID matches but the UniqueID does not
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is null




-----------------------------------------------------------------------------------------------------



--Breaking out address into individual columns (Address, City, State)

Select PropertyAddress
From Portfolio_Project.dbo.NashvilleHousing

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
From Portfolio_Project.dbo.NashvilleHousing
-- -1 to get rid of comma at end of address

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From Portfolio_Project.dbo.NashvilleHousing


--Split PropertyAddress and Split City then pull * Nashville housing to see the new columns



ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)




ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) 

Select *
From Portfolio_Project.dbo.NashvilleHousing




--Use PARSNAME  to Separate out Owner address into separate columns

Select OwnerAddress
From Portfolio_Project.dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',','.'), 3)
,PARSENAME(Replace(OwnerAddress, ',','.'), 2)
,PARSENAME(Replace(OwnerAddress, ',','.'), 1)
From Portfolio_Project.dbo.NashvilleHousing




--Add Columns and add values


ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',','.'), 3)


ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitCity =  PARSENAME(Replace(OwnerAddress, ',','.'), 2)


ALTER TABLE NashvilleHousing
ADD OwnerSplitState Nvarchar(255);


UPDATE NashvilleHousing
SET OwnerSplitState =  PARSENAME(Replace(OwnerAddress, ',','.'), 1) 


Select *
From Portfolio_Project.dbo.NashvilleHousing
 
 ----------------------------------------------------------------------------------------



 --Change Y and N to Yes and No in the "SoldAsVacant" column by creating a CASE statement



 Select Distinct(SoldAsVacant),COUNT(SoldAsVacant)
 From Portfolio_Project.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2


SELECT SoldAsVacant
,CASE When SoldAsVacant = 'Y' THEN 'YES'
	  When SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END
From Portfolio_Project.dbo.NashvilleHousing

--Use Update to Replace the Y and N with YES and NO


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	  When SoldAsVacant = 'N' THEN 'NO'
	  ELSE SoldAsVacant
	  END



	  ---------------------------------------------------------------------------------------------------



	  --Remove Duplicates
	  --Create a CTE and use Partitian


WITH RowNumCTE AS(
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

From Portfolio_Project.dbo.NashvilleHousing
--order by ParcelID
)
SELECT *
From RowNumCTE
Where row_num > 1
--Order by PropertyAddress

------------------------------------------------------------------------------------------------------------------------------------------------------------



-- Delete Unused Columns



Select *
From Portfolio_Project.dbo.NashvilleHousing


ALTER TABLE Portfolio_Project.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate