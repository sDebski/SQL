--1a) Tworzymy widok -- widok z informacjami o pracowniku uzyskanymi przez polaczenie tabel pracownik i kupno_uslugi
-- (uzycie CASE WHEN)
CREATE VIEW pracownik_recepcji_raport 
AS
SELECT p.id_pracownik,p.imie,p.nazwisko, CASE WHEN p.wynagrodzenie<=1500 THEN 'male' WHEN p.wynagrodzenie>=3000 then 'srednie' ELSE 'duze' END AS zarobki,

 COUNT(k.id_pracownik_recepcji) AS "ilosc_sprzedazy" FROM pracownik_recepcji p LEFT JOIN kupno_uslugi k
 ON p.id_pracownik=k.id_pracownik_recepcji 
GROUP BY p.id_pracownik,p.imie,p.nazwisko, p.wynagrodzenie
GO


--DROP VIEW dbo.pracownik_recepcji_raport
--1b) Sprawdzenie, ¿e widok dzia³a


select * from pracownik_recepcji_raport where id_pracownik = 1
GO


--2a) Tworzymy funkcjê 1 -- funcka obliczajaca ilosc wejsc w danym okresie

CREATE FUNCTION ilosc_wejsc_w_danym_okresie (
	@data_wczesniejsza DATE, @data_pozniejsza DATE
	) RETURNS INT
	BEGIN RETURN (SELECT COUNT(*) FROM kupno_uslugi
							WHERE data_wejscia>=@data_wczesniejsza AND data_wejscia<=@data_pozniejsza)
END;
GO

--2b) Sprawdzenie, ¿e funkcja 1 dzia³a
SELECT dbo.ilosc_wejsc_w_danym_okresie('2004-11-12', '2011-10-15') AS ilosc_wejsc;
GO
--3a) Tworzymy funkcjê 2 -- funkcja liczaca ile zarobila odzywka

CREATE FUNCTION ile_zarobila_odzywka(
	@id_odzywka INT) 
	RETURNS INT
	BEGIN RETURN (SELECT SUM(cena*ilosc)  FROM odzywka_zakupiona WHERE @id_odzywka=id_odzywka)
	END;
	GO

--3b) Sprawdzenie, ¿e funkcja 2 dzia³a

SELECT dbo.ile_zarobila_odzywka(3) AS suma_sprzedazy
GO


--4a) Tworzymy procedurê 1  -- przyznajemy premie najlepszemu pracownikowi

CREATE PROC przyznaj_premie_najlepszemu_pracownikowi
@premia MONEY
AS BEGIN
DECLARE @id_najlepszego_pracownika INT
SET @id_najlepszego_pracownika=
(SELECT TOP 1 p.id_pracownik FROM pracownik_recepcji p JOIN kupno_uslugi k ON p.id_pracownik=k.id_pracownik_recepcji 
GROUP BY p.id_pracownik
ORDER BY COUNT(k.id_pracownik_recepcji) DESC)
UPDATE pracownik_recepcji SET wynagrodzenie=wynagrodzenie+@premia WHERE id_pracownik=@id_najlepszego_pracownika;
END
GO



select * from pracownik_recepcji

--4b) Sprawdzenie, ¿e procedura 1 dzia³a

EXEC przyznaj_premie_najlepszemu_pracownikowi 500;
GO

--5a) Tworzymy procedurê 2  - usuwanie wszystkich kluczy obcych z obecnej bazy danych
-- uzycie IF EXISTS


CREATE PROCEDURE usun_klucze_obce AS
BEGIN
    WHILE(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_TYPE='FOREIGN KEY'))
    BEGIN
        DECLARE @sql NVARCHAR(2000)
        SELECT TOP 1 @sql=('ALTER TABLE ' + TABLE_SCHEMA + '.[' + TABLE_NAME
        + '] DROP CONSTRAINT [' + CONSTRAINT_NAME + ']')
        FROM information_schema.table_constraints
        WHERE CONSTRAINT_TYPE = 'FOREIGN KEY'
        EXEC (@sql)
    END
END




--5b) Sprawdzenie, ¿e procedura 2 dzia³a
EXEC usun_klucze_obce

--6a) Tworzymy wyzwalacz 1 - przy zmianie wartosci wynagrodzenia, dodatek pracownika sie zeruje
-- uzycie WHILE

CREATE TRIGGER podwyzka ON pracownik_recepcji
FOR UPDATE AS
BEGIN
	DECLARE kursor_pracownik_update CURSOR
	FOR SELECT wynagrodzenie, id_pracownik FROM DELETED;
	OPEN kursor_pracownik_update
	DECLARE @pensja MONEY, @id_pracownik INT
	FETCH NEXT FROM kursor_pracownik_update INTO @pensja, @id_pracownik
	WHILE @@FETCH_STATUS = 0
	BEGIN
		UPDATE pracownik_recepcji SET dodatek=0 WHERE id_pracownik=@id_pracownik
		FETCH NEXT FROM kursor_pracownik_update INTO @pensja, @id_pracownik
	END
	CLOSE kursor_pracownik_update
	DEALLOCATE kursor_pracownik_update
END




--6b) Sprawdzenie, ¿e wyzwalacz 1 dzia³a


UPDATE pracownik_recepcji SET wynagrodzenie=wynagrodzenie+200 where id_pracownik IN(1,2,3);


--7a) Tworzymy wyzwalacz 2 zamiast usuniecia pracownika, zmiana wartosci w kolumnie 'usuniety' z 0 na 1

	ALTER TABLE pracownik_recepcji ADD usuniety BIT;
	UPDATE pracownik_recepcji SET usuniety=0;

	CREATE TRIGGER prac_del_zastap ON pracownik_recepcji
	INSTEAD OF DELETE
	AS
	BEGIN
		UPDATE pracownik_recepcji
		SET usuniety=1
		WHERE id_pracownik IN (SELECT id_pracownik from DELETED)
	END
	GO

	

--7b) Sprawdzenie, ¿e wyzwalacz 2 dzia³a

SELECT * from pracownik_recepcji

DELETE FROM pracownik_recepcji WHERE id_pracownik=1
GO

--8a) Tworzymy wyzwalacz 3 brak mozliwosci dodania pracownika z pensja rowna 0 (uzycie IF ELSE)

CREATE TRIGGER pracownik_ins ON pracownik_recepcji
AFTER INSERT AS
BEGIN
	DECLARE @wynagrodzenie MONEY
	SET @wynagrodzenie=-1
	SELECT @wynagrodzenie=wynagrodzenie FROM INSERTED WHERE wynagrodzenie=0
	IF @wynagrodzenie=0
	BEGIN
		RAISERROR('Pensja nie moze byc rowna 0',1,2)
		ROLLBACK
	END
	ELSE print 'bardzo ladna pensja'
END
GO

DROP TRIGGER pracownik_ins

--8b) Sprawdzenie, ¿e wyzwalacz 3 dzia³a

INSERT INTO pracownik_recepcji(imie,nazwisko,ulica, nr_domu, kod, miasto, wynagrodzenie, dodatek)
VALUES ('imie9', 'nazwisko9', 'ulica9', 'nr_domu9', '99-999', 'miasto9', 0, 100)
GO

SELECT * from pracownik_recepcji
GO


--9a) Tworzymy wyzwalacz 4 brak mozliwosci dodania wiecej niz jednego pracownika na raz

CREATE TRIGGER duplikat_pracownik ON pracownik_recepcji
AFTER INSERT AS
IF @@ROWCOUNT > 1
BEGIN
	PRINT 'Pracownikow mozna dodawac tylko pojedynczo'
	ROLLBACK
END
GO

--9b) Sprawdzenie, ¿e wyzwalacz 4 dzia³a

INSERT INTO pracownik_recepcji(imie,nazwisko,ulica, nr_domu, kod, miasto, wynagrodzenie, dodatek)
 VALUES('imie9', 'nazwisko9', 'ulica9', 'nr_domu9', '99-999', 'miasto9', 50, 100),
 ('imie10','nazwisko10','ulica10','nr_domu10', '11-111', 'miasto10', 50, 100);


--10) Tworzymy tabelê przestawn¹ - oblicza przychod uzyskany przez konretne rodzaje uslug na poszczegolne lata


SELECT id_rodzaj_uslugi, [2016] AS ROK2016, [2017] AS ROK2017,  [2018] as ROK2018
FROM
(
    SELECT id_rodzaj_uslugi, YEAR(data_wejscia) as wplata, cena
    FROM kupno_uslugi
) tabela
PIVOT
(
    SUM(cena)
    FOR wplata IN ([2018],[2017],[2016])
) AS p
ORDER BY id_rodzaj_uslugi


