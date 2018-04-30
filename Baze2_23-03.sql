USE master
GO

CREATE DATABASE AjdinLjubuncic

USE AjdinLjubuncic
GO

CREATE TABLE Kupci
(
	KupacID			int IDENTITY(1,1)	CONSTRAINT  PK_Kupci PRIMARY KEY,
	Ime				nvarchar(50)		NOT NULL,
	Prezime			nvarchar(50)		NOT NULL,
	Adresa			nvarchar(50),
	Telefon			nvarchar(13),
	Email			nvarchar(50)		NOT NULL	UNIQUE
)
GO

CREATE TABLE Racuni
(
	RacunID		int	IDENTITY(1,1)		CONSTRAINT	PK_Racuni PRIMARY KEY,
	Datum			date,
	Iznos			decimal,
	Opis			nvarchar(max),
	KupacID			int					CONSTRAINT  FK_Kupci_Racuni FOREIGN KEY REFERENCES Kupci(KupacID)
)
GO

CREATE TABLE Artikli
(
	ArtikalID		int	IDENTITY(1,1)	CONSTRAINT  PK_Artikli	PRIMARY KEY,
	Naziv			nvarchar(100)		NOT NULL,
	StanjeZaliha	int					NOT NULL,
	Iznos			decimal	
)
GO

CREATE TABLE Artikli_Racuni
(
	ArtikalID		int					REFERENCES  Artikli(ArtikalID),
	RacunID			int					REFERENCES  Racuni(RacunID),
	Kolicina		decimal				NOT NULL, 
	Popust			int		,
	PRIMARY KEY(ArtikalID,RacunID)		
)

GO

INSERT INTO Kupci
VALUES ('Ajdin','Ljubuncic','Armije','055666333','ajdin@mail.com')

INSERT INTO Kupci
VALUES ('Ajdin','Halilovic','Bosanska','033666333','ajdinH@mail.com')

INSERT INTO Kupci
VALUES ('Salih','Agic','Marsala Tita','066236333','salih@mail.com')

INSERT INTO Artikli
VALUES('Cokolada',5,2)

INSERT INTO Artikli
VALUES('Majoneza',4,3)

INSERT INTO Artikli
VALUES('Jabuka',7,1)


INSERT INTO Racuni
VALUES ('20180506',1,3,2)

INSERT INTO Racuni
VALUES ('20180708',2,4,1)

INSERT INTO Racuni
VALUES ('20180101',1,1,2)

INSERT INTO Racuni
VALUES ('20180204',1,6,3)

INSERT INTO Racuni
VALUES ('20180306',2,3,2)

USE AjdinLjubuncic
GO

SELECT K.Ime,K.Prezime,COUNT(R.RacunID) Ukupno
FROM Kupci AS K
	 JOIN Racuni AS R ON K.KupacID=R.KupacID

SELECT K.Ime,K.Prezime,SUM(AR.Kolicina*A.Iznos)
FROM ArtikliRacuni AS AR
	 JOIN Racuni   AS R ON AR.RacunID=R.RacunID 
	 JOIN Artikli  AS A ON A.ArtikalID=AR.ArtikalID
	 JOIN Kupci	   AS K ON K.KupacID = R.KupacID
GROUP BY K.Ime

ALTER TABLE Racuni
DROP COLUMN Iznos

CREATE PROCEDURE Sedmi @Godina int
AS
SELECT	SUM(A.Iznos*AR.Kolicina)
FROM	Racuni				  AS R
		JOIN	ArtikliRacuni AS AR ON R.RacunID=AR.RacunID
		JOIN	Artikli		  AS A  ON AR.ArtikalID=A.ArtikalID
WHERE	@Godina=YEAR(R.Datum)


CREATE VIEW		Osmi
AS
SELECT	A.Naziv,SUM(A.Iznos*AR.Kolicina) AS Ukupno
FROM	Artikli AS A 
		JOIN ArtikliRacuni AS AR ON A.ArtikalID=AR.ArtikalID
HAVING	 Ukupno>100;

SELECT A.Naziv
FROM ArtikliRacuni AS  AR,
	JOIN	 Artikli AS A ON A.ArtikalID=AR.ArtikalID
	JOIN	 Racuni AS  R.RacunID=AR.RacunID
HAVING COUNT(AR.ArtikalID)>3 AND SUM(A.Iznos*R.Kolicina)>10



