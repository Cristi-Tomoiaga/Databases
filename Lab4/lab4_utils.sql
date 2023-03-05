USE WebHosting;
GO

-- random generators
CREATE OR ALTER VIEW vw_Rand
AS
SELECT RAND() AS val;
GO

CREATE OR ALTER FUNCTION uf_RandInt(@n INT) -- [0, @n)
RETURNS INT
AS
BEGIN
	DECLARE @rand_int INT;

	SELECT @rand_int=(SELECT val FROM vw_Rand) * @n;

	RETURN @rand_int;
END;
GO

CREATE OR ALTER FUNCTION uf_RandString(@length INT)
RETURNS VARCHAR(MAX)
AS
BEGIN
	DECLARE @alphabet VARCHAR(MAX);
	DECLARE @alphabet_length INT;

	SET @alphabet = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
	SET @alphabet_length = LEN(@alphabet);

	DECLARE @rand_string VARCHAR(MAX);
	DECLARE @index INT;

	SET @rand_string = '';
	SET @index = 0;
	WHILE(@index < @length)
	BEGIN
		SELECT @rand_string=@rand_string + SUBSTRING(@alphabet, CONVERT(INT, (SELECT val FROM vw_Rand) * @alphabet_length) + 1, 1);

		SET @index = @index + 1;
	END;

	RETURN @rand_string;
END;
GO

-- other utilities
CREATE OR ALTER FUNCTION uf_GetTablesFor(@test_id INT)
RETURNS TABLE	
AS
RETURN SELECT ta.TableID as table_id, ta.Name as table_name, tt.Position as table_position, tt.NoOfRows as table_num_rows
	   FROM Tests te INNER JOIN TestTables tt ON te.TestID=tt.TestID
	                 INNER JOIN Tables ta ON tt.TableID=ta.TableID
	   WHERE te.TestID=@test_id;
GO

CREATE OR ALTER FUNCTION uf_GetViewsFor(@test_id INT)
RETURNS TABLE
AS
RETURN SELECT v.ViewID as view_id, v.Name as view_name
	   FROM Tests te INNER JOIN TestViews tv ON te.TestID=tv.TestID
	                 INNER JOIN Views v ON tv.ViewID=v.ViewID
	   WHERE te.TestID=@test_id;
GO