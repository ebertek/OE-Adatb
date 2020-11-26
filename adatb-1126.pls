-- PL/SQL gyakorlat

set SERVEROUTPUT ON; -- sessiononkent 1x szukseges es elegseges lefuttatni

accept asd 'Kerek egy szamot'; -- ertek bekerese juzertol
-- valtozokat kulon reszben tudunk deklaralni es inicializalni:
declare
  szam number := 10;

begin
  szam := &valami; -- ertek bekerese juzertol
  dbms_output.put_line('Hello vilag szam: ' || szam * 2);
  dbms_output.put_line('Hello vilag asd: ' || &asd * 2);
end;

-- elagazasok:
declare
  szam number;
begin
  szam := &asdasd;
  if szam > 10 then
    dbms_output.put_line('nagyobb');
    else -- "else if" helyett pedig elsif van
    dbms_output.put_line('nem nagyobb');
  end if;
end;

-- ciklusok:
declare
  tol number :=  1;
   ig number := 10;
begin
  loop
    dbms_output.put_line(tol);
    tol := tol + 1;
    exit when tol = ig; -- ezt rakhatjuk mashova is, es akkor lehet elol/kozepen/hatultesztelos ciklus
  end loop;
end;

-- for ciklus:
declare
  tol number :=  1;
   ig number := 10;
begin
  for i in tol..ig
  loop
    dbms_output.put_line(i);
  end loop;
end;

-- egyszeru lekerdezesek:
declare
  maxfizu number; -- ebben taroljuk majd el
  minfizu number;
begin
  SELECT MAX(salary), MIN(salary) INTO maxfizu, minfizu FROM hr.employees;
  dbms_output.put_line(maxfizu);
  dbms_output.put_line(minfizu);
end;

-- adat bekerese felhasznalotol:
declare
  maxfizu number;
begin
  SELECT MAX(salary) INTO maxfizu FROM hr.employees WHERE job_id = '&asdasd';
  dbms_output.put_line(maxfizu);
end;

-- implicit kurzor:
declare
  egysor hr.employees%ROWTYPE;
begin
  for egysor in (select * from hr.employees)
  loop
    dbms_output.put_line(egysor.first_name);
  end loop;
end;

-- explicit kurzor:
declare
  cursor k is select * from hr.employees;
  egysor hr.employees%ROWTYPE;
begin
  for egysor in k
  loop
    dbms_output.put_line(egysor.first_name);
  end loop;
end;

-- pelda modositasra:
create table hr.employees2 as select * from hr.employees;

declare
  cursor k is select * from hr.employees2 for update of salary; -- vagy siman csak "for update"
  egysor hr.employees%ROWTYPE;
begin
  for egysor in k
  loop
    if egysor.job_id = 'AD_VP' then
      update hr.employees2 set salary = salary * 1.1 where current of k; -- ez a "where current of [cursor]" fontos, hogy csak az eppen aktualis rekord legyen update-elve
    end if;
  end loop;
end;

-- tarolt eljarasok (nincs visszateresi erteke):
create or replace procedure TaroltTeszt(szam number) is
lokszam number := 10; -- lokalis valtozo
begin
  dbms_output.put_line(szam * lokszam);
end;

execute TaroltTeszt(3);

-- tarolt fuggvenyek (van visszateresi erteke):
create or replace function TaroltFV(szam number) return number is
  asdasd number;
begin
  asdasd := szam * 2;
  return asdasd * 2;
end;

select TaroltFV(10) from dual;

-- vagy legalabbis valamit kezdeni kell a visszateresi ertekkel:
declare
  szam number;
begin
  szam := TaroltFV(10);
end;

-- az "or replace" akkor mukodik, ha ugyanolyan tipusu objektumrol van szo, tehat pl. procedure-t function nem fog igy sem felulirni

-- TRIGGEREK: esemeny elott, utan vagy helyett fut le
-- jo pl. logolasra, beszuras elotti komplexebb ellenorzesre (amit megszoritassal nem, vagy bonyolultan lehetne megvalositani)
create or replace trigger TesztTrig
before delete or insert or update on hr.employees2 -- "before" helyett lehet "after", "intead of"
begin
  if inserting then
    dbms_output.put_line('beszuras');
  end_if;
  if updating then
    dbms_output.put_line('modositas');
  end_if;
  if deleting then
    dbms_output.put_line('torles');
  end_if;
end;

update hr.employees2 set salary = salary * 1.1 where 1=2; -- ezt lefuttatva tuzelni fog a triggerunk is

-- sorszintu trigger (az elozo tablaszintu volt, 1=2 eseten is lefutott 1x, 1=1 eseten hiaba van sok rekord, akkor is csak 1x):
create or replace trigger TesztTrig
before delete or insert or update on hr.employees2 for each row
begin
  if inserting then
    dbms_output.put_line('beszuras');
  end_if;
  if updating then
    dbms_output.put_line('modositas');
  end_if;
  if deleting then
    dbms_output.put_line('torles');
  end_if;
end;

-- sorszintu triggereknel NEW es OLD kifejezeseket is lehet hasznalni:
create or replace trigger TesztTrig
before delete or insert or update on hr.employees2 for each row
begin
  if inserting then
    dbms_output.put_line('beszuras'); -- old null
  end_if;
  if updating then
    dbms_output.put_line('modositas: ' || :old.salary || ' -> ' || :new.salary);
  end_if;
  if deleting then
    dbms_output.put_line('torles'); -- new null
  end_if;
end;

-- sorszintu triggereknel feltetel megadasa a trigger tuzelesehez:
create or replace trigger TesztTrig
before delete or insert or update on hr.employees2 for each row when (new.salary > 16000)
begin
  if inserting then
    dbms_output.put_line('beszuras');
  end_if;
  if updating then
    dbms_output.put_line('modositas: ' || :old.salary || ' -> ' || :new.salary);
  end_if;
  if deleting then
    dbms_output.put_line('torles');
  end_if;
end;
