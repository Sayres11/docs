--Online rejestracja wizyty w szpitalu

--Stworzyc diagram zwiazkow encji dla systemu online rejestracji wizytow w szpitalu,
--pozwalajacy zobaczyc wszystkie informacje o wizytach. Nalezy pamietac:

-- dane personalne klientow 
-- dane lekarzy oraz ego specjalizacje

--Jeden klient/lekarz moze miec wiele wizyt. Kazdy lekarz ma dopiero jedna specjalizacje.
--Po wizycie kazdy klient otrzymuje przepis z komentarzem(zgodnie z diagnoza)


/*
DROP TABLE Wizyta;
DROP TABLE Diagnoza;
DROP TABLE Przepis;
DROP TABLE Klient;
DROP TABLE Lekarz;
DROP TABLE Specjalizacja;
DROP TABLE Osoba;
*/

GO
CREATE TABLE Diagnoza (
    IdDiagnoza int  NOT NULL,
    Nazwa varchar(30)  NOT NULL,
    CONSTRAINT Diagnoza_pk PRIMARY KEY  (IdDiagnoza)
);

GO
CREATE TABLE Klient (
    IdKlient int  NOT NULL,
    PESEL int  NOT NULL,
    CONSTRAINT Klient_pk PRIMARY KEY  (IdKlient)
);

GO
CREATE TABLE Lekarz (
    IdLekarz int  NOT NULL,
    IdSpecjalizacja int  NOT NULL,
    Pensja smallint  NOT NULL,
    CONSTRAINT Lekarz_pk PRIMARY KEY  (IdLekarz)
);

GO
CREATE TABLE Osoba (
    IdOsoba int  NOT NULL,
    Imie varchar(30)  NOT NULL,
    Nazwisko varchar(30)  NOT NULL,
    DataUrodzenia date  NOT NULL,
    NumerKomurkowy int  NOT NULL,
    CONSTRAINT Osoba_pk PRIMARY KEY  (IdOsoba)
);

GO
CREATE TABLE Przepis (
    IdPrzepis varchar(20)  NOT NULL,
    IdWizyt int  NOT NULL,
    Komentarz varchar(100)  NOT NULL,
    CONSTRAINT Przepis_pk PRIMARY KEY  (IdPrzepis)
);

GO
CREATE TABLE Specjalizacja (
    IdSpecjalizacja int  NOT NULL,
    Nazwa varchar(20)  NOT NULL,
    CONSTRAINT Specjalizacja_pk PRIMARY KEY  (IdSpecjalizacja)
);

GO
CREATE TABLE Wizyta (
    IdWizyt int  NOT NULL,
    IdKlient int  NOT NULL,
    IdLekarz int  NOT NULL,
    IdDiagnoza int  NOT NULL,
    Data datetime  NOT NULL,
    CONSTRAINT Wizyta_pk PRIMARY KEY  (IdWizyt)
);

GO
ALTER TABLE Klient ADD CONSTRAINT Klient_Osoba
    FOREIGN KEY (IdKlient)
    REFERENCES Osoba (IdOsoba);

GO
ALTER TABLE Lekarz ADD CONSTRAINT Lekarz_Osoba
    FOREIGN KEY (IdLekarz)
    REFERENCES Osoba (IdOsoba);

GO
ALTER TABLE Lekarz ADD CONSTRAINT Lekarz_Specjalizacja
    FOREIGN KEY (IdSpecjalizacja)
    REFERENCES Specjalizacja (IdSpecjalizacja);

GO
ALTER TABLE Przepis ADD CONSTRAINT Przepis_Wizyta
    FOREIGN KEY (IdWizyt)
    REFERENCES Wizyta (IdWizyt);

GO
ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Diagnoza
    FOREIGN KEY (IdDiagnoza)
    REFERENCES Diagnoza (IdDiagnoza);

GO
ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Klient
    FOREIGN KEY (IdKlient)
    REFERENCES Klient (IdKlient);

GO
ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Lekarz
    FOREIGN KEY (IdLekarz)
    REFERENCES Lekarz (IdLekarz);
	
GO
INSERT INTO OSOBA VALUES (1, 'a', 'b', '12-11-2003', 123456781);
INSERT INTO OSOBA VALUES (2, 'c', 'd', '02-12-2002', 123456782); 
INSERT INTO OSOBA VALUES (3, 'e', 'f', '12-03-2001', 123456783); 
INSERT INTO OSOBA VALUES (4, 'g', 'h', '12-11-2000', 123456784); 
INSERT INTO OSOBA VALUES (5, 'i', 'j', '01-01-2004', 123456785); 
INSERT INTO OSOBA VALUES (6, 'k', 'l', '10-11-1990', 123456786); 
INSERT INTO OSOBA VALUES (7, 'm', 'n', '10-10-1981', 123456787); 
INSERT INTO OSOBA VALUES (8, 'o', 'p', '07-11-1982', 123456788); 
INSERT INTO OSOBA VALUES (9, 'q', 's', '08-05-1983', 123456789); 

INSERT INTO Klient VALUES(1, 987654321);
INSERT INTO Klient VALUES(2, 987654322);
INSERT INTO Klient VALUES(3, 987654323);
INSERT INTO Klient VALUES(4, 987654324);
INSERT INTO Klient VALUES(5, 987654325);
INSERT INTO Klient VALUES(6, 987654326);

INSERT INTO Specjalizacja VALUES(1, 'A');
INSERT INTO Specjalizacja VALUES(2, 'B');

INSERT INTO Lekarz VALUES(7, 1, 1000);
INSERT INTO Lekarz VALUES(8, 1, 1000);
INSERT INTO Lekarz VALUES(9, 2, 2000);

INSERT INTO Diagnoza VALUES(1, 'X');
INSERT INTO Diagnoza VALUES(2, 'Y');
INSERT INTO Diagnoza VALUES(3, 'Z');

INSERT INTO Wizyta VALUES(1, 1, 7, 1, '01-01-2022 10:00:00');
INSERT INTO Wizyta VALUES(2, 2, 8, 2, '01-01-2021 10:00:00');
INSERT INTO Wizyta VALUES(3, 3, 7, 3, '01-05-2022 10:00:00');
INSERT INTO Wizyta VALUES(4, 4, 8, 1, '06-01-2022 10:00:00');
INSERT INTO Wizyta VALUES(5, 5, 9, 2, '03-01-2022 10:00:00');
INSERT INTO Wizyta VALUES(6, 6, 9, 3, '01-01-2022 10:00:00');

INSERT INTO Przepis VALUES(1, 1, 'aaa');
INSERT INTO Przepis VALUES(2, 2, 'bbb');
INSERT INTO Przepis VALUES(3, 3, 'ccc');
INSERT INTO Przepis VALUES(4, 4, 'ddd');
INSERT INTO Przepis VALUES(5, 5, 'eee');
INSERT INTO Przepis VALUES(6, 6, 'ggg');
GO


SET NOCOUNT ON;


--Stworzyc procedure, ktora przy pomocy kursora przejre wszystkie pencji lekarzow i zmodyfikuje ich tak, aby
--pencji mniej niz pierwszy argument funkcji mialy zwiekszone byly zwiekszone o 30%, natomiast pencji
--powyzej niz drugi argument byly zwiekszone o 15%
--Wypisac na ekran kazda wprowadzona zmiane

GO
CREATE PROCEDURE zwiekszeniePensji
@punkt1 INT, @punkt2 INT
AS
BEGIN
	DECLARE cur CURSOR FOR SELECT IdLekarz, Pensja
						   FROM Lekarz
						   WHERE Pensja NOT BETWEEN @punkt1 AND @punkt2
    DECLARE @IdLekarz INT, @Pensja INT;
    OPEN cur
	FETCH NEXT FROM cur INTO @IdLekarz, @Pensja
    WHILE @@FETCH_STATUS = 0 
		BEGIN
			IF @Pensja < @punkt1
				BEGIN 
					UPDATE Lekarz SET Pensja = Pensja * 1.3 WHERE IdLekarz = @IdLekarz
					PRINT 'Pensja lekarza ' + CAST(@IdLekarz AS VARCHAR) + ' byla zwiekszona na ' + CAST(@Pensja * 0.3 AS VARCHAR)
				END
			ELSE 
				BEGIN 
					UPDATE Lekarz SET Pensja = Pensja * 1.15 WHERE IdLekarz = @IdLekarz
					PRINT 'Pensja lekarza ' + CAST(@IdLekarz AS VARCHAR) + ' byla zwiekszona na ' + CAST(@Pensja * 0.15 AS VARCHAR)
				END
			FETCH NEXT FROM cur INTO @IdLekarz, @Pensja
		END
    CLOSE cur
	DEALLOCATE cur
END
SELECT * FROM Lekarz
EXECUTE zwiekszeniePensji 1200, 1500
EXECUTE zwiekszeniePensji 1200, 1500
SELECT * FROM Lekarz
DROP PROCEDURE zwiekszeniePensji



--Napisać wyzwalacz, który nie pozwoli wstawić nowego klienta z już 
--istniejącym PESEL w tabeli Klient i zgłosi błąd

GO
CREATE TRIGGER TR 
ON Klient FOR INSERT
AS
BEGIN
	BEGIN TRY
		IF EXISTS (SELECT 1
				   FROM inserted i LEFT JOIN deleted d ON i.IdKlient = d.IdKlient
				   WHERE d.IdKlient IS NULL AND EXISTS (SELECT 1
													    FROM Klient k
													    WHERE k.Pesel = i.Pesel AND k.IdKlient != i.IdKlient))
		BEGIN
			Raiserror ('Klient z tym PESEL juz istnieje', 16, 1)
			ROLLBACK
		END
	END TRY
	BEGIN CATCH
		Print ERROR_MESSAGE() + ' Severity = ' + 
			  Cast(ERROR_SEVERITY() As Varchar(3)) +
			  ' State = ' + Cast(ERROR_STATE() As Varchar(3))
	END CATCH
END
SELECT * FROM Klient
INSERT INTO Osoba VALUES(10, 't', 'u', '08-05-1980', 123456789);
INSERT INTO Klient VALUES(10, 987654321);
SELECT * FROM Klient
INSERT INTO Klient VALUES(10, 987654327);
SELECT * FROM Klient
DROP TRIGGER TR