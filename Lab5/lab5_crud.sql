USE WebHosting;
GO

-- Clienti
CREATE OR ALTER PROCEDURE usp_Read_Client
	@id INT,
	@nume VARCHAR(100) OUTPUT,
	@cif CHAR(12) OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Clienti))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	SELECT TOP 1 @nume=nume, @cif=cif FROM Clienti WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Create_Client
	@nume VARCHAR(100), 
	@cif CHAR(12),
	@id INT OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_CIF(@cif) = 0)
	BEGIN
		RAISERROR('Invalid value for cif', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nume(@nume) = 0)
	BEGIN
		RAISERROR('Invalid value for nume', 16, 1);
		RETURN;
	END;

	INSERT INTO Clienti(nume, cif) VALUES (@nume, @cif);
	
	DECLARE @inserted_id INT;
	SELECT @inserted_id = SCOPE_IDENTITY();
	SET @id = @inserted_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Update_Client
	@id INT,
	@nume VARCHAR(100)
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Clienti))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nume(@nume) = 0)
	BEGIN
		RAISERROR('Invalid value for nume', 16, 1);
		RETURN;
	END;

	UPDATE Clienti SET nume=@nume WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Delete_Client
	@id INT,
	@nume VARCHAR(100) OUTPUT,
	@cif CHAR(12) OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Clienti))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	EXEC usp_Read_Client @id, @nume OUTPUT, @cif OUTPUT;

	DELETE FROM Clienti WHERE id=@id;
END;
GO

-- FirmeHosting
CREATE OR ALTER PROCEDURE usp_Read_FirmaHosting
	@id INT,
	@nume VARCHAR(100) OUTPUT,
	@descriere VARCHAR(200) OUTPUT,
	@cif CHAR(12) OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM FirmeHosting))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	SELECT TOP 1 @nume=nume, @descriere=descriere, @cif=cif FROM FirmeHosting WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Create_FirmaHosting
	@nume VARCHAR(100),
	@descriere VARCHAR(200),
	@cif CHAR(12),
	@id INT OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_CIF(@cif) = 0)
	BEGIN
		RAISERROR('Invalid value for cif', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nume(@nume) = 0)
	BEGIN
		RAISERROR('Invalid value for nume', 16, 1);
		RETURN;
	END;

	INSERT INTO FirmeHosting(nume, descriere, cif) VALUES (@nume, @descriere, @cif);

	DECLARE @inserted_id INT;
	SELECT @inserted_id = SCOPE_IDENTITY();
	SET @id = @inserted_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Update_FirmaHosting
	@id INT,
	@nume VARCHAR(100),
	@descriere VARCHAR(200)
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM FirmeHosting))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nume(@nume) = 0)
	BEGIN
		RAISERROR('Invalid value for nume', 16, 1);
		RETURN;
	END;

	UPDATE FirmeHosting SET nume=@nume, descriere=@descriere WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Delete_FirmaHosting
	@id INT,
	@nume VARCHAR(100) OUTPUT,
	@descriere VARCHAR(200) OUTPUT,
	@cif CHAR(12) OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM FirmeHosting))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	EXEC usp_Read_FirmaHosting @id, @nume OUTPUT, @descriere OUTPUT, @cif OUTPUT;

	DELETE FROM FirmeHosting WHERE id=@id;
END;
GO

-- Recenzii
CREATE OR ALTER PROCEDURE usp_Read_Recenzie
	@id INT,
	@id_client INT OUTPUT,
	@id_firma INT OUTPUT,
	@nota REAL OUTPUT,
	@descriere VARCHAR(100) OUTPUT,
	@data_crearii DATETIME OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Recenzii))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	SELECT TOP 1 @id_client=id_client, @id_firma=id_firma, @nota=nota, @descriere=descriere, @data_crearii=data_crearii
	FROM Recenzii WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Create_Recenzie
	@id_client INT,
	@id_firma INT,
	@nota REAL,
	@descriere VARCHAR(100),
	@data_crearii DATETIME,
	@id INT OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id_client) = 0)
	BEGIN
		RAISERROR('Invalid value for id_client', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_ID(@id_firma) = 0)
	BEGIN
		RAISERROR('Invalid value for id_firma', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nota(@nota) = 0)
	BEGIN
		RAISERROR('Invalid value for nota', 16, 1);
		RETURN;
	END;

	INSERT INTO Recenzii(id_client, id_firma, nota, descriere, data_crearii)
	VALUES (@id_client, @id_firma, @nota, @descriere, @data_crearii);

	DECLARE @inserted_id INT;
	SELECT @inserted_id = SCOPE_IDENTITY();
	SET @id = @inserted_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Update_Recenzie
	@id INT,
	@nota REAL,
	@descriere VARCHAR(100),
	@data_crearii DATETIME
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Recenzii))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	IF (dbo.uf_Valid_Nota(@nota) = 0)
	BEGIN
		RAISERROR('Invalid value for nota', 16, 1);
		RETURN;
	END;

	UPDATE Recenzii SET nota=@nota, descriere=@descriere, data_crearii=@data_crearii WHERE id=@id;
END;
GO

CREATE OR ALTER PROCEDURE usp_Delete_Recenzie
	@id INT,
	@id_client INT OUTPUT,
	@id_firma INT OUTPUT,
	@nota REAL OUTPUT,
	@descriere VARCHAR(100) OUTPUT,
	@data_crearii DATETIME OUTPUT
AS
BEGIN
	IF (dbo.uf_Valid_ID(@id) = 0 OR @id NOT IN (SELECT id FROM Recenzii))
	BEGIN
		RAISERROR('Invalid value for id', 16, 1);
		RETURN;
	END;

	EXEC usp_Read_Recenzie @id, @id_client OUTPUT, @id_firma OUTPUT, @nota OUTPUT, @descriere OUTPUT, @data_crearii OUTPUT;

	DELETE FROM Recenzii WHERE id=@id;
END;
GO