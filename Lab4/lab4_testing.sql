USE WebHosting;
GO

CREATE OR ALTER PROCEDURE usp_DeleteTests
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM TestRunViews;
	DELETE FROM TestRunTables;
	DELETE FROM TestRuns;
	DBCC CHECKIDENT('TestRuns', RESEED, 0);
	DELETE FROM TestViews;
	DELETE FROM TestTables;
	DELETE FROM Tables;
	DBCC CHECKIDENT('Tables', RESEED, 0);
	DELETE FROM Views;
	DBCC CHECKIDENT('Views', RESEED, 0);
	DELETE FROM Tests;
	DBCC CHECKIDENT('Tests', RESEED, 0);
END;
GO

CREATE OR ALTER PROCEDURE usp_DeleteAllData
AS
BEGIN
	SET NOCOUNT ON;

	DELETE FROM IntrariFactura;
	DELETE FROM Facturi;
	DBCC CHECKIDENT('Facturi', RESEED, 0);
	DELETE FROM VPS;
	DBCC CHECKIDENT('VPS', RESEED, 0);
	DELETE FROM Recenzii;
	DBCC CHECKIDENT('Recenzii', RESEED, 0);
	DELETE FROM PlaciRetea;
	DBCC CHECKIDENT('PlaciRetea', RESEED, 0);
	DELETE FROM Memorii;
	DBCC CHECKIDENT('Memorii', RESEED, 0);
	DELETE FROM Stocare;
	DBCC CHECKIDENT('Stocare', RESEED, 0);
	DELETE FROM Procesoare;
	DBCC CHECKIDENT('Procesoare', RESEED, 0);
	DELETE FROM Servere;
	DBCC CHECKIDENT('Servere', RESEED, 0);
	DELETE FROM Producatori;
	DBCC CHECKIDENT('Producatori', RESEED, 0);
	DELETE FROM Clienti;
	DBCC CHECKIDENT('Clienti', RESEED, 0);
	DELETE FROM FirmeHosting;
	DBCC CHECKIDENT('FirmeHosting', RESEED, 0);
END;
GO

CREATE OR ALTER PROCEDURE usp_AddTestTable
	@table_name NVARCHAR(50),
	@table_id INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT * FROM Tables WHERE Name=@table_name)
	BEGIN
		INSERT INTO Tables(Name) VALUES(@table_name);
	END;

	SELECT TOP 1 @table_id=TableID FROM Tables WHERE Name=@table_name;
END;
GO

CREATE OR ALTER PROCEDURE usp_AddTestView
	@view_name NVARCHAR(50),
	@view_id INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	IF NOT EXISTS(SELECT * FROM Views WHERE Name=@view_name)
	BEGIN
		INSERT INTO Views(Name) VALUES(@view_name);
	END;

	SELECT TOP 1 @view_id=ViewID FROM Views WHERE Name=@view_name;
END;
GO

CREATE OR ALTER PROCEDURE usp_AddTest 
	@name NVARCHAR(50),
	@tables NVARCHAR(4000),
	@views NVARCHAR(4000),
	@testID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- adaugare test
	DECLARE @test_id INT;
	INSERT INTO Tests(Name) VALUES (@name);
	SELECT @test_id=IDENT_CURRENT(N'Tests');

	-- adaugare tabele
	DECLARE cursor_tables CURSOR LOCAL FAST_FORWARD FOR
	SELECT value FROM string_split(@tables, N',');
	OPEN cursor_tables;

	DECLARE @current_pair NVARCHAR(70);
	DECLARE @table_name NVARCHAR(50);
	DECLARE @table_position NVARCHAR(10);
	DECLARE @table_num_rows NVARCHAR(10);
	DECLARE @table_id INT;

	FETCH NEXT FROM cursor_tables INTO @current_pair;
	WHILE @@FETCH_STATUS=0
	BEGIN
		DECLARE cursor_table CURSOR LOCAL FAST_FORWARD FOR
		SELECT value FROM string_split(@current_pair, N' ');
		OPEN cursor_table;

		FETCH NEXT FROM cursor_table INTO @table_name;
		FETCH NEXT FROM cursor_table INTO @table_position;
		FETCH NEXT FROM cursor_table INTO @table_num_rows;

		-- adauga acest tabel
		EXEC usp_AddTestTable @table_name, @table_id OUTPUT;

		INSERT INTO TestTables(TestID, TableID, NoOfRows, Position) 
		VALUES (@test_id, @table_id, CONVERT(INT, @table_num_rows), CONVERT(INT, @table_position));

		CLOSE cursor_table;
		DEALLOCATE cursor_table;

		FETCH NEXT FROM cursor_tables INTO @current_pair;
	END;

	CLOSE cursor_tables;
	DEALLOCATE cursor_tables;

	-- adaugare views
	DECLARE cursor_views CURSOR LOCAL FAST_FORWARD FOR
	SELECT value FROM string_split(@views, N',');
	OPEN cursor_views;

	DECLARE @view_name NVARCHAR(50);
	DECLARE @view_id INT;

	FETCH NEXT FROM cursor_views INTO @view_name;
	WHILE @@FETCH_STATUS=0
	BEGIN
		-- adauga acest view
		EXEC usp_AddTestView @view_name, @view_id OUTPUT;

		INSERT INTO TestViews(TestID, ViewID) VALUES (@test_id, @view_id);

		FETCH NEXT FROM cursor_views INTO @view_name;
	END;

	CLOSE cursor_views;
	DEALLOCATE cursor_views;

	SET @testID=@test_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_ExecuteTest
	@test_id INT,
	@description NVARCHAR(2000),
	@test_runID INT OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- timp start test batch
	DECLARE @after DATETIME;
	DECLARE @before DATETIME;
	DECLARE @current_datetime DATETIME;
	SET @current_datetime=SYSDATETIME();

	-- adaugare test run
	DECLARE @test_run_id INT;
	INSERT INTO TestRuns(Description, StartAt) VALUES (@description, @current_datetime);
	SELECT @test_run_id=IDENT_CURRENT(N'TestRuns'); 

	-- executare teste tabele

	-- executare stergeri
	DECLARE cursor_tables CURSOR LOCAL FAST_FORWARD FOR
	SELECT * FROM uf_GetTablesFor(@test_id) ORDER BY table_position ASC;
	OPEN cursor_tables;

	DECLARE @table_id INT;
	DECLARE @table_name NVARCHAR(50);
	DECLARE @table_position INT;
	DECLARE @table_num_rows INT;
	DECLARE @insert_stmt NVARCHAR(MAX);

	FETCH NEXT FROM cursor_tables INTO @table_id, @table_name, @table_position, @table_num_rows;
	WHILE @@FETCH_STATUS=0
	BEGIN
		-- sterge date 
		EXEC(N'DELETE FROM ' + @table_name);
		IF (EXISTS (SELECT * FROM dbo.uf_GetPrimaryKeyColumnFor(@table_name)))
		BEGIN
			DBCC CHECKIDENT(@table_name, RESEED, 0); -- reseteaza identity
		END;

		FETCH NEXT FROM cursor_tables INTO @table_id, @table_name, @table_position, @table_num_rows;
	END;

	CLOSE cursor_tables;
	DEALLOCATE cursor_tables;

	-- executare inserari
	DECLARE cursor_tables CURSOR LOCAL FAST_FORWARD FOR
	SELECT * FROM uf_GetTablesFor(@test_id) ORDER BY table_position DESC;
	OPEN cursor_tables;

	FETCH NEXT FROM cursor_tables INTO @table_id, @table_name, @table_position, @table_num_rows;
	WHILE @@FETCH_STATUS=0
	BEGIN
		-- timp start inserare
		SET @before=SYSDATETIME();

		-- insereaza date
		EXEC usp_GenerateInsertStatement @test_id, @table_name, @table_num_rows, @insert_stmt OUTPUT;
		EXEC(@insert_stmt);

		-- timp stop inserare
		SET @after=SYSDATETIME();

		-- adauga tabela in results
		INSERT INTO TestRunTables(TestRunID, TableID, StartAt, EndAt) VALUES (@test_run_id, @table_id, @before, @after);

		FETCH NEXT FROM cursor_tables INTO @table_id, @table_name, @table_position, @table_num_rows;
	END;

	CLOSE cursor_tables;
	DEALLOCATE cursor_tables;

	-- executare teste view-uri
	DECLARE cursor_views CURSOR LOCAL FAST_FORWARD FOR
	SELECT * FROM uf_GetViewsFor(@test_id);
	OPEN cursor_views;

	DECLARE @view_id INT;
	DECLARE @view_name NVARCHAR(50);

	FETCH NEXT FROM cursor_views INTO @view_id, @view_name;
	WHILE @@FETCH_STATUS=0
	BEGIN
		-- timp start executare
		SET @before=SYSDATETIME();

		-- executare view
		EXEC(N'SELECT * FROM ' + @view_name);

		-- timp stop executare
		SET @after=SYSDATETIME();

		-- adauga view in results
		INSERT INTO TestRunViews(TestRunID, ViewID, StartAt, EndAt) VALUES (@test_run_id, @view_id, @before, @after);

		FETCH NEXT FROM cursor_views INTO @view_id, @view_name;
	END;

	CLOSE cursor_views;
	DEALLOCATE cursor_views;

	-- timp stop test batch
	SET @current_datetime=SYSDATETIME();
	UPDATE TestRuns SET EndAt=@current_datetime WHERE TestRunID=@test_run_id;

	SET @test_runID=@test_run_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_ShowTestInformation
	@test_id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT te.Name AS TestName, ta.Name as TableName, tt.NoOfRows as NumRows, tt.Position as Position
	FROM Tests te INNER JOIN TestTables tt ON te.TestID=tt.TestID
				  INNER JOIN Tables ta ON tt.TableID=ta.TableID
	WHERE te.TestID=@test_id
	ORDER BY Position;

	SELECT te.Name AS TestName, v.Name as ViewName
	FROM Tests te INNER JOIN TestViews tv ON te.TestID=tv.TestID
				  INNER JOIN Views V ON tv.ViewID=v.ViewID
	WHERE te.TestID=@test_id;
END;
GO

CREATE OR ALTER PROCEDURE usp_ShowTestRunInformation
	@test_run_id INT
AS
BEGIN
	SET NOCOUNT ON;

	SELECT tr.Description AS Description, tr.StartAt AS TestStartAt, tr.EndAt AS TestEndAt, 
		   t.Name as Name, trt.StartAt as StartAt, trt.EndAt as EndAt
	FROM TestRuns tr INNER JOIN TestRunTables trt ON tr.TestRunID=trt.TestRunID
	                 INNER JOIN Tables t ON trt.TableID=t.TableID
	WHERE tr.TestRunID=@test_run_id;

	SELECT tr.Description AS Description, tr.StartAt AS TestStartAt, tr.EndAt AS TestEndAt, 
		   v.Name as Name, trv.StartAt as StartAt, trv.EndAt as EndAt
	FROM TestRuns tr INNER JOIN TestRunViews trv ON tr.TestRunID=trv.TestRunID
	                 INNER JOIN Views v ON trv.ViewID=v.ViewID
	WHERE tr.TestRunID=@test_run_id;
END;
GO