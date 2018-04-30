USE AdventureWorks2017
GO

SELECT P.ProductNumber,P.Name,P.ListPrice,PIn.Quantity
FROM Production.Product AS P
	 JOIN	Production.ProductSubcategory AS PCS ON P.ProductSubcategoryID=PCS.ProductSubcategoryID
	 JOIN	Production.ProductCategory    AS PC  ON PC.ProductCategoryID=PCS.ProductCategoryID
	 JOIN	Production.ProductInventory   AS PIn ON PIn.ProductID=P.ProductID
	 JOIN	Production.Location			  AS L	 ON PIn.LocationID=L.LocationID
WHERE PC.Name='Bikes'
ORDER BY 4 DESC


SELECT P.FirstName,P.LastName,CONVERT(nvarchar,E.HireDate,103),EA.EmailAddress,ROUND(SUM(SOH.TotalDue),2)
FROM	HumanResources.Employee AS E
	JOIN Sales.SalesPerson		AS SP	ON E.BusinessEntityID=SP.BusinessEntityID
	JOIN Sales.SalesOrderHeader AS SOH	ON SP.BusinessEntityID=SOH.SalesPersonID
	JOIN Person.Person			AS P	ON E.BusinessEntityID=P.BusinessEntityID
	JOIN Sales.SalesTerritory	AS ST	ON SP.TerritoryID=ST.TerritoryID
	JOIN Person.EmailAddress	AS EA	ON EA.BusinessEntityID=E.BusinessEntityID 
WHERE DATEPART(YEAR,SOH.OrderDate)=2014 AND MONTH(SOH.OrderDate)=1 AND ST.[Group]='Europe'
GROUP BY P.FirstName,P.LastName,EA.EmailAddress,E.HireDate
ORDER BY 5 DESC

 

SELECT * FROM Sales.SalesPerson

SELECT * FROM Sales.SalesOrderHeader

SELECT * FROM Sales.SalesTerritory



SELECT  P.FirstName + P.LastName,
		SUBSTRING(E.LoginID,CHARINDEX('\',E.LoginID)+1,LEN(E.LoginID)),
		REPLACE(SUBSTRING(REVERSE(PW.PasswordHash),5,8),SUBSTRING(SUBSTRING(REVERSE(PW.PasswordHash),5,8),2,2),'X#'),
		YEAR(SYSDATETIME())-YEAR(E.BirthDate) AS 'starost',
		YEAR(SYSDATETIME())-YEAR(E.HireDate)  AS 'staz'
FROM HumanResources.Employee AS E
	JOIN Person.Person		 AS P	ON E.BusinessEntityID=P.BusinessEntityID
	JOIN Person.[Password] 	 AS PW	ON PW.BusinessEntityID=E.BusinessEntityID
WHERE E.Gender='F' AND YEAR(SYSDATETIME())-YEAR(E.BirthDate)>50 AND YEAR(SYSDATETIME())-YEAR(E.HireDate) >5










