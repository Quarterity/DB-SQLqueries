USE AdventureWorks2017

GO

--Kreirati upit koji prikazuje proizvode kojih na skladištu ima u količini manjoj od 30 komada. Lista treba da sadrži naziv proizvoda, naziv skladišta (lokaciju), stanje na skladištu i ukupnu prodanu količinu. U rezultate upita uključiti i one proizvode koji nikad nisu prodavani. Ukoliko je ukupna prodana količina prikazana kao NULL vrijednost, izlaz formatirati brojem 0.

SELECT P.Name,L.Name,pinv.Quantity,ISNULL(COUNT(SOD.ProductID),0) AS 'Ukupno prodano'
FROM Production.Product AS P
	JOIN Production.ProductInventory AS pinv ON P.ProductID=pinv.ProductID
	JOIN Production.Location AS L ON pinv.LocationID=L.LocationID
	LEFT JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
WHERE pinv.Quantity<30
GROUP BY P.Name,L.Name,pinv.Quantity


--Prikazati ukupnu količinu prodaje i ukupnu zaradu od prodaje svakog pojedinog proizvoda po teritoriji. Uzeti u obzir samo prodaju u sklopu ponude pod nazivom “Volume Discount 11 to 14” i to samo gdje je količina prodaje veća od 100 komada. Zaradu zaokružiti na dvije decimale, te izlaz sortirati po zaradi u opadajućem redoslijedu.

SELECT  P.Name,
		COUNT(SOD.OrderQty) AS 'Ukupna kolicina prodaje',
		ROUND(SUM(P.ListPrice*SOD.OrderQty*(1-SOD.UnitPriceDiscount)),2) AS 'Zarada od proizvoda'
FROM Production.Product AS P
	JOIN Production.ProductInventory AS pinv ON P.ProductID=pinv.ProductID
	JOIN Production.Location AS L ON pinv.LocationID=L.LocationID
	JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
	JOIN Sales.SpecialOfferProduct AS SOP ON SOP.ProductID=P.ProductID
	JOIN Sales.SpecialOffer AS SO ON SO.SpecialOfferID=SOP.SpecialOfferID
WHERE SO.Description = 'Volume Discount 11 to 14' 
GROUP BY P.Name
HAVING COUNT(SOD.OrderQty)>100
ORDER BY 3 DESC

--Kreirati upit koji prikazuje četvrtu najveću platu u preduzeću (po visini primanja). Tabela EmployeePayHistory.

SELECT TOP 1  Rate,FirstName ,PayFrequency
FROM (
SELECT TOP 4 EPH.Rate,FirstName ,PayFrequency
FROM HumanResources.EmployeePayHistory AS EPH
	 JOIN HumanResources.Employee AS E ON EPH.BusinessEntityID=E.BusinessEntityID
	 JOIN Person.Person AS P ON E.BusinessEntityID=P.BusinessEntityID
ORDER BY EPH.Rate DESC ) AS A 
ORDER BY Rate ASC


--Kreirati upit koji prikazuje naziv proizvoda, naziv lokacije, stanje zaliha na lokaciji, 
--ukupno stanje zaliha na svim lokacijama i ukupnu prodanu količinu. Uzeti u obzir prodaju 
--samo u 2013. Godini.


SELECT P.Name,L.Name,
		PI.Quantity,
		(
		SELECT SUM(PI.Quantity)
		 FROM  Production.ProductInventory AS PI
		) AS 'Ukupne zalihe lokacija',
		(
		SELECT SUM(SOD.OrderQty)
		FROM Sales.SalesOrderDetail AS SOD
		) AS 'Ukupno prodanih proizvoda'
FROM Production.Product AS P
	JOIN Production.ProductInventory AS PI ON P.ProductID=PI.ProductID
	JOIN Production.Location AS L ON L.LocationID=PI.LocationID
	JOIN Sales.SalesOrderDetail AS SOD ON SOD.ProductID=P.ProductID
	JOIN Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.OrderDate)=2013
GROUP BY P.Name,L.Name,PI.Quantity,P.ProductID




--Kreirati upit koji prikazuje ukupnu količinu utrošenog novca po kupcu. Izlaz treba da sadrži sljedeće kolone: ime i prezime kupca, tip kreditne kartice, broj kartice i ukupno utrošeno. Pri tome voditi računa da izlaz sadrži:
--a) Samo troškove koje su kupci napravili koristeći kredite kartice, b) Samo one kupce koji imaju više od jedne kartice, c) Prikazati i one kartice sa kojima kupac nije obavljao narudžbe, d) Ukoliko vrijedost kolone utrošeno bude nepoznata, zamijeniti je brojem 0 (nula), e) Izlaz treba biti sortiran po prezimenu kupca abecedno i količini utrošenog novca opadajućim redoslijedom.
--Tabele: Customer, Person, PersonCreditCard, CreditCard, SalesOrderHeader, SalesOrderDetail Napomena: Za prikaz rezultata upita izvršiti skriptu AWCreditCardsScript.









--Dodati novu narudžbu. Kao vrijednost polja OrderDate postaviti trenutno vrijeme, jednog od kupaca koji je dodan u zadatku 1, te jednog od zaposlenika koji je dodan u zadatku 3. Za ostale kolone unijeti testne podatke.



USE Northwind
GO

--INSERT INTO Customers 
----VALUES (3,'komp','ajdin','Ctitle','Adresa','sarajevo','balkan','12312','bih','06123456543','032133222');
--SELECT TOP 5 LEFT(V.Name,1),LEFT(V.Name,10),LEFT(P.FirstName+' '+P.LastName,20),LEFT(P.Title,20),LEFT(A.AddressLine1,20),LEFT(A.City,10),
--				SP.Name,LEFT(A.PostalCode,10),LEFT(SP.Name,10),LEFT(PNT.Name,20),LEFT(PNT.Name,20)
--FROM AdventureWorks2017.Sales.Customer AS C
--	 JOIN AdventureWorks2017.Person.Person AS P ON C.PersonID=P.BusinessEntityID
--	 JOIN AdventureWorks2017.Purchasing.Vendor AS V ON V.BusinessEntityID=P.BusinessEntityID
--	 JOIN AdventureWorks2017.Person.BusinessEntityAddress AS BEA ON BEA.BusinessEntityID=P.BusinessEntityID
--	 JOIN AdventureWorks2017.Person.Address AS A ON A.AddressID=BEA.AddressID
--	 JOIN AdventureWorks2017.Person.StateProvince AS SP ON A.StateProvinceID=SP.StateProvinceID     
--	 JOIN AdventureWorks2017.Person.PersonPhone AS PP  ON PP.BusinessEntityID=P.BusinessEntityID
--	 JOIN AdventureWorks2017.Person.PhoneNumberType AS PNT ON PNT.PhoneNumberTypeID=PP.PhoneNumberTypeID                 


