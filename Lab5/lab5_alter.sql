USE WebHosting;
GO

-- Clienti
ALTER TABLE Clienti
ADD CONSTRAINT ck_cif_clienti CHECK (dbo.uf_Valid_CIF(cif) = 1);

ALTER TABLE Clienti
ADD CONSTRAINT ck_nume_clienti CHECK (dbo.uf_Valid_Nume(nume) = 1);

-- FirmeHosting
ALTER TABLE FirmeHosting
ADD CONSTRAINT ck_cif_firmehosting CHECK (dbo.uf_Valid_CIF(cif) = 1);

ALTER TABLE FirmeHosting
ADD CONSTRAINT ck_nume_firmehosting CHECK (dbo.uf_Valid_Nume(nume) = 1);

-- Recenzii
ALTER TABLE Recenzii
ADD CONSTRAINT ck_nota_recenzii CHECK (dbo.uf_Valid_Nota(nota) = 1);