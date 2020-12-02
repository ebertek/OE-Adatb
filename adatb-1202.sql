-- Minta_ZH_2
SET serveroutput ON;
CREATE OR REPLACE PROCEDURE tanulmanyi (kurzus INT) IS kurzusnev VARCHAR2(50);
  jegy NUMBER;
  elvegezte NUMBER;
BEGIN
  SELECT nev INTO kurzusnev FROM kurzusok WHERE kurzusID = kurzus; SELECT ROUND(AVG(erdemjegy),2) INTO jegy
    FROM leckekonyv WHERE kurzusID = kurzus;
  SELECT COUNT(kurzusID) INTO elvegezte
    FROM leckekonyv WHERE erdemjegy > 1 AND kurzusID = kurzus;
  IF kurzusnev IS NOT NULL THEN
    dbms_output.put_line('Kurzusnév: '||kurzusnev); dbms_output.put_line('Kurzus átlag: '||jegy); dbms_output.put_line('Elvégezte: '||elvegezte|| ' hallgató');
  ELSE
    dbms_output.put_line('Nincs ilyen kurzus.');
  END IF;
END;

begin
  tanulmanyi(11);
end;

CREATE OR REPLACE TRIGGER felvetel BEFORE INSERT ON leckekonyv FOR EACH ROW
DECLARE
  maxfo NUMBER(2);
  felvettek NUMBER(3);
  terem NUMBER;
BEGIN
SELECT kapacitas INTO maxfo FROM
  termek NATURAL JOIN kurzusok WHERE kurzusID = :new.kurzusID; SELECT COUNT(neptunID) INTO felvettek FROM
  leckekonyv WHERE kurzusID = :new.kurzusID;
SELECT teremID INTO terem FROM
  termek NATURAL JOIN kurzusok WHERE kurzusID = :new.kurzusID;
IF maxfo > felvettek THEN
  dbms_output.put_line('Sikeres tárgyfelvétel! Kapacitás felvétel előtt: '||maxfo||'/'||felvettek);
ELSE
  UPDATE termek SET kapacitas= kapacitas + 10
    WHERE teremID = terem;
  dbms_output.put_line('Sikeres tárgyfelvétel!
    Betelt a terem, de módosítottuk a férőhelyek számát.');
END IF; END;
SAVEPOINT mentes;
INSERT INTO leckekonyv
  VALUES (201, 'OEM5G1', 378, 68, NULL, NULL);
ROLLBACK TO mentes;

-- a)
SELECT h.neptunID, vnev||' '||knev Hallgató, összkredit
  FROM hallgatok h INNER JOIN (SELECT neptunID, SUM(kredit) összkredit FROM kurzusok INNER JOIN leckekonyv USING(kurzusID) WHERE erdemjegy > 1 GROUP BY neptunID) okr ON h.neptunID = okr.neptunID WHERE összkredit > (SELECT AVG(kredit) FROM kurzusok NATURAL JOIN leckekonyv WHERE erdemjegy > 1) ORDER BY összkredit;
-- b)
SELECT o.oktatoID, vnev||' '||knev Oktató FROM
  oktatok o INNER JOIN (SELECT oktatoID FROM oktatok MINUS SELECT oktatoID FROM leckekonyv) s ON o.oktatoID = s.oktatoID;
-- c)
SELECT vnev||' '||knev Oktató, (SELECT COUNT(neptunID) FROM leckekonyv WHERE oktatoID = o.oktatoID) Tanítványok FROM oktatok o WHERE fizetes = (SELECT MAX(fizetes) FROM oktatok);
-- d)
SELECT vnev||' '||knev Oktató, fizetes Fizetés, Tárgyak
  FROM oktatok NATURAL JOIN (SELECT oktatoID, COUNT(*) Tárgyak FROM leckekonyv GROUP BY oktatoID HAVING AVG(ertekeles) >= 3) FETCH FIRST 5 ROWS ONLY;
-- e)
SELECT h.neptunID Neptun, vnev||' '||knev Név, email Email, Tárgyak, Átlag, Kreditek FROM hallgatok h INNER JOIN (SELECT neptunID, COUNT(kurzusID) Tárgyak, ROUND(AVG(erdemjegy),2) Átlag, SUM(kredit) Kreditek FROM leckekonyv INNER JOIN kurzusok USING(kurzusID) WHERE erdemjegy > 1 GROUP BY neptunID) targy
  ON h.neptunID = targy.neptunID ORDER BY Név;
-- f)
UPDATE oktatok SET fizetes = fizetes * 1.15 WHERE fizetes < 200000;



-- estis
create table magasfizetes as select * from employees where 1 = 2; create or replace trigger feladat
after insert on employees
for each row
declare
atlag number;
begin
select avg(salary) into atlag from employees where department_id = :new.department_id;
dbms_output.put_line(atlag);
if (atlag < :new.salary) then
insert into magasfizetes (first_name, last_name, email, hire_date, manager_id, job_id, department_id, salary)
values
(:new.first_name, :new.last_name, :new.email, :new.hire_date, :new.manager_id, :new.job_id, :new.department_id, :new.salary);
end if; end;
insert into employees (first_name, last_name, salary, employee_id, email, hire_date, department_id, job_id)
values
('asd','dsa', 20000, 567,'asd@asd',sysdate,10, 'IT_PROG');
select * from employees;
select * from magasfizetes;



create or replace procedure feladat (varosnev varchar2) is osszfizetes number;
begin
dbms_output.put_line(varosnev);
select sum(salary) into osszfizetes from employees e inner join departments d
on (e.department_id=d.departmen_id) inner join locations l
on (d.location_id = l.location_id)
where upper(city) = upper(varosnev)
if osszfizetes is null then dbms_output.put_line('Nincs ilyen város'); else
dbms_output.put_line(osszfizetes);
end if;
end;
begin feladat('Seattle'); end;
begin feladat('Szeged'); end;



select country_name from countries
inner join locations on (countries.country_id = locations.country_id)
inner join departments on (locations.location_id = departments.location_id) group by country_name
having count(department_id) >=2

select last_name, job_title from employees inner join jobs
where salary in (select max_salary from jobs)

select e.employee_id, e.salary, beosztottak, job_title
from employees e inner join jobs
using (job_id) inner join
(select manager_id, count(*) beosztottak
from employees
group by manager_id) f
on e.employee_id=f.manager_id

SELECT * FROM locations
ORDER BY location_id DESC
FETCH FIRST 4 ROWS ONLY;
