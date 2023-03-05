USE WebHosting;
GO

-- Delete all the data
EXEC usp_DeleteAllData;

-- Testing Utils
SELECT dbo.uf_Valid_CIF('RO1234567891');
SELECT dbo.uf_Valid_CIF('1234567891');
SELECT dbo.uf_Valid_ID(121);
SELECT dbo.uf_Valid_Nume('Nume');
SELECT dbo.uf_Valid_Nota(9);

-- Testing CRUD Operations

-- Clienti
DECLARE @id INT, @cif CHAR(12), @nume VARCHAR(100);

EXEC usp_Create_Client 'Nume 1', 'RO1234567892', @id OUTPUT;
PRINT @id; 

EXEC usp_Update_Client @id, 'Nume Nou'; 
EXEC usp_Read_Client @id, @nume OUTPUT, @cif OUTPUT;
PRINT @nume;
PRINT @cif;

EXEC usp_Delete_Client @id, @nume OUTPUT, @cif OUTPUT;
PRINT @nume;
PRINT @cif;

GO

-- FirmeHosting
DECLARE @id INT, @cif CHAR(12), @nume VARCHAR(100), @descriere VARCHAR(200);

EXEC usp_Create_FirmaHosting 'Nume 1', 'Descriere', 'RO1234567892', @id OUTPUT;
PRINT @id;

EXEC usp_Update_FirmaHosting @id, 'Nume Nou', 'Descriere noua'; 
EXEC usp_Read_FirmaHosting @id, @nume OUTPUT, @descriere OUTPUT, @cif OUTPUT;
PRINT @nume;
PRINT @descriere;
PRINT @cif;

EXEC usp_Delete_FirmaHosting @id, @nume OUTPUT, @descriere OUTPUT, @cif OUTPUT;
PRINT @nume;
PRINT @descriere;
PRINT @cif;

GO

-- Recenzii
DECLARE @id INT, @id_client INT, @id_firma INT, @nota REAL, @descriere VARCHAR(100), @data_crearii DATETIME;

EXEC usp_Create_Recenzie 1, 1, 4.5, 'Descriere', '2022-10-10', @id OUTPUT;
PRINT @id;

EXEC usp_Update_Recenzie @id, 5, 'Descriere noua', '2020-10-10';
EXEC usp_Read_Recenzie @id, @id_client OUTPUT, @id_firma OUTPUT, @nota OUTPUT, @descriere OUTPUT, @data_crearii OUTPUT;
PRINT @id_client;
PRINT @id_firma;
PRINT @nota;
PRINT @descriere;
PRINT @data_crearii; 

EXEC usp_Delete_Recenzie @id, @id_client OUTPUT, @id_firma OUTPUT, @nota OUTPUT, @descriere OUTPUT, @data_crearii OUTPUT;
PRINT @id_client;
PRINT @id_firma;
PRINT @nota;
PRINT @descriere;
PRINT @data_crearii;

GO