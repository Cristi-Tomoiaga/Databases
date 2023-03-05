USE WebHosting;
GO

-- Creare tabel versiuni
CREATE TABLE DBVersions(
	current_version INT NOT NULL
);
GO

INSERT INTO DBVersions(current_version) VALUES (0); -- versiunea initiala este 0
GO

-- Proceduri stocate pentru modificari
CREATE PROCEDURE ModificareTipFrecventaMemorii 
AS
BEGIN
	SET NOCOUNT ON;

	ALTER TABLE Memorii
	ALTER COLUMN frecventa INT NOT NULL;

	UPDATE DBVersions SET current_version=1;
END;
GO

CREATE PROCEDURE AdaugareDefaultTaraProducatori
AS
BEGIN
	SET NOCOUNT ON;

	ALTER TABLE Producatori
	ADD CONSTRAINT df_TaraProducatori DEFAULT 'Romania' FOR tara;

	UPDATE DBVersions SET current_version=2;
END;
GO

CREATE PROCEDURE StergeTabelaPlaciRetea
AS
BEGIN
	SET NOCOUNT ON;

	DROP TABLE PlaciRetea;

	UPDATE DBVersions SET current_version=3;
END;
GO

CREATE PROCEDURE AdaugaAnInfiintareProducatori
AS
BEGIN
	SET NOCOUNT ON;
	
	ALTER TABLE Producatori
	ADD an_infiintare DATE;

	UPDATE DBVersions SET current_version=4;
END;
GO

CREATE PROCEDURE StergeConstrangereFKProducatorServere
AS
BEGIN
	SET NOCOUNT ON;
	
	ALTER TABLE Servere
	DROP CONSTRAINT fk_Producator_Servere;

	UPDATE DBVersions SET current_version=5;
END;
GO

-- Proceduri stocate pentru operatiile inverse
CREATE PROCEDURE InversareModificareTipFrecventaMemorii 
AS
BEGIN
	SET NOCOUNT ON;

	ALTER TABLE Memorii
	ALTER COLUMN frecventa REAL NOT NULL;

	UPDATE DBVersions SET current_version=0;
END;
GO

CREATE PROCEDURE InversareAdaugareDefaultTaraProducatori
AS
BEGIN
	SET NOCOUNT ON;

	ALTER TABLE Producatori
	DROP CONSTRAINT df_TaraProducatori

	UPDATE DBVersions SET current_version=1;
END;
GO

CREATE PROCEDURE InversareStergeTabelaPlaciRetea
AS
BEGIN
	SET NOCOUNT ON;

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

	UPDATE DBVersions SET current_version=2;
END;
GO

CREATE PROCEDURE InversareAdaugaAnInfiintareProducatori
AS
BEGIN
	SET NOCOUNT ON;
	
	ALTER TABLE Producatori
	DROP COLUMN an_infiintare;

	UPDATE DBVersions SET current_version=3;
END;
GO

CREATE PROCEDURE InversareStergeConstrangereFKProducatorServere
AS
BEGIN
	SET NOCOUNT ON;
	
	ALTER TABLE Servere
	ADD CONSTRAINT fk_Producator_Servere FOREIGN KEY (id_producator) REFERENCES Producatori(id);

	UPDATE DBVersions SET current_version=4;
END;
GO

-- Procedura pentru tranzitie versiune
CREATE PROCEDURE SchimbareVersiune @new_version INT
AS
BEGIN
	IF(@new_version NOT IN (0,1,2,3,4,5))
	BEGIN
		RAISERROR('Versiune invalida!', 16, 1);
		RETURN;
	END;

	DECLARE @old_version INT;
	SELECT @old_version=current_version FROM DBVersions;

	DECLARE @version INT;
	SET @version=@old_version;

	IF(@old_version < @new_version)
	BEGIN
		WHILE(@version < @new_version)
		BEGIN
			IF(@version = 0)
				EXEC ModificareTipFrecventaMemorii;
			IF(@version = 1)
				EXEC AdaugareDefaultTaraProducatori;
			IF(@version = 2)
				EXEC StergeTabelaPlaciRetea;
			IF(@version = 3)
				EXEC AdaugaAnInfiintareProducatori;
			IF(@version = 4)
				EXEC StergeConstrangereFKProducatorServere;

			SET @version=@version+1;
		END;
	END;

	IF(@old_version > @new_version)
	BEGIN
		WHILE(@version > @new_version)
		BEGIN
			IF(@version = 1)
				EXEC InversareModificareTipFrecventaMemorii;
			IF(@version = 2)
				EXEC InversareAdaugareDefaultTaraProducatori;
			IF(@version = 3)
				EXEC InversareStergeTabelaPlaciRetea;
			IF(@version = 4)
				EXEC InversareAdaugaAnInfiintareProducatori;
			IF(@version = 5)
				EXEC InversareStergeConstrangereFKProducatorServere;

			SET @version=@version-1;
		END;
	END;
END;
GO

-- Testare proceduri
EXEC SchimbareVersiune @new_version=0;
SELECT * FROM DBVersions;