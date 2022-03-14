

-- Cleaning Data in SQL Queries

Select * from Housing


---------------------------------------------------------------------------------------------------------------------------
-- Standardize Date Format -- 

select saledate
from housing


select saledate, convert(date, saledate)
from housing


--method 1 
update Housing
set SaleDate = convert(date, saledate)

--method 2 
--The ALTER TABLE command adds, deletes, or modifies columns in a table
Alter table housing 
add SaleDateConverted date;

update housing
set saledateconverted = convert(date, saledate)


--Result 
select saledate, saledateconverted from housing




--------------------------------------------------------------------------------------------------------------------------
-- Populate Property Address Data 
-- checking 
select *
from housing
where propertyaddress is null

--identify the duplicate address 
select *
from housing
order by ParcelID

--Solution
-- 1. Self join table and identify the null address which has the same ParcelID 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
from Housing a
join housing b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 2. Replace the null column with the adress that is the same ParcelID 
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
from Housing a
join housing b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

-- 3. Update the query from step 2 
update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from Housing a
join housing b
	on a.ParcelID =b.ParcelID
	and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--4. Result & Cheking
-- it should show 0 row 
select propertyaddress
from Housing
where PropertyAddress is null



------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Breaking out Address into Individual Columns (Address, City, State)

-------------------------------------------PROPERTY ADRESS----------------------------------------------------------------
-- 1. identify the property address 
select propertyaddress
from Housing
order by propertyaddress

-- The SUBSTRING() function extracts some characters from a string
-- 2. '-1' is to remove the comma at the end of the address 
select
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as address
from housing 
order by propertyaddress

-- 3. he LEN() function returns the length of a string.
substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as address,
substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress)) as City
from housing 
order by propertyaddress

-- 4. Add the new column into the table & Update table from step 3 
Alter table housing 
add PropertySplitAdress Nvarchar(255);
update housing
set PropertySplitAdress = substring(PropertyAddress, 1, charindex(',', PropertyAddress) -1)

Alter table housing 
add PropertySplitCity Nvarchar(255);
update housing
set PropertySplitCity = substring(PropertyAddress, charindex(',', PropertyAddress) +1, len(PropertyAddress))


-- 5. Result 
select PropertySplitAdress, PropertySplitCity
from housing 

--or
-- you should see the 2 new added coloumn 'PropertySplitAdress' & 'PropertySplitCity'
Select *from housing 



----------------------------------------------OWNER ADRESS------------------------------------------------------------------------------------------------
-- another way to split data (easier)
-- 1. Identify Owner Adress 
select owneraddress
from Housing

--2. PARSENAME function to split delimited data (PARSENAME is only useful with period), therefore we need to replace commas with "."
select 
PARSENAME (replace(owneraddress, ',', '.') ,3) as address,
PARSENAME (replace(owneraddress, ',', '.') ,2) as city,
PARSENAME (replace(owneraddress, ',', '.') ,1) as state
from housing

--3.Add the new column into the table & Update table from step 2 
Alter table housing 
add OwnerSplitAddress Nvarchar(255);
update housing
set OwnerSplitAddress = PARSENAME (replace(owneraddress, ',', '.') ,3)

Alter table housing 
add OwnerSplitCity Nvarchar(255);
update housing
set OwnerSplitCity = PARSENAME (replace(owneraddress, ',', '.') ,2)

Alter table housing 
add OwnerSplitState Nvarchar(255);
update housing
set OwnerSplitState = PARSENAME (replace(owneraddress, ',', '.') ,1)

-- 4.Result & Checking 
Select * from housing 


----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field
-- 1. Identify "SoldAsVancant" column with distinct function 
select distinct(soldasvacant), count (soldasvacant)
from housing
group by soldasvacant
order by 2


-- 2.CASE function has the functionality of an IF-THEN-ELSE statement 
-- Syntax --
/*CASE
   WHEN condition1 THEN stuff
   WHEN condition2 THEN other stuff
   ...
   ELSE default stuff
END
*/

select soldasvacant,
	case	
		when SoldAsVacant = 'Y'then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else soldasvacant
	end 
from housing

-- 3. Update table from step 2 
update Housing
set SoldAsVacant = case	
		when SoldAsVacant = 'Y'then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else soldasvacant
	end 

-- 4. checking 
select distinct(soldasvacant), count (soldasvacant)
from housing
group by soldasvacant
order by 2




-----------------------------------------------------------------------------------------------------------------------------------------------------------
-- Remove Duplicates
-- 1. Row Number function, 
  --Syntax--
  /*
  Select *
  row_number () Over (
  partition by
	Order BY
  */
 -- identify the dupliucate data 
  With rownumberCTE as(
  Select *,
	 row_number() Over (
	 partition by parcelID,
					 PropertyAddress,
					 saleprice,
					 saledate,
					 legalreference
		order by uniqueid) row_num
	From housing 
		order by parcelID 

-- 2. identify the dupliucate data (CTE Function)
-- Common Table Expression (CTE) Types, used to generate a temporary named set (like a temporary table) that exists for the duration of a query.
  With rownumberCTE as(
  Select *,
	 row_number() Over (
	 partition by parcelID,
					 PropertyAddress,
					 saleprice,
					 saledate,
					 legalreference
		order by uniqueid) row_num
	From housing)
select * 
from rownumberCTE
where row_num >1
order by PropertyAddress

-- 3. delete the duplicate data which row_num shows 2 
 With rownumberCTE as(
  Select *,
	 row_number() Over (
	 partition by parcelID,
					 PropertyAddress,
					 saleprice,
					 saledate,
					 legalreference
		order by uniqueid) row_num
	From housing)
delete 
from rownumberCTE
where row_num >1

-- 4. Checking (Result should be empty)
  With rownumberCTE as(
  Select *,
	 row_number() Over (
	 partition by parcelID,
					 PropertyAddress,
					 saleprice,
					 saledate,
					 legalreference
		order by uniqueid) row_num
	From housing)
select * 
from rownumberCTE
where row_num >1
order by PropertyAddress




------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Delete Unused Columns

select * from housing 

-- 1. Delete the unclean columns
alter table housing 
drop column owneraddress,
			propertyaddress,
			taxdistrict,
			saledate




/*
RECAP

1. standardize format 
2. Split data into individual column
3. Replace value 
4. Remove duplicate 
5. Remove unused columns

*/

