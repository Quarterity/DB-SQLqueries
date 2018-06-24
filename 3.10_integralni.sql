CREATE DATABASE IB160080c
USE IB160080c

CREATE TABLE Proizvodi
(
	ProizvodID int IDENTITY(1,1) PRIMARY KEY,
	Sifra nvarchar(25) NOT NULL UNIQUE,
	Naziv nvarchar(50) NOT NULL ,	
	Kategorija nvarchar(50),	
	Podkategorija nvarchar(50) ,	
	Boja nvarchar(15) ,	
	Cijena decimal NOT NULL,	
	StanjeZaliha int NOT NULL
)
CREATE TABLE Prodaja
(
	ProdajaID int IDENTITY(1,1) PRIMARY KEY,
	ProizvodID int  FOREIGN KEY (ProizvodID) REFERENCES Proizvodi(ProizvodID),
	Godina int NOT NULL,
	Mjesec int NOT NULL,
	UkupnoProdano int NOT NULL,
	UkupnoPopust decimal NOT NULL,
	UkupnoIznos decimal NOT NULL,
)
SET IDENTITY_INSERT Proizvodi ON;

INSERT INTO Proizvodi (
	ProizvodID, 
	Sifra,
	Naziv,
	Kategorija,
	Podkategorija,
	Boja,
	Cijena,
	StanjeZaliha 
)
SELECT DISTINCT P.ProductID,
	P.ProductNumber,
	P.Name,
	PC.Name,
	PS.Name,
	P.Color,
	P.ListPrice,
	ISNULL((
	SELECT SUM(Quantity)
	FROM AdventureWorks2017.Production.ProductInventory 
		WHERE ProductID=P.ProductID
		GROUP BY ProductID
	),0)
FROM AdventureWorks2017.Production.Product AS P
	JOIN AdventureWorks2017.Production.ProductSubcategory AS PS ON PS.ProductSubcategoryID=P.ProductSubcategoryID
	JOIN AdventureWorks2017.Production.ProductCategory AS PC ON PC.ProductCategoryID=PS.ProductCategoryID
	JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON P.ProductID=SOD.ProductID
	JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOH.SalesOrderID=SOD.SalesOrderID
	JOIN AdventureWorks2017.Sales.SalesTerritory AS T ON SOH.TerritoryID=T.TerritoryID
WHERE T.[Group] = 'Europe'


SELECT * FROM Proizvodi
DROP TABLE  Proizvodi

--2b
INSERT INTO Prodaja 

SELECT 
	P.ProductID,
	YEAR(SOH.ShipDate),
	MONTH(SOH.ShipDate),
	COUNT(SOD.SalesOrderDetailID),
	ROUND(SUM(SOD.OrderQty*P.ListPrice*SOD.UnitPriceDiscount),2),
	ROUND(SUM(SOD.OrderQty*P.ListPrice*(1 - SOD.UnitPriceDiscount)), 2)
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
	JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOD.SalesOrderID=SOH.SalesOrderID
	JOIN AdventureWorks2017.Production.Product AS P ON P.ProductID=SOD.ProductID
WHERE P.ProductID IN (SELECT ProizvodID FROM Proizvodi )
GROUP BY P.ProductID,YEAR(SOH.ShipDate),MONTH(SOH.ShipDate)
ORDER BY 1,2,3


UPDATE Proizvodi
SET Proizvodi.StanjeZaliha =PINV.Quantity 
 FROM Proizvodi AS Pr 
 JOIN AdventureWorks2017.Production.Product AS P ON P.ProductID=Pr.ProizvodID
 JOIN AdventureWorks2017.Production.ProductInventory AS PINV ON P.ProductID=PINV.ProductID


 CREATE PROCEDURE usp_obrisiSifrom @sifra nvarchar(20)
 AS
 BEGIN
		DELETE FROM Prodaja
		WHERE Prodaja.ProizvodID = (SELECT ProizvodID FROM Proizvodi WHERE @sifra=Sifra)
 END;


 EXEC usp_obrisiSifrom 'HL-U509-R'

SELECT * FROM Proizvodi
SELECT * FROM Prodaja


CREATE VIEW view_ProizvoidProdaja
AS 
SELECT 
	P1.ProizvodID,
	P1.Sifra,
	P1.Kategorija,
	P1.Cijena,
	P1.StanjeZaliha,
	P2.Godina,
	P2.Mjesec,
	P2.UkupnoProdano,
	P2.UkupnoPopust,
	P2.UkupnoIznos
FROM Proizvodi AS P1
	JOIN Prodaja AS P2 ON P2.ProizvodID=P1.ProizvodID 

SELECT * FROM view_ProizvoidProdaja


SELECT ProizvodID,SUM(Cijena*UkupnoProdano) AS 'Zarada bez%',FLOOR((SUM(Cijena*UkupnoProdano-UkupnoPopust)) ) AS 'Zarada sa%',UkupnoPopust
FROM view_ProizvoidProdaja
WHERE  Godina=2013 AND Mjesec=5
GROUP BY ProizvodID,UkupnoPopust


SELECT ProizvodID,SUM(UkupnoIznos) AS 'Zarada bez%',FLOOR((SUM(UkupnoIznos-UkupnoPopust)) ) AS 'Zarada sa%',UkupnoPopust
FROM view_ProizvoidProdaja
WHERE  Godina=2013
GROUP BY ProizvodID,UkupnoPopust


SELECT SUM(UkupnoIznos) AS 'Zarada bez%',FLOOR((SUM(UkupnoIznos-UkupnoPopust)) ) AS 'Zarada sa%',Godina
FROM view_ProizvoidProdaja
GROUP BY Godina
ORDER BY Godina

UPDATE Prodaja
SET Prodaja.UkupnoPopust-=10
FROM Prodaja AS P
	JOIN AdventureWorks2017.Production.Product AS P2 ON P2.ProductID=P.ProizvodID
	JOIN AdventureWorks2017.Production.ProductSubcategory AS PS ON PS.ProductSubcategoryID=P2.ProductSubcategoryID
WHERE PS.Name='Pedals' AND P.UkupnoPopust>0
	
SELECT * 
FROM Prodaja AS P
	JOIN AdventureWorks2017.Production.Product AS P2 ON P2.ProductID=P.ProizvodID
	JOIN AdventureWorks2017.Production.ProductSubcategory AS PS ON PS.ProductSubcategoryID=P2.ProductSubcategoryID
WHERE PS.Name='Pedals'
	
BACKUP DATABASE IB160080c TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\full.bak'
	
	 

BACKUP DATABASE IB160080c TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\diffC.bak'
WITH DIFFERENTIAL	
	 











