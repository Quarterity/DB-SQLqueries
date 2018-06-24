--USE master 
--GO

--ALTER SERVER CONFIGURATION 
--SET BUFFER POOL EXTENSION ON
--    (FILENAME = 'E:\DB_Cache\SQL2014.BPE', SIZE = 1 GB);
--GO

USE master

CREATE DATABASE IB160080d ON PRIMARY
(
NAME=N'IB160080dDATA', FILENAME=N'D:\BP2\Data\IB160080dDATA.mdf'
) LOG ON
(
NAME=N'IB160080dLOG' ,FILENAME=N'D:\BP2\Log\IB160080dLOG.ldf'  
)

USE IB160080d

CREATE TABLE Proizvodi
(
	ProizvodID int IDENTITY(1,1) PRIMARY KEY,
	Sifra nvarchar(25) UNIQUE NOT NULL,
	Nativ nvarchar(50) NOT NULL,
	Kategorija nvarchar(50) NOT NULL,
	Cijena decimal NOT NULL 
)
CREATE TABLE Narudzbe
(
	NarudzbaID int IDENTITY(1,1) PRIMARY KEY,
	BrojNarudzbe nvarchar(25) UNIQUE NOT NULL,
	Datum datetime NOT NULL,
	Ukupno decimal NOT NULL
)
CREATE TABLE StavkeNarudzbe
(
	ProizvodID int  REFERENCES Proizvodi(ProizvodID),
	NarudzbaID int  REFERENCES Narudzbe(NarudzbaID),
	Kolicina int NOT NULL,
	Cijena decimal NOT NULL,
	Popust decimal NOT NULL,
	Iznos decimal NOT NULL,
	PRIMARY KEY(ProizvodID,NarudzbaID)
)

DROP TABLE StavkeNarudzbe
DROP TABLE Proizvodi
DROP TABLE Narudzbe

SET IDENTITY_INSERT Proizvodi ON
INSERT INTO Proizvodi
(
	ProizvodID,
	Sifra,
	Nativ,
	Kategorija,
	Cijena 
)
SELECT DISTINCT
	P.ProductID,
	P.ProductNumber,
	P.Name,
	PC.Name,
	P.ListPrice 
FROM AdventureWorks2017.Production.Product AS P
 JOIN AdventureWorks2017.Production.ProductSubcategory AS PS ON P.ProductSubcategoryID=PS.ProductSubCategoryID 
 JOIN AdventureWorks2017.Production.ProductCategory AS PC ON PC.ProductCategoryID=PS.ProductCategoryID
 JOIN AdventureWorks2017.Sales.SpecialOfferProduct AS SOP ON SOP.ProductID=P.ProductID
 JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOD.SpecialOfferID=SOP.SpecialOfferID
 JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
WHERE YEAR(SOH.ShipDate)=2014


SET IDENTITY_INSERT Proizvodi OFF


SET IDENTITY_INSERT Narudzbe ON
INSERT INTO Narudzbe
(
	NarudzbaID,
	BrojNarudzbe,
	Datum, 
	Ukupno
)
SELECT 
	SalesOrderID,
	SalesOrderNumber,
	OrderDate,
	TotalDue
FROM AdventureWorks2017.Sales.SalesOrderHeader AS SOH
WHERE YEAR(OrderDate)=2014
SET IDENTITY_INSERT Narudzbe OFF



--SET IDENTITY_INSERT StavkeNarudzbe ON
INSERT INTO StavkeNarudzbe
	(
	ProizvodID,
	NarudzbaID,
	Kolicina,
	Cijena,
	Popust, 
	Iznos
	)
SELECT DISTINCT
	P.ProductID,
	SOH.SalesOrderID,
	SOD.OrderQty,
	SOD.UnitPrice,
	SOD.UnitPriceDiscount,
	SOD.LineTotal
FROM AdventureWorks2017.Sales.SalesOrderDetail AS SOD
 JOIN AdventureWorks2017.Sales.SalesOrderHeader AS SOH ON SOD.SalesOrderID=SOH.SalesOrderID
 JOIN  AdventureWorks2017.Production.Product AS P ON P.ProductID=SOD.ProductID
WHERE YEAR(SOD.ModifiedDate)=2014

CREATE TABLE Skladista
(
	SkladisteID int IDENTITY(1,1) PRIMARY KEY,
	Naziv nvarchar(50) NOT NULL UNIQUE,
)
DROP TABLE Skladista
CREATE TABLE SkladistaProizvodi
(
	SkladisteID int FOREIGN KEY REFERENCES Skladista(SkladisteID),
	ProizvodID  int FOREIGN KEY REFERENCES Proizvodi(ProizvodID),
	Kolicina int NOT NULL,	
	PRIMARY KEY(SkladisteID,ProizvodID)
)
DROP TABLE SkladistaProizvodi

INSERT INTO Skladista 
VALUES ('skladiste1'),('skladiste2'),('skladiste3')

SELECT * FROM Skladista


INSERT INTO SkladistaProizvodi
--(
--	SkladisteID,
--	ProizvodID ,
--	Kolicina 
--)
SELECT 
	S.SkladisteID,
	P.ProizvodID,
	0
FROM   Proizvodi AS P 
	 CROSS JOIN Skladista AS S

CREATE PROCEDURE usp_StanjeSkladista (@sID int,@pID int, @kol int)
AS
BEGIN
	UPDATE  SkladistaProizvodi
	SET Kolicina=@kol
	WHERE SkladisteID=@sID AND ProizvodID=@pID
END;

DROP PROCEDURE usp_StanjeSkladista

SELECT * FROM SkladistaProizvodi

EXEC usp_StanjeSkladista @sID=1,@pID=680,@kol=5

----------------------------------------------------------

CREATE NONCLUSTERED INDEX IX_SifraNaziv ON  Proizvodi(Sifra ASC,Naziv ASC)

SELECT Sifra,Naziv
FROM Proizvodi
WHERE Naziv LIKE '%500%' AND Sifra LIKE '%0'
ORDER BY Sifra ASC


CREATE TRIGGER nekiTriger ON Proizvodi
INSTEAD OF DELETE
AS 
	PRINT ('Greska');


DROP TRIGGER nekiTriger

DELETE FROM Proizvodi
WHERE ProizvodID=680


ALTER VIEW view_ProizvodProdaja
AS
SELECT
	P.Sifra,
	P.Nativ,
	P.Cijena,
	SUM(SN.Kolicina) AS 'ukupna kol' ,
	SN.Popust,
	SN.Iznos,
	SUM(SN.Kolicina*P.Cijena) AS 'bez%',
	FLOOR(SUM(SN.Kolicina*P.Cijena*(1-(SN.Popust/100)))) AS 'Sa popustom'
FROM StavkeNarudzbe AS SN
	JOIN Proizvodi AS P ON SN.ProizvodID=P.ProizvodID
	JOIN Narudzbe AS N ON N.NarudzbaID=SN.NarudzbaID
GROUP BY P.Sifra,P.Nativ,P.Cijena,SN.Popust,SN.Iznos


UPDATE StavkeNarudzbe
SET Popust=5+Kolicina
WHERE ProizvodID%5=0

SELECT * FROM StavkeNarudzbe
WHERE Popust != 0


SELECT * FROM view_ProizvodProdaja


ALTER PROCEDURE usp_PretragaSifrom @sifra nvarchar(25)=NULL
AS 
BEGIN
	IF @sifra IS NOT NULL
	BEGIN
	SELECT [ukupna kol],[Sa popustom]
	FROM view_ProizvodProdaja
	WHERE Sifra=@sifra
	END
	ELSE 
	BEGIN
		SELECT * FROM view_ProizvodProdaja
	END
END;

EXEC usp_PretragaSifrom 'BB-7421'


CREATE USER Ajdinn FROM LOGIN [DELL-LATITUDE-3\Ajdin]
GRANT EXECUTE ON usp_PretragaSifrom TO Ajdinn 


BACKUP DATABASE IB160080d TO
DISK=N'D:\BP2\fullD.bak'

BACKUP DATABASE IB160080d TO
DISK=N'D:\BP2\diffD.bak'
WITH DIFFERENTIAL



--1.	Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. Fajlove baze podataka smjestiti na sljedeće lokacije:
--a)	Data fajl: D:\BP2\Data
--b)	Log fajl: D:\BP2\Log								5 bodova

--2.	U svojoj bazi podataka kreirati tabele sa sljedećom strukturom:
--a)	Proizvodi
--i.	ProizvodID, cjelobrojna vrijednost i primarni ključ
--ii.	Sifra, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
--iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
--iv.	Kategorija, polje za unos 50 UNICODE karaktera (obavezan unos)
--v.	Cijena, polje za unos decimalnog broja (obavezan unos)
--b)	Narudzbe
--i.	NarudzbaID, cjelobrojna vrijednost i primarni ključ,
--ii.	BrojNarudzbe, polje za unos 25 UNICODE karaktera (jedinstvena vrijednost i obavezan unos)
--iii.	Datum, polje za unos datuma (obavezan unos),
--iv.	Ukupno, polje za unos decimalnog broja (obavezan unos)
--c)	StavkeNarudzbe
--i.	ProizvodID, cjelobrojna vrijednost i dio primarnog ključa,
--ii.	NarudzbaID, cjelobrojna vrijednost i dio primarnog ključa,
--iii.	Kolicina, cjelobrojna vrijednost (obavezan unos)
--iv.	Cijena, polje za unos decimalnog broja (obavezan unos)
--v.	Popust, polje za unos decimalnog broja (obavezan unos)
--vi.	Iznos, polje za unos decimalnog broja (obavezan unos)
--10 bodova
--3.	Iz baze podataka AdventureWorks2014 u svoju bazu podataka prebaciti sljedeće podatke:
--a)	U tabelu Proizvodi dodati sve proizvode koji su prodavani u 2014. godini
--i.	ProductNumber -> Sifra
--ii.	Name -> Naziv
--iii.	ProductCategory (Name) -> Kategorija
--iv.	ListPrice -> Cijena
--b)	U tabelu Narudzbe dodati sve narudžbe obavljene u 2014. godini
--i.	SalesOrderNumber -> BrojNarudzbe
--ii.	OrderDate - > Datum
--iii.	TotalDue -> Ukupno
--c)	U tabelu StavkeNarudzbe prebaciti sve podatke o detaljima narudžbi urađenih u 2014. godini
--i.	OrderQty -> Kolicina
--ii.	UnitPrice -> Cijena
--iii.	UnitPriceDiscount -> Popust
--iv.	LineTotal -> Iznos 
--	Napomena: Zadržati identifikatore zapisa!							20 bodova

--4.	U svojoj bazi podataka kreirati novu tabelu Skladista sa poljima SkladisteID i Naziv, a zatim je povezati sa tabelom Proizvodi u relaciji više prema više. Za svaki proizvod na skladištu je potrebno čuvati količinu (cjelobrojna vrijednost).	 																				5 bodova
--5.	U tabelu Skladista  dodati tri skladišta proizvoljno, a zatim za sve proizvode na svim skladištima postaviti količinu na 0 komada.
--5 bodova
--6.	Kreirati uskladištenu proceduru koja vrši izmjenu stanja skladišta (količina). Kao parametre proceduri proslijediti identifikatore proizvoda i skladišta, te količinu.						10 bodova



--7.	Nad tabelom Proizvodi kreirati non-clustered indeks nad poljima Sifra i Naziv, a zatim napisati proizvoljni upit koji u potpunosti iskorištava kreirani indeks. Upit obavezno mora sadržavati filtriranje podataka.
--										5 bodova

--8.	Kreirati trigger koji će spriječiti brisanje zapisa u tabeli Proizvodi.	 			5 bodova

--9.	Kreirati view koji prikazuje sljedeće kolone: šifru, naziv i cijenu proizvoda, ukupnu prodanu količinu i ukupnu zaradu od prodaje.									10 bodova

--10.	Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda prikazivati ukupnu prodanu količinu i ukupnu zaradu. Ukoliko se ne unese šifra proizvoda procedura treba da prikaže prodaju svih proizovda. U proceduri koristiti prethodno kreirani view.								10 bodova

--11.	U svojoj bazi podataka kreirati novog korisnika za login student te mu dodijeliti odgovarajuću permisiju kako bi mogao izvršavati prethodno kreiranu proceduru.
--10 bodova
--12.	Napraviti full i diferencijalni backup baze podataka na lokaciji D:\BP2\Backup	