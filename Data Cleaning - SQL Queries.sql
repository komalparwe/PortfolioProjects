/*
Cleaning Data in SQL Queries
*/
select * from NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
select SaleDate, convert(date,Saledate)from NashvilleHousing 

----bottom query did not work
--update NashvilleHousing
--set Saledate=convert(date,SaleDate)

-- If it doesn't Update properly
ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT (date, Saledate)

 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

select * from NashvilleHousing 
--where PropertyAddress is null
order by ParcelID


select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress , ISNULL(a.propertyaddress, b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null


update a
set PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
from  NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select 
SUBSTRING(PropertyAddress , 1, CHARINDEX (',', PropertyAddress) -1 ) as Address
from NashvilleHousing


select 
SUBSTRING(PropertyAddress , CHARINDEX (',', PropertyAddress) +1 , LEN(PropertyAddress) ) as City
from NashvilleHousing


ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress , 1, CHARINDEX (',', PropertyAddress) -1 )

Alter table NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress , CHARINDEX (',', PropertyAddress) +1 , LEN(PropertyAddress) )

select * from NashvilleHousing


Select OwnerAddress from NashvilleHousing

-----parsename only looks for periods
select
PARSENAME (OwnerAddress, 1)
from NashvilleHousing

-- therfore new query

select
PARSENAME (Replace (OwnerAddress, ',' , '.'), 1)
, PARSENAME (Replace (OwnerAddress, ',' , '.'), 2)
, PARSENAME (Replace (OwnerAddress, ',' , '.'), 3)
from NashvilleHousing


--but it works backwards, therefore
select
PARSENAME (Replace (OwnerAddress, ',' , '.'), 3)
, PARSENAME (Replace (OwnerAddress, ',' , '.'), 2)
, PARSENAME (Replace (OwnerAddress, ',' , '.'),1)
from NashvilleHousing

ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME (Replace (OwnerAddress, ',' , '.'), 3)

---------------
ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME (Replace (OwnerAddress, ',' , '.'), 2)

--------------------
ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME (Replace (OwnerAddress, ',' , '.'), 1)
--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


select distinct SoldasVacant, Count(Soldasvacant) from NashvilleHousing 
group by SoldAsVacant

update NashvilleHousing
set SoldAsVacant = 'No' 
where SoldAsVacant = 'N'


update NashvilleHousing
set SoldAsVacant = 'Yes' 
where SoldAsVacant = 'Y'

-------do the same in one query
select SoldasVacant
, CASE when SoldAsVacant = 'N' THEN 'No'
		when SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END

from NashvilleHousing

update NashvilleHousing
set SoldasVacant = CASE when SoldAsVacant = 'N' THEN 'No'
		when SoldAsVacant = 'Y' THEN 'Yes'
		ELSE SoldAsVacant
		END
-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

--in case we didn't have unique id and we want to check for duplicates in data
select *
from NashvilleHousing



With RowNumCTE as (

select *,
ROW_NUMBER() over(
partition by	ParcelID, 
				PropertyAddress, 
				SalePrice, 
				SaleDate, 
				LegalReference 
				Order by 
				Uniqueid
				) as row_num 
from NashvilleHousing 
--order by ParcelID
)

--select * from RowNumCTE where row_num>1


Delete from RowNumCTE
where row_num>1

---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

  


alter table NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate


select * from NashvilleHousing order by LegalReference




