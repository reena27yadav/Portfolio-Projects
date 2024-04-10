use PortfolioProjects;

select * from NashvilleHousing;

--Standardize Date Format

Alter table NashvilleHousing
Add SaleDateConverted date;

update NashvilleHousing
set SaleDateConverted = convert(date,SaleDate);

--Populate property address data


Select *
From NashvilleHousing
--Where PropertyAddress is null
order by ParcelID

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress) 
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a
set a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from NashvilleHousing a
join NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out address into individual columns (Addres, City, State)

Select PropertyAddress
From NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID


select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
from NashvilleHousing

Alter table NashvilleHousing
Add PropertySplitAddress NVarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1);

Alter table NashvilleHousing
Add PropertySplitCity NVarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress));

select * from NashvilleHousing;

--Splitting address with multiple delimeter

select OwnerAddress from NashvilleHousing; 

select
PARSENAME(replace(OwnerAddress,',','.') ,3),
PARSENAME(replace(OwnerAddress,',','.') ,2),
PARSENAME(replace(OwnerAddress,',','.') ,1)
from NashvilleHousing; 

Alter table NashvilleHousing
Add OwnerSplitAddress NVarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress,',','.') ,3);

Alter table NashvilleHousing
Add OwnerSplitCity NVarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress,',','.') ,2);

Alter table NashvilleHousing
Add OwnerSplitState NVarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress,',','.') ,1);

select * from NashvilleHousing;

--Change Y and N as Yes and No in SoldAsVacant field

select distinct(SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
Group By SoldAsVacant
Order By 2;

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
	 from NashvilleHousing

update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
	 when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end

--Remove duplicates

--We can identify duplicate rows by rank, order rank, row_number

with RowNumCTE as(
select *, 
ROW_NUMBER() over(
partition By ParcelId,
			 LandUse,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 Order By UniqueID) row_num
from NashvilleHousing
--Order By ParcelID
)
Delete 
from RowNumCTE
where row_num>1

--to check if there are any duplicates
with RowNumCTE as(
select *, 
ROW_NUMBER() over(
partition By ParcelId,
			 LandUse,
			 PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 Order By UniqueID) row_num
from NashvilleHousing
--Order By ParcelID
)
Select *
from RowNumCTE
where row_num>1
Order By PropertyAddress

--Delete unused columns


alter table NashvilleHousing
drop column PropertyAddress,
	    SaleDate,
	    OwnerAddress,
	    TaxDistrict