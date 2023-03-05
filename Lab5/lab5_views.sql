USE WebHosting;
GO

CREATE OR ALTER VIEW vw_Clienti_NumRecenzii AS
SELECT TOP 100 C.id AS IdClient, C.nume AS NumeClient, COUNT(*) AS NumarRecenzii
FROM Clienti C INNER JOIN Recenzii R ON C.id=R.id_client
GROUP BY C.id, C.nume
ORDER BY NumarRecenzii DESC
GO

CREATE OR ALTER VIEW vw_Firme_NotaMedie AS
SELECT TOP 100 F.id AS IdFirma, F.nume AS NumeFirma, AVG(R.nota) AS NotaMedie
FROM FirmeHosting F INNER JOIN Recenzii R ON F.id=R.id_firma
GROUP BY F.id, F.nume
ORDER BY NotaMedie DESC;
GO

CREATE OR ALTER VIEW vw_Recenzii_Recente AS
SELECT F.nume AS NumeFirma, C.nume AS NumeClient, R.nota AS Nota, R.data_crearii AS DataCrearii
FROM Recenzii R INNER JOIN FirmeHosting F ON R.id_firma=F.id
                INNER JOIN Clienti C ON R.id_client=C.id
WHERE R.data_crearii between '2022-01-01' AND '2022-12-20'
GO

-- Testing views
SELECT * FROM vw_Clienti_NumRecenzii;
SELECT * FROM vw_Firme_NotaMedie;
SELECT * FROM vw_Recenzii_Recente;

-- DMV
SELECT *
FROM sys.dm_db_index_usage_stats
WHERE database_id = DB_ID(N'WebHosting');