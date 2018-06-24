-- PRIPREMA ZA ISPIT LAB 9

--Kreirati bazu podataka Studentska sluzba na data i log lokaciju.

CREATE DATABASE StudentskaSluzba ON PRIMARY
(
	NAME = N'StudentskaSluzba',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\StudentskaSluzba.mdf',
	SIZE =  5MB ,
	MAXSIZE = UNLIMITED,
	FILEGROWTH = 10% 
)
LOG ON
(
	NAME = N'StudentskaSluzba_log',
	FILENAME = N'C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA\StudentskaSluzba_log.ldf',
	SIZE = 2MB,
	FILEGROWTH = 10%
)

USE StudentskaSluzba


CREATE TABLE Edukatori
(
	EdukatorID int IDENTITY(1,1) PRIMARY KEY,
	Ime	nvarchar (35) NOT NULL,
	Prezime	nvarchar (35) NOT NULL,
	Titula	nvarchar (10) ,
	[Status] bit default 1,
	Slika varbinary(max) 
)

CREATE TABLE Predmeti
(
	PredmetID int IDENTITY(1,1) PRIMARY KEY,
	Naziv	nvarchar (30) NOT NULL,
	Oznaka	nvarchar (5) NOT NULL,
	ECTS int NOT NULL,
)
CREATE TABLE EdukatoriPredmeti
(
	EdukatorID int  NOT NULL FOREIGN KEY (EdukatorID)REFERENCES Edukatori(EdukatorID),
	PredmetID int  NOT NULL FOREIGN KEY (PredmetID) REFERENCES Predmeti(PredmetID),
	BrojSati int NOT NULL,
	PRIMARY KEY(EdukatorID,PredmetID)
)
CREATE TABLE Fakultet
(
	FakultetID int NOT NULL IDENTITY(1,1) PRIMARY KEY,
	Naziv	nvarchar (30) NOT NULL UNIQUE NONCLUSTERED,
)

ALTER TABLE Edukatori
ADD	FakultetID int NOT NULL FOREIGN KEY (FakultetID) REFERENCES Fakultet(FakultetID)

ALTER TABLE EdukatoriPredmeti
ADD	FakultetID int NOT NULL FOREIGN KEY (FakultetID) REFERENCES Fakultet(FakultetID)

ALTER TABLE Predmeti
ALTER COLUMN ECTS decimal(18,1)


INSERT INTO Fakultet
VALUES ('FIT'),('ETF'),('EFSA')


INSERT INTO Predmeti
VALUES ('Baze2','BPII',7),('Programiranje2','PR2',9),('Programiranje3','PR3',5)


INSERT INTO Edukatori
VALUES ('Jasmin','Azemovic','DR',DEFAULT),('Profa2','PrezProf2','MG',0),('Profa3','PrezProf3','DOC',1)

DROP TABLE Fakultet
DROP TABLE Predmeti
DROP TABLE Edukatori
DROP TABLE EdukatoriPredmeti


CREATE PROCEDURE DodajEdukatore
(
 @ime nvarchar(35),
 @prezime nvarchar (35),
 @titula nvarchar (10),
 @status BIT = 1,
 @slika varbinary(max)=NULL,
 @fakultetID INT
)
AS
BEGIN
	INSERT INTO Edukatori
	VALUES ( @ime, @prezime , @titula , @status,@slika, @fakultetID )
END;



SELECT * FROM Edukatori


EXEC DodajEdukatore 'Ajdin','Lj','st',1,NULL,1



CREATE PROCEDURE IzmjeniEdukatore
(
 @edukatorID INT,
 @ime nvarchar(35),
 @prezime nvarchar (35),
 @titula nvarchar (10),
 @status BIT = 1,
 @slika varbinary(max)=NULL,
 @fakultetID INT
)
AS
BEGIN
	UPDATE Edukatori
	SET Ime= @ime,
	Prezime=@prezime ,
	Titula= @titula ,
	[Status]= @status,
	Slika = @slika,
	FakultetID = @fakultetID 
WHERE EdukatorID=@edukatorID
END;

CREATE PROCEDURE ObrisiEdukatore
(
 @edukatorID INT

)
AS
BEGIN
	DELETE FROM Edukatori
	WHERE EdukatorID=@edukatorID
	
END;

SELECT * FROM Edukatori
SELECT * FROM Predmeti
SELECT * FROM Fakultet
INSERT INTO Edukatori
VALUES ('Jasmin','Azemovic','dr',1,NULL,2),('Denis','Music','doc',0,NULL,3)

USE StudentskaSluzba
INSERT INTO EdukatoriPredmeti
VALUES (1,1,2,1),(1,2,3,1),(2,1,5,2),(3,2,3,2),(2,3,1,3)

CREATE VIEW view_EdukatoriPredmeti
AS
SELECT E.Ime,E.Prezime,P.Naziv
FROM EdukatoriPredmeti AS EP
JOIN Edukatori AS E ON E.EdukatorID=EP.EdukatorID
JOIN Predmeti AS P ON P.PredmetID=EP.PredmetID
JOIN Fakultet AS F ON F.FakultetID=EP.FakultetID


SELECT * FROM  view_EdukatoriPredmeti

USE StudentskaSluzba

INSERT INTO Edukatori (Ime,Prezime,Titula,FakultetID)
SELECT TOP 10 
	SUBSTRING(NC.ContactName,1,CHARINDEX(' ',NC.ContactName)) ,
	SUBSTRING(NC.ContactName,CHARINDEX(' ',NC.ContactName),35),
	LEFT(SUBSTRING(NC.ContactTitle,1,CHARINDEX(' ',NC.ContactTitle)) ,10),
	1
FROM [Northwind].dbo.Customers AS NC
WHERE CHARINDEX(' ',NC.ContactName)<>0 AND
	SUBSTRING(NC.ContactTitle,1,CHARINDEX(' ',NC.ContactTitle)) NOT LIKE ''


SELECT TOP 10 
	SUBSTRING(NC.ContactName,1,CHARINDEX(' ',NC.ContactName)) AS ime ,
	SUBSTRING(NC.ContactName,CHARINDEX(' ',NC.ContactName)+1,35) AS prezime,
	LEFT(SUBSTRING(NC.ContactTitle,1,CHARINDEX(' ',NC.ContactTitle)) ,10) AS titula,
	1 as fakultet
INTO	#tempEduk		--Edukatori (Ime,Prezime,Titula,FakultetID)
	FROM [Northwind].dbo.Customers AS NC
	WHERE CHARINDEX(' ',NC.ContactName)<>0 AND
	SUBSTRING(NC.ContactTitle,1,CHARINDEX(' ',NC.ContactTitle)) NOT LIKE ''
ORDER BY NC.ContactName DESC

INSERT INTO Edukatori (Ime,Prezime,Titula,FakultetID)
SELECT	*
 FROM #tempEduk

 SELECT * FROM Edukatori

 DROP TABLE #tempEduk



CREATE PROCEDURE proc_Prezime @Prezime nvarchar(35)
AS 
SELECT *
FROM Edukatori
WHERE Prezime LIKE @Prezime + '%'

EXEC proc_Prezime 'A'



