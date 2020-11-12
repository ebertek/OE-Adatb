-- ertek szerinti elagazas (case switch)
-- listazzuk ki a dolgozo nevet es fizeteset. ha a fizetese pont 9000, akkor legyen kiirva, hogy kilencezer:
SELECT first_name,
       CASE salary
         WHEN 9000 THEN 'kilencezer'
         WHEN 10000 THEN 'tizezer'
         ELSE TO_CHAR(salary) -- Mivel a 'kilencezer' es a 'tizezer' szoveg, a salary meg szam, at kell alakitani: TO_CHAR(salary)
       END Fizu
FROM hr.employees;


-- egyszeru elagazas:
SELECT first_name,
       CASE WHEN LENGTH(first_name) < 7 THEN
         'igen'
       ELSE
         'nem'
       END Rovideaneve
FROM hr.employees;


-- tobbtablas lekerdezesek – ebbol Descartes-szorzat lesz az osszes lehetseges variacioval:
SELECT first_name, last_name, department_name FROM hr.employees, hr.departments;

-- ha osszekotjuk department_id alapjan (de ez nem listazza ki azokat, akik egyik departmentben sem dolgoznak):
SELECT first_name, last_name, department_name
FROM hr.employees, hr.departments
WHERE hr.employees.department_id = hr.departments.department_id;

-- a WHERE nem olyan jo :(
-- osszekotes inkabb JOIN + USING hasznalataval, ha egyezo nevu oszlopok vannak:
SELECT first_name, last_name, department_name, department_id
FROM hr.employees JOIN hr.departments USING(department_id);

-- ha kulonbozo:
SELECT first_name, last_name, department_name, hr.employees.department_id
FROM hr.employees JOIN hr.departments ON(hr.employees.departmant_id = hr.departments.department_id);

-- alapbol JOIN = INNER JOIN. csak azok a rekordok jelennek meg, ahol egyezik a department_id, tehat akinel nincs department, az nem is jelenik meg.
-- LEFT JOIN = LEFT OUTER JOIN = reszben INNER JOIN, de a bal oldali tablabol azok az ertekek is latszodni fognak, ahol ahol a department_id (null)

-- rekordok, amiknek nincs parja a B oldalon:
SELECT first_name, last_name, department_name, hr.departments.department_id
FROM hr.employees LEFT JOIN hr.departments ON(hr.employees.departmant_id = hr.departments.department_id)
WHERE hr.employees.department_id IS null;

-- a kozos parok es a pluszban az egyik, ill. pluszban a masik tablaban levo rekordok:
-- FULL outer JOIN = left outer join + right outer join + inner joing

-- Oracle SQL-ben van egy ilyen rak is, hogy NATURAL inner JOIN:
SELECT first_name, last_name, department_name, department_id
FROM hr.employees NATURAL JOIN hr.departments;
-- Ez ebben az esetben pont elromlik, talan azert, mert van manager_id is mindket tablaban.

-- tobb tabla eseten is ugyanigy mukodik a dolog, ill. mindenfele koztes adatokat is fel tudunk hasznalni:
SELECT first_name, last_name, region_name
FROM hr.employees
INNER JOIN hr.departments ON(hr.employees.department_id = hr.departments.department_id)
INNER JOIN hr.locations ON(hr.departments.location_id = hr.locations.location_id)
INNER JOIN hr.countries ON(hr.locations.country_id = hr.countries.country_id)
INNER JOIN hr.regions ON(hr.countries.region_id = hr.regions.region_id)
WHERE hr.countries.country_id = 'CA';

-- reszlegvezetok listazasa (itt mindenkeppen ON van, nem USING):
SELECT first_name, last_name, department_name
FROM hr.employees
INNER JOIN hr.departments ON(hr.employees.employee_id = hr.departments.manager_id);

-- tabla osszekotese onmagaval – ilyenkor mindenkeppen aliasolni kell:
SELECT e1.first_name, e1.last_name, e2.first_name, e2.last_name
FROM hr.employees e1, hr.employees e2
WHERE e1.employee_id = e2.manager_id;

SELECT e1.first_name, e1.last_name, e2.first_name, e2.last_name
FROM hr.employees e1
INNER JOIN hr.employees e2 ON (e1.employee_id = e2.manager_id);


-- hierarchikus lekerdezesek
-- Oracle-be beepitett zaradekokkal van, amit konnyebben meg lehet oldani, mint JOIN-okkal, pl. START WITH es CONNECT BY (szulo-gyermek kapcsolat)
SELECT first_name, last_name, PRIOR first_name, PRIOR last_name, LEVEL, CONNECT_BY_ROOT last_name, SYS_CONNECT_BY_PATH(last_name, '/')
FROM hr.employees
-- WHERE level = 1
START WITH employee_id = 100
CONNECT BY PRIOR employee_id = manager_id
ORDER BY last_name ASC, salary DESC;

-- LEVEL kiirja, hogy hanyadik szinten van, CONNECT_BY_ROOT kiirja a gyokerhez tartozo erteket, SYS_CONNECT_BY_PATH pedig a teljes utvonalat.

-- rendezesek: ORDER BY
-- lehet aliasokat hasznalni (WHERE-nel ugye nem lehetett)
-- lehet sorszammal megadni, hogy hanyadik oszlop szerint
-- lehet a rendes neve szerint
-- ORDER SIBLINGS BY: azonos szinten levok jonnek egymas utan
