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

SET SERVEROUTPUT ON;
ALTER SESSION SET NLS_DATE_FORMAT = 'DD-MM-YYYY';
ALTER SESSION SET NLS_TIMESTAMP_FORMAT = 'DD-MM-YYYY HH24:MI:SS';

CREATE TABLE Diagnoza (
    IdDiagnoza integer  NOT NULL,
    Nazwa varchar2(30)  NOT NULL,
    CONSTRAINT Diagnoza_pk PRIMARY KEY (IdDiagnoza)
) ;

CREATE TABLE Klient (
    IdKlient integer  NOT NULL,
    PESEL integer  NOT NULL,
    CONSTRAINT Klient_pk PRIMARY KEY (IdKlient)
) ;

CREATE TABLE Lekarz (
    IdLekarz integer  NOT NULL,
    IdSpecjalizacja integer  NOT NULL,
    Pensja smallint  NOT NULL,
    CONSTRAINT Lekarz_pk PRIMARY KEY (IdLekarz)
) ;

CREATE TABLE Osoba (
    IdOsoba integer  NOT NULL,
    Imie varchar2(30)  NOT NULL,
    Nazwisko varchar2(30)  NOT NULL,
    DataUrodzenia date  NOT NULL,
    NumerKomurkowy integer  NOT NULL,
    CONSTRAINT Osoba_pk PRIMARY KEY (IdOsoba)
) ;

-- Table: Przepis
CREATE TABLE Przepis (
    IdPrzepis varchar2(20)  NOT NULL,
    IdWizyt integer  NOT NULL,
    Komentarz varchar2(100)  NOT NULL,
    CONSTRAINT Przepis_pk PRIMARY KEY (IdPrzepis)
) ;

CREATE TABLE Specjalizacja (
    IdSpecjalizacja integer  NOT NULL,
    Nazwa varchar2(20)  NOT NULL,
    CONSTRAINT Specjalizacja_pk PRIMARY KEY (IdSpecjalizacja)
) ;

CREATE TABLE Wizyta (
    IdWizyt integer  NOT NULL,
    IdKlient integer  NOT NULL,
    IdLekarz integer  NOT NULL,
    IdDiagnoza integer  NOT NULL,
    Data timestamp  NOT NULL,
    CONSTRAINT Wizyta_pk PRIMARY KEY (IdWizyt)
) ;

ALTER TABLE Klient ADD CONSTRAINT Klient_Osoba
    FOREIGN KEY (IdKlient)
    REFERENCES Osoba (IdOsoba);

ALTER TABLE Lekarz ADD CONSTRAINT Lekarz_Osoba
    FOREIGN KEY (IdLekarz)
    REFERENCES Osoba (IdOsoba);

ALTER TABLE Lekarz ADD CONSTRAINT Lekarz_Specjalizacja
    FOREIGN KEY (IdSpecjalizacja)
    REFERENCES Specjalizacja (IdSpecjalizacja);

ALTER TABLE Przepis ADD CONSTRAINT Przepis_Wizyta
    FOREIGN KEY (IdWizyt)
    REFERENCES Wizyta (IdWizyt);

ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Diagnoza
    FOREIGN KEY (IdDiagnoza)
    REFERENCES Diagnoza (IdDiagnoza);

ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Klient
    FOREIGN KEY (IdKlient)
    REFERENCES Klient (IdKlient);

ALTER TABLE Wizyta ADD CONSTRAINT Wizyta_Lekarz
    FOREIGN KEY (IdLekarz)
    REFERENCES Lekarz (IdLekarz);
    


INSERT INTO OSOBA VALUES (1, 'a', 'b', '10-11-2003', 123456781);
INSERT INTO OSOBA VALUES (2, 'c', 'd', '02-12-2002', 123456782); 
INSERT INTO OSOBA VALUES (3, 'e', 'f', '13-03-2001', 123456783); 
INSERT INTO OSOBA VALUES (4, 'g', 'h', '12-11-2000', 123456784); 
INSERT INTO OSOBA VALUES (5, 'i', 'j', '30-01-2004', 123456785); 
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





--Stworzy? funkcje, ktora przy pomocy kursora przejre wszystkie pencji lekarz?w i zmodyfikuje ich tak, aby
--pencji mniej niz pierwszy argument funkcji mialy zwiekszone byly zwiekszone o 30%, natomiast pencji
--powyzej niz drugi argument byly zwiekszone o 15%. Funkcja powinna zwracan liczbe zaktualizowanych biletow. Wypisac na ekran kazda wprowadzona zmiane.

CREATE OR REPLACE FUNCTION zwiekszeniePensji
(punkt1 INT, punkt2 INT)
RETURN INT 
-- tworzymy funkcje zwiekszeniePencji z dwoma argumentami(zwraca wartosc INT)
AS
CURSOR cur(v_punkt1 INT, v_puntk2 INT) IS (SELECT IdLekarz, Pensja
                                           FROM Lekarz
                                           WHERE Pensja NOT BETWEEN v_punkt1 AND v_puntk2); -- inicjalizujemy kursor z 2 parametrami
v_IloscModyfikacji INT := 0; --inicjalizujemy zmienna, ktora bedzie zliczac liczbe z biletow
v_IdLekarz INT;
v_Pensja INT; -- deklarujemy dwie zmienne dla kursora
nieprawidlowaPensja EXCEPTION; -- deklarujemy wyjatek
BEGIN
    OPEN cur(punkt1, punkt2); -- otworzymy kursor i przekajemy parametry funkcji jako parametry
    LOOP
        FETCH cur INTO v_IdLekarz, v_Pensja; --przypisujemy zmiennym wartosci zwrucone przez kursor
        EXIT WHEN cur%NOTFOUND;
        IF v_Pensja < punkt1 THEN -- jesli cena jest mniejsza niz pierwszy parametr
            UPDATE Lekarz SET Pensja = Pensja * 1.3 WHERE IdLekarz = v_IdLekarz; --zwiekszamy cene o 30%
            dbms_output.put_line('Pensja lekarza ' || v_IdLekarz || ' byla zwiekszona na ' || v_Pensja * 0.3); -- wypisujemy komunikat o modyfikacji
        ELSIF v_Pensja > punkt2 THEN -- je?li cena jest wieksza ni? pierwszy parametr
            UPDATE Lekarz SET Pensja = Pensja * 1.15 WHERE IdLekarz = v_IdLekarz; 
            dbms_output.put_line('Pensja lekarza ' || v_IdLekarz || ' byla zwiekszona na ' || v_Pensja * 0.15); -- wypisujemy komunikat o modyfikacji
        ELSE -- w innym przypadku
            RAISE nieprawidlowaPensja; -- zdlaszamy wyjatek
        END IF;
        
        v_IloscModyfikacji := v_IloscModyfikacji + 1; -- ilosc zmodyfikowanych biletow + 1
    END LOOP;

    RETURN v_IloscModyfikacji; -- zwracamy ilosc zmodyfikowanych biletow o jeden

    EXCEPTION -- obslugujemy wyjatek
    WHEN nieprawidlowaPensja THEN
        dbms_output.put_line('bledna wartosc pensji');
END;


--Test
SELECT * FROM Lekarz;
DECLARE
v_counter INT;
BEGIN
    v_counter := zwiekszeniePensji(1000, 2000);
    dbms_output.put_line('Ilosc modyfikacji: ' || v_counter);
END;
SELECT * FROM Lekarz;




































    
    


