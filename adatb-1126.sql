-- Jogosultsagkezeles
-- SYS-re valtsunk at SQL Developerben, vagy SQL*PLUS Terminalban felhasznalo nev: conn as sysdba

-- uj juzer letrehozasa:
create user teszt
  identified by teszt;

-- SQL Developerben ezutan tudunk egy uj connectiont csinalni, SID: orcl
-- CREATE SESSION privilegiuma nincs a juzernek, ugyhogy ehhez kell adni neki ilyet:
grant create session to teszt;

grant create table to teszt;
create table asd(asdasd number);
revoke create table from teszt;

-- ha a juzert kitoroljuk, akkor a hozza kapcsolodo objektumok is kitorlodnek!

-- tobb juzer kezelese egysegben: szerepek
create role szerep;
grant szerep to teszt;
grant create view to szerep;
create or replace view nezet as select * from teszt; -- valamiert ez nem megy :D ha Terminalban csinaljuk: grant szerep to teszt; conn teszt/teszt; create view …; akkor jo

-- Mentesi pontok hasznalata. Hasznos pl., ha azt szeretnenk, hogy vagy az osszes muveletunk hajtodjon vegre, vagy egyik sem.
savepoint sp1;
update hr.employees2 set salary = 1;
select * from hr.employees2; -- mindenkinek 1 a fizetese
rollback to sp1; -- savepoint-kori allapot visszaallitasa
commit; -- veglegesites
-- DDL utasitasok (pl. truncate) nem vonhatoak vissza; DML (pl. delete) igen
