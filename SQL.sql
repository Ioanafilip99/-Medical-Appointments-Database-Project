-- INTEROGARI

SELECT * FROM DEPARTAMENTE_IFI;
SELECT * FROM MEDICI_IFI;
SELECT * FROM SERVICII_IFI;
SELECT * FROM PACIENTI_IFI;
SELECT * FROM RETETE_IFI;
SELECT * FROM PROGRAMARI_IFI;

-- 1. Sa se afiseze medicul/medicii cu numarul maxim de programari.
SELECT id_medic AS "Id", nume || ' ' || prenume AS "Nume", COUNT(id_programare) AS "Nr programari"
FROM medici_ifi
JOIN programari_ifi USING(id_medic)
GROUP BY id_medic, nume, prenume
HAVING COUNT(id_programare) = (SELECT MAX(COUNT(id_programare))
                               FROM programari_ifi
                               GROUP BY id_medic, nume, prenume);


-- 2. Sa se afiseze medicii, numele departamentelor din care fac parte si nr total de pacienti; ordonati descrescator dupa nr de pacienti.                       
SELECT m.id_medic AS "Id", m.nume || ' ' || m.prenume AS "Nume", d.nume AS "Departament", COUNT(pa.cnp) AS "Nr pacienti"
FROM medici_ifi m
JOIN programari_ifi p ON(m.id_medic = p.id_medic)
JOIN pacienti_ifi pa ON(p.cnp_pacient = pa.cnp)
JOIN departamente_ifi d ON(m.id_departament = d.id_departament)
GROUP BY m.id_medic, m.nume, m.prenume, d.nume
ORDER BY 4 DESC;


-- 3. Sa se afiseze media preturilor serviciilor pentru fiecare departament.
SELECT d.id_departament, d.nume, AVG(s.pret) AS "Media preturilor"
FROM departamente_ifi d
JOIN servicii_ifi s ON(s.id_departament = d.id_departament)
GROUP BY d.id_departament, d.nume;

--4. De cate luni nu a mai avut o programare pacientul cu numele Stanciu
SELECT MIN(ROUND(MONTHS_BETWEEN(SYSDATE, pr.data))) AS "Nr luni"
FROM programari_ifi pr
JOIN pacienti_ifi pa ON(pr.cnp_pacient = pa.cnp)
WHERE UPPER(pa.nume) LIKE 'STANCIU';

-- 5.Sa se afiseze serviciile cu preturi cuprinse intre 150 si 500 
-- sau serviciile care au fost oferite pacientilor a caror nume incep cu 'F'
SELECT s1.id_serviciu, s1.denumire, s1.descriere, s1.pret
FROM servicii_ifi s1
WHERE s1.pret BETWEEN 150 AND 500
UNION
SELECT s2.id_serviciu, s2.denumire, s2.descriere, s2.pret
FROM servicii_ifi s2
JOIN programari_ifi pr ON(pr.id_serviciu = s2.id_serviciu)
JOIN pacienti_ifi pa ON(pa.cnp = pr.cnp_pacient)
WHERE UPPER(pa.nume) LIKE 'L%';

-- 6. Sa se afiseze pacientii care au fost tratati de cel putin aceiasi medici 
--care l-au tratat pe pacientul cu cnp-ul '2222222222222'; excludeti-l pe acesta.
SELECT DISTINCT cnp, nume
FROM pacienti_ifi pa
WHERE NOT EXISTS(SELECT 1
                 FROM programari_ifi pr1
                 WHERE pr1.cnp_pacient LIKE '2222222222222' AND
                 NOT EXISTS(SELECT 2
                            FROM programari_ifi pr2
                            WHERE pr2.cnp_pacient = pa.cnp
                            AND pr2.id_medic = pr1.id_medic))
AND cnp <> '2222222222222';

-- 7. Sa se afiseze numele si adresele de email ale medicilior. Daca un medic nu are adresa de email, sa se scrie "Fara email".
SELECT nume || ' ' || prenume AS "Nume", NVL(TO_CHAR(email), 'Fara email') AS "Email"
FROM medici_ifi;

-- 8. Sa se listeze numarul total de pacienti si numarul de pacienti ai fiecarui medic.
-- Numiti coloanele astfel: Nr total, Nr id_medic (unde id_medic va lua id-ul fiecarui medic).
SELECT COUNT(cnp_pacient) AS "Nr total", SUM(DECODE(id_medic, 100, 1, 0)) AS "Nr 100",
                                         SUM(DECODE(id_medic, 101, 1, 0)) AS "Nr 101",
                                         SUM(DECODE(id_medic, 102, 1, 0)) AS "Nr 102",
                                         SUM(DECODE(id_medic, 103, 1, 0)) AS "Nr 103",
                                         SUM(DECODE(id_medic, 104, 1, 0)) AS "Nr 104"
FROM programari_ifi;

-- 9. Sa se afiseze lista pacientilor care au avut programari preluate doar de medicul cu id-ul 100
SELECT DISTINCT pr.cnp_pacient AS "CNP", pa.nume || ' ' || pa.prenume AS "Nume" 
FROM programari_ifi pr
JOIN pacienti_ifi pa ON(pr.cnp_pacient = pa.cnp)
WHERE NOT EXISTS (SELECT id_medic
                  FROM programari_ifi pr1
                  WHERE pr.cnp_pacient = pr1.cnp_pacient
                  MINUS
                  SELECT id_medic
                  FROM programari_ifi pr2
                  WHERE id_medic = 100);


-- 10. Sa se listeze informatii despre retetele pacientilor care au avut cel putin 3 programari.
SELECT r.id_reteta AS "Id", r.data AS "Data", r.cnp_pacient AS "CNP", pa.nume || ' ' || pa.prenume AS "Pacient"
FROM retete_ifi r
JOIN pacienti_ifi pa ON(r.cnp_pacient = pa.cnp)
WHERE r.cnp_pacient IN (SELECT cnp_pacient
                        FROM programari_ifi
                        GROUP BY cnp_pacient
                        HAVING COUNT(id_programare) >= 3);

-- 11. Sa se afle de catre care departament a fost preluat pacientul a caru reteta are id-ul 109
SELECT r.id_reteta, pa.cnp, pr.id_medic, m.id_medic, m.id_departament, d.nume    
FROM departamente_ifi d
JOIN medici_ifi m ON(m.id_departament = d.id_departament)
JOIN programari_ifi pr ON(pr.id_medic = m.id_medic)
JOIN pacienti_ifi pa ON(pa.cnp = pr.cnp_pacient)
JOIN retete_ifi r ON(r.cnp_pacient = pa.cnp)
WHERE r.id_reteta = 109 AND r.data = pr.data;


-- 12. Sa se afiseze numele si prenumele medicilor, numele si preumele pacientilor care au avut programari in luni impare ale anului.
--De asemenea sa se afiseze si id-ul si data programarii
SELECT m.nume || ' ' || m.prenume AS "Nume Medic",  pa.nume || ' ' || pa.prenume AS "Nume Pacient", 
       pr.id_programare AS "Id", TO_CHAR(pr.data, 'month') AS "Luna"
FROM medici_ifi m
JOIN programari_ifi pr ON(pr.id_medic = m.id_medic)
JOIN pacienti_ifi pa ON(pa.cnp = pr.cnp_pacient)
WHERE MOD(EXTRACT(MONTH FROM pr.data),2) = 1;

-- 13. Sa se afiseze id-ul programarilor a caror data e in acelasi an in care au avut programare cei mai multi pacienti.
SELECT id_programare AS "Id", TO_CHAR(data, 'YYYY') AS "An"
FROM programari_ifi 
WHERE TO_CHAR(data, 'YYYY') = (SELECT TO_CHAR(data, 'YYYY')
                               FROM programari_ifi
                               GROUP BY TO_CHAR(data, 'YYYY')
                               HAVING COUNT(id_programare) = (SELECT MAX(COUNT(id_programare))
                                                              FROM programari_ifi
                                                              GROUP BY TO_CHAR(data, 'YYYY')));

-- 14. Sa se afiseze inforrmatii despre medici in formatul urmator: "Medicul <nume prenume> face parte din departamentul <nume>
-- si a avut <nr programari> programari"                                                             
SELECT 'Medicul ' || m.nume || ' ' || m.prenume || ' face parte din departamentul ' || d.nume ||
        ' si a avut nr de programari ' || CASE WHEN nr > 0 THEN nr
                                          ELSE 0
                                          END
FROM medici_ifi m
JOIN departamente_ifi d ON(d.id_departament = m.id_departament)
LEFT JOIN (SELECT id_medic, COUNT(id_programare) nr
           FROM programari_ifi
           GROUP BY id_medic) aux ON(m.id_medic = aux.id_medic);

-- 15. Sa se afiseze numele, prenumele si lungimea numelui pacientilor, unde lungimea numelui este diferita de cea a prenumelui
SELECT pa.nume || ' ' || pa.prenume AS "Nume", LENGTH(pa.nume) AS "Lungime nume"
FROM pacienti_ifi pa
WHERE NULLIF(LENGTH(pa.nume), LENGTH(pa.prenume)) IS NOT NULL;

-- 16. Sa se realizeze un script prin care sa se afiseze id-ul programarii si ora pentru programarile a caror ora 
-- este intre 2 ore introduse de utilizator
ACCEPT p_ora1 PROMPT 'ora de inceput(de forma 'HH:MM') '
ACCEPT p_ora2 PROMPT 'ora de sfarsit(de forma 'HH:MM') '
SELECT id_programare, ora
FROM programari_ifi
WHERE ora BETWEEN &p_ora1 AND &p_ora2;


