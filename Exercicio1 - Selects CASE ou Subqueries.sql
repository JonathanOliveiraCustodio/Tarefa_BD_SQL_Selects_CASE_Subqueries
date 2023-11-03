USE master
GO
DROP DATABASE project

CREATE DATABASE project
GO
USE project

CREATE TABLE projects (
id			INT         NOT NULL IDENTITY (10001,1),
name        VARCHAR(45) NOT NULL,
description VARCHAR(45) NOT NULL UNIQUE,
date        DATE        NOT NULL CHECK (date > '2014-09-01')
PRIMARY KEY (id)
)
GO

CREATE TABLE users (
id			INT				NOT NULL IDENTITY (1,1),
name		VARCHAR(45)		NOT NULL,
username	VARCHAR(45)		NOT NULL,
password	VARCHAR(45)		NOT NULL DEFAULT ('123mudar'),
email		VARCHAR(45)		NOT NULL 
PRIMARY kEY	(id)
)
GO

CREATE TABLE users_has_projects(
id_users			INT				NOT NULL,
id_projects         INT				NOT NULL
PRIMARY KEY (id_users, id_projects)
FOREIGN KEY (id_users)    REFERENCES users(id),
FOREIGN KEY (id_projects) REFERENCES projects(id)
)
GO

ALTER TABLE projects
ADD CONSTRAINT UQ_description UNIQUE (description);

--Altera os campos da Tabela
ALTER TABLE users ALTER COLUMN username VARCHAR(10)
ALTER TABLE users ALTER COLUMN password VARCHAR(08)

/*--BULK INSERT
INSERT INTO users VALUES
('Maria', 'Rh_maria', '123@mudar', 'maria@empresa.com'),
('Paulo', 'Ti_paulo', '123@456', 'paulo@empresa.com'),
('Ana', 'Rh_ana', '123@mudar', 'ana@empresa.com'),
('Clara', 'Ti_clara', '123@mudar', 'clara@empresa.com'),
('Aparecido', 'Rh_apareci', '55@!cido', 'aparecido@empresa.com')
*/

INSERT INTO users (name, username, email)
VALUES ('Maria', 'Rh_maria', 'maria@empresa.com')

INSERT INTO users (name, username, password,email)
VALUES ('Paulo', 'Ti_paulo', '123@456', 'paulo@empresa.com')

INSERT INTO users (name, username, email)
VALUES ('Ana', 'Rh_ana', 'ana@empresa.com')

INSERT INTO users (name, username, email)
VALUES ('Clara', 'Ti_clara', 'clara@empresa.com')

INSERT INTO users (name, username, password,email)
VALUES ('Aparecido', 'Rh_apareci', '55@!cido', 'aparecido@empresa.com')
/*
--BULK INSERT
INSERT INTO projects VALUES
('Re-folha', 'Refatoração das Folhas', '2014-09-05'),
('Manutenção PC´s', 'Manutenção PC´s', '2014-09-06'),
('Auditoria', Null, '2014-09-07')
*/
INSERT INTO projects (name, description, date)
VALUES ('Re-folha', 'Refatoração das Folhas', '2014-09-05')

INSERT INTO projects (name, description, date)
VALUES ('Manutenção PC´s', 'Manutenção PC´s', '2014-09-06')

ALTER TABLE projects
ALTER COLUMN description VARCHAR(45) NULL;

INSERT INTO projects (name, description, date)
VALUES ('Auditoria', Null, '2014-09-07')


INSERT INTO users_has_projects VALUES
(1,10001),
(5,10001),
(3,10003),
(4,10002),
(2,10002)

-- Fazer uma consulta que retorne id, nome, email, username e caso a senha seja diferente de
--123mudar, mostrar ******** (8 asteriscos), caso contrário, mostrar a própria senha.

SELECT 
    id,
    name,
    email,
    username,
    CASE
        WHEN password != '123mudar' THEN '********'
        ELSE password
    END AS Senha
FROM users;

/* Considerando que o projeto 10001 durou 15 dias, fazer uma consulta que mostre o nome do
projeto, descrição, data, data_final do projeto realizado por usuário de e-mail
aparecido@empresa.com
*/
SELECT
    name AS Nome_Projeto,
    description AS Descricao_Projeto,
	CONVERT(CHAR(10), date, 103) AS Data_Inicio,
    CONVERT(CHAR(10), DATEADD(DAY, 15, date), 103) AS nova_data_fim	
FROM projects 
WHERE id = 10001 
AND id IN
 (
    SELECT id_projects
    FROM users_has_projects
    WHERE id_users IN
    (
        SELECT id
        FROM users
        WHERE email = 'aparecido@empresa.com'
    )
);

-- Fazer uma consulta que retorne o nome e o email dos usuários que estão envolvidos no
--projeto de nome Auditoria

SELECT
    name AS Nome_Usuario,
    email AS Email_Usuario
FROM users
WHERE id IN
(
    SELECT id_users
    FROM users_has_projects
    WHERE id_projects IN
    (
        SELECT id
        FROM projects
        WHERE name = 'Auditoria'
    )
);

/*Considerando que o custo diário do projeto, cujo nome tem o termo Manutenção, é de 79.85
e ele deve finalizar 16/09/2014, consultar, nome, descrição, data, data_final e custo_total do
projeto
*/

SELECT
    name AS Nome_Projeto,
    description AS Descricao_Projeto,
	CONVERT(CHAR(10), date, 103) AS Data_Inicio,
    CONVERT(CHAR(10), DATEADD(DAY, 15, date), 103) AS DataFim,
	--DATEDIFF(DAY, DATEADD(DAY, 3, GETDATE()), '2014-09-16') AS QtdDias
	--'R$ ' + CAST(79.85 * DATEDIFF(DAY, date, '2014-09-16')) AS Custo_Total

	'R$ ' + CAST(CAST(79.85 * DATEDIFF(DAY, date, '2014-09-16') AS DECIMAL(7,2)) AS VARCHAR(8)) AS Valor_Tota
FROM projects 
WHERE name LIKE '%Manutenção%'

SELECT * from users
SELECT * from projects
SELECT * from users_has_projects