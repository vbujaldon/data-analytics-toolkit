USE `transactions`;

-- NIVELL 1 - EX2
-- Llistat dels països que estan generant vendes.
SELECT DISTINCT country AS llista_pais_amb_vendes
FROM transaction t
JOIN company c ON company_id = c.id
WHERE declined = 0
ORDER BY llista_pais_amb_vendes;

-- Des de quants països es generen les vendes.
SELECT COUNT(DISTINCT country) AS recompte_països_amb_vendes
 FROM transaction t
 JOIN company c ON company_id = c.id
 WHERE declined = 0
 ORDER BY recompte_països_amb_vendes;
 
 -- Identifica la companyia amb la mitjana més gran de vendes.
SELECT company_id AS codi_empresa, company_name AS nom_empresa, ROUND(AVG(amount),2) AS mitja_transaccions 
FROM transaction t JOIN company c ON company_id = c.id 
WHERE declined = 0
GROUP BY company_id 
ORDER BY mitja_transaccions DESC 
LIMIT 1;


-- NIVELL 1 - EX3 Utilitzant només subconsultes (no JOIN):
-- Mostra totes les transaccions realitzades per empreses d'Alemanya.
SELECT *
FROM transaction
WHERE company_id IN (
	SELECT c.id
    FROM company c
    WHERE country = 'Germany' AND declined = 0
); 

-- Llista les empreses que han realitzat transaccions per un amount superior a la mitjana de totes les transaccions.
SELECT company_id AS codi_empresa, ROUND(AVG(amount),2) AS mitja_transaccions_de_lempresa
FROM transaction t
GROUP BY codi_empresa
HAVING ROUND(AVG(amount),2) > 
	(
	SELECT ROUND(AVG(amount),2) AS mitjana_general 
    FROM transaction
	)
ORDER BY mitja_transaccions_de_lempresa DESC;

-- Empreses que no tenen transaccions registrades.
SELECT c.id AS codi_empresa
FROM company c
WHERE NOT EXISTS (
    SELECT company_id
    FROM transaction t
    WHERE company_id = c.id
);

/* la meva primera opció, però no em funciona aquest codi, hi deu haver nulls a company_id
SELECT c.id AS codi_empresa, company_name AS nom_empresa
FROM company c
WHERE c.id NOT IN (
	SELECT company_id
    FROM transaction
	); */

-- NIVELL 2 - EX1 
/* Identifica els cinc dies amb més ingressos per vendes. 
Mostra la data de cada transacció juntament amb el total de les vendes.*/

SELECT DATE(timestamp) AS data, SUM(amount) AS total_vendes
FROM transaction
WHERE declined = 0
GROUP BY DATE(timestamp)
ORDER BY total_vendes DESC
LIMIT 5;

-- NIVELL 2 - EX2 mitjana de vendes per país ordendes de major a menor mitjana.
SELECT country AS país, ROUND(AVG(amount),2) AS mitjana_vendes
FROM transaction t 
JOIN company c ON t.company_id = c.id
WHERE declined = 0 AND country IS NOT NULL
GROUP BY country
ORDER BY mitjana_vendes DESC;

-- NIVELL 2 - EX3 SUBQUERIES
/* llista de totes les transaccions realitzades per empreses
 que estan situades en el mateix país que aquesta companyia. */

-- a) JOIN + SUBUQERY
SELECT *
FROM transaction t
JOIN company c ON t.company_id = c.id
WHERE country = (
	SELECT country
	FROM company
	WHERE company_name LIKE '%Non Institute%'
    );

-- b) SUBQUERY    
SELECT 
	t.*,
	(SELECT c.id FROM company c WHERE c.id = t.company_id) AS company_id,
	(SELECT c.company_name FROM company c WHERE c.id = t.company_id) AS company_name,
	(SELECT c.phone FROM company c WHERE c.id = t.company_id) AS phone,
	(SELECT c.email FROM company c WHERE c.id = t.company_id) AS email,
    (SELECT c.country FROM company c WHERE c.id = t.company_id) AS country
FROM transaction t
WHERE company_id IN 
	(
	SELECT id
    FROM company
    WHERE country = 
		(
		SELECT country
		FROM company
		WHERE company_name LIKE '%Non Institute%'
        )
	);
  
-- NIVELL 3 - EX1 
/* Presenta el nom, telèfon, país, data i amount, d'aquelles 
empreses que van realitzar transaccions amb un valor comprès
 entre 350 i 400 euros i en alguna d'aquestes dates: 29 d'abril 
 del 2015, 20 de juliol del 2018 i 13 de març del 2024. 
Ordena els resultats de major a menor quantitat. */

SELECT company_name AS nom_empresa, phone AS telefon, country AS país, DATE(timestamp) AS data_transacció, amount AS import_transacció
FROM transaction t
JOIN company c ON company_id = c.id
WHERE amount BETWEEN 350 AND 400 AND DATE(timestamp) IN ('2015-04-29', '2018-07-20', '2024-03-13')
ORDER BY import_transacció DESC;

-- NIVELL 3 - EX2 llistat empreses amb més de 400 transaccions o menys
SELECT c.id, company_name AS nom_empresa, COUNT(amount) AS total_transaccions,
	CASE
		WHEN COUNT(amount) >= 400 THEN '400_O_MÉS'
        WHEN COUNT(amount) < 400 THEN 'INFERIOR_400'
        ELSE 'sense_info' -- per si és null
	END AS classificacio_segons_transaccions
FROM transaction t
JOIN company c ON company_id = c.id
GROUP BY c.id
ORDER BY total_transaccions DESC; -- no demanava pero per si volen contactar 1er les que fan + transaccions
