select * from NashvilleHousingData

--Standardize sale date

select [Sale Date], CONVERT(date, [Sale Date])
from NashvilleHousingData

update NashvilleHousingData
set [Sale Date]= CONVERT(date, [Sale Date])
---- incase the above doesn't work

select SaleDate from NashvilleHousingData

alter table NashvilleHousingData
add SaleDate date;

update NashvilleHousingData
set SaleDate = CONVERT(date, [Sale Date])

--Populating Property Adress Data

select [Property Address], [Parcel ID]
from NashvilleHousingData
where [Property Address] is null
and [Parcel ID] is not null

select * 
from NashvilleHousingData a
join NashvilleHousingData b
on a.[Parcel ID] = b.[Parcel ID]
and a.F1 <> b.F1
where a.[Property Address] is null


select a.[Property Address], a.[Parcel ID], b.[Property Address], b.[Parcel ID], ISNULL(a.[Property Address], b.[Property Address])
from NashvilleHousingData a join NashvilleHousingData b 
on a.[Parcel ID] = b.[Parcel ID]
and a.F1 <> b.F1
where a.[Property Address] is null

update a
set [Property Address] = ISNULL(a.[Property Address], b.[Property Address])
from NashvilleHousingData a join NashvilleHousingData b 
on a.[Parcel ID] = b.[Parcel ID]
and a.F1 <> b.F1
where a.[Property Address] is null

select * 
from NashvilleHousingData a join NashvilleHousingData b
on a.[Parcel ID] = b.[Parcel ID] 
and a.F1 <> b.F1
where a.[Property Address] is null

--change y and n to yes and no in Sold as vacant field

select distinct([Sold As Vacant])
from NashvilleHousingData

select [Sold As Vacant],
case
when [Sold As Vacant] = 'Y' then 'Yes'
when [Sold As Vacant] = 'N' then 'No'
else [Sold As Vacant]
end
from NashvilleHousingData

update NashvilleHousingData
set [Sold As Vacant] = case
when [Sold As Vacant] = 'Y' then 'Yes'
when [Sold As Vacant] = 'N' then 'No'
else [Sold As Vacant]
end

-- Remove Duplicates
--checking before deleting

with RowNumCTE as(
select *, ROW_NUMBER() over 
(partition by [Parcel ID],[Property Address],[Sale Date],[Sale Price],[Legal Reference] order by F1) row_num
from NashvilleHousingData
)
select * from RowNumCTE
where row_num>1
order by [Property Address]

-- deleting data

with RowNumCTE as(
select *, ROW_NUMBER() over 
(partition by [Parcel ID],[Property Address],[Sale Date],[Sale Price],[Legal Reference] order by F1) row_num
from NashvilleHousingData
)
delete 
from RowNumCTE
where row_num>1



--Deleting unused columns

alter table NashvilleHousingData
drop column
[Unnamed: 0],[Suite/ Condo   #], Address,[Tax District] 

alter table NashvilleHousingData
drop column [Sale Date]


select * from NashvilleHousingData