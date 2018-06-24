
-- LEKCIJA 1:INDEKSIRANJE

create database test

use test

go


create table dbo.Book
(
	ISBN nvarchar(20) primary key,
	PublisherID int not null,
	Title nvarchar(50) not null,
	ReleaseDate date not null
)

create nonclustered index IX_Book_Publisher
	on dbo.Book (PublisherID, ReleaseDate DESC);

create nonclustered index ix_book_publisher
	on dbo.Book (PublisherID,ReleaseDate DESC)
	include (Title);
	
select PublisherID ,Title, ReleaseDate
from Book
where ReleaseDate>DATEADD(year,-1,sysdatetime())
order by PublisherID, ReleaseDate desc;

alter index ix_book_publisher on Book
disable;

alter index ix_book_publisher on Book
rebuild;

use AdventureWorks2017
go

create nonclustered index Contact_FirstName_LastName
	on Person.Person (FirstName ASC, LastName ASC)


select * from sys.dm_db_index_physical_stats (null,null,null,null,null)
order by avg_fragmentation_in_percent desc


declare @db_id smallint;
declare @object_id int;

set @db_id = DB_ID('AdventureWorks2017');
set @object_id=OBJECT_ID('AdventureWorks2017.Person.Address');

if	@db_id is null
begin;
	print	N'naziv baze je pogresan';
end ;
else  if @object_id is null
begin;
	print N'naziv objekta je pogresan';
end;
else
begin;
	select * from sys.dm_db_index_physical_stats(@db_id,@object_id,null,null,'LIMITED');
end;

declare @db_id smallint;
declare @object_id int;

set @db_id = DB_ID('AdventureWorks2017');
set @object_id=OBJECT_ID('AdventureWorks2017.dbo.DatabaseLog');

if @object_id is null
begin;
	print N'naziv objekta je pogresan';
end;
else
begin;
	select * from sys.dm_db_index_physical_stats(@db_id,@object_id,0,null,'DETAILED');
end;

-- KRAJ LEKCIJE 1:INDEKSIRANJE

-- LEKCIJA 2: pogledi,procedure,okidaci
USE AdventureWorks2017

CREATE VIEW neki
AS
SELECT E.BusinessEntityID, P.FirstName,P.LastName
FROM Person.Person AS P
JOIN HumanResources.Employee AS E ON E.BusinessEntityID=P.BusinessEntityID

DROP VIEW dbo.neki

CREATE PROCEDURE neka
AS 
BEGIN
	SELECT SP.BusinessEntityID,P.LastName,P.FirstName
	FROM Sales.SalesPerson AS SP
	JOIN Person.Person AS P ON P.BusinessEntityID=SP.BusinessEntityID
	WHERE SP.TerritoryID IS NOT NULL
	ORDER BY SP.BusinessEntityID
END;

EXECUTE neka
GO

SELECT SCHEMA_NAME(schema_id) AS SN,
	Name AS ProcedureName
FROM sys.procedures;

DROP PROCEDURE neka;


CREATE PROCEDURE neka2 @DD datetime,@Status tinyint=5
AS
	SELECT SalesOrderID,OrderDate,CustomerID
	FROM	Sales.SalesOrderHeader 
	WHERE DueDate= @DD
	AND	  [Status]= @Status
GO


EXEC neka2 '20140712'

DROP PROCEDURE neka2

CREATE PROCEDURE neka3 @DD datetime,@OC int OUTPUT
AS
	SELECT @OC= COUNT(1)
	FROM	Sales.SalesOrderHeader
	WHERE	DueDate=@DD;
GO

DECLARE @DD datetime='20140712';
DECLARE @OC int;
EXEC neka3 @DD,@OC OUTPUT;
SELECT @OC

DROP PROCEDURE neka3


CREATE TRIGGER triger
ON DATABASE
FOR DROP_PROCEDURE
AS 
	PRINT 'Greska'
	ROLLBACK;

DROP TRIGGER triger ON DATABASE 



CREATE TRIGGER triger3
ON Production.ProductReview
AFTER UPDATE AS 
BEGIN
	SET NOCOUNT ON;
	UPDATE PR
	SET PR.ModifiedDate=SYSDATETIME()
	FROM Production.ProductReview AS PR
	JOIN inserted AS I
	ON I.ProductReviewID=PR.ProductReviewID;
END;


-- KRAJ LEKCIJE 2: pogledi,procedure,okidaciž

-- LEKCIJA 3 :Sigurnost

CREATE LOGIN [DELL-LATITUDE-3\Ajdin]
FROM WINDOWS
WITH DEFAULT_DATABASE = AdventureWorks2017


CREATE LOGIN Neki
WITH PASSWORD = 'Pa$$w0rd'

CREATE LOGIN Neki2
WITH PASSWORD = 'password',
DEFAULT_DATABASE = AdventureWorks2017,
CHECK_EXPIRATION=OFF,
CHECK_POLICY=OFF

ALTER LOGIN Neki2 WITH PASSWORD='NewPa$$w0rd'

DROP LOGIN[DELL-LATITUDE-3\Ajdin]


-- KRAJ LEKCIJA 3 :Sigurnost

--LEKCIJA 4: Disaster Recovery

BACKUP DATABASE test TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\Test.bak'


BACKUP DATABASE test TO
DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\Backup\TestDIF.bak'
WITH DIFFERENTIAL

-- KRAJ LEKCIJA 4: Disaster Recovery

--LEKCIJA 5: Kriptografija, cloud -napredne teme

CREATE DATABASE CryptoDB

USE CryptoDB
--master key
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Some3xLr4Passw00rd';
 --certifikat
 CREATE CERTIFICATE Cert4SymKey
 ENCRYPTION BY PASSWORD='dsda3GAda12adfaASFs'
 WITH SUBJECT='Guardian of Symetric key',
 EXPIRY_DATE = '20201031';
 --AES 256
 CREATE SYMMETRIC KEY CustomerSymKey
 WITH ALGORITHM = AES_256,
 IDENTITY_VALUE='FIT'
 ENCRYPTION BY CERTIFICATE Cert4SymKey;
 --otvori kljuc
 OPEN SYMMETRIC KEY CustomerSymKey
 DECRYPTION BY CERTIFICATE Cert4SymKey
 WITH PASSWORD = 'dsda3GAda12adfaASFs'
 GO 



CREATE TABLE EncryCustomer
(
	CustomerID int NOT NULL PRIMARY KEY,
	EmailAddress varbinary(200),
	Phone varbinary(150)
)
 DROP TABLE EncryCustomer

INSERT INTO EncryCustomer
(
	CustomerID,
	EmailAddress ,
	Phone
) 
SELECT
	EA.BusinessEntityID,
	EncryptByKey(Key_Guid('CustomerSymKey'),EA.EmailAddress),
	ENCRYPTBYKEY(KEY_GUID('CustomerSymKey'),PP.PhoneNumber)
FROM AdventureWorks2017.Person.EmailAddress AS EA
	--JOIN AdventureWorks2017.Person.Person AS P ON EA.BusinesEntityID= P.BusinessEntityID
	JOIN AdventureWorks2017.Person.PersonPhone AS PP ON PP.BusinessEntityID=EA.BusinessEntityID

CLOSE SYMMETRIC KEY CustomerSymKey;



SELECT * FROM EncryCustomer

OPEN SYMMETRIC KEY CustomerSymKey
DECRYPTION BY CERTIFICATE Cert4SymKey
WITH PASSWORD='dsda3GAda12adfaASFs'

SELECT CAST(DECRYPTBYKEY(EmailAddress) AS nvarchar (100)) AS DecEA
FROM EncryCustomer

CLOSE SYMMETRIC KEY CustomerSymKey

DROP SYMMETRIC KEY CustomerSymKey

DROP CERTIFICATE Cert4SymKey

DROP MASTER KEY

USE master

DROP DATABASE CryptoDB


--DML triger


CREATE DATABASE CSI

USE CSI

CREATE TABLE T1
(
	ID INT NOT NULL PRIMARY KEY,
	kolona1 INT NOT NULL,
	kolona2 nvarchar(50) NULL
);
GO

CREATE TABLE dmlKontPristupa
(
	lsn INT NOT NULL IDENTITY PRIMARY KEY,
	ID INT NOT NULL,
	ImeKolone sysname NOT NULL,
	StariPodatak SQL_VARIANT NULL,
	NoviPodatak SQL_VARIANT NULL
)

CREATE TRIGGER trg_dmlKontPristupa
ON T1 FOR UPDATE
AS
IF @@rowcount = 0 RETURN;

INSERT INTO dmlKontPristupa(ID,ImeKolone,StariPodatak,NoviPodatak)
SELECT * 
FROM ( SELECT I.ID,ImeKolone,
		CASE ImeKolone
			WHEN N'kolona1' THEN CAST(D.kolona1 AS SQL_VARIANT)
			WHEN N'kolona2' THEN CAST(D.kolona2 AS SQL_VARIANT)
			END AS StariPodatak ,
		CASE ImeKolone
			WHEN N'kolona1' THEN CAST(I.kolona1 AS SQL_VARIANT)
			WHEN N'kolona2' THEN CAST(I.kolona2 AS SQL_VARIANT)
		END AS NoviPodatak
		FROM inserted AS I
		JOIN deleted AS D
			ON I.ID=D.ID
		CROSS JOIN 
		(
		 SELECT N'kolona1' AS ImeKolone
		 UNION ALL SELECT N'kolona2') AS C)AS D
	WHERE StariPodatak <> NoviPodatak
		OR (StariPodatak IS NULL AND NoviPodatak IS NOT NULL)
		OR (StariPodatak IS NOT NULL AND NoviPodatak IS NULL);


INSERT INTO T1(ID,kolona1,kolona2) VALUES (1,10,'A');
INSERT INTO T1(ID,kolona1,kolona2) VALUES (2,20,'B');
INSERT INTO T1(ID,kolona1,kolona2) VALUES (3,30,'C');


SELECT ID , kolona1,kolona2 FROM T1

UPDATE T1
SET kolona2= kolona2 + ', modif vr',
	kolona1 = 100+kolona1
	WHERE ID<3;  

SELECT lsn,ID,ImeKolone,StariPodatak,NoviPodatak FROM dmlKontPristupa ;

-- KRAJ LEKCIJA 5: Kriptografija, cloud -napredne teme


DROP TRIGGER trg_dmlKontPristupa