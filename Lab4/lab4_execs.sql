USE WebHosting;
GO

-- Views
SELECT * FROM dbo.vw_AllClienti;
SELECT * FROM dbo.vw_ClientiWithFacturi;
SELECT * FROM dbo.vw_VPSWithClienti;

-- Tables
SELECT * FROM Tests;
SELECT * FROM Tables;
SELECT * FROM Views;
SELECT * FROM TestTables;
SELECT * FROM TestViews;

SELECT * FROM TestRuns;
SELECT * FROM TestRunTables;
SELECT * FROM TestRunViews;

-- Functions
SELECT * FROM dbo.uf_GetTablesFor(1) ORDER BY table_position;
SELECT * FROM dbo.uf_GetViewsFor(1);

SELECT val FROM vw_Rand;
SELECT dbo.uf_RandInt(10) AS val;
SELECT dbo.uf_RandString(15) AS val;

SELECT * FROM dbo.uf_GetInsertColumnsFor(N'Memorii');
SELECT * FROM dbo.uf_GetForeignKeyColumnsFor(N'Memorii');
SELECT * FROM dbo.uf_GetPrimaryKeyColumnFor(N'Memorii');

DECLARE @insertStmt NVARCHAR(4000);
EXEC usp_GenerateInsertStatement 1, N'Clienti', 10, @insertStmt OUTPUT; 
PRINT @insertStmt;

-- Tests
EXEC usp_DeleteAllData;
EXEC usp_DeleteTests;

DECLARE @test_id INT;
EXEC usp_AddTest 
	N'Test 1', 
	N'Clienti 4 500,Facturi 3 500,IntrariFactura 1 500,VPS 2 500', 
	N'vw_AllClienti,vw_ClientiWithFacturi,vw_VPSWithClienti', 
	@test_id OUTPUT;
EXEC usp_ShowTestInformation @test_id;

DECLARE @test_run_id INT;
EXEC usp_ExecuteTest 
	@test_id,
	N'Description of test run for test 1',
	@test_run_id OUTPUT;

EXEC usp_ShowTestRunInformation @test_run_id;

/*******************************************/

--DECLARE @test_id INT;
EXEC usp_AddTest 
	N'Test 2', 
	N'Clienti 5 50,Facturi 3 40,IntrariFactura 1 60,VPS 2 30,Recenzii 4 20', 
	N'vw_AllClienti,vw_ClientiWithFacturi,vw_VPSWithClienti', 
	@test_id OUTPUT;
EXEC usp_ShowTestInformation @test_id;

--DECLARE @test_run_id INT;
EXEC usp_ExecuteTest 
	@test_id,
	N'Description of test run for test 2',
	@test_run_id OUTPUT;

EXEC usp_ShowTestRunInformation @test_run_id;