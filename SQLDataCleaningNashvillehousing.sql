SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [Housingdatacleaning].[dbo].[Nashvillehousing]



  select *
  From Housingdatacleaning.dbo.Nashvillehousing


  -- standardize the sales date for the housing.

  select SaleDate, CONVERT(date,saledate) as updatedsaledate
  From Housingdatacleaning.dbo.Nashvillehousing

  --updating the coloumn in actual data.

  update Nashvillehousing
  set SaleDate = CONVERT(date,saledate)
  --due to some technical reasons above command didnot worked.
  -- using another approch to convert. Using alter command.

  alter table Nashvillehousing
  add saledateconverted date;
  
  --Updating in actual data.

    update Nashvillehousing
  set saledateconverted = CONVERT(date,saledate)

    select saledateconverted, CONVERT(date,saledate) as updatedsaledate
  From Housingdatacleaning.dbo.Nashvillehousing

  -- working on populate property address.

    select *
  From Housingdatacleaning.dbo.Nashvillehousing
  --where PropertyAddress is null
  order by ParcelID

  -- observing the data shows that there is same property address for parcelID. o, we can join on parceID and property address.
  -- Using ISNULL command this commands states if something is null in this case a.propertyaddress than put other thing in this case
  -- b.propertyaddress.

  select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
  from Housingdatacleaning.dbo.Nashvillehousing a
  join Housingdatacleaning.dbo.Nashvillehousing b
  on a.ParcelID = b.ParcelID
  And a.[UniqueID] <> b.[UniqueID]
  where a.PropertyAddress is null

  -- UPdating the data with the new propertyaddress.

  Update a
  SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
  from Housingdatacleaning.dbo.Nashvillehousing a
  join Housingdatacleaning.dbo.Nashvillehousing b
  on a.ParcelID = b.ParcelID
  And a.[UniqueID] <> b.[UniqueID]
  where a.PropertyAddress is null


  -- Breaking address into individual coloumn (Address, City, State)

  select PropertyAddress
  from Housingdatacleaning.dbo.Nashvillehousing

  -- using substring and character index command to seprate address.

  Select
  SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
  From Housingdatacleaning.dbo.Nashvillehousing


 -- using substring and character index command to seprate address.
 -- Using the same commands to seprate city.

   Select
   SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1) as Address
  ,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as Address
  From Housingdatacleaning.dbo.Nashvillehousing

  -- Now creating two new coloumn for both of address and city.


  alter table Nashvillehousing
  add PropertyAddressSplit Nvarchar(255)

  
  Update Nashvillehousing
  set PropertyAddressSplit = SUBSTRING(PropertyAddress, 1,CHARINDEX(',', PropertyAddress)-1)

  --Now doing the above similar for the city region.

  alter table NashvilleHousing
  add PropertyCitySplit Nvarchar(255)

  Update Nashvillehousing
  set PropertyCitySplit = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))



  Select*
  from Housingdatacleaning.dbo.Nashvillehousing

  alter table NashvilleHousing
  add PropertySplitAddress Nvarchar(255)


  
  Update Nashvillehousing
  set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

  -- Doing similar to seprate Owner address in form of city, state and address using parse name.

  select ownerAddress
  from Housingdatacleaning.dbo.Nashvillehousing

  -- nothing happened as parsename workes only works with (.) and not with (,) so we need to replace.
  select
  PARSENAME(OwnerAddress,1)
  From Housingdatacleaning.dbo.Nashvillehousing

  -- replacing. and plus parsename works from the backwards so it is showing state.

  select
  PARSENAME(replace(OwnerAddress, ',', '.'), 3)
  ,PARSENAME(replace(OwnerAddress, ',', '.'), 2)
  ,PARSENAME(replace(OwnerAddress, ',', '.'), 1)
  From Housingdatacleaning.dbo.Nashvillehousing

  -- Now updating the data.


    alter table NashvilleHousing
  add OwnerSplitAddress Nvarchar(255)

  
  Update Nashvillehousing
  set OwnerSplitAddress= PARSENAME(replace(OwnerAddress, ',', '.'),3)


  
    alter table NashvilleHousing
  add OwnerSplitcity Nvarchar(255)

  
  Update Nashvillehousing
  set OwnerSplitcity= PARSENAME(replace(OwnerAddress, ',', '.'),2)


  
    alter table NashvilleHousing
  add OwnerSplitState Nvarchar(255)


  
  Update Nashvillehousing
  set OwnerSplitState= PARSENAME(replace(OwnerAddress, ',', '.'),1)


  Select*
  from Housingdatacleaning.dbo.Nashvillehousing


  --Change Y and N to Yes and No in " Sold and vacant" coloumn.
  -- Let's make some count over all.

  Select Distinct (SoldAsVacant), COUNT (SoldAsVacant)
  From Housingdatacleaning.dbo.Nashvillehousing
  Group by SoldAsVacant
  Order by 2

  -- Using case satement making changes.

  Select SoldAsVacant
  , Case When SoldAsVacant = 'Y' then 'Yes'
         When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End
From Housingdatacleaning.dbo.Nashvillehousing


Update Nashvillehousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
         When SoldAsVacant = 'N' then 'No'
		 Else SoldAsVacant
		 End


--Removing Duplicates.

--Removing data may lead to losing of all the important data as well. So, trying the removingn commands on a CTE and then
-- using the command in real can save the data.



WITH RowNumCTE AS(
Select*,
ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   Order by UniqueID
				   ) row_num

From Housingdatacleaning.dbo.Nashvillehousing
)
Select*
from RowNumCTE
where row_num > 1
order by ParcelID

--So now as all the duplicates are found we can delete them.


WITH RowNumCTE AS(
Select*,
ROW_NUMBER() OVER(
      PARTITION BY ParcelID,
	               PropertyAddress,
				   SalePrice,
				   SaleDate,
				   LegalReference
				   Order by UniqueID
				   ) row_num

From Housingdatacleaning.dbo.Nashvillehousing
)
Delete
from RowNumCTE
where row_num > 1
--order by ParcelID


-- Removing all the unwanted coloumns.

select*
from Housingdatacleaning.dbo.Nashvillehousing

Alter Table Housingdatacleaning.dbo.Nashvillehousing
Drop column TaxDistrict, PropertyAddressSplit, PropertySplitAddress


Alter Table Housingdatacleaning.dbo.Nashvillehousing
Drop column SaleDate