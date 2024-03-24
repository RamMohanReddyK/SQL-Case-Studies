SELECT *
FROM [PortFolio2].[dbo].[HousingData]

--- Used WINDOW FUNCTIONS, CTE, CAST/CONVERT, ISNULL, SELFJOIN, SUBSTRING , CHARINDEX,PARSENAME, REPLACE,CASE, ALTER,DROP, UPDATE
/* CLEANING DATA Portfolio Project*/
--1. Standardize SaleDate Format
SELECT Saledate2
	,CONVERT(DATE, SaleDate)
FROM HousingData

-- Adding a column converted date
ALTER TABLE HousingData ADD SaleDate2 DATE;

-- Updating the date to normal format
UPDATE HousingData
SET SaleDate2 = CONVERT(DATE, SaleDate)

--2 After looking that table you should know parcelid is an ID for prop. address, 
--lets get the missing addresses
SELECT a.uniqueid
	,a.ParcelID
	,a.PropertyAddress
	,b.uniqueid
	,b.ParcelID
	,b.PropertyAddress
FROM HousingData a
JOIN HousingData b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
ORDER BY 1

-- Updating address now 
UPDATE a
SET Propertyaddress = ISNULL(a.propertyaddress, b.propertyaddress)
FROM HousingData a
JOIN HousingData b ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

--Order by 1
--- Breaking Prop. ADDRESS & Owner Address in to individual columns   (SUBSTRING, PARSENAME, CHARINDEX,UPDATE,ALTER)
--PropertyAddress	
SELECT PropertyAddress
	,SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1) AS PropAddress
	,SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress)) AS PropCity
FROM HousingData

---Now update the table with 2 new columns
ALTER TABLE HousingData ADD PropAddress NVARCHAR(200);

ALTER TABLE HousingData ADD PropCity NVARCHAR(200);

UPDATE HousingData
SET PropAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) - 1);

UPDATE HousingData
SET PropCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) + 1, LEN(propertyaddress));

SELECT *
FROM HousingData

--OwnerAddress USING PARSENAME instead of substring
SELECT OwnerAddress
FROM HousingData

SELECT PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM HousingData

ALTER TABLE HOUSINGDATA ADD OwnAdd NVARCHAR(200);

ALTER TABLE HOUSINGDATA ADD OwnCity NVARCHAR(200);

ALTER TABLE HOUSINGDATA ADD OwnState NVARCHAR(200);

UPDATE HousingData
SET Ownadd = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3);

UPDATE HousingData
SET OwnCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2);

UPDATE HousingData
SET OwnState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1);

SELECT ownadd
	,owncity
	,Ownstate
FROM HousingData

--- Cleaning Y and N as YES and NO in Sold as Vacant COlumn
SELECT DISTINCT SoldAsVacant
	,CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SOldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END AS New_SAVacant
FROM HousingData

UPDATE HousingData
SET SoldAsVacant = CASE 
		WHEN SoldAsVacant = 'Y'
			THEN 'Yes'
		WHEN SOldAsVacant = 'N'
			THEN 'No'
		ELSE SoldAsVacant
		END
FROM HousingData

SELECT DISTINCT SoldAsVacant
FROM HousingData
	-- Remove Duplicates ROW_NUMBER() , WITH CTE
	-- CTE temp to view duplicates
	WITH ROWCTE AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ParcelID
				,Propertyaddress
				,SalePrice
				,SaleDate
				,LegalReference ORDER BY UniqueID
				) AS RowNum
		FROM HousingData
		)

SELECT *
FROM ROWCTE
WHERE ROWNUM > 1
--- CTE TEMP to delete duplicates
WITH ROWCTE AS (
		SELECT *
			,ROW_NUMBER() OVER (
				PARTITION BY ParcelID
				,Propertyaddress
				,SalePrice
				,SaleDate
				,LegalReference ORDER BY UniqueID
				) AS RowNum
		FROM HousingData
		)

DELETE
FROM ROWCTE
WHERE ROWNUM > 1

--- Delete Unused Columns
SELECT *
FROM HousingData

---lets drop unused columns
ALTER TABLE HousingData

DROP COLUMN OwnerAddress
	,PropertyAddress
	,SaleDate

