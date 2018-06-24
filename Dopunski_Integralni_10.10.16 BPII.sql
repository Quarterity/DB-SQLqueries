/*
1.	Kroz SQL kod, napraviti bazu podataka koja nosi ime vašeg broja dosijea. U postupku kreiranja u obzir uzeti samo DEFAULT postavke. 

Unutar svoje baze podataka kreirati tabele sa sljedećom strukturom:
a)	Proizvodi
i.	ProizvodID, automatski generator vrijednosti i primarni ključ
ii.	Sifra, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
iii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
iv.	Cijena, polje za unos decimalnog broja (obavezan unos) 
b)	Skladista
i.	SkladisteID, automatski generator vrijednosti i primarni ključ
ii.	Naziv, polje za unos 50 UNICODE karaktera (obavezan unos)
iii.	Oznaka, polje za unos 10 UNICODE karaktera (obavezan unos), jedinstvena vrijednost
iv.	Lokacija, polje za unos 50 UNICODE karaktera (obavezan unos)
c)	SkladisteProizvodi
i.	Stanje, polje za unos cijelih brojeva (obavezan unos)	
Napomena: Na jednom skladištu može biti uskladišteno više proizvoda, dok isti proizvod može biti uskladišten na više različitih skladišta. Onemogućiti da se isti proizvod na skladištu može pojaviti više puta.  														10 bodova
2.	Popunjavanje tabela podacima:
a)	Putem jedne INSERT komande u tabelu Skladista dodati minimalno 3 skladišta.
b)	Koristeći bazu podataka AdventureWorks2014, preko INSERT i SELECT komande importovati 10 količinski najprodavanijih bicikala (kategorija proizvoda 'Bikes') u tabelu Proizvodi i to sljedeće kolone:
i.	Broj proizvoda (ProductNumber) -> Sifra,
ii.	Naziv bicikla (Name) -> Naziv,
iii.	Cijena po komadu (ListPrice) -> Cijena,
c)	Putem INSERT i SELECT komande u tabelu SkladisteProizvodi importovati sve prethodno dodane proizvode tako da stanje bude 100.
10 bodova

3.	Kreirati uskladištenu proceduru koja će vršiti povećanje stanja skladišta za određeni proizvod na odabranom skladištu. Obavezno provjeriti ispravnost kreirane procedure.																10 bodova
4.	Kreiranje indeksa u bazi podataka nada tabelama:

a)	Non-clustered indeks nad tabelom Proizvodi. Potrebno je indeksirati Sifru i Naziv. Također, potrebno je uključiti kolonu Cijena.
b)	Napisati proizvoljni upit nad tabelom Proizvodi koji u potpunosti iskorištava indeks  iz prethodnog koraka
c)	Uraditi disable indeksa iz koraka a)																	5 bodova

5.	Kreirati view sa sljedećom definicijom. Objekat treba da prikazuje oznaku, naziv i lokaciju skladišta, šifru, naziv i cijenu proizvoda, te stanje na skladištu.					
											10 bodova

6.	Kreirati  uskladištenu proceduru koja će na osnovu unesene šifre proizvoda prikazati ukupno stanje zaliha na svim skladištima. U rezultatu prikazati šifra, naziv i cijenu proizvoda te ukupno stanje zaliha. U proceduri koristiti prethodno kreirani view. Provjeriti ispravnost kreirane procedure.
10 bodova


7.	Kreirati uskladištenu proceduru koja će vršiti upis novih proizvoda, te stanje skladišta za uneseni proizvod postaviti na 0 za sva skladišta. Obavezno provjeriti ispravnost kreirane procedure.
 10 bodova

8.	Kreirati uskladištenu proceduru koje će za unesenu šifru proizvoda vršiti brisanje brisanje proizvoda uključujući stanje na svim skladištima. Obavezno provjeriti ispravnost kreirane procedure.
  10 bodova

9.	Kreirati uskladištenu proceduru koja će za unesenu šifru proizvoda (obavezno) i oznaku skladišta (opcionalno) vršiti pretragu nad prethodno kreiranim view-om (zadatak 5).

Uslovi su sljedeći:

a)	Ako je proslijeđena samo vrijednost parametra šifra proizvoda, prikazati ukupno stanje na svim skladištima za odabrani proizvod. U rezultatu prikazati šifru proizvoda, naziv i ukupno stanje.

b)	Ako su proslijeđene vrijednosti oba parametra šifra proizvoda i oznaka skladišta, koristeći dvije SELECT komande, prikazati ukupno stanje za odabrani proizvod na odabranom skladištu, te u drugom rezultatu prikazati stanje na ostalim skladištima (pogledati sliku ispod).			 20 bodova

 
			                                 						
10.	Napraviti full i diferencijalni backup baze podataka na default lokaciju servera:

a)	C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup	 5 bodova
*/





USE master

CREATE DATABASE ib160080a

USE ib160080a

CREATE TABLE Proizvodi
(
	ProizvodID int IDENTITY(1,1) PRIMARY KEY,
	Sifra nvarchar(10) NOT NULL UNIQUE,
	Naziv nvarchar(50) NOT NULL,
	Cijena decimal NOT NULL
)
CREATE TABLE Skladista
(
	SkladisteID int IDENTITY(1,1) PRIMARY KEY,
	Naziv nvarchar(50) NOT NULL,
	Oznaka nvarchar(10) NOT NULL UNIQUE,
	Lokacija nvarchar(50) NOT NULL
)
CREATE TABLE SkladisteProizvodi
(
	SkladisteID int FOREIGN KEY(SkladisteID) REFERENCES Skladista(SkladisteID),
	ProizvodID int FOREIGN KEY(ProizvodID) REFERENCES Proizvodi(ProizvodID) UNIQUE,
	Stanje int NOT NULL
	PRIMARY KEY(SkladisteID,ProizvodID)
)

INSERT INTO Skladista 
VALUES ('skladiste1','111','Mostar'),('skladiste2','222','Sarajevo'),('skladiste3','333','Bugojno')


INSERT INTO Proizvodi (Sifra,Naziv,Cijena)
SELECT TOP 10
	PP.ProductNumber,
	PP.Name,
	PP.ListPrice,
	COUNT(SOD.ProductID)
FROM AdventureWorks2017.[Production].[Product] AS PP
JOIN AdventureWorks2017.Sales.SpecialOfferProduct AS SOP ON SOP.ProductID = PP.ProductID
JOIN AdventureWorks2017.Sales.SalesOrderDetail AS SOD ON SOP.SpecialOfferID=SOD.SpecialOfferID
JOIN AdventureWorks2017.Production.ProductSubcategory AS PSC ON PSC.ProductSubcategoryID=PP.ProductSubcategoryID
JOIN AdventureWorks2017.Production.ProductCategory AS PC ON PSC.ProductCategoryID= PC.ProductCategoryID
WHERE PC.Name LIKE 'Bikes'
GROUP BY PP.ProductNumber,PP.Name,PP.ListPrice
ORDER BY COUNT(SOD.ProductID) ASC

SELECT * FROM Proizvodi


INSERT INTO SkladisteProizvodi (SkladisteID,ProizvodID,Stanje)
SELECT 
	2,
	P.ProizvodID,
	200
FROM Proizvodi AS P
WHERE ProizvodID>10

SELECT * FROM SkladisteProizvodi

CREATE PROCEDURE proc_PovecajStanjeSkladista
(
 @prozvodID int ,
 @skladisteID int,
 @kolicina int
 )
AS 
BEGIN
	UPDATE SkladisteProizvodi
	SET Stanje=Stanje+@kolicina 
	WHERE  ProizvodID=@prozvodID AND SkladisteID=@skladisteID
END;



EXEC proc_PovecajStanjeSkladista 2,1,5

CREATE NONCLUSTERED INDEX Sifra_Naziv
	ON Proizvodi (Sifra ASC,Naziv ASC)
	INCLUDE (Cijena);

DROP INDEX  Sifra_Naziv ON Proizvodi

SELECT 
	Sifra, 
	Naziv,
	Cijena
FROM
	Proizvodi
WHERE 
	Sifra like '%a' or
	Naziv like '%e%'



ALTER INDEX Sifra_Naziv ON Proizvodi
DISABLE


CREATE VIEW view_zad5
AS 
SELECT 
	S.Oznaka,
	S.Naziv,
	S.Lokacija,
	P.Sifra,
	P.Naziv AS proizvoid,
	P.Cijena,
	SP.Stanje

FROM SkladisteProizvodi AS SP
JOIN Skladista AS S ON S.SkladisteID=SP.SkladisteID
JOIN Proizvodi AS P ON P.ProizvodID=SP.ProizvodID

SELECT * FROM view_zad5
	
ALTER PROCEDURE  proc_PretragaSifrom (@sifra nvarchar(10))
AS
BEGIN
	SELECT
		V.Sifra,
		V.proizvoid,
		V.Cijena,
		SUM(V.Stanje)
	FROM view_zad5 AS V
	WHERE V.Sifra = @sifra
	GROUP BY Sifra,proizvoid,Cijena
END;


EXEC proc_PretragaSifrom 'BK-M18B-52'

--TODO:
--ALTER TABLE SkladisteProizvodi
--	ALTER COLUMN ProizvodID int FOREIGN KEY(ProizvodID) REFERENCES Proizvodi(ProizvodID) 
CREATE TABLE SkladisteProizvodi2
(
	SkladisteID int FOREIGN KEY(SkladisteID) REFERENCES Skladista(SkladisteID),
	ProizvodID int FOREIGN KEY(ProizvodID) REFERENCES Proizvodi(ProizvodID) ,
	Stanje int NOT NULL
	PRIMARY KEY(SkladisteID,ProizvodID)
)

INSERT INTO SkladisteProizvodi2 
SELECT * FROM SkladisteProizvodi



CREATE PROCEDURE proc_DodajProizvode  
(
	@Sifra nvarchar(10),
	@Naziv nvarchar(50),
	@Cijena decimal(18,0)
)
AS
BEGIN
	INSERT INTO Proizvodi VALUES (@Sifra,@Naziv,@Cijena)
END
BEGIN
	DECLARE @prvi int =(SELECT TOP 1 SkladisteID FROM Skladista ORDER BY SkladisteID ASC)
	DECLARE @zadnji int =(SELECT TOP 1 SkladisteID FROM Skladista ORDER BY SkladisteID DESC)
	DECLARE @proizvod int = (SELECT ProizvodID FROM Proizvodi WHERE @Sifra=Sifra)
	WHILE @prvi<=@zadnji
	BEGIN
	INSERT INTO SkladisteProizvodi2 VALUES(@prvi,@proizvod,0)
	SELECT @prvi=@prvi+1;
	END
END

DROP PROCEDURE proc_DodajProizvode

EXEC proc_DodajProizvode '313','novra',66

SELECT * FROM SkladisteProizvodi

--TODO:


CREATE PROCEDURE proc_BrisiSifrom @Sifra nvarchar(30)
AS 
BEGIN
	BEGIN transaction
		DECLARE @proizvod int = ( SELECT ProizvodID FROM Proizvodi WHERE @Sifra = Sifra)
		DELETE FROM SkladisteProizvodi
		WHERE ProizvodID = @proizvod
		BEGIN
		DELETE FROM Proizvodi 
		WHERE ProizvodID=@proizvod	
		END
	COMMIT transaction
END

DROP PROCEDURE proc_BrisiSifrom

SELECT *FROM SkladisteProizvodi
SELECT * FROM Proizvodi
SELECT * FROM Skladista



EXEC proc_BrisiSifrom 'BK-M38S-38'

CREATE PROCEDURE proc_PretragaSifrom (@Sifra nvarchar(10),@oznaka nvarchar(10) = NULL) 
AS 
BEGIN
	IF @oznaka=NULL
	BEGIN
	SELECT SUM(Stanje),Sifra,Naziv
	FROM view_zad5 AS V
	--CASE WHEN @oznaka <> NULL THEN
	--WHERE @Sifra = V.Sifra AND @oznaka = V.Oznaka
	--ELSE 
	--	WHERE @Sifra LIKE V.Sifra
	WHERE @Sifra=Sifra OR @oznaka=Oznaka
	GROUP BY Sifra,Naziv 
	END
	ELSE
	BEGIN
	SELECT SUM(Stanje)
	FROM view_zad5
	WHERE @Sifra=Sifra AND @oznaka=Oznaka
	SELECT SUM(Stanje)
	FROM view_zad5
	WHERE @Sifra=Sifra AND @oznaka<>Oznaka
	END
END

DROP PROCEDURE proc_PretragaSifrom

EXEC proc_PretragaSifrom 'BK-M18B-42' 

BACKUP DATABASE  ib160080a TO 
DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\full.bak'
	


BACKUP DATABASE ib160080a TO 
DISK='C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\dif.bak'
WITH DIFFERENTIAL 

