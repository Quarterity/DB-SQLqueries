CREATE DATABASE IB160080b

USE IB160080b

CREATE TABLE Studenti
(
	StudentID int IDENTITY(1,1) PRIMARY KEY,
	BrojDosijea nvarchar(10) NOT NULL UNIQUE,
	Ime nvarchar(35) NOT NULL,
	Prezime nvarchar(35) NOT NULL,
	GodinaStudija int NOT NULL,
	NacinStudiranja nvarchar(10) NOT NULL DEFAULT 'Redovan',
	Email nvarchar(50)
)
CREATE TABLE Predmeti
(
	PredmetID int IDENTITY(1,1) PRIMARY KEY,
	Naziv nvarchar(100) NOT NULL,
	Oznaka nvarchar(10) NOT NULL UNIQUE,		
)
CREATE TABLE Ocjene
(
	PredmetID int FOREIGN KEY(PredmetID) REFERENCES Predmeti(PredmetID),
	StudentID int FOREIGN KEY(StudentID) REFERENCES Studenti(StudentID),
	Ocjena int NOT NULL ,
	Bodovi int NOT NULL ,
	DatumPolaganja datetime NOT NULL,
	PRIMARY KEY(PredmetID,StudentID)
)

INSERT INTO Predmeti VALUES
('Programiranje 3','PR3'),('Baze Podataka','BP2'),('Web razvoj','WRD')

INSERT INTO Studenti (BrojDosijea,Ime,Prezime,GodinaStudija,Email)
SELECT TOP 10
	C.AccountNumber ,
	P.FirstName,
	P.LastName,
	2,
	EA.EmailAddress
FROM AdventureWorks2017.Sales.Customer AS C
 JOIN AdventureWorks2017.Person.Person AS P ON C.PersonID=P.BusinessEntityID
 JOIN AdventureWorks2017.Person.EmailAddress AS EA ON EA.BusinessEntityID=P.BusinessEntityID

 
SELECT * FROM Studenti
SELECT * FROM Predmeti

CREATE PROCEDURE usp_DodajOcjene 
(
	@PredmetID int,
	@StudentID int , 
	@Ocjena int,
	@Bodovi int,
	@DatumPolaganja datetime
)
AS 
BEGIN 
	INSERT INTO Ocjene
	VALUES (@PredmetID,
			@StudentID,
			@Ocjena,
			@Bodovi,
			@DatumPolaganja)
END;



EXEC usp_DodajOcjene 1,22,5,55,'20140201'
EXEC usp_DodajOcjene 2,23,5,2,'20150203'
EXEC usp_DodajOcjene 1,25,10,100,'20140101'
EXEC usp_DodajOcjene 3,26,7,65,'20140201'
EXEC usp_DodajOcjene 2,27,8,82,'20180811'

SELECT * FROM Ocjene





CREATE NONCLUSTERED INDEX PersonInd ON Person.Person (LastName ASC,FirstName ASC) INCLUDE (Title)


SELECT LastName,FirstName,Title
FROM Person.Person
WHERE LastName LIKE '%a' OR FirstName LIKE'%b%'

ALTER INDEX PersonInd ON Person.Person
DISABLE;


CREATE CLUSTERED INDEX IX_CreditCard_CardID ON Sales.CreditCard (CreditCardID ASC)

CREATE NONCLUSTERED INDEX IX_NC_CreditCard_CardID ON Sales.CreditCard (CreditCardID ASC) 
							INCLUDE (ExpMonth , ExpYear )


CREATE VIEW view_CreditCard_Person
AS
	SELECT P.LastName,P.FirstName,CC.CardNumber,CC.CardType
	FROM Person.Person AS P 
	JOIN Sales.PersonCreditCard AS CCP ON P.BusinessEntityID=CCP.BusinessEntityID
	JOIN Sales.CreditCard AS CC ON CCP.CreditCardID=CC.CreditCardID
	WHERE CC.CardType LIKE 'Vista' AND (P.Title IS NULL OR P.Title LIKE '')



BACKUP DATABASE IB160080b TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\fullB.bak'


BACKUP DATABASE IB160080b TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\difB.bak'
WITH DIFFERENTIAL


CREATE USER AjdinLjubuncic FOR LOGIN[DELL-LATITUDE-3\Ajdin] 


CREATE PROCEDURE proc_Pretraga
(
 @prezime nvarchar(30)  = NULL,
 @ime nvarchar(30) = NULL,
 @brKartice nvarchar(20) = NULL
)
AS
BEGIN
	--2
	IF @prezime IS NOT NULL AND @ime IS NULL AND @brKartice IS NULL
	BEGIN
		SELECT *
		FROM view_CreditCard_Person AS V
		WHERE LastName LIKE @prezime+'%'
	END
	--3
	ELSE IF (@prezime IS NOT NULL AND @ime IS NOT NULL AND @brKartice IS NULL)
	BEGIN
		SELECT *
		FROM view_CreditCard_Person AS V
		WHERE LastName LIKE @prezime+'%' AND FirstName LIKE @ime+'%'
	END
	--4
	ELSE IF (@prezime IS NOT NULL AND @ime IS NOT NULL AND @brKartice IS NOT NULL)
	BEGIN 
		SELECT *
		FROM view_CreditCard_Person AS V
		WHERE LastName LIKE @prezime+'%' AND FirstName LIKE @ime+'%' AND CardNumber=@brKartice
	END
	--1
	ELSE
	BEGIN 
		SELECT *
		FROM view_CreditCard_Person AS V
	END
END;

DROP PROCEDURE proc_Pretraga

EXECUTE proc_Pretraga 'Bar'


DECLARE @a nvarchar(5)='Bar'
SELECT * FROM view_CreditCard_Person
WHERE LastName LIKE @a+'%'



CREATE PROCEDURE proc_zad10 @brKartice nvarchar(20)
AS
BEGIN
	BEGIN TRAN
	DECLARE @karticaID int=(SELECT CreditCardID FROM Sales.CreditCard WHERE @brKartice=CardNumber);
		DELETE FROM Sales.PersonCreditCard
		WHERE CreditCardID=@karticaID
			DELETE FROM Sales.CreditCard
			WHERE @brKartice=CardNumber
	COMMIT TRAN
END

SELECT * FROM Sales.PersonCreditCard
SELECT * FROM Sales.CreditCard

EXEC proc_zad10 '33332664695310'

