-- Allekerdezesek: belulrol kifele haladva. Amit a belso lekerdezesunk general adathalmazt, azt hasznalja fel a kulso lekerdezesunk.
SELECT first_name, salary, (SELECT sysdate FROM dual)
  FROM hr.employees;
-- Allekerdezesben a belso SELECT-ben csak egy darab oszlop allhat. Az alabbi "Too many values"-t fog dobni:
SELECT first_name, salary, (SELECT first_name, last_name FROM hr.employees)
  FROM hr.employees;
-- Egy erteket adhat vissza (maximum). Ez pl. 0-t fog, igy jo:
SELECT first_name, salary, (SELECT first_name FROM hr.employees WHERE 1=2)
  FROM hr.employees;
-- Kulso es belso lekerdezes osszekotese:
SELECT first_name, salary, (SELECT last_name FROM hr.employees WHERE e1.employee_id = employee_id)
  FROM hr.employees e1;

-- Sima csoportosito lekerdezes nem tudja megadni, hogy kihez tartozik az adott ertek:
SELECT department_id, max(salary)
  FROM hr.employees
  GROUP BY department_id;
-- Allekerdezessel megoldhato:
SELECT e1.department_id, last_name, fizu
  FROM hr.employees e1,
    (SELECT department_id, max(salary) fizu
      FROM hr.employees
      GROUP BY department_id) allek
  WHERE e1.department_id = allek.department_id
    AND e1.salary = allek.fizu;
-- Vagy JOIN-nal:
SELECT e1.department_id, last_name, fizu
  FROM hr.employees e1 INNER JOIN
    (SELECT department_id, max(salary) fizu
      FROM hr.employees
      GROUP BY department_id) allek
  ON(e1.department_id = allek.department_id AND e1.salary = allek.fizu);

-- Az atlagos fizu duplajanal kik keresnek tobbet?
SELECT *
  FROM hr.employees
  WHERE salary / 2 > (SELECT round(avg(salary)) FROM hr.employees);
-- Munkakori atlagnal nagyobb-e a fizuja?
SELECT *
  FROM hr.employees e1
  WHERE salary > (SELECT round(avg(salary)) FROM hr.employees WHERE job_id = e1.job_id);
-- Ha "IN" helyett "=" lenne, akkor "Too many values"
SELECT *
  FROM hr.employees
  WHERE salary IN (SELECT DISTINCT salary FROM hr.employees WHERE job_id = 'IT_PROG');
-- "IN" helyett "= ANY" is jo itt, de nem mindig:
SELECT *
  FROM hr.employees
  WHERE salary = ANY (SELECT DISTINCT salary FROM hr.employees WHERE job_id = 'IT_PROG');
-- ALL: mindegyikre igaznak kell lennie a feltetelnek. Pl. a legmagasabb fizuval akarjuk osszehasonlitani:
SELECT *
  FROM hr.employees
  WHERE salary > ALL (SELECT DISTINCT salary FROM hr.employees WHERE job_id = 'IT_PROG');

-- Halmazmuveletek: UNION, INTERSECT, MINUS
-- Unio:
SELECT first_name FROM hr.employees
  UNION
    SELECT first_name FROM hr.employees;
-- Ez a fenti azt adja vissza, amit ez is:
SELECT DISTINCT first_name FROM hr.employees;
-- Ez pedig nem szedi ki az ismetlodeseket:
SELECT first_name FROM hr.employees
  UNION ALL
    SELECT first_name FROM hr.employees;
-- Metszet: menedzserek, akik reszleget is vezetnek es beosztottjaik is vannak.
SELECT manager_id FROM hr.employees
  INTERSECT
    SELECT manager_id FROM hr.departments;
-- Akiknek van beosztottja, de nem vezet reszleget:
SELECT manager_id FROM hr.employees
  MINUS
    SELECT manager_id FROM hr.departments;

-- Elso ot erteket mutassa csak (ennel az esetnel pont nem jo, mert eloszor szuri, utana rendezi csak):
SELECT *
  FROM hr.employees
  WHERE rownum < 6
  ORDER BY first_name;
-- Allekerdezessel ez is megoldhato:
SELECT *
  FROM (SELECT * FROM hr.employees ORDER BY first_name)
  WHERE rownum <= 5;

-- ROWNUM helyett van FETCH es OFFSET Oracle-ben, ami nem rontja el:
SELECT *
  FROM hr.employees
  ORDER BY first_name
  FETCH FIRST 5 ROWS ONLY;
-- Pl. csak a 3.-tol mutassa:
SELECT *
  FROM hr.employees
  ORDER BY first_name
  OFFSET 3 rows;
-- Kombinalva:
SELECT *
  FROM hr.employees
  ORDER BY first_name
  OFFSET 3 ROWS FETCH NEXT 5 ROWS ONLY;
