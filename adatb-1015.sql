-- Ha A tablaban van fk B tablara, akkor B tablaban ne legyen fk A tablara

-- tablak letrehozasa meglevo tabla semajanak / lekerdezes eredmenyenek felhasznalasaval:
CREATE TABLE hr.employees2
AS
SELECT * FROM hr.employees;

DESCRIBE hr.employees2;
DESCRIBE hr.employees;

-- fk es pk megszoritasok nem kerulnek at, kezzel meg kell csinalni…

-- erdemes CREATE elott eldobni a meglevo tablat:
DROP TABLE hr.employees2;

-- ures tabla meglevo szerkezettel:
CREATE TABLE hr.employees2
AS
SELECT * FROM hr.employees WHERE 1 = 2;

CREATE TABLE hr.employees2
AS
SELECT hr.employees.*,1 AS oszlopnev FROM hr.employees WHERE 1 = 2;

CREATE TABLE hr.teszt(
szam NUMBER(6,2), -- 6 szamjegy, abbol 2 a tortresz
szoveg VARCHAR2(50) default 'teszt', -- valtozo hosszusagu karakterhossz, max. 50
datum DATE, -- vagy TIMESTAMP, ha pontosabb kell
-- default, unique, not null, check, pk: unique not null, fk
CONSTRAINT pk_teszt PRIMARY KEY (szam) -- erdemes igy csinalni, nem csak a szam-hoz odairni, hogy PRIMARY KEY
);

CREATE TABLE hr.teszt2(
szam NUMBER(6,2),
szam2 NUMBER(6,2), -- 6 szamjegy, abbol 2 a tortresz
szoveg VARCHAR2(50) default 'teszt', -- valtozo hosszusagu karakterhossz, max. 50
datum DATE UNIQUE,
datum2 DATE NOT NULL,
CONSTRAINT pk_teszt2 PRIMARY KEY (szam2), -- erdemes igy csinalni, nem csak a szam-hoz odairni, hogy PRIMARY KEY, mert akkor tudunk a nevere hivatkozni: pk_teszt2.nextval
CONSTRAINT fk_teszt FOREIGN KEY (szam) REFERENCES hr.teszt(szam)
);

CREATE TABLE hr.teszt3(
szam NUMBER(6,2),
szam2 NUMBER(6,2),
szoveg VARCHAR2(50) default 'teszt', -- valtozo hosszusagu karakterhossz, max. 50
datum DATE UNIQUE,
datum2 DATE NOT NULL,
CONSTRAINT chek_szam CHECK (szam > 1000), -- ennel nagyobbat tudunk csak beszurni
CONSTRAINT chk_szoveg CHECK (szoveg LIKE '%teszt%')
);

ALTER TABLE hr.teszt3
ADD (teszt NUMBER(5))
MODIFY (szoveg VARCHAR2(100))
DROP COLUMN datum
RENAME COLUMN datum2 TO datum;

-- INSERT /*append*/ -- ez egy hint :D

RENAME hr.teszt3 TO hr.teszt33;

CREATE INDEX ind_teszt
ON hr.teszt33 (szoveg);

CREATE SEQUENCE seq_teszt
MINVALUE 10
MAXVALUE 100
START WITH 10
INCREMENT BY 1
CACHE 30; -- default 20 lenne

SELECT seq_teszt.NEXTVAL FROM DUAL; -- mindig a kovetkezo erteket adja vissza
SELECT seq_teszt.CURRVAL FROM DUAL; -- jelenlegi ertek

CREATE TABLE hr.teszt4(
c1 NUMBER(4),
c2 VARCHAR2(30)
);
INSERT INTO hr.teszt4 (c1, c2) VALUES (
seq_teszt.NEXTVAL, 'teszt'
);
