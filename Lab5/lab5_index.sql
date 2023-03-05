USE WebHosting;
GO

DROP INDEX IX_Firme_id_asc_nume_asc ON FirmeHosting;
DROP INDEX IX_Recenzii_id_firma_asc ON Recenzii;
DROP INDEX IX_Clienti_id_asc_nume_asc ON Clienti;
DROP INDEX IX_Recenzii_id_client_asc ON Recenzii;
DROP INDEX IX_Recenzii_data_crearii_asc_id_client_asc_id_firma_asc ON Recenzii;


CREATE INDEX IX_Firme_id_asc_nume_asc ON FirmeHosting(id, nume);
CREATE INDEX IX_Recenzii_id_firma_asc ON Recenzii(id_firma, nota);
CREATE INDEX IX_Clienti_id_asc_nume_asc ON Clienti(id, nume);
CREATE INDEX IX_Recenzii_id_client_asc ON Recenzii(id_client);
CREATE INDEX IX_Recenzii_data_crearii_asc_id_client_asc_id_firma_asc ON Recenzii(data_crearii, id_client, id_firma) INCLUDE (nota);