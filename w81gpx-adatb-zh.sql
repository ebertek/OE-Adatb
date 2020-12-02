-- 1: sorszintu trigger
create table employees2 as select * from employees;

set serveroutput on;
create or replace trigger mennyien
before insert on employees2
for each row -- minden beszuras utan jelenjen meg az output
declare
ennyien number;
begin
select count(*) into ennyien from employees2 where department_id = :new.department_id;
ennyien := ennyien + 1; -- mert ez egy before trigger, mert after triggerben nem lehetne selectelni, hozzadjuk a most hozzaadando embert is a szamlalashoz
dbms_output.put_line(ennyien || ' dolgozo van az ujjal egyutt ebben a reszlegben.');
end;
/
insert into employees2
values (10,'utonev','vezeteknev','email','123.456.7890',sysdate,'it_prog',10000,0,100,90);

-- 2: tarolt eljaras
create or replace procedure menteszt (dolgozo_id number) is
menedzsere number;
vezetoe number;
begin
select count(*) into menedzsere from employees where manager_id = dolgozo_id;
select count(*) into vezetoe from departments where manager_id = dolgozo_id;
if menedzsere > 0 then
dbms_output.put_line(dolgozo_id || '. dolgozo ' || menedzsere || ' masik dolgozo menedzsere.');
else
dbms_output.put_line(dolgozo_id || '. dolgozo nem menedzsere egyik masik dolgozonak sem.');
end if;
if vezetoe > 0 then
dbms_output.put_line(dolgozo_id || '. dolgozo ' || vezetoe || ' reszleg vezetoje.');
else
dbms_output.put_line(dolgozo_id || '. dolgozo nem vezetoje egyik reszlegnek sem.');
end if;
end;
/
begin
menteszt(100);
menteszt(102);
menteszt(103);
menteszt(104);
end;
/

-- 3a: keresztnev elso betuje, hany dolgozonak kezdodik az adott betuvel
select substr(first_name, 1, 1) as kezdobetu, count(first_name) as darab from employees group by substr(first_name, 1, 1) order by kezdobetu;
-- 3b: nev es fizu, ahol job_history.end_date < 2016. jan. 1.
select employees.first_name||' '||employees.last_name as "Nev", employees.salary
from employees
inner join job_history on (job_history.employee_id = employees.employee_id)
where job_history.end_date < TO_TIMESTAMP_TZ('2006-01-01 00:00:00 +1:00', 'YYYY-MM-DD HH24:MI:SS TZH:TZM');
-- 3c: nev, munkakor atlagfizujanak es sajat fizunak kulonbsege
select e1.first_name||' '||e1.last_name as "Nev", (select e1.salary-round(avg(salary)) from employees e2 where e2.job_id = e1.job_id) as "Kulonbseg"
from employees e1;
-- 3d: 2. legtobbet kereso dolgozo neve
select first_name||' '||last_name as "Nev" from employees order by salary desc offset 1 rows fetch first 1 rows only;
