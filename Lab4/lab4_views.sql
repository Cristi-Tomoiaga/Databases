USE WebHosting;
GO

CREATE VIEW vw_AllClienti
AS
SELECT * FROM Clienti;
GO

CREATE VIEW vw_VPSWithClienti
AS
SELECT v.id as Id, c.nume as NumeClient, v.sistem_operare as SistemOperare, v.nr_cores as NrCores, v.activ as Activ
FROM VPS v INNER JOIN Clienti c ON v.id_client=c.id;
GO

CREATE VIEW vw_ClientiWithFacturi
AS
SELECT c.id as IdClient, c.nume as NumeClient, COUNT(f.id) AS NrFacturi
FROM Clienti c INNER JOIN Facturi f ON c.id=f.id_client
GROUP BY c.id, c.nume;
GO