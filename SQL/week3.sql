USE Northwind
GO

-- 1. Kérdezzük le azokat a termékeket (Products), melyek értéke (UnitPrice) X és Y között van. 
-- Az X és Y értéket változóval adjuk meg.

SELECT * FROM Products

SELECT * FROM Products
WHERE UnitPrice BETWEEN 50 AND 100

DECLARE @x money = 50, 
		@y money = 100

SELECT * FROM Products
WHERE UnitPrice BETWEEN @x AND @y
GO

-- 2. Hozzunk létre egy tárolt eljárást (spBetweenProducts) az előző feladatból, 
-- vagyis visszaadja azokat a termékeket (Products), melyek értéke (UnitPrice) X és Y között van.

CREATE PROCEDURE spBetweenProducts(@x money = 50, @y money = 100) AS
SELECT * FROM Products
WHERE UnitPrice BETWEEN @x AND @y

EXECUTE spBetweenProducts 50, 100
GO

-- 3. Kérdezzük le, hogy egy adott ügyfélhez (Customers) hány darab megrendelés (Orders) tartozik.
-- Az ügyfél definiálását változóval végezzük, az eredményt is változóba töltsük be, 
-- és ez utóbbi változót irassuk ki.

SELECT * FROM Orders

SELECT * FROM Orders
WHERE CustomerID = 'VINET'

SELECT COUNT(*) AS OrderCount 
FROM Orders
WHERE CustomerID = 'VINET'

DECLARE @customerid nchar(5), @ordercount int

SET @customerid = 'VINET'

SELECT @ordercount = COUNT(*) 
FROM Orders
WHERE CustomerID = @customerid

PRINT @ordercount
GO

-- 4. Hozzunk létre egy függvényt (fnCustomerOrderCount) az előző feladatból, vagyis a függvény adja vissza, 
-- hogy egy adott ügyfélhez (Customers) hány darab megrendelés (Orders) tartozik.
-- A függvényünket használjuk fel egy az ügyfél (Customers) táblát érintő lekérdezésben.

CREATE FUNCTION fnCustomerOrderCount(@customerid nchar(5)) RETURNS int AS
BEGIN
	DECLARE @ordercount int

	SELECT @ordercount = COUNT(*) 
	FROM Orders
	WHERE CustomerID = @customerid

	RETURN @ordercount
END
GO

SELECT *,  dbo.fnCustomerOrderCount(CustomerID) AS OrderCount
FROM Customers

-- 5. Készítsünk egy lekérdezést, amely egy megadott megrendelés azonosítóra (OrderID) visszaadja 
-- a megrendelés (Orders) összértékét (SubTotal). A megrendelés azonosítót változóval adjuk meg.

SELECT * FROM [Order Details]

SELECT *, UnitPrice*Quantity*(1-Discount) AS LineTotal
FROM [Order Details]

SELECT *, UnitPrice*Quantity*(1-Discount) AS LineTotal
FROM [Order Details]
WHERE OrderID = 10248

SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS SubTotal
FROM [Order Details]
WHERE OrderID = 10248

DECLARE @orderid int = 10248

SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS SubTotal
FROM [Order Details]
WHERE OrderID = @orderid
GO

-- 6. Hozzunk létre egy függvényt (fnOrderSubTotal) az előző feladatból, vagyis 
-- amely egy megadott megrendelés azonosítóra (OrderID) visszaadja a megrendelés (Orders) összértékét (SubTotal).
-- A függvényünket használjuk fel egy a megrendelés (Orders) táblát érint? lekérdezésben.

CREATE FUNCTION fnOrderSubTotal(@orderid int) RETURNS money AS
BEGIN
	RETURN (SELECT SUM(UnitPrice*Quantity*(1-Discount)) AS SubTotal
			FROM [Order Details]
			WHERE OrderID = @orderid)
END
GO

SELECT *, dbo.fnOrderSubTotal(OrderID) AS Subtotal  
FROM Orders
GO

 -- 7. Hozzunk létre egy tárolt eljárást, amely egy beszállító-azonosító (SupplierID) paraméterre megadja, 
 -- hogy az adott beszállítóhoz (Suppliers) hány termék (Products) tartozik!
SELECT COUNT(*) ProductCount
FROM dbo.Products
WHERE SupplierID = 1
GO

CREATE PROCEDURE dbo.spSupplierProducts 
(
	@productid int
)
AS
BEGIN
	SELECT COUNT(*) ProductCount
	FROM dbo.Products
	WHERE SupplierID = @productid
END
GO

EXECUTE dbo.spSupplierProducts 1
GO

-- 8. Hozzunk létre egy függvényt, amely egy beszállító-azonosító (SupplierID) paraméterre megadja, 
-- hogy az adott beszállítóhoz (Suppliers) hány termék (Products) tartozik!
CREATE FUNCTION dbo.fnSupplierProductCount 
(
	@productid int
) RETURNS int
AS
BEGIN
	DECLARE @productcount int

	SELECT @productcount=COUNT(*) 
	FROM dbo.Products
	WHERE SupplierID = @productid

	RETURN @productcount
END
GO

SELECT *, dbo.fnSupplierProductCount(SupplierID) AS Productcount
FROM dbo.Suppliers
GO

-- 9. Hozzunk létre egy függvényt (fnCustomerByCountry), amely egy megadott ország (Country) paraméterre
-- visszaadja az adott országban él? ügyfeleket. 
-- Amennyiben nem adunk meg országot, az összes ügyfelet listázza a függvény.

SELECT *
FROM Customers
WHERE Country = 'USA'

DECLARE @country nvarchar(15) = NULL

SELECT *
FROM Customers
WHERE Country = @country OR @country IS NULL
GO

CREATE FUNCTION fnCustomerByCountry(@country nvarchar(15) = NULL) RETURNS table AS
RETURN (SELECT * FROM Customers WHERE Country = @country OR @country IS NULL)
GO

SELECT * FROM fnCustomerByCountry('USA')
SELECT * FROM fnCustomerByCountry(DEFAULT)
GO

-- 10. Hozzunk létre egy függvényt (fnCustomerTotalByCountry), amely egy megadott ország (Country) paraméterre
-- visszaadja az adott országban élő ügyfeleket és a megrendeléseik összértékét. 
-- Amennyiben nem adunk meg országot, az összes ügyfelet listázza a függvény. 
-- Használjuk fel az előzőleg létrehozott függvényeinket.

SELECT * 
FROM fnCustomerByCountry('USA')

SELECT * 
FROM fnCustomerByCountry('USA') AS C JOIN Orders O
ON C.CustomerID = O.CustomerID

SELECT *, dbo.fnOrderSubTotal(OrderID) AS Subtotal 
FROM fnCustomerByCountry('USA') AS C JOIN Orders O
ON C.CustomerID = O.CustomerID

SELECT C.CompanyName, SUM(dbo.fnOrderSubTotal(OrderID)) AS Total 
FROM fnCustomerByCountry('USA') AS C JOIN Orders O
ON C.CustomerID = O.CustomerID
GROUP BY C.CustomerID, C.CompanyName
GO

CREATE FUNCTION fnCustomerTotalByCountry(@country nvarchar(15) = NULL)
RETURNS @result TABLE(CompanyName nvarchar(40), Total money)
AS
BEGIN
	INSERT INTO @result
	SELECT CompanyName, SUM(dbo.fnOrderSubTotal(OrderID)) AS Total
	FROM dbo.fnCustomerByCountry(@country) AS fnCustomer JOIN Orders O
	ON O.CustomerID = fnCustomer.CustomerID
	GROUP BY O.CustomerID, fnCustomer.CompanyName
	RETURN 
END
GO

SELECT * FROM dbo.fnCustomerTotalByCountry('USA')
SELECT * FROM dbo.fnCustomerTotalByCountry(DEFAULT)
GO