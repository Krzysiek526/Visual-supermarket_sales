--1

CREATE SCHEMA supermarket

CREATE TABLE supermarket.Sales_Landing
(
[Invoice_ID] VARCHAR(50)
,[Branch] VARCHAR(50)
,[City]	VARCHAR(50)
,[Customer_type] VARCHAR(50)
,[Gender] VARCHAR(50)
,[Product_line] VARCHAR(50)
,[Unit_price] VARCHAR(50)
,[Quantity] VARCHAR(50)
,[Date] VARCHAR(50)
,[Time] VARCHAR(50)
,[Payment] VARCHAR(50)
,[Rating] VARCHAR(50)

)

SELECT * FROM supermarket.Sales_Landing

INSERT INTO supermarket.Sales_Landing
([City]) Values ('KRK')

TRUNCATE TABLE supermarket.Sales_Landing

DROP TABLE supermarket.Sales_Landing
  

--------------------------------------------------------------------------
--2




CREATE TABLE supermarket.[Sales_Staging]
(
 [Invoice_ID] VARCHAR(50)
,[Branch] VARCHAR(50)
,[City]	VARCHAR(50)
,[Customer_type] VARCHAR(50)
,[Gender] VARCHAR(50)
,[Product_line] VARCHAR(50)
,[Unit_price] DECIMAL(4,2)
,[Quantity] INT
,[Date] DATE
,[Time] TIME
,[Payment] VARCHAR(50)
,[Rating] DECIMAL(3,1)
)

SELECT * FROM supermarket.Sales_Staging

DROP TABLE supermarket.Sales_Staging

INSERT INTO supermarket.Sales_Staging ([City])
Values ('CAN')

TRUNCATE TABLE supermarket.Sales_Staging



CREATE OR ALTER PROCEDURE supermarket.loaddata AS
BEGIN TRY
	BEGIN TRAN
	TRUNCATE TABLE supermarket.Sales_Staging;
	INSERT INTO supermarket.Sales_Staging
	(
		[Invoice_ID]
		,[Branch]
		,[City]
		,[Customer_type]
		,[Gender]
		,[Product_line]
		,[Unit_price]
		,[Quantity]
		,[Date]
		,[Time]
		,[Payment]
		,[Rating]
	)
	SELECT
		 [Invoice_ID]
		,[Branch]
		,[City]
		,[Customer_type]
		,[Gender]
		,[Product_line]
		,CAST([Unit_price] AS DECIMAL(4,2))
		,CAST([Quantity] AS INT)
		,CAST([Date] AS DATE)
		,CAST([Time] AS TIME)
		,[Payment]
		,CAST([Rating] AS DECIMAL(3,1))
		FROM supermarket.Sales_Landing
		ALTER TABLE supermarket.Sales_Staging ALTER COLUMN [Payment] VARCHAR (15);
	COMMIT TRAN
END TRY

BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE()
END CATCH



EXEC  supermarket.loaddata


SELECT * FROM supermarket.Sales_Staging
INSERT INTO supermarket.Sales_Staging ([City])
Values ('CAN')







SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Sales_Staging'





--------------------------------------------------------------------------------------------------------------------------------
--3 a)

CREATE TABLE supermarket.City
(
	CityId INT IDENTITY(1,1),
	CityName NVARCHAR(15),
	CONSTRAINT PK_City_CityId PRIMARY KEY CLUSTERED
	(
	CityId ASC
	),
	CONSTRAINT UK_City_CityName UNIQUE
	(
	CityName
	)
)

DROP TABLE supermarket.City

CREATE OR ALTER PROCEDURE supermarket.CityPROC AS
BEGIN TRY
    BEGIN TRANSACTION
        SELECT DISTINCT
            [City]
        INTO 
			#tmpDim
        FROM
            supermarket.Sales_Staging
        INSERT INTO supermarket.City (CityName)
        SELECT
            [City]
        FROM #tmpDim
        EXCEPT
        SELECT CityName
        FROM
        supermarket.City
        DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH

SELECT * FROM supermarket.City
EXEC supermarket.CityPROC


------------------------------------------------------------------------------------------------
--3 City - Branch
CREATE TABLE supermarket.Branch
(
	BranchId INT IDENTITY(1,1),
	BranchName NVARCHAR(2),
	CONSTRAINT PK_Branch_BranchId PRIMARY KEY CLUSTERED
	(
	BranchId ASC
	),
	CONSTRAINT UK_Branch_BranchName UNIQUE
	(
	BranchName
	),
	CityId INT FOREIGN KEY REFERENCES supermarket.City(CityId),
)

SELECT * FROM supermarket.Branch

CREATE OR ALTER PROCEDURE supermarket.BranchPROC AS
BEGIN TRY
    BEGIN TRANSACTION
		DROP TABLE IF EXISTS #tmpDim 
		SELECT DISTINCT
            stg.[Branch],
			c.CityId
		INTO
			#tmpDim
		FROM
		supermarket.Sales_Staging stg
		JOIN
		supermarket.City c
		ON [stg].[City] = c.CityName
        INSERT INTO supermarket.Branch(BranchName, CityId)
		SELECT
			Branch,
			CityId
		FROM
			#tmpDim
		EXCEPT
		SELECT
			BranchName,
			CityId
		FROM supermarket.Branch
		DROP TABLE #tmpDim
    COMMIT TRANSACTION
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH


SELECT * from supermarket.Branch

EXEC supermarket.BranchPROC

TRUNCATE TABLE supermarket.Branch
--------------------------------------------------
--3 c

CREATE TABLE supermarket.CustomerType
(
	TypeId INT IDENTITY(1,1),
	Customer_type NVARCHAR(10),
	CONSTRAINT PK_CustomerType_TypeId PRIMARY KEY CLUSTERED
	(
	TypeId ASC
	),
	CONSTRAINT UK_CustomerType_Customer_type UNIQUE
	(
	Customer_type
	)
)


CREATE OR ALTER PROC supermarket.CustomerTypePROC AS
BEGIN TRY
	BEGIN TRAN
	DROP TABLE IF EXISTS #tmpDim 
		
		SELECT DISTINCT
		[Customer_type]
		INTO
			#tmpDim
		FROM
		supermarket.Sales_Staging
		INSERT INTO supermarket.CustomerType (Customer_type)
		SELECT
            [Customer_type]
        FROM #tmpDim
        EXCEPT
        SELECT [Customer_type]
        FROM
        supermarket.CustomerType
        DROP TABLE #tmpDim
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
    PRINT ERROR_MESSAGE();
END CATCH


SELECT * FROM supermarket.CUSTOMERTYPE

EXEC supermarket.CustomerTypePROC


------------------------------------------------
--3 d

CREATE TABLE supermarket.Gender
(
	GenderId INT IDENTITY(1,1),
	Gender NVARCHAR(10),
	CONSTRAINT PK_Gender_GenderId PRIMARY KEY CLUSTERED
	(
	GenderId ASC
	)
)

CREATE OR ALTER PROC supermarket.GenderPROC AS
BEGIN TRY
	BEGIN TRAN

		DROP TABLE IF EXISTS #tmpDIM

		SELECT DISTINCT [GENDER]
		INTO #tmpDIM
		FROM supermarket.Sales_Staging

		INSERT INTO supermarket.Gender(Gender)

		SELECT [Gender] FROM #tmpDIM
		EXCEPT
		SELECT [Gender] FROM supermarket.Gender

		DROP TABLE #tmpDIM
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH

SELECT * FROM supermarket.Gender

EXEC supermarket.GenderPROC

TRUNCATE TABLE supermarket.GENDER
-------------------------------------------------------------------
--3 e

CREATE TABLE supermarket.Product
(
	ProductId INT IDENTITY (1,1),
	Product_line NVARCHAR(25),
	CONSTRAINT PK_Product_ProductId PRIMARY KEY CLUSTERED
	(
	ProductId ASC
	)
)

CREATE OR ALTER PROC supermarket.ProductPROC AS
BEGIN TRY
	BEGIN TRAN
		DROP TABLE IF EXISTS #tmpDIM
		
		SELECT DISTINCT [Product_line] 
		INTO #tmpDIM
		FROM supermarket.Sales_Staging

		INSERT INTO supermarket.Product(Product_line)

		SELECT [Product_line] FROM #tmpDim
		EXCEPT
		SELECT [Product_line] FROM supermarket.Product

		DROP TABLE #tmpDIM
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH

SELECT * FROM supermarket.Product

EXEC supermarket.ProductPROC




TRUNCATE TABLE supermarket.Product


--------------------------------------------------------------
--3 f

CREATE TABLE supermarket.OrderDetails
(
	OrderId INT IDENTITY (1,1),
	Unit_price DECIMAL(4,2),
	Quantity INT,
	Total_Netto DECIMAL (5,2),
	Total_Brutto DECIMAL (8,4),
	Tax DECIMAL (6,4),
	Gross_margin DECIMAL(17,15),
	Time TIME,
	Date Varchar(10),
	CONSTRAINT PK_OrderDetails_OrderId PRIMARY KEY CLUSTERED
	(
	OrderId ASC
	)
)

DROP TABLE supermarket.OrderDetails

CREATE OR ALTER PROC supermarket.orderdetailsPROC AS
BEGIN TRY
	BEGIN TRAN
		DROP TABLE IF EXISTS #tmpDIM

		SELECT Unit_price, Quantity,
		CAST((Unit_price*Quantity)AS DECIMAL (5,2)) AS Netto,
		CAST((((Unit_price*Quantity)*105)/100) AS DECIMAL (8,4)) AS Brutto,
		(CAST((((Unit_price*Quantity)*105)/100)AS DECIMAL (8,4)) - CAST((Unit_price*Quantity)AS DECIMAL (5,2))) AS TAX,
		(((CAST((((Unit_price*Quantity)*105)/100)AS DECIMAL (8,4)) - CAST((Unit_price*Quantity)AS DECIMAL (5,2))) / CAST((((Unit_price*Quantity)*105)/100) AS DECIMAL (8,4)))*100) AS GROSS,
		Time,
		CONVERT(varchar, Date, 101) AS Date
		INTO #tmpDIM
		FROM supermarket.Sales_Staging
		INSERT INTO supermarket.OrderDetails(Unit_price,Quantity,Total_Netto,Total_Brutto,Tax,Gross_margin,Time,Date)

		SELECT [Unit_price],[Quantity],[Netto],[Brutto],[TAX],[GROSS],[Time],[Date] FROM #tmpDim
		EXCEPT
		SELECT [Unit_price],[Quantity],[Total_Netto],[Total_Brutto],[Tax],[Gross_margin],[Time],[Date] FROM supermarket.OrderDetails

		DROP TABLE #tmpDIM
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH


EXEC supermarket.orderdetailsPROC

TRUNCATE TABLE supermarket.OrderDetails
SELECT * FROM supermarket.OrderDetails
---------------------------------------------------------

SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OrderDetails'


SELECT Unit_price, Quantity
		,Time
		,DATE
		,CONVERT(varchar, Date, 1)
		,CONVERT(varchar, Date, 2)
		,CONVERT(varchar, Date, 101)
		FROM supermarket.Sales_Staging



---
--3 g



CREATE TABLE supermarket.Payment
(
	PaymentId INT IDENTITY (1,1),
	Payment Varchar(15),
	CONSTRAINT PK_Payment_PaymentId PRIMARY KEY CLUSTERED
	(
	PaymentId ASC
	)
)

CREATE OR ALTER PROC supermarket.PaymentPROC AS
BEGIN TRY
	BEGIN TRAN
		DROP TABLE IF EXISTS #tmpDIM

		SELECT DISTINCT Payment
		INTO #tmpDIM
		FROM supermarket.Sales_Staging

		INSERT INTO supermarket.Payment(Payment)

		SELECT [Payment] FROM #tmpDim
		EXCEPT
		SELECT [Payment] FROM supermarket.Payment

		DROP TABLE #tmpDIM
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH

EXEC supermarket.PaymentPROC

SELECT * FROM supermarket.Payment



TRUNCATE TABLE supermarket.Payment


-------------------------------------------------------------------
--4 Fact


SELECT * FROM supermarket.FactSales

CREATE TABLE supermarket.FactSales
(
	  InvoiceID NVARCHAR(15)
	, BranchId INT FOREIGN KEY REFERENCES supermarket.Branch(BranchId)
	, CustomerTypeId INT FOREIGN KEY REFERENCES supermarket.CustomerType(TypeId)
    , GenderId INT FOREIGN KEY REFERENCES supermarket.Gender(GenderId)
    , OrderDetailsId INT FOREIGN KEY REFERENCES supermarket.OrderDetails(OrderId)
    , PaymentId INT FOREIGN KEY REFERENCES supermarket.Payment(PaymentId)
    , ProductId INT FOREIGN KEY REFERENCES supermarket.Product(ProductId)
	, Rating DECIMAL (4,2)
	, CONSTRAINT PK_FactSales_Id PRIMARY KEY CLUSTERED
	(
	InvoiceID ASC
	)
)

DROP TABLE supermarket.FactSales

CREATE OR ALTER PROC supermarket.FactSalesPROC AS
BEGIN TRY
	BEGIN TRAN
		TRUNCATE TABLE supermarket.FactSales
		
		INSERT INTO supermarket.FactSales
		(	
			InvoiceID
			,BranchId
			,CustomerTypeId
			,GenderId
			,OrderDetailsId
			,PaymentId
			,ProductId
			,Rating
		)

		SELECT
		stg.Invoice_ID
		,b.BranchId
		,c.TypeId
		,g.GenderId
		,od.OrderId
		,p.PaymentId
		,po.ProductId
		,stg.Rating
		FROM
          supermarket.Sales_Staging stg
        JOIN
			supermarket.Branch b
			ON b.BranchName = stg.Branch
		JOIN
			supermarket.CustomerType c
			ON c.Customer_type = stg.Customer_type
		JOIN
			supermarket.Gender g
			ON g.Gender = stg.Gender
		JOIN
			supermarket.OrderDetails od
			ON (od.Unit_price = stg.Unit_price
			AND
			od.Quantity = stg.Quantity
			AND
			od.Date = stg.Date
			)
		JOIN
			supermarket.Product po
			ON po.Product_line = stg.Product_line
		JOIN
			supermarket.Payment p
			ON p.Payment = stg.Payment
	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH


EXEC supermarket.FactSalesPROC


SELECT * FROM supermarket.FactSales


TRUNCATE TABLE supermarket.FactSales

--------------------------------------------------------------------
-- 5View

CREATE OR ALTER PROC supermarket.viewPROC AS
BEGIN TRY
	BEGIN TRAN
	EXEC('
		CREATE OR ALTER VIEW supermarket.viewALL AS
		SELECT
			fct.InvoiceID
			,br.[BranchName]
			,c.[CityName]
			,ct.[Customer_type]
			,g.[Gender]
			,pr.[Product_line]
			,od.[Unit_price]
			,od.[Quantity]
			,od.[Total_Netto]
			,od.[Tax]
		    ,od.[Total_Brutto]
		    ,od.[Gross_margin]
		    ,od.[Time]
		    ,od.[Date]
			,p.[Payment]
			,fct.[Rating]
		FROM supermarket.FactSales fct
		JOIN
			supermarket.Branch br
			ON fct.BranchId = br.BranchId
		JOIN
			supermarket.City c
			ON c.CityId = br.CityId
		JOIN
			supermarket.CustomerType ct
			ON ct.TypeId = fct.CustomerTypeId
		JOIN
			supermarket.Gender g
			ON g.GenderId = fct.GenderId
		JOIN
			supermarket.OrderDetails od
			ON od.OrderId = fct.OrderDetailsId
		JOIN
			supermarket.Payment p
			ON p.PaymentId = fct.PaymentId
		JOIN
			supermarket.Product pr
			ON pr.ProductId = fct.ProductId
		')

	COMMIT TRAN
END TRY
BEGIN CATCH
	ROLLBACK TRAN
	PRINT ERROR_MESSAGE();
END CATCH



EXEC supermarket.viewPROC
