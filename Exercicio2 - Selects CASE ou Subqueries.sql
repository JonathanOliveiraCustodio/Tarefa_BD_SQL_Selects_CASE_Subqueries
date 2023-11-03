--Apagar Tabela
USE master 
GO
DROP DATABASE locadora
--================================================
/*
Exercicio 2: Dom�nio Locadora 
*/
CREATE DATABASE locadora
GO
USE locadora

CREATE TABLE Filme (
id			INT			NOT NULL IDENTITY (1001,1),
titulo      VARCHAR(40) NULL,
ano			INT			NULL CHECK (ano < = 2021)
PRIMARY KEY (id)
)
GO

CREATE TABLE Estrela(
id		  INT		    NOT NULL IDENTITY (9901,1),
nome      VARCHAR(50)   NOT NULL
PRIMARY KEY(id)
)
GO

CREATE TABLE Filme_Estrela(
id_filme	INT			NOT NULL,
id_estrela  INT			NOT NULL
PRIMARY KEY (id_filme,id_estrela)
FOREIGN KEY (id_filme)   REFERENCES Filme (id),
FOREIGN KEY (id_estrela) REFERENCES Estrela (id)
)
GO

CREATE TABLE DVD (
num			     INT		NOT NULL IDENTITY(10001,1),
data_fabricacao  DATE		NOT NULL CHECK (data_fabricacao < GETDATE()),
id_filme		 INT		NOT NULL	
PRIMARY KEY (num) 
FOREIGN KEY (id_filme) REFERENCES Filme(id)
)
GO


CREATE TABLE Cliente (
num_cadastro		INT		     NOT NULL IDENTITY (5501,1),
nome				VARCHAR(70)  NOT NULL,
logradouro			VARCHAR(150) NOT NULL,
num					INT			 NOT NULL CHECK (num >=0),
cep					CHAR(8)		 NOT NULL CHECK (LEN(cep) = 8)
PRIMARY KEY (num_cadastro)
)
GO

CREATE TABLE Locacao (
num_dvd             INT				NOT NULL,	
num_cadastro        INT				NOT NULL, 
data_locacao		DATE			NOT NULL DEFAULT (GETDATE()),
data_devolucao		DATE			NOT NULL,
valor				DECIMAL(7,2)    NOT NULL CHECK(valor >0)
PRIMARY KEY (num_dvd,num_cadastro,data_locacao)
FOREIGN KEY (num_dvd) REFERENCES DVD (num),
FOREIGN KEY (num_cadastro) REFERENCES Cliente(num_cadastro),
CONSTRAINT chk_data_locacao_data_devolucao CHECK(data_devolucao > data_locacao)
)
GO

/*
Restri��es:
Ano de filme deve ser menor ou igual a 2021
Data de fabrica��o de DVD deve ser menor do que hoje
N�mero do endere�o de Cliente deve ser positivo
CEP do endere�o de Cliente deve ter, especificamente, 8 caracteres
Data de loca��o de Loca��o, por padr�o, deve ser hoje
Data de devolu��o de Loca��o, deve ser maior que a data de loca��o
Valor de Loca��o deve ser positivo
*/

ALTER TABLE Estrela
ADD nome_real VARCHAR(50) NULL;

ALTER TABLE Filme
ALTER COLUMN titulo VARCHAR(80) NULL;


INSERT INTO Filme VALUES
('Whiplash', 2015),
('Birdman', 2015),
('Interestelar',2014 ),
('A Culpa � das estrelas',2014),
('Alexandre e o Dia Terr�vel, Horr�vel, Espantoso e Horroroso',2014),
('Sing',2016)

INSERT INTO Estrela VALUES
('Michael Keaton', 'Michael John Douglas'),
('Emma Stone', 'Emily Jean Stone'),
('Miles Teller',NULL ),
('Steve Carell','Steven John Carell'),
('Jennifer Garner','Jennifer Anne Garner')

INSERT INTO Filme_Estrela VALUES
(1002,9901),
(1002,9902),
(1001,9903),
(1005,9904),
(1005,9905)

INSERT INTO DVD VALUES
('2020-12-02',1001),
('2019-10-18',1002),
('2020-04-03',1003),
('2020-12-02',1001),
('2019-10-18',1004),
('2020-04-03',1002),
('2020-12-02',1005),
('2019-10-18',1002),
('2020-04-03',1003)

ALTER TABLE Cliente
ALTER COLUMN cep CHAR(08) NULL;

INSERT INTO Cliente VALUES
('Matilde Luz','Rua S�ria',150,'03086040'),
('Carlos Carreiro','Rua Bartolomeu Aires',1250,'04419110'),
('Daniel Ramalho','Rua Itajutiba',169,NULL),
('Roberta Bento','Rua Jayme Von Rosenburg',36,NULL),
('Rosa Cerqueira','Rua Arnaldo Sim�es Pinto', 235,'02917110')

INSERT INTO Locacao VALUES
(10001,5502,'2021-02-18','2021-02-21',3.50),
(10009,5502,'2021-02-18','2021-02-21',3.50),
(10002,5503,'2021-02-18','2021-02-19',3.50),
(10002,5505,'2021-02-20','2021-02-23',3.00),
(10004,5505,'2021-02-20','2021-02-23',3.00),
(10005,5505,'2021-02-20','2021-02-23',3.00),
(10001,5501,'2021-02-24','2021-02-26',3.50),
(10008,5501,'2021-02-24','2021-02-26',3.50)

--Opera��es com dados:
--Os CEP dos clientes 5503 e 5504 s�o 08411150 e 02918190 respectivamente
UPDATE Cliente SET cep = '08411150' where num_cadastro = 5503
UPDATE Cliente SET cep = '02918190' where num_cadastro = 5504

--A loca��o de 2021-02-18 do cliente 5502 teve o valor de 3.25 para cada DVD alugado
UPDATE Locacao SET valor = 3.25 WHERE data_locacao='2021-02-18' AND num_cadastro =5502

--A loca��o de 2021-02-24 do cliente 5501 teve o valor de 3.10 para cada DVD alugado
UPDATE Locacao SET valor = 3.10 WHERE data_locacao='2021-02-24' AND num_cadastro =5501

--O DVD 10005 foi fabricado em 2019-07-14
UPDATE DVD SET data_fabricacao ='2019-07-14' WHERE num = 10005

--O nome real de Miles Teller � Miles Alexander Teller
UPDATE Estrela SET nome_real ='Miles Alexander Teller' WHERE nome = 'Miles Teller'

--O filme Sing n�o tem DVD cadastrado e deve ser exclu�do
DELETE FROM Filme WHERE titulo ='Sing';

/*
1) Fazer uma consulta que retorne ID, Ano, nome do Filme (Caso o nome do filme tenha
mais de 10 caracteres, para caber no campo da tela, mostrar os 10 primeiros
caracteres, seguidos de retic�ncias ...) dos filmes cujos DVDs foram fabricados depois
de 01/01/2020
*/


SELECT 
    id,
    ano,
    CASE
        WHEN LEN(titulo) > 10 THEN SUBSTRING(titulo, 1, 10) + '...'
        ELSE titulo
    END AS Titulo_Filme
FROM Filme
 WHERE id IN (
    SELECT id_filme
    FROM DVD 
	data_fabricacao
    WHERE data_fabricacao > '2020-01-01'
);


/*
2) Fazer uma consulta que retorne num, data_fabricacao, qtd_meses_desde_fabricacao
(Quantos meses desde que o dvd foi fabricado at� hoje) do filme Interestelar
*/
SELECT
    num AS Numero_DVD,
    CONVERT(CHAR(10),data_fabricacao) AS Data_Fabrica��o,
	DATEDIFF(MONTH, data_fabricacao, GETDATE()) AS QuantidadeDeMeses

FROM DVD 
WHERE id_filme IN (
    SELECT id
    FROM Filme 
    WHERE titulo = 'Interestelar'
);

/*
3) Fazer uma consulta que retorne num_dvd, data_locacao, data_devolucao,
dias_alugado(Total de dias que o dvd ficou alugado) e valor das loca��es da cliente que
tem, no nome, o termo Rosa
*/
SELECT
    num_dvd AS Numero_DVD,
    CONVERT(CHAR(10), data_locacao, 103) AS Data_Locacao,
	CONVERT(CHAR(10), data_devolucao, 103) AS Data_Devolu��o,
	DATEDIFF(DAY, data_locacao,data_devolucao) AS Qtd_Dias
FROM Locacao 
WHERE num_cadastro IN (
    SELECT num_cadastro
    FROM Cliente 
    WHERE nome LIKE '%Rosa%'
);
/*
4) Nome, endere�o_completo (logradouro e n�mero concatenados), cep (formato
XXXXX-XXX) dos clientes que alugaram DVD de num 10002.
*/
SELECT
    nome AS Nome,
    logradouro + ', ' + CAST(num AS VARCHAR(5)) 
			+ ' - CEP: ' + SUBSTRING(cep,1,5) + '-' + SUBSTRING(cep,6,3) AS Endere�o_Completo	
FROM Cliente 
WHERE num_cadastro IN (
    SELECT num_cadastro
    FROM Locacao 
    WHERE num_dvd LIKE 10002
);

Select * from Filme
Select * from DVD
Select * from Estrela
Select * from Cliente
Select * from Locacao
