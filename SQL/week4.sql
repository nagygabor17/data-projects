USE Northwind
GO

-- 1. Listázzuk ki a termékeket (Products), adjunk hozzá egy eredmény (Result) mezőt,
-- melynek értéke 'OK' ha az előző évhez képest nőtt az eladási darabszám (Quantity), és 'Not OK' ha nem.

SELECT *
FROM Products

SELECT *
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID

SELECT *
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID JOIN Orders O
ON O.OrderID = OD.OrderID

SELECT P.ProductID, P.ProductName, O.OrderDate, OD.Quantity
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID JOIN Orders O
ON O.OrderID = OD.OrderID

SELECT P.ProductID, P.ProductName, YEAR(O.OrderDate) AS Year, SUM(OD.Quantity) As TotalQty
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID JOIN Orders O
ON O.OrderID = OD.OrderID
GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate)
ORDER BY P.ProductID, P.ProductName, YEAR(O.OrderDate)

;WITH cteProductsByYear AS
(SELECT P.ProductID, P.ProductName, YEAR(O.OrderDate) AS Year, SUM(OD.Quantity) As TotalQty
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID JOIN Orders O
ON O.OrderID = OD.OrderID
GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate))
SELECT	*,
		LAG(TotalQty,1,0) OVER (PARTITION BY ProductID ORDER BY Year) AS PrevQty,
		IIF(TotalQty>LAG(TotalQty,1,0) OVER (PARTITION BY ProductID ORDER BY Year),'OK','Not OK') AS Result
FROM cteProductsByYear

SELECT	P.ProductID, 
		P.ProductName, 
		YEAR(O.OrderDate) AS Year, 
		SUM(OD.Quantity) As TotalQty,
		LAG(SUM(OD.Quantity),1,0) OVER (PARTITION BY P.ProductID ORDER BY YEAR(O.OrderDate)) AS PrevQty,
		IIF(SUM(OD.Quantity)>LAG(SUM(OD.Quantity),1,0) OVER (PARTITION BY P.ProductID ORDER BY YEAR(O.OrderDate)),'OK','Not OK') AS Result
FROM Products P JOIN [Order Details] OD
ON P.ProductID = Od.ProductID JOIN Orders O
ON O.OrderID = OD.OrderID
GROUP BY P.ProductID, P.ProductName, YEAR(O.OrderDate)
GO

-- 2. Kérdezzük le az ügyfelek (Customers) kedvenc termékét (Products), vagyis azt a terméket, amiből az ügyfél 
-- a legtöbb darabot (Quantity) vásárolta eddig. 
-- A kimenetben szerepeljen az ügyfél neve (CompanyName) és a termék megnevezése (ProductName).

SELECT *
FROM Customers

SELECT *
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID

SELECT *
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID

SELECT *
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON P.ProductID = Od.ProductID

SELECT	C.CompanyName,
		P.ProductName,
		SUM(OD.Quantity) AS TotalQty
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON P.ProductID = Od.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName
ORDER BY C.CustomerID, TotalQty DESC

SELECT	C.CustomerID,
		C.CompanyName,
		P.ProductName,
		SUM(OD.Quantity) AS TotalQty,
		ROW_NUMBER() OVER (PARTITION BY C.CustomerID ORDER BY SUM(OD.Quantity) DESC) AS RowNumber,
		RANK() OVER (PARTITION BY C.CustomerID ORDER BY SUM(OD.Quantity) DESC) AS RankNumber
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON P.ProductID = Od.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName

;WITH cteCustomerProductsQuantity AS
(SELECT	C.CustomerID,
		C.CompanyName,
		P.ProductName,
		SUM(OD.Quantity) AS TotalQty,
		ROW_NUMBER() OVER (PARTITION BY C.CustomerID ORDER BY SUM(OD.Quantity) DESC) AS RowNumber,
		RANK() OVER (PARTITION BY C.CustomerID ORDER BY SUM(OD.Quantity) DESC) AS RankNumber
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON P.ProductID = Od.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName)
SELECT CT.CompanyName, CT.ProductName
FROM cteCustomerProductsQuantity CT
WHERE CT.RowNumber = 1
GO

-- 3. Készítsünk egy tárolt eljárást, amely megadja a megrendelések (Orders) összértékét.
-- Az eljárunknak legyen egy paramétere, ami megadja, hogy melyik dátumösszetevőre (év, hónap, hét, nap) 
-- kell kiszámolni az összértéket.

SELECT *
FROM Orders

SELECT	*
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID

SELECT	DISTINCT O.*, 
		SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID

;WITH cteOrderTotal AS
(
SELECT	DISTINCT O.*, 
		SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID
)
SELECT	*,
		YEAR(OrderDate) As Year,
		MONTH(OrderDate) AS Month,
		DATEPART(WEEK,OrderDate) AS Week,
		DAY(OrderDate) AS Day,
		FORMAT(SubTotal,'C','en-US') AS OrderTotal
FROM cteOrderTotal

;WITH cteOrderTotal AS
(
SELECT	DISTINCT O.*, 
		SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID
)
SELECT	YEAR(OrderDate) As Year,
		MONTH(OrderDate) AS Month,
		DATEPART(WEEK,OrderDate) AS Week,
		DAY(OrderDate) AS Day,
		SUM(SubTotal) AS Total
FROM cteOrderTotal
GROUP BY YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)

;WITH cteOrderTotal AS
(
SELECT	DISTINCT O.*, 
		SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID
)
SELECT	YEAR(OrderDate) As Year,
		MONTH(OrderDate) AS Month,
		DATEPART(WEEK,OrderDate) AS Week,
		DAY(OrderDate) AS Day,
		SUM(SubTotal) AS Total,
		GROUPING_ID(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)) AS Grouping
FROM cteOrderTotal
GROUP BY ROLLUP(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate))

DECLARE @grouping nvarchar(10) = 'Year'
DECLARE @group int 

SELECT @group =	CASE @grouping
					WHEN 'Total' THEN 15
					WHEN 'Year'  THEN 7
					WHEN 'Month' THEN 3
					WHEN 'Week'  THEN 1
					WHEN 'Day'   THEN 0
					ELSE NULL
				END

;WITH cteOrderTotal AS
(
SELECT	DISTINCT O.*, 
		SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
FROM Orders O INNER JOIN [Order Details] OD
ON O.OrderID = Od.OrderID
)
SELECT	YEAR(OrderDate) As Year,
		MONTH(OrderDate) AS Month,
		DATEPART(WEEK,OrderDate) AS Week,
		DAY(OrderDate) AS Day,
		SUM(SubTotal) AS Total,
		GROUPING_ID(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)) AS Grouping
FROM cteOrderTotal
GROUP BY ROLLUP(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate))
HAVING GROUPING_ID(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)) = @group
GO

CREATE PROCEDURE spOrderTotal(@grouping nvarchar(10)) AS
BEGIN
	DECLARE @group int 

	SELECT @group =	CASE @grouping
						WHEN 'Total' THEN 15
						WHEN 'Year'  THEN 7
						WHEN 'Month' THEN 3
						WHEN 'Week'  THEN 1
						WHEN 'Day'   THEN 0
					ELSE NULL
					END

	;WITH cteOrderTotal AS
	(
	SELECT	DISTINCT O.*, 
			SUM(OD.Quantity*OD.UnitPrice*(1-OD.Discount)) OVER (PARTITION BY O.OrderId) AS SubTotal
	FROM Orders O INNER JOIN [Order Details] OD
	ON O.OrderID = Od.OrderID
	)
	SELECT	YEAR(OrderDate) As Year,
			MONTH(OrderDate) AS Month,
			DATEPART(WEEK,OrderDate) AS Week,
			DAY(OrderDate) AS Day,
			SUM(SubTotal) AS Total,
			GROUPING_ID(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)) AS Grouping
	FROM cteOrderTotal
	GROUP BY ROLLUP(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate))
	HAVING GROUPING_ID(YEAR(OrderDate),MONTH(OrderDate),DATEPART(WEEK,OrderDate),DAY(OrderDate)) = @group OR @group IS NULL
END

EXECUTE spOrderTotal 'Total'
EXECUTE spOrderTotal 'Year'
EXECUTE spOrderTotal 'Month'
EXECUTE spOrderTotal 'Week'
EXECUTE spOrderTotal 'Day'
EXECUTE spOrderTotal 'Wekk'
GO

-- 4. Keressük az év dolgozóját, vagyis az az alkalmazottat (Employees), akinek a megrendeléseinek (Orders) összértéke
-- a legdinamikusabban nőtt az előző évhez képest. 
-- A lekérdezés kimenetében szerepeljen az év, és az alkalmazott neve.

SELECT *
FROM Employees

SELECT *
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID

SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GO

CREATE FUNCTION fnOrderSubTotal(@orderid int) RETURNS money AS
BEGIN
	RETURN (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS SubTotal
			FROM [Order Details]
			WHERE OrderID = @orderid)
END
GO

SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		dbo.fnOrderSubTotal(OrderID) AS SubTotal
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GO

SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		SUM(dbo.fnOrderSubTotal(OrderID)) AS YearTotal
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName,E.LastName,YEAR(O.OrderDate)

SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		SUM(dbo.fnOrderSubTotal(OrderID)) AS YearTotal,
		LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS PrevTotal
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName,E.LastName,YEAR(O.OrderDate)

SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		SUM(dbo.fnOrderSubTotal(OrderID)) AS YearTotal,
		LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS PrevTotal,
		SUM(dbo.fnOrderSubTotal(OrderID))-LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS Difference
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName,E.LastName,YEAR(O.OrderDate)

;WITH cteEmployeeSales AS
(SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		SUM(dbo.fnOrderSubTotal(OrderID)) AS YearTotal,
		LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS PrevTotal,
		SUM(dbo.fnOrderSubTotal(OrderID))-LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS Difference
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName,E.LastName,YEAR(O.OrderDate))
SELECT	*,
		RANK() OVER (PARTITION BY Year ORDER BY Difference DESC) AS YearRank
FROM cteEmployeeSales

;WITH cteEmployeeSales AS
(SELECT	E.FirstName+' '+E.LastName As Name,
		YEAR(O.OrderDate) AS Year,
		SUM(dbo.fnOrderSubTotal(OrderID)) AS YearTotal,
		LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS PrevTotal,
		SUM(dbo.fnOrderSubTotal(OrderID))-LAG(SUM(dbo.fnOrderSubTotal(OrderID)),1,0) OVER (PARTITION BY E.FirstName+' '+E.LastName ORDER BY YEAR(O.OrderDate)) AS Difference
FROM Employees E JOIN Orders O
ON E.EmployeeID = O.EmployeeID
GROUP BY E.FirstName,E.LastName,YEAR(O.OrderDate))
,
cteEmployeeRank AS
(SELECT	*,
		RANK() OVER (PARTITION BY Year ORDER BY Difference DESC) AS YearRank
FROM cteEmployeeSales)
SELECT Year, Name
FROM cteEmployeeRank
WHERE YearRank = 1
GO

-- 5. Hozzunk létre egy triggert, mely egy Termék (Product) törlése esetén, 
-- törlés helyett a Discontinued mező értékét állítja át 1-re!
CREATE TRIGGER dbo.TorlesFigyelo ON dbo.Products
INSTEAD OF DELETE AS 
BEGIN
	UPDATE dbo.Products SET Discontinued = 1
	FROM dbo.Products INNER JOIN DELETED 
	ON dbo.Products.ProductID = DELETED.ProductID
END
GO

DELETE FROM dbo.Products
WHERE ProductID = 1

SELECT *
FROM dbo.Products
WHERE ProductID = 1
GO

-- 6. Hozzunk létre egy tárolt eljárást (spCustomerOrderCount) ami visszaadja, 
-- hogy egy adott ügyfélhez (Customers) hány darab megrendelés (Orders) tartozik.
CREATE PROCEDURE spCustomerOrderCount(@customerid nchar(5)) AS
BEGIN
	DECLARE @ordercount int

	SELECT @ordercount = COUNT(*) 
	FROM Orders
	WHERE CustomerID = @customerid

	PRINT @ordercount
END
GO

EXECUTE spCustomerOrderCount 'ALFKI'
GO

-- 7. Az előző tárolt eljárásunkat egészítsük ki hibakezeléssel, vagyis ha olyan ügyfélazonosítót
-- adunk meg, amely nem létezik, adjon az eljárás hibaüzennetet.
ALTER PROCEDURE spCustomerOrderCount(@customerid nchar(5)) AS
BEGIN 
	DECLARE @ordercount int

	IF (@customerid NOT IN (SELECT CustomerID FROM dbo.Customers))
		BEGIN
			THROW 51000, 'The record does not exist.', 1;   
			RETURN 0
		END

	SELECT @ordercount = COUNT(*) 
	FROM Orders
	WHERE CustomerID = @customerid

	PRINT @ordercount
END
GO

EXECUTE spCustomerOrderCount 'ALFKI'
EXECUTE spCustomerOrderCount 'ALFKA'
GO

-- 8. Hozzunk létre az ügyfél (Customers) táblához egy indexet, amivel hatékonyan
-- tudjuk támogatni azokat a lekérdezéseket, amelyek feltétele egy ország!
CREATE NONCLUSTERED INDEX IDX_Country ON dbo.Customers
(
	[Country] ASC
)

-- 9. Irassuk ki a Termékek (Products) táblát XML-ben!
SELECT *
FROM dbo.Products
ORDER BY ProductName
FOR XML AUTO, ELEMENTS

-- 10. Hozzunk lére egy új táblát a munkatársak nyilvántartására (dbo.EmployeesHierarchy)
-- amiben szerepeltetjük a dolgozók hierarchiában elfoglalt helyét is!
SELECT	E.EmployeeID, 
	E.FirstName+' '+E.LastName AS Name, 
	hierarchyid::GetRoot() AS HierarchyID,
	CAST(hierarchyid::GetRoot() AS varchar(20)) AS Level
FROM Employees E
WHERE ReportsTo IS NULL

;WITH EmployeeNum AS
(
	SELECT	E.EmployeeID, 
		E.FirstName+' '+E.LastName AS Name, 
		E.ReportsTo,	
		ROW_NUMBER() OVER (PARTITION BY ReportsTo ORDER BY ReportsTo) As Num
	FROM Employees E
)
,
EmployeeHierarchyByID(EmployeeID, Name, HierarchyID) AS
(
	SELECT	EmployeeID, 
		Name,
		hierarchyid::GetRoot() AS HierarchyID
	FROM EmployeeNum
	WHERE ReportsTo IS NULL
	UNION ALL
	SELECT	E.EmployeeID, 
		E.Name, 
		CAST((H.HierarchyID.ToString() + CAST(E.Num AS varchar(30))) + '/' AS hierarchyid)
	FROM EmployeeNum E JOIN EmployeeHierarchyByID H
	ON E.ReportsTo = H.EmployeeID
)
SELECT	*, 
		HierarchyID.ToString() AS Level INTO dbo.EmployeesHierarchy
FROM EmployeeHierarchyByID 

SELECT *
FROM dbo.EmployeesHierarchy












