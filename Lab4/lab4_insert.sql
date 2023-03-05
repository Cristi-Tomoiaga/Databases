USE WebHosting;
GO

CREATE OR ALTER FUNCTION uf_GetInsertColumnsFor(@table_name NVARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT c.name AS column_name, t.name AS type_name, c.max_length AS type_length
       FROM sys.columns c INNER JOIN sys.types t ON c.user_type_id=t.user_type_id 
       WHERE c.object_id=OBJECT_ID(@table_name) AND c.is_identity = 0 AND c.default_object_id = 0;
GO

CREATE OR ALTER FUNCTION uf_GetForeignKeyColumnsFor(@table_name NVARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT c.name AS column_name, t.name AS referenced_table_name
       FROM sys.foreign_key_columns fkc INNER JOIN sys.columns c ON fkc.parent_object_id=c.object_id AND fkc.parent_column_id=c.column_id
                                        INNER JOIN sys.tables t ON fkc.referenced_object_id=t.object_id
       WHERE c.object_id=OBJECT_ID(@table_name);
GO

CREATE OR ALTER FUNCTION uf_GetPrimaryKeyColumnFor(@table_name NVARCHAR(50))
RETURNS TABLE
AS
RETURN SELECT c.name AS column_name, t.name AS type_name
       FROM sys.columns c INNER JOIN sys.types t ON c.user_type_id=t.user_type_id 
       WHERE c.object_id=OBJECT_ID(@table_name) AND c.is_identity = 1;
GO

CREATE OR ALTER PROCEDURE usp_GenerateInsertStatement
	@test_id INT,
	@table_name NVARCHAR(50),
	@table_num_rows INT,
	@insertStmt NVARCHAR(MAX) OUTPUT
AS
BEGIN
	SET NOCOUNT ON;

	-- creare "antet" insert into
	DECLARE @insert NVARCHAR(MAX);
	SET @insert='INSERT INTO ' + @table_name + '(';

	DECLARE cursor_column_names CURSOR LOCAL FAST_FORWARD FOR
	SELECT * FROM uf_GetInsertColumnsFor(@table_name);
	OPEN cursor_column_names;

	DECLARE @column_name NVARCHAR(128);
	DECLARE @type_name NVARCHAR(128);
	DECLARE @type_length SMALLINT;

	FETCH NEXT FROM cursor_column_names INTO @column_name, @type_name, @type_length;
	WHILE @@FETCH_STATUS=0
	BEGIN
		SET @insert=@insert + @column_name + N', ';

		FETCH NEXT FROM cursor_column_names INTO @column_name, @type_name, @type_length;
	END;
	SELECT @insert=SUBSTRING(@insert, 1, LEN(@insert) - 1);
	SET @insert=@insert + N') VALUES ';
	
	CLOSE cursor_column_names;

	-- pentru inserare de fk
	DECLARE @referenced_table_name NVARCHAR(128);
	DECLARE @fk_id INT;
	DECLARE @pk_len INT;

	-- cazul cheie primara dubla
	DECLARE @first_id INT, @second_id INT, @which_id BIT; -- 0 -> @first_id, 1 -> @second_id
	DECLARE @first_len INT, @second_len INT;
	DECLARE @first_table_name NVARCHAR(128), @second_table_name NVARCHAR(128);

	-- detectare cheie primara dubla
	DECLARE @flag BIT;
	SET @flag = 0;
	IF (NOT EXISTS (SELECT * FROM dbo.uf_GetPrimaryKeyColumnFor(@table_name)))
	BEGIN
		SET @flag = 1;
		
		DECLARE cursor_primary_double CURSOR LOCAL FAST_FORWARD FOR
		SELECT referenced_table_name FROM dbo.uf_GetForeignKeyColumnsFor(@table_name);
		OPEN cursor_primary_double;

		FETCH NEXT FROM cursor_primary_double INTO @first_table_name;
		SELECT @first_len=IDENT_CURRENT(@first_table_name); 

		FETCH NEXT FROM cursor_primary_double INTO @second_table_name;
		SELECT @second_len=IDENT_CURRENT(@second_table_name);

		CLOSE cursor_primary_double;
		DEALLOCATE cursor_primary_double;

		SET @first_id=1;
		SET @second_id=1;
		SET @which_id=0;
	END;

	-- creare randuri de inserat
	DECLARE @index INT;
	SET @index = 0;

	WHILE @index < @table_num_rows
	BEGIN
		OPEN cursor_column_names;
		SET @insert=@insert + N'(';

		FETCH NEXT FROM cursor_column_names INTO @column_name, @type_name, @type_length;
		WHILE @@FETCH_STATUS=0
		BEGIN
			-- coloana care nu e FK/PK
			IF (@column_name NOT IN (SELECT column_name FROM uf_GetForeignKeyColumnsFor(@table_name)))
			BEGIN
				IF (@type_name IN (N'int', N'real'))
				BEGIN
					SELECT @insert=@insert + CONVERT(NVARCHAR(7), dbo.uf_RandInt(1000000)) + N', ';
				END
				ELSE IF (@type_name IN (N'varchar', N'char'))
				BEGIN
					SELECT @insert=@insert + N'''' +dbo.uf_RandString(@type_length) + N'''' + N', '
				END
				ELSE IF (@type_name IN (N'datetime', N'date'))
				BEGIN
					SET @insert=@insert + N'GETDATE(), ';
				END;
			END
			ELSE
			BEGIN
				SELECT TOP 1 @referenced_table_name=referenced_table_name FROM uf_GetForeignKeyColumnsFor(@table_name) WHERE column_name=@column_name;
				
				IF (@referenced_table_name NOT IN (SELECT table_name FROM dbo.uf_GetTablesFor(@test_id)))
				BEGIN
					-- cheie straina catre tabel din afara testului
					SET @insert=@insert + N'NULL, ';
				END
				ELSE 
				BEGIN
					IF (@flag = 0) 
					BEGIN
						SELECT @pk_len=IDENT_CURRENT(@referenced_table_name); 
						SELECT @fk_id=dbo.uf_RandInt(@pk_len) + 1;

						SET @insert=@insert + CONVERT(NVARCHAR(7), @fk_id) + N', ';
					END
					ELSE
					BEGIN
						IF (@which_id=0)
						BEGIN
							SET @insert=@insert + CONVERT(NVARCHAR(7), @first_id) + N', ';
							SET @which_id=1;
						END
						ELSE 
						BEGIN
							SET @insert=@insert + CONVERT(NVARCHAR(7), @second_id) + N', ';
							SET @which_id=0;

							-- actualizare first si second
							SELECT @second_id=@second_id + 1;
							IF (@second_id = @second_len + 1)
							BEGIN
								SET @second_id=1;
								SET @first_id=@first_id + 1;
							END;
						END;
					END;
				END;
			END;

			FETCH NEXT FROM cursor_column_names INTO @column_name, @type_name, @type_length;
		END;

		SELECT @insert=SUBSTRING(@insert, 1, LEN(@insert) - 1);
		SET @insert=@insert + N'), ';
		CLOSE cursor_column_names;

		SET @index=@index+1;
	END;
	SELECT @insert=SUBSTRING(@insert, 1, LEN(@insert) - 1);
	SET @insert=@insert + N';';

	DEALLOCATE cursor_column_names;

	SET @insertStmt=@insert;
END;
GO