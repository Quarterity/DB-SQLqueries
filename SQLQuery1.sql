USE AdventureWorks2017

GO
SELECT TOP 1 * 
FROM
(SELECT TOP 4 EPH.Rate
FROM HumanResources.EmployeePayHistory AS EPH
ORDER BY EPH.Rate DESC) AS A
ORDER BY Rate ASC

SELECT 'Dobrodosli '+T.Title+' '+T.FirstName+' '+T.LastName+', trenutno je '+SUBSTRING(CONVERT(nvarchar(20),(SYSDATETIME())),12,5)+' sati'
FROM Person.Person AS T
WHERE T.Title IS NOT NULL


SELECT ST.TerritoryID,COUNT(STH.BusinessEntityID) AS 'Ukupno kupaca'
FROM Sales.Customer AS C
	 JOIN Person.Person AS P ON C.PersonID = P.BusinessEntityID
	 JOIN Sales.SalesTerritory AS ST ON ST.TerritoryID=C.TerritoryID
	 JOIN Sales.SalesTerritoryHistory AS STH ON ST.TerritoryID=STH.TerritoryID
GROUP BY ST.TerritoryID
HAVING COUNT(STH.BusinessEntityID)>1000


SELECT SOD.SalesORderDetailID
FROM Sales.SalesOrderDetail AS SOD
	 JOIN Production.Product AS P ON SOD.ProductID=P.ProductID

SELECT SOD.SalesORderDetailID
FROM Sales.SalesOrderDetail AS SOD
	 JOIN Sales.SpecialOfferProduct AS SOP ON SOP.SpecialOfferID=SOD.SpecialOfferID AND SOP.ProductID=SOD.ProductID
	 JOIN Production.Product AS P ON P.ProductID=SOP.ProductID



SELECT P1.ProductID,SUM(SOD1.OrderQty) 
FROM Production.Product AS P1
			JOIN Sales.SalesOrderDetail AS SOD1 ON P1.ProductID=SOD1.ProductID
--WHERE P1.ProductID !=714
GROUP BY P1.ProductID
HAVING SUM(SOD1.OrderQty)=
(
	SELECT TOP 1 [Ukupna kolicina prodaje]
	FROM
	(
		SELECT TOP 10 P.ProductID,SUM(SOD.OrderQty) AS 'Ukupna kolicina prodaje'
		FROM Production.Product AS P
			JOIN Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
		GROUP BY P.ProductID
		ORDER BY SUM(SOD.OrderQty) DESC
	) AS A
	ORDER BY [Ukupna kolicina prodaje]
)




SELECT SOD.ProductID,ROUND(SUM(SOD.OrderQty*SOD.UnitPrice*(1-SOD.UnitPriceDiscount)),2) AS 'Zarada sa popustom',
				   ROUND(SUM(SOD.OrderQty*SOD.UnitPrice),2 ) AS 'Zarada bez popusta'
FROM Sales.SalesOrderDetail AS SOD 
WHERE SOD.UnitPriceDiscount IS NOT NULL
GROUP BY SOD.ProductID,SOD.UnitPriceDiscount
ORDER BY SOD.UnitPriceDiscount  ASC





/*
pronaci razliku sume cijena onih produkta koji nikad nisu prodavani i 
sume cijena proudkta koji su bili prodavani barem 3 puta */


SELECT	--dio samo za provjeru ispisa
(
SELECT SUM(P.ListPrice) AS 'A2'
FROM Production.Product AS P
	 JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
HAVING COUNT(SOD.ProductID)>3 
) AS 'Prodani vise od 3 puta'
,
(
SELECT SUM(P.ListPrice) AS 'A1'
FROM Production.Product AS P
	 LEFT JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
WHERE SOD.SalesOrderDetailID IS NULL 
) AS 'Nisu Prodani'
,		--dio samo za provjeru ispisa

--SELECT
(
SELECT SUM(P.ListPrice) AS 'A2'
FROM Production.Product AS P
	 JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
HAVING COUNT(SOD.ProductID)>3 
) 
-
(
SELECT SUM(P.ListPrice) AS 'A1'
FROM Production.Product AS P
	 LEFT JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
WHERE  
P.ProductID NOT IN
		(
		SELECT P.ProductID
		FROM Production.Product AS P
			 JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
		GROUP BY P.ProductID
		)
)  AS 'Razlika' 
