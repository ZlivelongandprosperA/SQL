/*
Cleaning Data in SQL Queries
*/


Select *
From PortfolioProject.dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format


select SaleDate
from PortfolioProject.dbo.NashvilleHousing


select SaleDate, convert(date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

alter table NashvilleHousing
add SaleDateConverted date

update PortfolioProject.dbo.NashvilleHousing
set SaleDateConverted = convert(date, SaleDate)


select SaleDate, SaleDateConverted
from PortfolioProject.dbo.NashvilleHousing


 --------------------------------------------------------------------------------------------------------------------------


-- Populate Property Address data
-- (dealing with empty(null) PropertyAddress values in records which have the same ParcelID - coping values
-- from ones with PropertyAddress filled to the ones with empty PropertyAddress cell)

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
where propertyaddress is null


select distinct PropertyAddress
From PortfolioProject.dbo.NashvilleHousing


select *
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
order by parcelID


with CountGreaterThanOne
as
(
select parcelID, count(*) as counting
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null
group by parcelID
--order by parcelID
)
select *
from CountGreaterThanOne
where counting <>1
order by counting desc



select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null 

-- after running a query below and coming back to the one above result should be empty


update a
set PropertyAddress = isnull(a.propertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing a
join PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.UniqueID <> b.UniqueID
	where a.PropertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where propertyaddress is null


select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
--CHARINDEX(',', PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertySplitAddress nvarchar(255)


alter table NashvilleHousing
add PropertySplitCity nvarchar(255)

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))



select PropertySplitAddress, PropertySplitCity
from PortfolioProject.dbo.NashvilleHousing



-- Another way to split a string with parsename (good for string with delimiters)
select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'), 1)
,parsename(replace(OwnerAddress, ',', '.'), 2)
,parsename(replace(OwnerAddress, ',', '.'), 3)
From PortfolioProject.dbo.NashvilleHousing


select
parsename(replace(OwnerAddress, ',', '.'), 3)
,parsename(replace(OwnerAddress, ',', '.'), 2)
,parsename(replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255)

update NashvilleHousing
set OwnerSplitAddress = parsename(replace(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255)

update NashvilleHousing
set OwnerSplitCity = parsename(replace(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255)

update NashvilleHousing
set OwnerSplitState = parsename(replace(OwnerAddress, ',', '.'), 1)


select *
From PortfolioProject.dbo.NashvilleHousing





--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct SoldAsVacant, count(*)
From PortfolioProject.dbo.NashvilleHousing
group by soldasvacant



select soldasvacant
, case when soldasvacant = 'Y' then 'Yes'
       when soldasvacant = 'N' then 'No'
	   else soldasvacant
	   end
From PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set soldasvacant = case when soldasvacant = 'Y' then 'Yes'
						when soldasvacant = 'N' then 'No'
						else soldasvacant
						end




-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

with RowNumCTE as
(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
			) row_num
From PortfolioProject.dbo.NashvilleHousing
)
select * 
from RowNumCTE
where row_num > 1




-- delete
with RowNumCTE as
(
select *,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by 
				 UniqueID
			) row_num
From PortfolioProject.dbo.NashvilleHousing
)
delete                                         -- delete
from RowNumCTE
where row_num > 1




select *
From PortfolioProject.dbo.NashvilleHousing





---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress, SaleDate



Select *
From PortfolioProject.dbo.NashvilleHousing





-----------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------

--- Importing Data using OPENROWSET and BULK INSERT	

--  have to configure server appropriately to do correctly

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