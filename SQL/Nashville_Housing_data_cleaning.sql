
select * 
from data_cleaning.dbo.[Nashville House] 


-- date formatting

select SaleDate, convert(date,saledate)
from data_cleaning.dbo.[Nashville House]

--Alter table [Nashville House] 
--add convertedsaledate date

--update [Nashville House] 
--set convertedsaledate = convert(date,saledate)

--select convertedsaledate 
--from [Nashville House]

Alter table data_cleaning.dbo.[Nashville House]
alter column saledate date

-- alter table [Nashville House] 
-- drop column convertedsaledate

select * from data_cleaning.dbo.[Nashville House]

-- property address data

select propertyaddress 
from data_cleaning.dbo.[Nashville House]
where PropertyAddress is null

select a.[UniqueID ],a.parcelid,a.propertyaddress,b.[UniqueID ],b.parcelid,b.propertyaddress
from data_cleaning.dbo.[Nashville House] a
join data_cleaning.dbo.[Nashville House] b 
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

update a 
set a.PropertyAddress = b.PropertyAddress
from data_cleaning.dbo.[Nashville House] a
join data_cleaning.dbo.[Nashville House] b 
on a.ParcelID = b.ParcelID 
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

select *
from data_cleaning.dbo.[Nashville House]
where PropertyAddress is null


-- dividing address into individual colunns

select PropertyAddress
from data_cleaning.dbo.[Nashville House]

select propertyaddress, 
SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1) as address,
SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(PropertyAddress)) as city
from data_cleaning.dbo.[Nashville House]

alter table data_cleaning.dbo.[Nashville House] 
add addresssplit  nvarchar(255)

alter table data_cleaning.dbo.[Nashville House]
add citysplit nvarchar(255) 

update data_cleaning.dbo.[Nashville House]
set addresssplit = SUBSTRING(propertyaddress,1,CHARINDEX(',',propertyaddress)-1)

update data_cleaning.dbo.[Nashville House]
set citysplit = SUBSTRING(propertyaddress,CHARINDEX(',',propertyaddress)+1,len(PropertyAddress))

select *
from data_cleaning.dbo.[Nashville House]

-- owner address 

select 
PARSENAME(replace(owneraddress,',','.'),3),
PARSENAME(replace(owneraddress,',','.'),2),
PARSENAME(replace(owneraddress,',','.'),1)
from data_cleaning.dbo.[Nashville House]

alter table data_cleaning.dbo.[Nashville House]
add owneraddresssplit nvarchar(255) 

update data_cleaning.dbo.[Nashville House]
set owneraddresssplit = PARSENAME(replace(owneraddress,',','.'),3)

alter table data_cleaning.dbo.[Nashville House]
add ownercitysplit nvarchar(255) 

update data_cleaning.dbo.[Nashville House]
set ownercitysplit = PARSENAME(replace(owneraddress,',','.'),2)

alter table data_cleaning.dbo.[Nashville House]
add ownerstatesplit nvarchar(255) 

update data_cleaning.dbo.[Nashville House]
set ownerstatesplit = PARSENAME(replace(owneraddress,',','.'),1)

select * 
from data_cleaning.dbo.[Nashville House]
order by [UniqueID ]


-- soldasvacnt column cleaning

select distinct SoldAsVacant
from data_cleaning.dbo.[Nashville House]

select replace(SoldAsVacant,'Y','Yes'),
replace(SoldAsVacant,'N','No')
from data_cleaning.dbo.[Nashville House]
where SoldAsVacant = 'Y' or SoldAsVacant ='N'

update data_cleaning.dbo.[Nashville House]
set SoldAsVacant = replace(SoldAsVacant,'Y','Yes') 
where SoldAsVacant = 'Y' 

update data_cleaning.dbo.[Nashville House]
set SoldAsVacant = replace(SoldAsVacant,'N','No') 
where SoldAsVacant = 'N'

select distinct SoldAsVacant
from data_cleaning.dbo.[Nashville House]

--select SoldAsVacant,
--case 
--when SoldAsVacant = 'Y' then 'Yes'
--when SoldAsVacant = 'N' then 'No'
--else SoldAsVacant
--end
--from data_cleaning.dbo.[Nashville House]


--Remove duplicates

with uniqcte as (
select *,
ROW_NUMBER() over(
partition by parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			order by 
			uniqueid) row_num

from data_cleaning.dbo.[Nashville House]
-- order by ParcelID
)
select *
from uniqcte
where row_num >1
order by propertyaddress 


with uniqcte as (
select *,
ROW_NUMBER() over(
partition by parcelid,
			propertyaddress,
			saleprice,
			saledate,
			legalreference
			order by 
			uniqueid) row_num

from data_cleaning.dbo.[Nashville House]
-- order by ParcelID
)
delete
from uniqcte
where row_num >1


-- delete unused columns

select * 
from data_cleaning.dbo.[Nashville House]


alter table data_cleaning.dbo.[Nashville House]
drop column propertyaddress

alter table data_cleaning.dbo.[Nashville House]
drop column owneraddress

alter table data_cleaning.dbo.[Nashville House]
drop column taxdistrict
