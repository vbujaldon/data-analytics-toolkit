USE `transactions`;

-- SPRINT  - NIVELL 1
-- 1.1 EXERCICI 1 CREAR TAULA CREDIT CARD
CREATE TABLE IF NOT EXISTS credit_card (
        `id` VARCHAR(15) NOT NULL,
        `iban` VARCHAR(255) DEFAULT NULL, 
        `pan` VARCHAR(255) DEFAULT NULL, 
        `pin` INT DEFAULT NULL, 
        `cvv` INT DEFAULT NULL, 
        `expiring_date` VARCHAR (10) DEFAULT NULL, 
			/* si poso DATE no coincideix yyyy-mm-dd amb els registres mm-dd-yy.
            Es pot transformar després amb amb str_to_date()*/
        PRIMARY KEY (id)
    );

-- OBRIM datos_introducir_sprint3_credit.sql i executem

-- AFEGIM CONSTRAINT FOREIGN KEY    
ALTER TABLE transaction
	ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);




-- 1.2 EXERCICI 2: modificar registre a credit_card

UPDATE credit_card
SET iban = 'TR323456312213576817699999'
WHERE id LIKE 'CcU_2938';
-- hauria de ser WHERE id = 'CcU_2938'; pero no funciona amb = (comentat Alana)

SELECT * FROM credit_card WHERE id = 'CcU-2938';



-- NIVELL 1 EXERCICI 3: afegir registre a transaction
-- 1er creo el registre a les altres taules: a) company amb ID=b-9999'
INSERT INTO company (id)
VALUES ('b-9999');

-- b) Creo el registre a credit_card amb ID='CcU-9999'
INSERT INTO credit_card (id)
VALUES ('CcU-9999');

-- Creo registre demanat a transaction:
INSERT INTO transaction (id, credit_card_id, company_id, user_id, lat, longitude, amount, declined)
VALUES ('108B1D1D-5B23-A76C-55EF-C568E49A99DD', 'CcU-9999', 'b-9999',  9999, 829.999, -117.999, 111.11, 0);

  
  
  
-- NIVELL 1 EXERCICI 4: eliminar columna pan taula credit_card 
ALTER TABLE credit_card
DROP COLUMN pan;

SELECT * FROM credit_card; -- per comprovar q pan eliminada




-- NIVELL 2 - EXERCICI 1 eliminar registre a transaction
DELETE FROM transaction
WHERE id = '000447FE-B650-4DCF-85DE-C7ED0EE1CAAD';




-- NIVELL 2 - EXERCICI 2 crear vista
CREATE VIEW VistaMarketing AS
SELECT c.company_name AS nom_empresa, c.phone AS telf,
       c.country AS país, AVG(t.amount) AS mitja_empresa
FROM company c
JOIN transaction t ON c.id=t.company_id
GROUP BY c.id
ORDER BY mitja_empresa DESC;

SELECT * FROM VistaMarketing;




-- NIVELL 2 - EXERCICI 3 filtrar vista
SELECT * 
FROM VistaMarketing
WHERE país = 'Germany';




-- NIVELL 3 - EXERCICI 1 taula user

-- Crear taula user
CREATE TABLE IF NOT EXISTS user (
	id CHAR(10) PRIMARY KEY,
	name VARCHAR(100),
	surname VARCHAR(100) DEFAULT NULL,
	phone VARCHAR(150) DEFAULT NULL,
	email VARCHAR(150) DEFAULT NULL,
    birth_date VARCHAR(100) DEFAULT NULL,
	country VARCHAR(150) DEFAULT NULL,
	city VARCHAR(150) DEFAULT NULL,
	postal_code VARCHAR(100) DEFAULT NULL,
	address VARCHAR(255) DEFAULT NULL    
);

-- Afegir registres a user executant estructura_datos_user.sql
-- Modificar datatype de user.id de char a int xq sigui = q transaction.user_id
ALTER TABLE user
MODIFY id INT NOT NULL;

-- Reanomeno columna email
ALTER TABLE user
CHANGE COLUMN email personal_email VARCHAR(150);
-- Comprovo canvis:
SHOW COLUMNS FROM user;

-- Al crear foreign key a transaction per user_id, dóna error pq existeix algun registre a transaction que no coincideix a user (error1452)
-- Llista de registres de transaction q no existeixen a user
SELECT DISTINCT t.user_id
FROM transaction t
LEFT JOIN user u ON t.user_id = u.id
WHERE u.id IS NULL;

-- Creo el registre que existeix a transaction pero no a user amb ID=9999
INSERT INTO user(id)
VALUES (9999);

-- Crear constraint Foreign key a transaction per user_id
ALTER TABLE transaction
	ADD FOREIGN KEY (user_id) REFERENCES user(id);

-- Eliminar company.website
ALTER TABLE company
DROP COLUMN website;

-- Modificar datatypes i afegir data_actual a CREDIT_CARD
ALTER TABLE credit_card
MODIFY COLUMN iban VARCHAR(50),
MODIFY COLUMN pin VARCHAR(4),
ADD COLUMN fecha_actual DATE DEFAULT (CURRENT_DATE);


-- Modificar datatype de credit_card.id i de transaction.credit_card_id:
ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_3,
MODIFY COLUMN credit_card_id VARCHAR(255) DEFAULT NULL;

ALTER TABLE credit_card
DROP PRIMARY KEY,
MODIFY COLUMN id VARCHAR(20),
ADD PRIMARY KEY (id);

ALTER TABLE transaction
ADD CONSTRAINT transaction_ibfk_3 FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);

-- NIVELL 3 EXERCICI 2 Crear vista Informetecnico

CREATE OR REPLACE VIEW InformeTecnico AS
	SELECT t.id AS ID_transaccion, c.company_name AS nom_empresa, u.name AS nom_usuari, u.surname AS cognom_usuari, cc.iban
    FROM transaction t
    JOIN credit_card cc ON t.credit_card_id = cc.id
    JOIN company c ON t.company_id = c.id
    JOIN user u ON t.user_id = u.id
    ORDER BY ID_transaccion DESC;

SELECT * FROM InformeTecnico;

























-- ALTRES CODIS APRESOS:
-- Com elimino foreign key constraint:
ALTER TABLE transaction
DROP FOREIGN KEY transaction_ibfk_1, -- per saber el nom de la foreign key he usat 'SHOW CREATE TABLE transaction;'
DROP FOREIGN KEY transaction_ibfk_2;

-- o bé:
-- ALTER TABLE transaction DROP CONSTRAINT transaction_ibfk_3;
-- ALTER TABLE transaction DROP CONSTRAINT transaction_ibfk_4;

-- Torno a crear les constraints tipus FOREIGN KEY:
ALTER TABLE transaction
    ADD FOREIGN KEY (credit_card_id) REFERENCES credit_card(id),
    ADD FOREIGN KEY (company_id) REFERENCES company(id);
    
/* si vols especificar nom de la constraint / regla foreign key
ALTER TABLE transaction
	ADD CONSTRAINT fk_constraint3
    FOREIGN KEY (credit_card_id) REFERENCES credit_card(id);*/


-- Per assegurar que s'han creat, es pot fer servir el codi
SELECT
    table_name,
    column_name,
    constraint_name,
    referenced_table_name,
    referenced_column_name
FROM
    INFORMATION_SCHEMA.KEY_COLUMN_USAGE
WHERE
	referenced_table_schema = 'transactions';
  -- AND referenced_table_name = 'transaction'; opcional si volem veure taula concreta
-- per veure CONSTRAINTS D'UNA BASE DE DADES (O d'una taula, veure comando opcional al final) 
