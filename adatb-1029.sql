create table oehr_departments2 as select * from oehr_departments;
create table oehr_employees2 as select * from oehr_employees;

alter table oehr_departments2 add constraint
	oehr_departments2_pk primary key(department_id);
alter table oehr_employees2 add constraint
	oehr_employees2_pk primary key(employee_id);
alter table oehr_employees2 add constraint
	oehr_employees2_fk foreign key(department_id) references oehr_departments2(department_id);

-- ezt nem engedi beszurni, mert "unique constraint violated":
insert into oehr_departments2 (department_name, department_id)
	values ('Proba', 10);
-- igy mar jo lesz:
insert into oehr_departments2 (department_id, department_name)
	values (55, 'Proba');

update oehr_departments2
	set manager_id = manager_id + 1, location_id = 2400
	where department_id = 55; -- itt lehet ugyanugy and/or/in, vagy akar egy ujabb selecttel egy allekerdezes

-- "integrity constraint violated" a foreign key miatt; addig nem lehet kitorolni, amig van employee a 10-es departmentben. kaszkadolt torlessel vagy az ilyen employee-k department_id-jenek NUL-ra allitasaval megoldhato lenne a torles.
delete from oehr_departments2
	where department_id = 10;
-- ez megy: :)
delete from oehr_departments2
	where department_id = 55;

-- nezetek: gyakorlatilag egy lekerdezest tudunk elmenteni
create view oehr_departments2_v as
	select * from oehr_departments2;
select * from oehr_departments2_v
	where department_id = 55; -- ugyanugy lehet szurni, mintha tabla lenne; mindig az aktualis adatokat adja vissza
-- show create view oehr_departments2_v;

-- itt nem kell droppolni, mint a tablaknal, hanem lehet ilyet csinalni:
create or replace view oehr_departments2_v3 as
	select * from oehr_departments2;

-- csoportosito lekerdezesek:
select max(salary) from oehr_employees2;
select min(salary) from oehr_employees2;
select sum(salary) from oehr_employees2;
select count(*) from oehr_employees2; -- a NUL ertekeket is beleszamolja!
select count(commission_pct) from oehr_employees2; -- igy mar nem :)
select round(avg(salary),2) from oehr_employees2;

-- csoportokat kepez department_id alapjan, szoval igy az osszes departmenten belul keresi meg a legnagyobb fizukat:
select max(salary), department_id from oehr_employees2 group by department_id;
-- mivel itt mar nem egyedek, hanem csoportok vannak, a SELECT utan csak csoportosito fuggvenyek vagy GROUP_BY utani oszlopnevek lehetnek

-- tobbtablas csoportosito lekerdezeseket is lehet, pl.:
select max(salary), department_name from oehr_employees2 inner join oehr_departments2 using(department_id) group by department_name;

-- egy lekerdezesben tobbfele csoportositas:
select max(salary), department_id, manager_id from oehr_employees2
	group by
	grouping sets ((department_id, manager_id), (department_id), ());

select max(salary), department_id, manager_id from oehr_employees2
	group by
	rollup (department_id, manager_id); -- eloszor az osszes alapjan, aztan az utolsot leveszi, aztan az azelottit is stb., vegul a teljes tabla

select max(salary), department_id, manager_id from oehr_employees2
	group by
	cube (department_id, manager_id); -- osszes kombi

select min(salary)
	from oehr_employees2
	where manager_id > 130
	group by department_id; -- igy mar csak a WHERE-rel leszurtek kerulnek be csoportokba

select min(salary)
	from oehr_employees2
	where manager_id > 130
	group by department_id
	having min(salary) > 7000
	order by 1;
