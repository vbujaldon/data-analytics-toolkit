-- SPRINT 4
-- Crear database `transactions_s4`
CREATE DATABASE IF NOT EXISTS `transactions_S4`;

-- Crear taula de fets 'transaction'
USE `transactions_S4`;
CREATE TABLE IF NOT EXISTS transaction (
	id VARCHAR(255),
    card_id VARCHAR(255),
    business_id VARCHAR(255),
    timestamp TIMESTAMP,
    amount decimal(10,2),
    declined tinyint DEFAULT 0,
    product_ids VARCHAR(255),
    user_id VARCHAR(255),
    lat FLOAT,
    longitude FLOAT,
    PRIMARY KEY (id)
    );

-- ABANS DEL LOAD DATA, REVISAR:
SHOW GLOBAL VARIABLES LIKE 'local_infile'; -- Està deshabilitat (OFF) el upload desde local, llavors:
SET GLOBAL local_infile = 1;
SHOW VARIABLES LIKE 'secure_file_priv';

-- Carregar registres des de CSV a taula 'transaction' amb LOAD (IMPORTANT semicolon_separated_values ";" )
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\transactions.csv'
	INTO TABLE `transaction` -- si no fas servir "USE `DB`" abans, seria nomDB.nomTaula
    FIELDS TERMINATED BY ';'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;
   

-- Crear taula de dimensions 'companies'
CREATE TABLE IF NOT EXISTS companies (
	company_id VARCHAR(255),
    company_name VARCHAR(100),
    phone VARCHAR(20),
    email VARCHAR(255),
    country VARCHAR(100),
    website VARCHAR(255),
    PRIMARY KEY (company_id)
    );

-- Carregar registres companies des de CSV
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\companies.csv'
    INTO TABLE companies
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS;

-- Crear taula de dimensions 'credit_cards'
CREATE TABLE IF NOT EXISTS credit_cards (
	id VARCHAR(255),
    user_id VARCHAR(255),
    iban VARCHAR(255),
    pan VARCHAR(100),
    pin VARCHAR(10),
    cvv VARCHAR(4),
    track1 VARCHAR(255),
    track2 VARCHAR(255),
    expiring_date DATE,
    PRIMARY KEY (id)
    );
    
-- Carregar registres credit_cards des de CSV
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\credit_cards.csv'
    INTO TABLE credit_cards
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id,user_id,iban,pan,pin,cvv,track1,track2,@expiring_date)
    SET expiring_date = str_to_date(@expiring_date, '%m/%d/%y'); -- variable d'usuari temporal q converteix dada
    
-- Crear taula de dimensions 'users'
CREATE TABLE IF NOT EXISTS users (
	id VARCHAR(255),
    name VARCHAR(255),
    surname VARCHAR(255),
    phone VARCHAR(255),
    email VARCHAR(255),
    birth_date DATE,
    continent VARCHAR(255), -- NEW
    country VARCHAR(255),
    city VARCHAR(255),
    postal_code VARCHAR(255),
    address VARCHAR(255),
    PRIMARY KEY (id)
    );
    
-- Carregar registres users des de CSV
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\\american_users.csv'
    INTO TABLE users
    FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
	SET 
		birth_date = str_to_date(@birth_date, '%b %d, %Y'),
		continent = 'AMERICA';
        
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\european_users.csv'
    INTO TABLE users
    FIELDS TERMINATED BY ','
	ENCLOSED BY '"'
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id,name,surname,phone,email,@birth_date,country,city,postal_code,address)
	SET 
		birth_date = str_to_date(@birth_date, '%b %d, %Y'),
		continent = 'EUROPA';


-- Crear taula de dimensions 'products'
CREATE TABLE IF NOT EXISTS products (
	id VARCHAR(255),
    product_name VARCHAR(255),
    price DECIMAL (10,2),
    colour VARCHAR(255),
    weight DECIMAL (10,2),
    warehouse_id VARCHAR(255),
	PRIMARY KEY (id)
);

-- Carregar registres 'products' des de CSV
LOAD DATA
	INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\products.csv'
    INTO TABLE products
    FIELDS TERMINATED BY ','
    LINES TERMINATED BY '\n'
    IGNORE 1 ROWS
    (id,product_name,@price,colour,weight,warehouse_id)
	SET price = REPLACE(@price, '$', ''); -- alternativa: netejar les dades prèviament

-- NOTA: Crearem taula pont i relacions products / transactions / transactions_products al nivell 3


-- CREAR CONSTRAINTS FOREIGN KEY 
ALTER TABLE transaction	
	ADD FOREIGN KEY (card_id) REFERENCES credit_cards(id),
    ADD FOREIGN KEY (business_id) REFERENCES companies(company_id),
    ADD FOREIGN KEY (user_id) REFERENCES users(id);

SELECT * FROM transaction;
SELECT * FROM companies;
SELECT * FROM credit_cards;
SELECT * FROM products;
SELECT * FROM users;

-- Nivell 1 EX 1: subconsulta usuaris > 80 transaccions (min. 2 taules)
SELECT id, name AS Nom, surname AS Cognom, email
FROM users
WHERE id IN (
	SELECT user_id
    FROM transaction 
    GROUP BY user_id
    HAVING COUNT(id) > 80 
    )
ORDER BY id;


-- Nivell 1 EX 2: mitjana d'amount per IBAN de les targetes de crèdit a la companyia Donec Ltd, (min. 2 taules)
SELECT c.company_id, iban, ROUND(AVG(amount),2) AS mitjana
FROM transaction t
INNER JOIN companies c ON business_id = c.company_id
INNER JOIN credit_cards cc ON cc.id = card_id
WHERE company_name LIKE ('%Donec Ltd%')
GROUP BY iban, c.company_id
ORDER BY mitjana DESC; -- per veure major gasto 1er


-- Nivell 2 EX 1: estat targetes

-- Crear taula
CREATE TABLE targetes_actives (
	card_id VARCHAR(255),
    Activitat_targeta VARCHAR(50)
    );
    
-- Fer filtre targetes per inserir registres a la taula.
INSERT INTO targetes_actives (card_id, Activitat_targeta)

-- ALTERNATIVA AMB FUNCIONS DE FINESTRA (row_number) I CTE
WITH ranking_targetes AS (SELECT
	card_id,
    id AS id_transacció,
    timestamp AS data_transacció,
    declined,
	ROW_NUMBER() OVER(PARTITION BY card_id ORDER BY timestamp DESC) AS ranking_estat_targetes
FROM transaction)

SELECT card_id, Activitat_targeta
FROM (
	SELECT
		card_id,
		CASE
			WHEN SUM(declined) = 3 THEN 'Targeta INACTIVA'
            ELSE 'Targeta ACTIVA'
			END AS 'Activitat_targeta'
	FROM (
		SELECT 
		card_id, 
		id_transacció,
		data_transacció,
		declined,
		ranking_estat_targetes
		FROM ranking_targetes
		WHERE ranking_estat_targetes <= 3
		) AS taula_ranking_3
	GROUP BY card_id
	ORDER BY card_id
    ) AS classificacio_activa_inactiva
WHERE Activitat_targeta = 'Targeta ACTIVA';

SELECT * FROM targetes_actives; -- comprovar inserció registres
SELECT count(Activitat_targeta) AS recompte_targetes_actives 
FROM targetes_actives; -- RESULTAT RECOMPTE AMB WITH+ROW_NUMBER()

-- ALTERNATIVA AMB SUBQUERIES (més lenta)

DROP TABLE targetes_actives;


CREATE TABLE targetes_actives (
	card_id VARCHAR(255),
    Activitat_targeta VARCHAR(50)
    );
   
   
INSERT INTO targetes_actives (card_id, Activitat_targeta)
SELECT *
FROM 
	(
	SELECT
		card_id,
		CASE
			WHEN SUM(declined) = 3 THEN 'Targeta INACTIVA'
			ELSE 'Targeta ACTIVA'
		END AS Activitat_targeta
	FROM 
		(
		SELECT
			t1.card_id, 
			t1.declined
		FROM transaction t1
		WHERE 
			(
			SELECT COUNT(*)
			FROM transaction t2
			WHERE t2.card_id = t1.card_id
				AND t2.timestamp > t1.timestamp -- per cada transaccio segons card_id recompta num trans amb data més recent
			) < 3 -- filtra 0, 1 o 2 registres més recents (top3)
		) AS 3_recents
	GROUP BY card_id
	ORDER BY card_id asc
    ) AS taula_targetes_actives_inactives
WHERE Activitat_targeta = 'Targeta ACTIVA';

SELECT * FROM targetes_actives; -- comprovar inserció registres
SELECT count(Activitat_targeta) AS recompte_targetes_actives FROM targetes_actives; -- RESULTAT RECOMPTE AMB SUBQUERIES



-- NIVELL 3
-- Crear taula intermitja 'transaction_product' amb id_compost dels dos (no serà columna)
CREATE TABLE IF NOT EXISTS transaction_product (
    transaction_id VARCHAR(255) NOT NULL,
    product_id VARCHAR(255) NOT NULL,
	price DECIMAL (10,2),
    unitats INT UNSIGNED,
    PRIMARY KEY (transaction_id, product_id),
    FOREIGN KEY (product_id) REFERENCES products(id),
    FOREIGN KEY (transaction_id) REFERENCES transaction(id)
	);
    
SELECT * FROM transaction_product;

-- Carrego els registres productes de la transaccio a la taula pont.
-- ALTERNATIVA 1
INSERT INTO transaction_product (transaction_id, product_id, price, unitats)
SELECT 
    t.id AS transaction_id,
    p.id AS product_id,
    p.price AS price,
    1 AS unitats -- si posem DEFAULT 1 al CREATE TABLE, ja no caldria
FROM transaction t
JOIN products p 
  ON FIND_IN_SET(p.id, REPLACE(t.product_ids, ' ', '')) > 0
WHERE t.declined = 0; 

select * from transaction_product;

  -- suma total d'unitats venudes agrupada per product_id
SELECT 
	product_id AS Ref_producte,
    SUM(unitats) AS total_unitats_venudes -- també ok COUNT(*) o COUNT(unitats) pq unitat = 1 per registre
FROM transaction_product
JOIN transaction ON transaction_id = id
WHERE declined = 0
GROUP BY Ref_producte
ORDER BY total_unitats_venudes; -- veure 1er els top vendes

DROP TABLE transaction_product;

-- ALTERNATIVA 2: FER SERVIR JSON_TABLE
INSERT INTO transaction_product (transaction_id, product_id, price, unitats)
SELECT 
    t.id AS transaction_id,
    jt.product_id,
    p.price AS price,
    1 AS unitats
FROM 
    transaction t,
    JSON_TABLE
	(
        CONCAT('["', REPLACE(REPLACE(t.product_ids, ' ', ''), ',', '","'), '"]'), -- no cal si tingués format ["73","21","43"]
        "$[*]" COLUMNS (product_id VARCHAR(255) PATH "$") 
    ) AS jt
JOIN products p ON p.id = jt.product_id
WHERE t.declined = 0;

-- el find_in_set es aprox. 1 segon més lent que JSON_tABLE