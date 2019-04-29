CREATE TABLE producent_sprzetu(id_producent serial PRIMARY KEY,nazwa VARCHAR(50) CHECK(LENGTH(nazwa)>2),
                                ulica VARCHAR(50) CHECK(LENGTH(ulica)>2) NOT NULL
);

INSERT INTO producent_sprzetu(nazwa, ulica) VALUES ('Nazwa1','Brzeszczyñskiego');
INSERT INTO producent_sprzetu(nazwa, ulica) VALUES ('Nazwa2','23 Marca');
INSERT INTO producent_sprzetu(nazwa, ulica) VALUES ('Nazwa3','11 Listopada');
INSERT INTO producent_sprzetu(nazwa, ulica) VALUES ('Nazwa4','Afrodyty');
INSERT INTO producent_sprzetu(nazwa, ulica) VALUES ('Nazwa5','Biologiczna');

CREATE TABLE sprzet (id_sprzet serial PRIMARY KEY,ilosc INTEGER DEFAULT 0 CHECK(ilosc>=0),
                     id_producent INTEGER NOT NULL REFERENCES producent_sprzetu(id_producent)
);

INSERT INTO sprzet(ilosc,id_producent) VALUES (1,1);
INSERT INTO sprzet(ilosc,id_producent) VALUES (10,3);
INSERT INTO sprzet(ilosc,id_producent) VALUES (18,3);
INSERT INTO sprzet(ilosc,id_producent) VALUES (5,2);
INSERT INTO sprzet(ilosc,id_producent) VALUES (1,1);


CREATE TABLE sala_cwiczeniowa (id_sala serial PRIMARY KEY,nazwa VARCHAR(50) NOT NULL,opis VARCHAR(100) NOT NULL
);

INSERT INTO sala_cwiczeniowa(nazwa,opis) VALUES ('nazwa_sali1','opis1');
INSERT INTO sala_cwiczeniowa(nazwa,opis) VALUES ('nazwa_sali2','opis2');
INSERT INTO sala_cwiczeniowa(nazwa,opis) VALUES ('nazwa_sali3','opis3');
INSERT INTO sala_cwiczeniowa(nazwa,opis) VALUES ('nazwa_sali4','opis4');
INSERT INTO sala_cwiczeniowa(nazwa,opis) VALUES ('nazwa_sali5','opis5');

CREATE TABLE sprzet_sala (id_sprzet INT NOT NULL REFERENCES sprzet(id_sprzet),id_sala INT NOT NULL REFERENCES sala_cwiczeniowa(id_sala) ON UPDATE CASCADE,
                          ilosc INT DEFAULT 0 CHECK(ilosc>=0),PRIMARY KEY(id_sala, id_sprzet)
);

INSERT INTO sprzet_sala(id_sala,id_sprzet,ilosc) VALUES (2,3,7);
INSERT INTO sprzet_sala(id_sala,id_sprzet,ilosc) VALUES (3,1,10);
INSERT INTO sprzet_sala(id_sala,id_sprzet,ilosc) VALUES (1,5,5);
INSERT INTO sprzet_sala(id_sala,id_sprzet,ilosc) VALUES (2,1,20);
INSERT INTO sprzet_sala(id_sala,id_sprzet,ilosc) VALUES (2,4,10);


CREATE TABLE producent_odzywki (
id_producent_odzywki serial PRIMARY KEY,nazwa VARCHAR(50) NOT NULL,ulica VARCHAR(50) NOT NULL,nr_domu VARCHAR(10) NOT NULL
);

INSERT INTO producent_odzywki(nazwa,ulica,nr_domu) VALUES('Nazwa1','Biologiczna','68/3');
INSERT INTO producent_odzywki(nazwa,ulica,nr_domu) VALUES('Nazwa2','Biologiczna','68/3');
INSERT INTO producent_odzywki(nazwa,ulica,nr_domu) VALUES('Nazwa3','Biologiczna','68/3');
INSERT INTO producent_odzywki(nazwa,ulica,nr_domu) VALUES('Nazwa4','Biologiczna','68/3');
INSERT INTO producent_odzywki(nazwa,ulica,nr_domu) VALUES('Nazwa5','Biologiczna','68/3');

CREATE TABLE odzywka (id_odzywka serial PRIMARY KEY,nazwa VARCHAR(50) NOT NULL,
                      ilosc INTEGER DEFAULT 0 CHECK(ilosc>=0) NOT NULL,
                      id_producent_odzywki INT NOT NULL REFERENCES producent_odzywki(id_producent_odzywki) ON UPDATE CASCADE
);

INSERT INTO odzywka(nazwa,ilosc,id_producent_odzywki) VALUES('nazwa_odzywki1',10,5);
INSERT INTO odzywka(nazwa,ilosc,id_producent_odzywki) VALUES('nazwa_odzywki2',10,2);
INSERT INTO odzywka(nazwa,ilosc,id_producent_odzywki) VALUES('nazwa_odzywki3',15,2);
INSERT INTO odzywka(nazwa,ilosc,id_producent_odzywki) VALUES('nazwa_odzywki4',20,1);
INSERT INTO odzywka(nazwa,ilosc,id_producent_odzywki) VALUES('nazwa_odzywki5',25,2);

CREATE TABLE trener (id_trener serial PRIMARY KEY,imie VARCHAR(50) NOT NULL,nazwisko VARCHAR(50) CHECK(LENGTH(nazwisko)>2) NOT NULL,ulica VARCHAR(50) CHECK(LENGTH(ulica)>2) NOT NULL
);

INSERT INTO trener(imie,nazwisko,ulica) VALUES ('Ddam1','Ddamski1','Bartoszycka'),
('Ddam2','Ddamski2','Bartoszycka'),
('Ddam3','Ddamski3','Bartoszycka'),
('Ddam4','Ddamski4','Bartoszycka'),
('Ddam5','Ddamski5','Bartoszycka');

CREATE TABLE rodzaj_uslugi (id_rodzaj_uslugi serial PRIMARY KEY,nazwa VARCHAR(50) NOT NULL,
                            czas_trwania_w_minutach INT NOT NULL CHECK(czas_trwania_w_minutach>=0),
                            id_trener INT NOT NULL REFERENCES trener(id_trener) ON UPDATE CASCADE
);

INSERT INTO rodzaj_uslugi(nazwa,czas_trwania_w_minutach, id_trener) VALUES ('Nazwa_uslugi1',50,1),
('Nazwa_uslugi2',20,1),
('Nazwa_uslugi3',50,1),
('Nazwa_uslugi4',50,1),
('Nazwa_uslugi5',50,1);

CREATE TABLE klient (id_klient serial PRIMARY KEY,imie VARCHAR(50),nazwisko VARCHAR(50) CHECK(LENGTH(nazwisko)>2) NOT NULL,kod CHAR(6) NOT NULL
);

INSERT INTO klient( imie, nazwisko,kod) VALUES('Adam1','Adamski1','80-680'),
('Adam2','Adamski2','81-528'),
('Adam3','Adamski3','81-362'),
('Adam4','Adamski4','11-200'),
('Adam5','Adamski5','11-100');


CREATE TABLE pracownik_recepcji (id_pracownik serial PRIMARY KEY,imie VARCHAR(50) NOT NULL,
                                 nazwisko VARCHAR(50) NOT NULL, ulica VARCHAR(50) CHECK(LENGTH(ulica)>2)
);

INSERT INTO pracownik_recepcji( imie, nazwisko,ulica) VALUES ('Bdam5','Bdamski5','Bartoszycka'),
('Bdam5','Bdamski5','Bartoszycka'),
('Bdam5','Bdamski5','Bartoszycka'),
('Bdam5','Bdamski5','Bartoszycka'),
('Bdam5','Bdamski5','Bartoszycka');

CREATE TABLE kupno_uslugi (id_kupno_uslugi serial PRIMARY KEY,cena NUMERIC DEFAULT 0,cena_razem NUMERIC DEFAULT 0,data_wejscia DATE DEFAULT NOW(),
                           id_klient INT REFERENCES klient(id_klient) ON UPDATE CASCADE,id_pracownik_recepcji INT REFERENCES pracownik_recepcji(id_pracownik) ON UPDATE CASCADE,
                           id_rodzaj_uslugi INT REFERENCES rodzaj_uslugi(id_rodzaj_uslugi) ON UPDATE CASCADE
);

INSERT INTO kupno_uslugi(cena,cena_razem,data_wejscia,id_klient,id_pracownik_recepcji,id_rodzaj_uslugi) VALUES(50,150,'20060606 09:24:59 AM',4,4,3),
(30,150,'20060606 11:14:49 AM',2,1,2),
(20,150,'20060606 10:54:39 AM',3,4,1),
(10,1050,'20060606 11:23:19 AM',5,4,3),
(50,1500,'20060606 10:11:09 AM',5,1,3),
(50,1505,'20060606 11:11:09 AM',3,4,3);

CREATE TABLE wykupiona_usluga_na_sale (id_kupno_uslugi INT NOT NULL REFERENCES kupno_uslugi(id_kupno_uslugi),
                                       id_sala INT REFERENCES sala_cwiczeniowa(id_sala),PRIMARY KEY(id_sala, id_kupno_uslugi)
);

INSERT INTO wykupiona_usluga_na_sale(id_kupno_uslugi,id_sala) VALUES(1,2);
INSERT INTO wykupiona_usluga_na_sale(id_kupno_uslugi,id_sala) VALUES(2,5);
INSERT INTO wykupiona_usluga_na_sale(id_kupno_uslugi,id_sala) VALUES(1,4);
INSERT INTO wykupiona_usluga_na_sale(id_kupno_uslugi,id_sala) VALUES(3,3);
INSERT INTO wykupiona_usluga_na_sale(id_kupno_uslugi,id_sala) VALUES(1,1);

CREATE TABLE odzywka_zakupiona (cena NUMERIC DEFAULT 0,ilosc INT DEFAULT 0 CHECK(ilosc>=0),
                                id_kupno_uslugi INT NOT NULL REFERENCES kupno_uslugi(id_kupno_uslugi) ON UPDATE CASCADE,
                                id_odzywka INT NOT NULL REFERENCES odzywka(id_odzywka) ON UPDATE CASCADE,PRIMARY KEY(id_odzywka, id_kupno_uslugi)
);

INSERT INTO odzywka_zakupiona(cena,ilosc,id_kupno_uslugi,id_odzywka) VALUES(50,6,1,3);
INSERT INTO odzywka_zakupiona(cena,ilosc,id_kupno_uslugi,id_odzywka) VALUES(100,6,2,3);
INSERT INTO odzywka_zakupiona(cena,ilosc,id_kupno_uslugi,id_odzywka) VALUES(20,5,5,3);
INSERT INTO odzywka_zakupiona(cena,ilosc,id_kupno_uslugi,id_odzywka) VALUES(50,6,3,3);
INSERT INTO odzywka_zakupiona(cena,ilosc,id_kupno_uslugi,id_odzywka) VALUES(50,6,4,3);