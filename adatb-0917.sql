-- HR sema EMPLOYEES tablajanak lekerdezese:
SELECT * FROM HR.EMPLOYEES;

-- SELECT es FROM zaradekoknak Oracle SQL-ben mindenkeppen benne kell lenni (MSSQL-nel nem). "dual"-t lehet ilyenekre hasznalni, hogy szintaktikailag helyes legyen:
SELECT sysdate FROM dual;

-- alias (AS, de nem fontos kiirni) es konkatenacio (||):
SELECT employee_id AS azonosito, first_name||' '||last_name "Nev" FROM hr.employees;

-- projekcio
-- szelekcio: rekordok csokkentese

SELECT employees.*, 1+2 from hr.employees;

SELECT salary + (commission_pct * salary) AS "ossz. fizu", commision_pct FROM hr.employees;
-- (null)-t jo lenne itt 0-ra cserelni:
SELECT salary + (NVL(commission_pct,0) * salary) AS "ossz. fizu", commision_pct FROM hr.employees;

SELECT * FROM hr.employees
WHERE salary BETWEEN 8000 AND 15000;

-- WHERE utan nem lehet az aliast nevet hasznalni, ujra ki kell irni az egeszet
-- BETWEEN-nel a szelso ertekek is benne vannak; kacsacsoroket is lehet hasznalni, az egyertelmubb


-- Szovegre is lehet szurni, de case-sensitive:
SELECT * FROM hr.employees
WHERE job_id = 'IT_PROG';

-- Praktikus megoldas pl.:
SELECT * FROM hr.employees
WHERE UPPER(job_id) = UPPER('IT_prog');

-- Reszre kereses: _ -> egy karaktert helyettesit LIKE-nal; % -> barmennyit
SELECT * FROM hr.employees
WHERE LOWER(job_id) like LOWER('%pro%');
