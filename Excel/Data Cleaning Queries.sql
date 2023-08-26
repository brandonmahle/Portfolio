/* 

Cleaning Data in SQL Queries 

*/

Select * 
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------


-- Standardize Data Format



Select SaleDate, Convert(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate)


Alter table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = Convert(Date, SaleDate)



Select SaleDate, SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing

--Fixed the date 

Select SaleDateConverted
From PortfolioProject.dbo.NashvilleHousing




-----------------------------------------------------------------------------------------------------------


-- Populate Property Address Data


Select *
From PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
Order by ParcelID




Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
Join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null




-----------------------------------------------------------------------------------------------------------


-- Breaking out Address into Individual COlumns (Address, City, State)


Select PropertyAddress
From PortfolioProject.dbo.NashvilleHousing
-- Where PropertyAddress is null
-- order by ParcelID

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress)) as Address 
From PortfolioProject.dbo.NashvilleHousing


ALTER Table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)



ALTER Table NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +2, LEN(PropertyAddress))



Select *
From PortfolioProject.dbo.NashvilleHousing



Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing




Select
PARSENAME(REPLACE(OwnerAddress,',', '.'),3)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),2)
,PARSENAME(REPLACE(OwnerAddress,',', '.'),1)
From PortfolioProject.dbo.NashvilleHousing



ALTER Table NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

ALTER Table NashvilleHousing
Add OwnerSplitCity nvarchar(255);

ALTER Table NashvilleHousing
Add OwnerSplitState nvarchar(255);



Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)



Select *
From PortfolioProject.dbo.NashvilleHousing


-----------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

Select Distinct(SoldAsVacant), count(soldasvacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE	When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing



Update NashvilleHousing 
SET SoldAsVacant = CASE	
		When SoldAsVacant = 'Y' THEN 'Yes'
		When SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From PortfolioProject.dbo.NashvilleHousing




-----------------------------------------------------------------------------------------------------------

-- Remove Duplicates - dont do this often 


WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
-- Order by ParcelID
)
Select * 
From RowNumCTE
Where row_num >1
Order by PropertyAddress

-- Now DELETE them

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER(
	PARTITION BY	ParcelID,
					PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					ORDER BY 
					UniqueID
					) row_num
FROM PortfolioProject.dbo.NashvilleHousing
-- Order by ParcelID
)
DELETE
From RowNumCTE
Where row_num >1



-----------------------------------------------------------------------------------------------------------

-- Delete Unused Columns 

Select * 
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE  PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate












-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  More advanced and looks cooler, but have to configure server appropriately to do correctly
--  Wanted to provide this in case you wanted to try it


--sp_configure 'show advanced options', 1;
--RECONFIGURE;
--GO
--sp_configure 'Ad Hoc Distributed Queries', 1;
--RECONFIGURE;
--GO


--USE PortfolioProject 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'AllowInProcess', 1 

--GO 

--EXEC master.dbo.sp_MSset_oledb_prop N'Microsoft.ACE.OLEDB.12.0', N'DynamicParameters', 1 

--GO 


---- Using BULK INSERT

--USE PortfolioProject;
--GO
--BULK INSERT nashvilleHousing FROM 'C:\Temp\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv'
--   WITH (
--      FIELDTERMINATOR = ',',
--      ROWTERMINATOR = '\n'
--);
--GO


---- Using OPENROWSET
--USE PortfolioProject;
--GO
--SELECT * INTO nashvilleHousing
--FROM OPENROWSET('Microsoft.ACE.OLEDB.12.0',
--    'Excel 12.0; Database=C:\Users\alexf\OneDrive\Documents\SQL Server Management Studio\Nashville Housing Data for Data Cleaning Project.csv', [Sheet1$]);
--GO