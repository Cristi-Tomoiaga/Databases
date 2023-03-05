USE master;
GO
DROP DATABASE IF EXISTS WebHosting;
Go

CREATE DATABASE WebHosting;
GO
USE WebHosting;
GO

CREATE TABLE FirmeHosting(
	id INT PRIMARY KEY IDENTITY,
	nume VARCHAR(100) NOT NULL,
	descriere VARCHAR(200),
	cif CHAR(12) NOT NULL UNIQUE
);

CREATE TABLE Producatori(
	id INT PRIMARY KEY IDENTITY,
	nume VARCHAR(100) NOT NULL,
	tara VARCHAR(50)
);

CREATE TABLE Servere(
	id INT PRIMARY KEY IDENTITY,
	marca VARCHAR(100),
	denumire VARCHAR(100) NOT NULL,
	id_producator INT,
	id_firma INT FOREIGN KEY REFERENCES FirmeHosting(id),
	CONSTRAINT fk_Producator_Servere FOREIGN KEY (id_producator) REFERENCES Producatori(id)
);

CREATE TABLE Procesoare(
	id INT PRIMARY KEY IDENTITY,
	serie VARCHAR(50) NOT NULL UNIQUE,
	denumire VARCHAR(100) NOT NULL,
	familie VARCHAR(50),
	nr_cores INT NOT NULL,
	frecventa REAL NOT NULL,
	data_fabricatie DATE,
	id_producator INT FOREIGN KEY REFERENCES Producatori(id),
	id_server INT FOREIGN KEY REFERENCES Servere(id)
);

CREATE TABLE Memorii(
	id INT PRIMARY KEY IDENTITY,
	serie VARCHAR(50) NOT NULL UNIQUE,
	denumire VARCHAR(100) NOT NULL,
	capacitate INT NOT NULL,
	frecventa REAL NOT NULL,
	tip CHAR(4),
	data_fabricatie DATE,
	id_producator INT FOREIGN KEY REFERENCES Producatori(id),
	id_server INT FOREIGN KEY REFERENCES Servere(id)
);

CREATE TABLE Stocare(
	id INT PRIMARY KEY IDENTITY,
	serie VARCHAR(50) NOT NULL UNIQUE,
	denumire VARCHAR(100) NOT NULL,
	capacitate INT NOT NULL,
	tehnologie VARCHAR(10),
	data_fabricatie DATE,
	id_producator INT FOREIGN KEY REFERENCES Producatori(id),
	id_server INT FOREIGN KEY REFERENCES Servere(id)
);

CREATE TABLE PlaciRetea(
	id INT PRIMARY KEY IDENTITY,
	serie VARCHAR(50) NOT NULL UNIQUE,
	denumire VARCHAR(100) NOT NULL,
	nr_porturi INT NOT NULL,
	viteza_max INT,
	data_fabricatie DATE,
	id_producator INT FOREIGN KEY REFERENCES Producatori(id),
	id_server INT FOREIGN KEY REFERENCES Servere(id)
);

CREATE TABLE Clienti(
	id INT PRIMARY KEY IDENTITY,
	nume VARCHAR(100) NOT NULL,
	cif CHAR(12) NOT NULL UNIQUE
);

CREATE TABLE VPS(
	id INT PRIMARY KEY IDENTITY,
	id_server INT FOREIGN KEY REFERENCES Servere(id),
	id_client INT FOREIGN KEY REFERENCES Clienti(id),
	sistem_operare VARCHAR(50) NOT NULL,
	nr_cores INT NOT NULL,
	capacitate_ram INT NOT NULL,
	capacitate_storage INT NOT NULL,
	activ BIT DEFAULT 1
);

CREATE TABLE Recenzii(
	id INT PRIMARY KEY IDENTITY,
	id_client INT FOREIGN KEY REFERENCES Clienti(id),
	id_firma INT FOREIGN KEY REFERENCES FirmeHosting(id),
	nota REAL NOT NULL CHECK (1 <= nota AND nota <= 10), -- FARA CHECK
	descriere VARCHAR(100),
	data_crearii DATETIME DEFAULT GETDATE(),
	CONSTRAINT uq_Recenzii UNIQUE (id_client, id_firma) -- FARA UNIQUE
);

CREATE TABLE Facturi(
	id INT PRIMARY KEY IDENTITY,
	id_client INT FOREIGN KEY REFERENCES Clienti(id),
	id_firma INT FOREIGN KEY REFERENCES FirmeHosting(id),
	data_facturarii DATETIME DEFAULT GETDATE(),
	platita BIT DEFAULT 0
);

CREATE TABLE IntrariFactura(
	id_factura INT FOREIGN KEY REFERENCES Facturi(id),
	id_vps INT FOREIGN KEY REFERENCES VPS(id),
	pret REAL NOT NULL,
	uptime INT NOT NULL,
	CONSTRAINT pk_IntrariFactura PRIMARY KEY (id_factura, id_vps)
);