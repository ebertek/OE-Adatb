-- CONNECT SYS AS SYSDBA
-- sema letrehozasa
DROP USER suli CASCADE;
DROP TABLESPACE suli_tbs
	INCLUDING CONTENTS AND DATAFILES
	CASCADE CONSTRAINTS;
DROP TABLESPACE suli_temp_tbs
	INCLUDING CONTENTS AND DATAFILES
	CASCADE CONSTRAINTS;
CREATE TABLESPACE suli_tbs
	DATAFILE 'suli_tbs.dat'
	SIZE 10M AUTOEXTEND ON;
CREATE TEMPORARY TABLESPACE suli_temp_tbs
	TEMPFILE 'suli_temp_tbs.dat'
	SIZE 5M AUTOEXTEND ON;

CREATE USER suli
	IDENTIFIED BY jelszo
	DEFAULT TABLESPACE suli_tbs
	TEMPORARY TABLESPACE suli_temp_tbs
	QUOTA 10M ON suli_tbs;
GRANT ALL PRIVILEGES TO suli;

-- korabbi tablak es szekvenciak torlese

DROP TABLE suli.Szamla PURGE;
DROP TABLE suli.Ora PURGE;
DROP TABLE suli.Tanar PURGE;
DROP TABLE suli.Diak PURGE;

DROP SEQUENCE suli.Diak_SEQ;
DROP SEQUENCE suli.Tanar_SEQ;
DROP SEQUENCE suli.Ora_SEQ;
DROP SEQUENCE suli.Szamla_SEQ;

-- pk-khoz hasznalt szekvenciak letrehozasa

CREATE SEQUENCE suli.Diak_SEQ
	MINVALUE 1
	MAXVALUE 1000
	START WITH 13
	INCREMENT BY 1
	CACHE 30;

CREATE SEQUENCE suli.Tanar_SEQ
	MINVALUE 1
	MAXVALUE 1000
	START WITH 12
	INCREMENT BY 1
	CACHE 30;

CREATE SEQUENCE suli.Ora_SEQ
	MINVALUE 1
	MAXVALUE 1000
	START WITH 24
	INCREMENT BY 1
	CACHE 30;

CREATE SEQUENCE suli.Szamla_SEQ
	MINVALUE 1
	MAXVALUE 1000
	START WITH 1
	INCREMENT BY 1
	CACHE 30;

-- 5/A: Tablak letrehozasa megszoritasokkal egyutt

CREATE TABLE suli.Diak(
	Diak_ID	NUMBER(20)	NOT NULL,
	VezetekNev	VARCHAR2(70)	NOT NULL,
	UtoNev	VARCHAR2(70)	NOT NULL,
	Cim	VARCHAR2(70),
	Telefonszam	VARCHAR2(25),
	Szintfelmero	VARCHAR2(3),
	Jelenlegi_szint	VARCHAR2(3),
	CONSTRAINT Diak_Telefonszam_CHK	CHECK (REGEXP_LIKE(Telefonszam,'^\+\d{6,}$')),
	CONSTRAINT Diak_Szintfelmero_CHK	CHECK (REGEXP_LIKE(Szintfelmero,'^[ABC][12][\+\-]*$')),
	CONSTRAINT Diak_Jelenlegi_szint_CHK	CHECK (REGEXP_LIKE(Jelenlegi_szint,'^[ABC][12][\+\-]*$')),
	CONSTRAINT Diak_PK	PRIMARY KEY (Diak_ID)
);

CREATE TABLE suli.Tanar(
	Tanar_ID	NUMBER(20)	NOT NULL,
	VezetekNev	VARCHAR2(70)	NOT NULL,
	UtoNev	VARCHAR2(70)	NOT NULL,
	Cim	VARCHAR2(70)	NOT NULL,
	Telefonszam	VARCHAR2(25),
	Adoszam	VARCHAR2(14)	NOT NULL,
	CONSTRAINT Tanar_Telefonszam_CHK	CHECK (REGEXP_LIKE(Telefonszam,'^\+\d{6,}$')),
	CONSTRAINT Tanar_Adoszam_UK	UNIQUE (Adoszam),
	CONSTRAINT Tanar_Adoszam_CHK	CHECK (REGEXP_LIKE(Adoszam,'^\d{8}-\d-\d{2}$|^\d{10}$|^[A-Z]{2}\w{8,12}$')),
	CONSTRAINT Tanar_PK	PRIMARY KEY (Tanar_ID)
);

CREATE TABLE suli.Ora(
	Ora_ID	NUMBER(20)	NOT NULL,
	Idopont	TIMESTAMP WITH TIME ZONE	NOT NULL,
	Szint	VARCHAR2(3)	NOT NULL,
	Tematika	VARCHAR2(255),
	Ar	NUMBER(6)	NOT NULL,
	Tanar_ID	NUMBER(20)	NOT NULL,
	CONSTRAINT Ora_Szint_CHK	CHECK (REGEXP_LIKE(Szint,'^[ABC][12][\+\-]*$')),
	CONSTRAINT Ora_PK	PRIMARY KEY (Ora_ID),
	CONSTRAINT Tanar_FK	FOREIGN KEY (Tanar_ID) REFERENCES suli.Tanar(Tanar_ID)
);

CREATE TABLE suli.Szamla(
	Szamla_ID	NUMBER(20)	NOT NULL,
	Kiallitas_ip	TIMESTAMP WITH TIME ZONE	NOT NULL,
	Fizetes_ip	TIMESTAMP WITH TIME ZONE,
	Diak_ID	NUMBER(20)	NOT NULL,
	Ora_ID	NUMBER(20)	NOT NULL,
	CONSTRAINT Szamla_PK	PRIMARY KEY (Szamla_ID),
	CONSTRAINT Diak_FK	FOREIGN KEY (Diak_ID) REFERENCES suli.Diak(Diak_ID),
	CONSTRAINT Ora_FK	FOREIGN KEY (Ora_ID) REFERENCES suli.Ora(Ora_ID)
);

-- 5/B: Tablak feltoltese adatokkal
-- A Diak es Tanar tablaknal a kezdeti adatoknal nem hasznaljuk a suli.xxx_SEQ.NEXTVAL-t, hogy az Ora es Szamla tablakat is biztosan jol tudjuk feltolteni

INSERT INTO suli.Diak
	VALUES(1,'Angol', 'András','1034 Budapest, Bécsi út 104-108. 1. szoba','+36302646526','A1','B1');
INSERT INTO suli.Diak
	VALUES(2,'Brit', 'Béla','1034 Budapest, Bécsi út 104-108. 2. szoba','+36302748235','B2+','C1');
INSERT INTO suli.Diak
	VALUES(3,'Cseh', 'Csilla','1034 Budapest, Bécsi út 104-108. 3. szoba','+36302734274','A1','A2');
INSERT INTO suli.Diak
	VALUES(4,'Dán', 'Dániel','1034 Budapest, Bécsi út 104-108. 4. szoba','+36303263264','A2','A2+');
INSERT INTO suli.Diak
	VALUES(5,'Észt', 'Eszter','1034 Budapest, Bécsi út 104-108. 5. szoba','+36303798379','B1','B1');
INSERT INTO suli.Diak
	VALUES(6,'Finn', 'Fruzsina','1034 Budapest, Bécsi út 104-108. 6. szoba','+36302646526','B2-','C1');
INSERT INTO suli.Diak
	VALUES(7,'Grúz', 'Gábor','1034 Budapest, Bécsi út 104-108. 7. szoba','+36304789422','B1','A2');
INSERT INTO suli.Diak
	VALUES(8,'Holland', 'Hedvig','1034 Budapest, Bécsi út 104-108. 8. szoba','+36304655263','B1+','B2');
INSERT INTO suli.Diak
	VALUES(9,'Izraeli', 'Ibolya','1034 Budapest, Bécsi út 104-108. 9. szoba','+36304972354','A1','A2');
INSERT INTO suli.Diak
	VALUES(10,'Jamaicai', 'János','1034 Budapest, Bécsi út 104-108. 10. szoba','+36305262422','B1-','C2');
INSERT INTO suli.Diak
	VALUES(11,'Kubai', 'Károly','7624 Pécs, Petőfi utca 8.','+36305822452','B2','B1');
INSERT INTO suli.Diak
	VALUES(12,'Lengyel', 'László','7636 Pécs, Kenderföld utca 11.','+36305364935','B2','B2');

INSERT INTO suli.Tanar
	VALUES(1,'Magyar', 'Melinda','7632 Pécs, Mezőszél utca 6.','+36306249276','HU12345678');
INSERT INTO suli.Tanar
	VALUES(2,'Norvég', 'Nándor','7632 Pécs, Maléter Pál út 40.','+36306678346','23456789-2-22');
INSERT INTO suli.Tanar
	VALUES(3,'Orosz', 'Olga','7633 Pécs, Endresz György utca 19.','+36306767965','34567890-2-42');
INSERT INTO suli.Tanar
	VALUES(4,'Portugál', 'Péter','7624 Pécs, Éva utca 15.','+36307678842','PT212345678');
INSERT INTO suli.Tanar
	VALUES(5,'Román', 'Réka','7636 Pécs, Polgárszőlő utca 28.','+36307662673','RO87654321');
INSERT INTO suli.Tanar
	VALUES(6,'Svéd', 'Sándor','7625 Pécs, István utca 38.','+36307833726','SE123456789101');
INSERT INTO suli.Tanar
	VALUES(7,'Török', 'Tamás','7635 Pécs, Körtés köz 8.','+36308676582','8123456789');
INSERT INTO suli.Tanar
	VALUES(8,'Ukrán', 'Ubul','1034 Budapest, Bécsi út 104-108. 11. szoba','+36308572682','45678901-2-13');
INSERT INTO suli.Tanar
	VALUES(9,'Vietnámi', 'Viktor','1034 Budapest, Bécsi út 104-108. 12. szoba','+36308438626','56789012-2-41');
INSERT INTO suli.Tanar
	VALUES(10,'Wakandai', 'Walter','1034 Budapest, Bécsi út 104-108. 13. szoba','+36309252632','67890123-2-41');
INSERT INTO suli.Tanar
	VALUES(11,'Zimbabwei', 'Zoltán','1034 Budapest, Bécsi út 104-108. 14. szoba','+36309462229','8234567890');

INSERT INTO suli.Ora
	VALUES(1,TIMESTAMP '2020-10-19 08:00:00 +2:00','A1','Szintfelmérő',1,1);
INSERT INTO suli.Ora
	VALUES(2,TIMESTAMP '2020-10-19 09:00:00 +2:00','A2','Kezdő angol',2000,2);
INSERT INTO suli.Ora
	VALUES(3,TIMESTAMP '2020-10-19 10:00:00 +2:00','B2','Középfokú nyelvvizsga-felkészítő',3500,3);
INSERT INTO suli.Ora
	VALUES(4,TIMESTAMP '2020-10-19 11:00:00 +2:00','C1','Haladó angol',4000,4);
INSERT INTO suli.Ora
	VALUES(5,TIMESTAMP '2020-10-19 12:00:00 +2:00','C1','Business English',4500,5);
INSERT INTO suli.Ora
	VALUES(6,TIMESTAMP '2020-10-19 13:00:00 +2:00','B2','Állásinterjú-felkészítő',3000,6);
INSERT INTO suli.Ora
	VALUES(7,TIMESTAMP '2020-10-19 14:00:00 +2:00','B2+','Nyelvtan felturbózó',3500,7);
INSERT INTO suli.Ora
	VALUES(8,TIMESTAMP '2020-10-19 15:00:00 +2:00','A2','Kötetlen csoportos beszélgetés',2000,8);
INSERT INTO suli.Ora
	VALUES(9,TIMESTAMP '2020-10-19 16:00:00 +2:00','C1','Haladó angol',4000,9);
INSERT INTO suli.Ora
	VALUES(10,TIMESTAMP '2020-10-20 08:00:00 +2:00','A1','Szintfelmérő',1,1);
INSERT INTO suli.Ora
	VALUES(11,TIMESTAMP '2020-10-20 09:00:00 +2:00','B1','Alapfokú angol',2500,2);
INSERT INTO suli.Ora
	VALUES(12,TIMESTAMP '2020-10-20 10:00:00 +2:00','C2','Business English',4500,3);
INSERT INTO suli.Ora
	VALUES(13,TIMESTAMP '2020-10-20 11:00:00 +2:00','C1','Felsőfokú nyelvvizsga-felkészítő',4500,4);
INSERT INTO suli.Ora
	VALUES(14,TIMESTAMP '2020-10-20 12:00:00 +2:00','B2','Igeidők (intenzív)',4000,5);
INSERT INTO suli.Ora
	VALUES(15,TIMESTAMP '2020-10-20 13:00:00 +2:00','A2+','Kezdő angol',2000,6);
INSERT INTO suli.Ora
	VALUES(16,TIMESTAMP '2020-10-20 14:00:00 +2:00','B1','Alapfokú angol',2500,7);
INSERT INTO suli.Ora
	VALUES(17,TIMESTAMP '2020-10-20 15:00:00 +2:00','B2','Középfokú nyelvvizsga-felkészítő',3500,8);
INSERT INTO suli.Ora
	VALUES(18,TIMESTAMP '2020-10-20 16:00:00 +2:00','B1','Alapfokú nyelvvizsga-felkészítő',3000,9);
INSERT INTO suli.Ora
	VALUES(19,TIMESTAMP '2020-10-26 08:00:00 +1:00','A1','Szintfelmérő',1,1);
INSERT INTO suli.Ora
	VALUES(20,TIMESTAMP '2020-11-17 18:00:00 +1:00','B1','Alapfokú társalgás',3000,8);
INSERT INTO suli.Ora
	VALUES(21,TIMESTAMP '2022-11-19 18:00:00 +1:00','B1','Alapfokú társalgás',3000,8);
INSERT INTO suli.Ora
	VALUES(22,TIMESTAMP '2038-02-12 12:00:00 +1:00','B1','Alapfokú nyelvtan',3000,2);
INSERT INTO suli.Ora
	VALUES(23,TIMESTAMP '2038-02-12 14:00:00 +1:00','B2','Középfokú nyelvtan',3500,2);

INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,1,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,2,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,3,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,4,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,5,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,6,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,7,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,8,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,9,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,10,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,11,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,12,1);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-26 09:00:00 +1:00',1,2);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-26 09:01:00 +1:00',2,2);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-27 09:12:00 +1:00',3,3);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-26 10:04:00 +1:00',4,3);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-26 11:21:00 +1:00',5,4);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-28 09:03:00 +1:00',6,4);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-27 14:37:00 +1:00',7,5);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-29 15:43:00 +1:00',8,5);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-28 16:20:00 +1:00',9,6);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-30 10:09:00 +1:00',10,6);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,11,7);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-29 12:44:00 +1:00',12,7);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',NULL,1,8);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-29 09:39:00 +1:00',2,8);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-27 13:26:00 +1:00',3,9);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-26 08:00:00 +1:00',TIMESTAMP '2020-10-26 16:19:00 +1:00',4,9);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,1,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,2,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,3,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,4,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,5,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,6,10);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-29 10:21:00 +1:00',12,11);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-27 13:29:00 +1:00',11,11);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-30 09:54:00 +1:00',10,12);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,9,12);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-28 13:13:00 +1:00',8,13);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,7,13);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-27 09:09:00 +1:00',6,13);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-27 10:10:00 +1:00',5,13);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-28 11:11:00 +1:00',4,14);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-29 12:12:00 +1:00',3,14);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,2,15);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,1,15);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-11-03 11:22:00 +1:00',12,16);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,11,16);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-10-28 14:32:00 +1:00',10,17);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,9,17);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',NULL,8,18);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-10-27 08:00:00 +1:00',TIMESTAMP '2020-11-02 10:06:00 +1:00',7,18);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,7,19);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,8,19);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,9,19);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,10,19);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,11,19);
INSERT INTO suli.Szamla
	VALUES(suli.Szamla_SEQ.NEXTVAL,TIMESTAMP '2020-11-02 08:00:00 +1:00',NULL,12,19);

-- 5/C: Tablak kilistazasa
SELECT * FROM suli.Diak;
SELECT * FROM suli.Tanar;
SELECT * FROM suli.Ora;
SELECT * FROM suli.Szamla;

-- 6/A: DQL, egyszeru lekerdezesek: WHERE, ORDER BY
-- 1: Kezdo szintu diakok nevei
SELECT VezetekNev||' '||UtoNev AS "Nev"
	FROM suli.Diak
	WHERE UPPER(Jelenlegi_szint) LIKE UPPER('A_%')
	ORDER BY VezetekNev ASC;
-- 2: Budapesti tanarok nevei es telefonszamai
SELECT VezetekNev||' '||UtoNev AS "Nev", Telefonszam
	FROM suli.Tanar
	WHERE LOWER(Cim) LIKE LOWER('%budapest%')
	ORDER BY VezetekNev ASC;
-- 3: Kozepszintu orak idopontjai, tematikaja es arai
SELECT Idopont, Tematika, Ar
	FROM suli.Ora
	WHERE UPPER(Szint) LIKE UPPER('B_%')
	ORDER BY Ar DESC;

-- 6/B: Csoportosito lekerdezesek: GROUP BY, HAVING
-- 1: Kulonbozo szinten levo diakok megszamlalasa, ezek kozul azon szintek kilistazasa, amin legalabb 2 diak van
SELECT Jelenlegi_szint, COUNT(Jelenlegi_szint) AS "Diakok szama"
	FROM suli.Diak
	GROUP BY Jelenlegi_szint
	HAVING COUNT(Jelenlegi_szint) >= 2
	ORDER BY Jelenlegi_szint DESC;
-- 2: A legolcsobb es legdragabb arak szintenkent csoportositva, ha nem ugyanannyiba kerul az osszes adott szintu ora
SELECT Szint, MIN(Ar), MAX(Ar)
	FROM suli.Ora
	GROUP BY Szint
	HAVING MIN(Ar) <> MAX(Ar)
	ORDER BY Szint ASC;
-- 3: A kulonbozo tanarok altal tartott orak arainak atlaga
SELECT Tanar_ID, AVG(Ar)
	FROM suli.Ora
	GROUP BY Tanar_ID
	HAVING AVG(Ar) > 1
	ORDER BY AVG(Ar) DESC;

-- 6/C: Tobbtablas lekerdezesek: INNER JOIN, OUTER JOIN
-- 1: A mar beerkezett penzekbol ki mennyit kap
SELECT suli.Tanar.VezetekNev||' '||suli.Tanar.UtoNev AS "Nev", SUM(suli.Ora.Ar)
	FROM suli.Szamla
	INNER JOIN suli.Ora ON(suli.Szamla.Ora_ID = suli.Ora.Ora_ID)
	INNER JOIN suli.Tanar ON(suli.Ora.Tanar_ID = suli.Tanar.Tanar_ID)
	WHERE suli.Szamla.Fizetes_ip IS NOT NULL
	GROUP BY suli.Ora.Tanar_ID, suli.Tanar.VezetekNev||' '||suli.Tanar.UtoNev
	ORDER BY SUM(suli.Ora.Ar) DESC;
-- 2: Kubai Karoly koronas lett, melyik orakon vett reszt?
SELECT suli.Tanar.VezetekNev||' '||suli.Tanar.UtoNev AS "Tanar neve", suli.Ora.Ora_ID, suli.Ora.Idopont
	FROM suli.Szamla
	JOIN suli.Ora ON(suli.Szamla.Ora_ID = suli.Ora.Ora_ID)
	JOIN suli.Tanar ON(suli.Ora.Tanar_ID = suli.Tanar.Tanar_ID)
	JOIN suli.Diak ON(suli.Szamla.Diak_ID = suli.Diak.Diak_ID)
	WHERE suli.Diak.Diak_ID = 11;
-- 3: A 2020. okt. 27. elott kiallitott, de nem kifizetett szamlakhoz tartozo nevek es osszegek
SELECT suli.Diak.VezetekNev||' '||suli.Diak.UtoNev AS "Tartozo neve", suli.Ora.Ar
	FROM suli.Szamla
	JOIN suli.Ora ON(suli.Szamla.Ora_ID = suli.Ora.Ora_ID)
	JOIN suli.Diak ON(suli.Szamla.Diak_ID = suli.Diak.Diak_ID)
	WHERE suli.Ora.Ar > 1
	AND suli.Szamla.Fizetes_ip IS NULL
	AND suli.szamla.Kiallitas_ip < TO_TIMESTAMP_TZ('2020-10-27 00:00:00 +1:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM')
	ORDER BY suli.Szamla.Kiallitas_ip ASC;

-- 6/D: Allekerdezesek: IN, ANY, ALL, EXISTS
-- 1: 6/C/2 alapjan: Kubai Karoly kikkel erintkezett, kiket kell felhivni?
SELECT DISTINCT suli.Diak.VezetekNev || ' ' || suli.Diak.UtoNev AS "Nev", suli.Diak.Telefonszam FROM suli.Diak JOIN suli.Szamla ON(suli.Szamla.Diak_ID = suli.Diak.Diak_ID)
	WHERE suli.Szamla.Ora_ID IN(SELECT suli.Ora.Ora_ID
		FROM suli.Szamla
		JOIN suli.Ora ON(suli.Szamla.Ora_ID = suli.Ora.Ora_ID)
		JOIN suli.Diak ON(suli.Szamla.Diak_ID = suli.Diak.Diak_ID)
		WHERE suli.Diak.Diak_ID = 11)
		ORDER BY "Nev";
-- 2: B1/B2 orak, amik a B1/B2 orak atlagaranal (3179 Ft) dragabbak
SELECT *
	FROM suli.Ora
	WHERE Ar > (SELECT ROUND(AVG(Ar)) FROM suli.Ora WHERE Szint LIKE 'B%')
	AND Szint LIKE 'B%'
	ORDER BY Ora_ID;
-- 3: Azok a C1/C2 orak, amik dragabbak, mint barmelyik (tehat az osszes) B1/B2 ora
SELECT *
	FROM suli.Ora
	WHERE Ar > ALL (SELECT Ar FROM suli.Ora WHERE Szint LIKE 'B%')
	AND Szint LIKE 'C%'
	ORDER BY Ora_ID;
-- 4: Azok a C1/C2 orak, amik nem dragabbak, mint barmelyik (tehat akar egy is) B1/B2 ora
SELECT *
	FROM suli.Ora
	WHERE Ar <= ANY (SELECT Ar FROM suli.Ora WHERE Szint LIKE 'B%')
	AND Szint LIKE 'C%'
	ORDER BY Ora_ID;

-- 6/E: Halmazoperatorok: UNION, INTERSECT, MINUS
-- 1: Osszes keresztnev kilistazasa
SELECT suli.Tanar.UtoNev FROM suli.Tanar
	UNION
	SELECT suli.Diak.UtoNev FROM suli.Diak;
-- 2: A mar kiszamlazott orak azonositoinak kilistazasa
SELECT suli.Ora.Ora_ID FROM suli.Ora
	INTERSECT
	SELECT suli.Szamla.Ora_ID FROM suli.Szamla
	ORDER BY Ora_ID DESC;
-- 3: Az orakat nem tarto tanarok kilistazasa
SELECT suli.Tanar.Tanar_ID FROM suli.Tanar
	MINUS
	SELECT suli.Ora.Tanar_ID FROM suli.Ora;

-- 6/F: Nezetek
-- 1: Jovobeli orak
CREATE OR REPLACE VIEW suli.Ora_V AS
	SELECT suli.Ora.Idopont, suli.Tanar.VezetekNev || ' ' || suli.Tanar.UtoNev AS "Nev", suli.Ora.Tematika FROM suli.Ora JOIN suli.Tanar ON(suli.Ora.Tanar_ID = suli.Tanar.Tanar_ID) WHERE suli.Ora.Idopont > CURRENT_TIMESTAMP;
SELECT * FROM suli.Ora_V;
-- 2: Diakok, akik meg nem fejlodtek
CREATE OR REPLACE VIEW suli.Diak_sni_V AS
	SELECT suli.Diak.VezetekNev || ' ' || suli.Diak.UtoNev AS "Nev" FROM suli.Diak WHERE suli.Diak.Szintfelmero = suli.Diak.Jelenlegi_szint;
SELECT * FROM suli.Diak_sni_V;
-- 3: Videki diakok
CREATE OR REPLACE VIEW suli.Diak_videk_V AS
	SELECT suli.Diak.VezetekNev || ' ' || suli.Diak.UtoNev AS "Nev" FROM suli.Diak WHERE LOWER(suli.Diak.Cim) NOT LIKE LOWER('%budapest%');
SELECT * FROM suli.Diak_videk_V;

-- 6/G: DDL
-- 1, 2, 3: Oszlop modositasa, uj oszlop beszurasa, uj megszoritas letrehozasa
ALTER TABLE suli.Diak
	MODIFY (Cim	VARCHAR2(80))
	ADD (Karanten	NUMBER(1)	DEFAULT 0	NOT NULL)
	ADD CONSTRAINT Diak_Karanten_CHK CHECK (REGEXP_LIKE(Karanten,'^[01]$'))
	ADD (Ingyenelo	NUMBER(1)	DEFAULT 0	NOT NULL)
	ADD CONSTRAINT Diak_Ingyenelo_CHK CHECK (REGEXP_LIKE(Ingyenelo,'^[01]$'));
ALTER TABLE suli.Tanar
	ADD (Cegnev VARCHAR2(70));
-- 4: Megszoritas torlese
ALTER TABLE suli.Tanar
	DROP CONSTRAINT Tanar_Adoszam_UK;
-- 5: Megszoritas kikapcsolasa
ALTER TABLE suli.Diak
	DISABLE CONSTRAINT Diak_Telefonszam_CHK;
-- 6: Oszlop torlese
ALTER TABLE suli.Diak
	DROP COLUMN Telefonszam;
-- 7: Oszlop atnevezese
ALTER TABLE suli.Diak
	RENAME COLUMN Cim TO Lakohely;
-- 8: Tabla atnevezese
-- RENAME Szamla TO Nyugta; jo lenne, ha a suli seman belul lennenk
ALTER TABLE suli.Szamla RENAME TO Nyugta;

-- 6/H: DML
-- 1: Ket diak karantenba kerult
UPDATE suli.Diak
	SET Karanten = 1
	WHERE Diak_ID = 11 OR Diak_ID = 12;
SELECT Diak_ID, Karanten FROM suli.Diak;
-- 2: A pecsi tanarok e.v. helyett ezentul cegkent szamlaznak
UPDATE suli.Tanar
	SET Cegnev = 'Pécsi Nyelvsuli Kft.', Adoszam = '22334455-2-02'
	WHERE LOWER(Cim) LIKE LOWER('%pécs%');
SELECT Tanar.VezetekNev||' '||Tanar.UtoNev AS "Nev", Cegnev, Adoszam FROM suli.Tanar;
-- 3: Diakok megjelolese, akik csak az ingyenes orakon vettek reszt
UPDATE suli.Diak
	SET Ingyenelo = 1
	WHERE suli.Diak.Diak_ID IN (SELECT suli.Nyugta.Diak_ID
		FROM suli.Nyugta
		JOIN suli.Ora ON(suli.Nyugta.Ora_ID = suli.Ora.Ora_ID)
		GROUP BY suli.Nyugta.Diak_ID
		HAVING Max(suli.Ora.Ar)='1');
SELECT Diak_ID, Ingyenelo from suli.Diak;
-- 4: A mar beerkezett fizetesek torlese az adatbazisbol, meg ne lassa a NAV
-- 6/I: TCL (tranzakciokezeles)
SAVEPOINT nav;
-- Ez direkt rossz:
DELETE FROM suli.Nyugta
	WHERE Fizetes_ip IS NULL;
ROLLBACK TO nav;
DELETE FROM suli.Nyugta
	WHERE Fizetes_ip IS NOT NULL;
COMMIT;
-- 5: Kubai Karoly sajnos meghalt, toroljunk ki rola mindent
DELETE FROM suli.Nyugta
	WHERE Diak_ID = 11;
DELETE FROM suli.Diak
	WHERE Diak_ID = 11;
-- 6: A budapesti tanarok is mind meghaltak 2020. nov. 14-en, a jovobeli oraik elmaradnak
DELETE FROM suli.Ora
	WHERE Tanar_ID IN (SELECT Tanar_ID
		FROM suli.Tanar
		WHERE LOWER(Cim) LIKE LOWER('%budapest%'))
		AND Idopont > TO_TIMESTAMP_TZ('2020-11-14 00:00:00 +1:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM');

-- 6/J: DCL: GRANT, REVOKE
-- 1: 2 szerepkor, benne 1-1 felhasznalo, 1-1 jogosultsaggal
DROP ROLE hresek;
DROP ROLE auditorok;
DROP USER Helga CASCADE;
DROP USER Agnes CASCADE;
CREATE ROLE hresek;
GRANT SELECT, INSERT, UPDATE, DELETE
	ON suli.Tanar
	TO hresek;
CREATE ROLE auditorok;
GRANT SELECT
	ON suli.Nyugta
	TO auditorok;
CREATE USER Helga IDENTIFIED BY kiruglak;
GRANT CREATE SESSION TO Helga;
GRANT hresek TO Helga;
CREATE USER Agnes IDENTIFIED BY bezarlak;
GRANT CREATE SESSION TO Agnes;
GRANT auditorok TO Agnes;
-- 2: Jogosultsagok hatasanak demonstralasa
CONNECT Helga/kiruglak;
SELECT Adoszam FROM suli.Tanar WHERE Tanar_ID = 1; -- lefut
SELECT * FROM suli.Nyugta; -- ORA-00942: table or view does not exist
DISCONNECT;
CONNECT Agnes/bezarlak;
SELECT Kiallitas_ip FROM suli.Nyugta WHERE Ora_ID = 1 AND Diak_ID = 1; -- lefut
UPDATE suli.Nyugta
	SET Ora_ID = 1; -- ORA-01031: insufficient privileges
DISCONNECT;
CONNECT Suli/jelszo;

-- 6/K: PL/SQL, 1 tablaszintu, 2 sorszintu trigger
SET SERVEROUTPUT ON;
-- 1: PL/SQL: Egesz eves tanfolyam beszurasa
DECLARE
	l_tol	NUMBER := 0; -- az INSERT-en beluli SELECT-ben levo i*7 miatt indulunk 0-rol
	l_ig	NUMBER := 51;
--	i_ora_id	suli.Ora.Ora_ID%type := 24; -- CURRVAL-t nem tudunk meg hasznalni, mert nem volt NEXTVAL erre a sequence-re hasznalva eddig
--	i_idopont	suli.Ora.Idopont%type := '2021-01-04 14:00:00 +1:00';
	i_szint	suli.Ora.Szint%type := 'B2';
	i_tematika	suli.Ora.Tematika%type := 'Középfokú rendszeres tanfolyam';
	i_ar	suli.Ora.Ar%type := 3000;
	i_tanar_id	suli.Ora.Tanar_ID%type := 2;
BEGIN
	FOR i IN l_tol..l_ig
	LOOP
		INSERT INTO suli.Ora(Ora_ID, Idopont, Szint, Tematika, Ar, Tanar_ID)
			VALUES(
				suli.Ora_SEQ.NEXTVAL,
				(SELECT TO_TIMESTAMP_TZ('2021-01-04 14:00:00 +1:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM') + NUMTODSINTERVAL(i*7, 'DAY') FROM dual),
				i_szint,
				i_tematika,
				i_ar,
				i_tanar_id
			);
	END LOOP;
END;
-- PL/SQL blokk lezarasa, hogy tudjuk folytatni sima SQL lekerdezesekkel:
/
SELECT * FROM suli.Ora WHERE Ora_ID > 23;
-- 2: Tablaszintu trigger, szol, ha az Ora tablaban valtozas tortenik
CREATE OR REPLACE TRIGGER Ora_BDIU_TRG
	BEFORE DELETE OR INSERT OR UPDATE ON suli.Ora
	BEGIN
		IF inserting THEN
			dbms_output.put_line('Beszuras tortent az Ora tablaba');
		END IF;
		IF updating THEN
			dbms_output.put_line('Modositas tortent az Ora tablaban');
		END IF;
		IF deleting THEN
			dbms_output.put_line('Torles tortent az Ora tablabol');
		END IF;
	END;
/
UPDATE suli.Ora SET Ar = Ar * 1.2;
ALTER TRIGGER Ora_BDIU_TRG DISABLE;
-- 3: Sorszintu trigger, kiirja, hogy mi lett az uj Ar
CREATE OR REPLACE TRIGGER Ora_BDIUR_TRG
	BEFORE DELETE OR INSERT OR UPDATE ON suli.Ora FOR EACH ROW
	BEGIN
		IF inserting THEN
			dbms_output.put_line('Beszuras tortent az Ora tablaba');
		END IF;
		IF updating THEN
			dbms_output.put_line('Modositas tortent az Ora tablaban: ' || :old.Ar || ' -> ' || :new.Ar);
		END IF;
		IF deleting THEN
			dbms_output.put_line('Torles tortent az Ora tablabol');
		END IF;
	END;
/
UPDATE suli.Ora SET Ar = Ar * 1.2;
ALTER TRIGGER Ora_BDIUR_TRG DISABLE;
-- 4: Sorszintu trigger, csak felteteles esetben tuzel (ha tul magas lesz egy Ar)
CREATE OR REPLACE TRIGGER Ora_BDIURW_TRG
	BEFORE DELETE OR INSERT OR UPDATE ON suli.Ora FOR EACH ROW WHEN (new.Ar > 6000)
	BEGIN
		IF inserting THEN
			dbms_output.put_line('Beszuras tortent az Ora tablaba');
		END IF;
		IF updating THEN
			dbms_output.put_line('Modositas tortent az Ora tablaban, tul magas Ar: ' || :old.Ar || ' -> ' || :new.Ar);
		END IF;
		IF deleting THEN
			dbms_output.put_line('Torles tortent az Ora tablabol');
		END IF;
	END;
/
UPDATE suli.Ora SET Ar = Ar * 1.12;
ALTER TRIGGER Ora_BDIURW_TRG DISABLE;
