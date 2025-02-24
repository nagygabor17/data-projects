USE Northwind
GO

-- 1. -- Listázzuk ki azokat az ügyfeleket (Customers), 
      -- akik még nem vásároltak tőlünk semmit!
-- Első megoldás
SELECT CustomerID
FROM Customers
EXCEPT
SELECT CustomerID
FROM Orders

-- Második megoldás
SELECT * FROM Customers C
WHERE C.CustomerID NOT IN (SELECT CustomerID FROM Orders)

--Harmadik megoldás
SELECT * 
FROM Customers C

SELECT * 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID

SELECT * 
FROM Customers C LEFT JOIN Orders O
ON C.CustomerID = O.CustomerID

SELECT C.* 
FROM Customers C LEFT JOIN Orders O
ON C.CustomerID = O.CustomerID
WHERE O.OrderID IS NULL

-- 2. -- Listázzuk ki a termékeket (Products) a legnagyobb és a legkisebb 
      -- értékű (UnitPrice) nélkül!
SELECT * 
FROM Products

-- Első megoldás
SELECT MAX(UnitPrice)
FROM Products

SELECT MIN(UnitPrice)
FROM Products

SELECT * 
FROM Products
WHERE UnitPrice > (SELECT MIN(UnitPrice) FROM Products) AND UnitPrice < (SELECT MAX(UnitPrice) FROM Products)

-- Második megoldás
SELECT COUNT(*)
FROM Products

SELECT *
FROM Products
ORDER BY UnitPrice
OFFSET 1 ROWS
FETCH NEXT (SELECT COUNT(*) FROM Products)-2 ROWS ONLY

-- 3. -- Listázzuk ki a termékeket (Products), a beszállítókat (Suppliers) 
       -- és a megrendelés részleteket (Order Details), 
	   -- egészítsük ki a sorösszeggel (LineTotal) a lekérdezést!
SELECT *
FROM [Order Details] O 

SELECT *, (O.Quantity*O.UnitPrice)*(1-O.Discount) AS LineTotal
FROM [Order Details] O 

SELECT *, (O.Quantity*O.UnitPrice)*(1-O.Discount) AS LineTotal
FROM [Order Details] O JOIN Products P
ON P.ProductID = O.ProductID 

SELECT *, (O.Quantity*O.UnitPrice)*(1-O.Discount) AS LineTotal
FROM [Order Details] O JOIN Products P
ON P.ProductID = O.ProductID JOIN Suppliers S
ON S.SupplierID = P.SupplierID

-- 4. -- Listázzuk ki a megrendelések (Orders) sorszámát (OrderID), dátumát (OrderDate), 
       -- értékét (OrderTotal), valamint az ügyfelek (Customers) cégnevét (CompanyName)!
SELECT *
FROM Orders

SELECT *
FROM Orders O JOIN [Order Details] OD
ON O.OrderID = OD.OrderID

SELECT *
FROM Orders O JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Customers C
ON O.CustomerID = C.CustomerID

SELECT *, (OD.Quantity*OD.UnitPrice*1-OD.Discount) AS LineTotal
FROM Orders O JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Customers C
ON O.CustomerID = C.CustomerID

SELECT O.OrderID, O.OrderDate, C.CompanyName, SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)) AS OrderTotal
FROM Orders O JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Customers C
ON O.CustomerID = C.CustomerID
GROUP BY O.OrderID, O.OrderDate, C.CompanyName
-- 5. -- Listázzuk ki, hogy melyik kategóriából (Categories) adtuk el a legtöbbet (Quantity)! 
SELECT *
FROM [Order Details]

SELECT *
FROM [Order Details] OD JOIN Products P
ON OD.ProductID = P.ProductID

SELECT *
FROM [Order Details] OD JOIN Products P
ON OD.ProductID = P.ProductID JOIN Categories C 
ON C.CategoryID = P.CategoryID

SELECT P.CategoryID, C.CategoryName, SUM(OD.Quantity) AS Db
FROM [Order Details] OD JOIN Products P
ON OD.ProductID = P.ProductID JOIN Categories C 
ON C.CategoryID = P.CategoryID
GROUP BY P.CategoryID, C.CategoryName

SELECT TOP 1 P.CategoryID, C.CategoryName, SUM(OD.Quantity) AS Db
FROM [Order Details] OD JOIN Products P
ON OD.ProductID = P.ProductID JOIN Categories C 
ON C.CategoryID = P.CategoryID
GROUP BY P.CategoryID, C.CategoryName
ORDER BY Db DESC

-- 6. -- Listázzuk ki , hogy egy munkatárs (Employees), hány ügyféllel (Customers) 
       -- van kapcsolatban!
SELECT *
FROM Employees

SELECT *
FROM Employees JOIN Orders 
ON Employees.EmployeeID = Orders.EmployeeID JOIN Customers 
ON Customers.CustomerID = Orders.CustomerID

SELECT  Employees.FirstName+' '+Employees.LastName, COUNT(Customers.CustomerID) AS CustomerCount
FROM Employees JOIN Orders 
ON Employees.EmployeeID = Orders.EmployeeID JOIN Customers 
ON Customers.CustomerID = Orders.CustomerID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName

SELECT COUNT(*)
FROM Customers

SELECT  Employees.FirstName+' '+Employees.LastName, COUNT(DISTINCT Customers.CustomerID) AS CustomerCount
FROM Employees JOIN Orders 
ON Employees.EmployeeID = Orders.EmployeeID JOIN Customers 
ON Customers.CustomerID = Orders.CustomerID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName

SELECT  Employees.FirstName+' '+Employees.LastName, COUNT(DISTINCT Orders.CustomerID) AS CustomerCount
FROM Employees JOIN Orders 
ON Employees.EmployeeID = Orders.EmployeeID
GROUP BY Employees.EmployeeID, Employees.FirstName, Employees.LastName

-- 7. -- Listázzuk ki, hogy az egyes beszállítók (Suppliers) hány különböző kategóriában 
       -- szállítanak be, kell a beszállító neve (CompanyName), és a mennyiség (SupplierCount)!
SELECT * 
FROM Suppliers

SELECT * 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID

SELECT * 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID JOIN Categories C
ON C.CategoryID = P.CategoryID

SELECT S.CompanyName, COUNT(C.CategoryID) AS SupplierCount
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID JOIN Categories C
ON C.CategoryID = P.CategoryID
GROUP BY S.SupplierID, S.CompanyName

SELECT S.CompanyName, COUNT(DISTINCT P.CategoryID) AS SupplierCount
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID 
GROUP BY S.SupplierID, S.CompanyName

-- 8. -- Listázzuk ki, hogy melyik kategóriának (Categories) 
       -- van a legtöbb beszállítója (Suppliers)!
SELECT *
FROM Categories C

SELECT *
FROM Categories C JOIN Products P
ON C.CategoryID = P.CategoryID

SELECT C.CategoryName, COUNT(DISTINCT P.SupplierID) AS SupplierCount
FROM Categories C JOIN Products P
ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryID, C.CategoryName

SELECT TOP 1 WITH TIES C.CategoryName, COUNT(DISTINCT P.SupplierID) AS SupplierCount
FROM Categories C JOIN Products P
ON C.CategoryID = P.CategoryID
GROUP BY C.CategoryID, C.CategoryName
ORDER BY SupplierCount DESC

-- 9. -- Listázzuk ki, hogy az egyes beszállítók (Suppliers) 
        -- mennyi bevételt (SupplierTotal) jelentettek nekünk!
SELECT *
FROM Suppliers

SELECT * 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID

SELECT * 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID JOIN [Order Details] OD
ON P.ProductID = OD.ProductID

SELECT *, O.Quantity*O.UnitPrice*(1-O.Discount) AS LineTotal 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID JOIN [Order Details] O
ON P.ProductID = O.ProductID

SELECT S.CompanyName, SUM((O.Quantity*O.UnitPrice)*(1-O.Discount)) AS SupplierTotal 
FROM Suppliers S JOIN Products P
ON S.SupplierID = P.SupplierID JOIN [Order Details] O
ON P.ProductID = O.ProductID
GROUP BY S.SupplierID, S.CompanyName

-- 10. -- Listázzuk ki a munkatársakat (Employees) és a főnökeiket (ReportsTo)!
SELECT * 
FROM Employees

SELECT * 
FROM Employees E JOIN  Employees M
ON E.Reportsto = M.EmployeeID

SELECT E.FirstName+' '+E.LastName AS EmployeeName, M.FirstName+' '+M.LastName AS ManagerName
FROM Employees E LEFT JOIN Employees M
ON E.Reportsto = M.EmployeeID

-- 11. -- Listázzuk ki, hogy átlagosan hány nap telt el a megrendelés (Orders - OrderDate)
       -- és a kiszállítás (ShippedDate) között!
SELECT * 
FROM Orders

SELECT *, DATEDIFF(DAY, OrderDate,ShippedDate) AS OrderDays 
FROM Orders

SELECT *, DATEDIFF(DAY, OrderDate,ISNULL(ShippedDate,GETDATE())) AS OrderDays 
FROM Orders

SELECT AVG(DATEDIFF(DAY, OrderDate,ISNULL(ShippedDate,GETDATE()))) AS AvgDays  
FROM Orders

-- 12. -- Listázzuk ki, hogy az egyes ügyfelek (Customers) 
       -- eddig milyen értékben vásároltak (CustomerTotal)! Formázzuk a kimenetet (FORMAT)!
SELECT * 
FROM Customers

SELECT * 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID

SELECT *, (OD.Quantity*OD.UnitPrice)*(1-OD.Discount) AS LineTotal 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID

SELECT C.CompanyName, SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)) AS CustomerTotal 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName

SELECT C.CompanyName, FORMAT(SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)),'C', 'en-US') AS CustomerTotal 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName

-- 13. -- Listázzuk ki, hogy az ügyfeleink (Customers) átlagosan 
       -- milyen értékben vásároltak (CustomerTotalAvg)! 
-- Első megoldás
DROP VIEW IF EXISTS vCustomerTotal
GO

CREATE VIEW vCustomerTotal AS
SELECT C.CompanyName, SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)) AS CustomerTotal 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID
GROUP BY C.CustomerID, C.CompanyName
GO

SELECT *
FROM vCustomerTotal

SELECT FORMAT(AVG(CustomerTotal),'C','en-US') AS CustomerTotalAvg
FROM vCustomerTotal

DROP VIEW IF EXISTS vCustomerTotal
GO;

-- Második megoldás
WITH cteCustomerTotal AS
(
	SELECT C.CompanyName, SUM((OD.Quantity*OD.UnitPrice)*(1-OD.Discount)) AS CustomerTotal 
	FROM Customers C JOIN Orders O
	ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID
	GROUP BY C.CustomerID, C.CompanyName
)
SELECT FORMAT(AVG(CustomerTotal),'C','en-US') AS CustomerTotalAvg
FROM cteCustomerTotal

-- 14. -- Listázzuk ki a termékeket (Products), egészítsük ki egy mezővel (CategoryAvg), 
       -- mely megadja a kategóriájának átlagát!
-- Első megoldás
SELECT	*,
		(SELECT AVG(UnitPrice) FROM Products SubP WHERE Subp.CategoryID = P.CategoryID) AS CategoryAvg
FROM Products P

-- Második megoldás
SELECT	*,
		AVG(P.UnitPrice) OVER (PARTITION BY P.CategoryID) As CategoryAvg
FROM Products P

-- 15. -- Listázzuk ki a termékeket (Products), egészítsük ki egy mezővel (CategoryAvg), 
       -- mely megadja a kategóriájának átlagát, 
	   -- valamint az átlagtól való eltérést értékelő mezőt (ProductRate)!
-- Első megoldás
SELECT	*
	,(SELECT AVG(UnitPrice) FROM Products SubP WHERE Subp.CategoryID = P.CategoryID) AS CategoryAvg
	,CASE
		WHEN P.UnitPrice > (SELECT AVG(UnitPrice) FROM Products SubP WHERE Subp.CategoryID = P.CategoryID) THEN 'Drága'
		WHEN P.UnitPrice = (SELECT AVG(UnitPrice) FROM Products SubP WHERE Subp.CategoryID = P.CategoryID) THEN 'Átlagos'
		WHEN P.UnitPrice < (SELECT AVG(UnitPrice) FROM Products SubP WHERE Subp.CategoryID = P.CategoryID) THEN 'Olcsó'
	END AS ProductRate
FROM Products P

-- Második megoldás
SELECT	*
	,AVG(P.UnitPrice) OVER (PARTITION BY P.CategoryID) CategoryAvg
	,IIF(P.UnitPrice >= (AVG(P.UnitPrice) OVER (PARTITION BY P.CategoryID)),'Drága','Olcsó') AS ProductRate 	
FROM Products P

-- 16. -- Listázzuk ki az ügyfeleket (Customers) és írjuk ki melléjük annak a 
       -- terméknek (Products) a nevét, amelyből a legtöbbet vásárolták!
SELECT *
FROM Customers

SELECT * 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID

SELECT	C.CompanyName, 
		P.ProductName, 
		SUM(OD.Quantity) AS CustomerQuantity 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON OD.ProductID = P.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName 

SELECT	C.CompanyName, 
		P.ProductName, 
		SUM(OD.Quantity) AS CustomerQuantity 
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON OD.ProductID = P.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName 
ORDER BY C.CompanyName, CustomerQuantity DESC

SELECT	C.CompanyName, 
		P.ProductName, 
		SUM(OD.Quantity) AS CustomerQuantity,
		MAX(SUM(OD.Quantity)) OVER (PARTITION BY C.CustomerID) As CustomerMax
FROM Customers C JOIN Orders O
ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
ON O.OrderID = OD.OrderID JOIN Products P
ON OD.ProductID = P.ProductID
GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName 

;WITH cteCustomerQuantity AS
(
	SELECT	C.CompanyName, 
			P.ProductName, 
			SUM(OD.Quantity) AS CustomerQuantity,
			MAX(SUM(OD.Quantity)) OVER (PARTITION BY C.CustomerID) As CustomerMax
	FROM Customers C JOIN Orders O
	ON C.CustomerID = O.CustomerID JOIN [Order Details] OD
	ON O.OrderID = OD.OrderID JOIN Products P
	ON OD.ProductID = P.ProductID
	GROUP BY C.CustomerID, C.CompanyName, P.ProductID, P.ProductName 
)
SELECT CompanyName, ProductName
FROM cteCustomerQuantity
WHERE CustomerQuantity = CustomerMax

-- 17. -- Listázzuk ki a beszállítókat (Suppliers), 
       -- egészítsük ki egy értékeléssel (Rate), 
	   -- hogy az átlagos bevételtől melyik irányba térnek el!
;WITH cteSupplierTotal AS
(
	SELECT	S.CompanyName, 
			SUM((O.Quantity*O.UnitPrice)*(1-O.Discount)) AS SupplierTotal
	FROM Suppliers S JOIN Products P
	ON S.SupplierID = P.SupplierID JOIN [Order Details] O
	ON P.ProductID = O.ProductID
	GROUP BY S.SupplierID, S.CompanyName)
,
cteSupplierTotalAvg AS
(
	SELECT *, (SELECT AVG(SupplierTotal)  FROM cteSupplierTotal) AS SupplierTotalAvg
	FROM cteSuppliertotal 
)
SELECT	*, 
		FORMAT(SupplierTotal-SupplierTotalAvg,'C','en-US') As Difference,
		IIF(SupplierTotal >= SupplierTotalAvg, 'Good','Bad') AS Rate
FROM cteSupplierTotalAvg 

-- 18. -- Az 'Exotic Liquids' beszállító (Suppliers) termékeiből (Products) 
       -- érkezett 'Extra' kiszerelésű változat (50 db), 
	   -- mely az eredeti ár (UnitPrice) duplájába kerül. Vigyük fel az adatbázisba!
SELECT * 
FROM Products

SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids'

SELECT	P.ProductName +' Extra',
		P.SupplierID,
		P.CategoryID,
		P.QuantityPerUnit,
		P.UnitPrice * 2,
		50,
		0,
		P.ReorderLevel,
		P.Discontinued
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND Discontinued = 0	

INSERT INTO Products (ProductName,SupplierID,CategoryID,QuantityPerUnit,UnitPrice,UnitsInStock,P.UnitsOnOrder,P.ReorderLevel,P.Discontinued)
SELECT	P.ProductName +' Extra',P.SupplierID,P.CategoryID,P.QuantityPerUnit,P.UnitPrice * 2,50,0,P.ReorderLevel,P.Discontinued
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND Discontinued = 0	

SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids'

-- 19. -- Az előzóleg felvitt termékek (Products) árát (UnitPrice) a beszállító 
       -- 'Exotic Liquids' (Suppliers) 20%-kal csökkentette. Módosítsuk a rekordokat!
SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'
 
UPDATE Products
SET UnitPrice = UnitPrice * 0.8
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'

SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'

-- 20. -- Az előzóleg felvitt termékeket (Products) a beszállító 
       -- 'Exotic Liquids' (Suppliers) visszavonta. Töröljük a rekordokat!
SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'

DELETE FROM Products 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'

SELECT * 
FROM Products P JOIN Suppliers S
ON P.SupplierID = S.SupplierID
WHERE CompanyName = 'Exotic Liquids' AND P.ProductName LIKE '%Extra'