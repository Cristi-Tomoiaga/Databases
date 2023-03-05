USE WebHosting;
GO

-- 1) Firmele care au o nota medie >= 5 impreuna cu numarul de recenzii si numarul de clienti care au lasat recenzii
SELECT FH.nume, AVG(R.nota) AS NotaMedie, COUNT(R.id) AS NrRecenzii, COUNT(DISTINCT C.id) AS NrClienti
FROM FirmeHosting FH INNER JOIN Recenzii R ON FH.id=R.id_firma
				     INNER JOIN Clienti C ON R.id_client=C.id
GROUP BY FH.nume
HAVING AVG(R.nota) >= 5
ORDER BY NotaMedie DESC;

-- 2) Numarul de facturari pentru fiecare firma
SELECT FH.nume, COUNT(C.id) AS NrFacturari
FROM FirmeHosting FH INNER JOIN Facturi F ON FH.id=F.id_firma
					 INNER JOIN Clienti C ON F.id_client=C.id
GROUP BY FH.nume;

-- 3) Totalul ramas de plata pentru fiecare client
SELECT C.nume, SUM(I.pret) AS TotalPlata
FROM Clienti C INNER JOIN Facturi F ON C.id=F.id_client
			   INNER JOIN IntrariFactura I on F.id=I.id_factura
WHERE F.platita = 0
GROUP BY C.nume;

-- 4) Evidenta facturilor pentru un client dat
SELECT C.nume AS Client, FH.nume AS Furnizor, F.data_facturarii AS DataEmiterii, FI.Total AS Total, F.platita AS Platita
FROM Clienti C INNER JOIN Facturi F on C.id=F.id_client 
INNER JOIN (SELECT F1.id AS id_factura, SUM(I.pret) AS Total FROM Facturi F1 INNER JOIN IntrariFactura I ON F1.id=I.id_factura GROUP BY F1.id) FI ON F.id=FI.id_factura
INNER JOIN FirmeHosting FH ON F.id_firma=FH.id
WHERE C.nume LIKE '%Cleansoft%';

-- 5) Numele producatorilor de servere pe care ruleaza VPS-uri
SELECT DISTINCT p.nume
FROM Producatori P INNER JOIN Servere S ON P.id=S.id_producator
				   INNER JOIN VPS V ON S.id=V.id_server
WHERE V.activ = 1;

-- 6) Numele clientilor care au minim o factura platita cu un uptime de minim o jumatate de zi
SELECT DISTINCT C.nume
FROM Clienti C INNER JOIN Facturi F ON C.id=F.id_client
INNER JOIN (SELECT F1.id AS id_factura FROM Facturi F1 INNER JOIN IntrariFactura I ON F1.id=I.id_factura WHERE F1.platita = 1 GROUP BY F1.id HAVING SUM(I.uptime) >= 12) Fp
ON F.id=Fp.id_factura;

-- 7) Puterea totala de procesare, ram si stocare pe care o detin firmele care au o capacitate de stocare mai mare de 16gb de ram
SELECT FH.nume, SUM(P.nr_cores) AS NrCores, SUM(M.capacitate) AS RAM, SUM(St.capacitate) AS Storage
FROM FirmeHosting FH INNER JOIN Servere S ON FH.id=S.id_firma
                     INNER JOIN Procesoare P ON S.id=P.id_server
					 INNER JOIN Memorii M ON S.id=M.id_server
					 INNER JOIN Stocare St ON S.id=St.id_server
GROUP BY FH.nume
HAVING SUM(M.capacitate) > 16;

-- 8) Numarul de VPS-uri ce ruleaza un anumit sistem de operare pentru fiecare firma
SELECT FH.nume AS Firma, COUNT(V.id) AS NumVPS
FROM FirmeHosting FH INNER JOIN Servere S ON FH.id=S.id_firma
                     INNER JOIN VPS V ON S.id=V.id_server
WHERE V.sistem_operare LIKE '%Windows Server%' AND V.activ = 1
GROUP BY FH.nume;

-- 9) Resursele consumate si neplatite inca de catre clienti
SELECT C.nume AS client, SUM(V.nr_cores) AS cores, SUM(V.capacitate_ram) AS ram, SUM(V.capacitate_storage) AS storage
FROM Clienti C INNER JOIN Facturi F ON C.id=F.id_client
			   INNER JOIN IntrariFactura I ON F.id=I.id_factura
               INNER JOIN VPS V ON I.id_vps=V.id
WHERE F.platita = 0
GROUP BY C.nume

-- 10) Viteza medie de internet teoretica a vps-urilor inchiriate de clienti
SELECT C.nume AS Client, AVG(P.viteza_max) AS AvgSpeed
FROM Clienti C INNER JOIN VPS V ON C.id=V.id_client
               INNER JOIN Servere S ON V.id_server=s.id
			   INNER JOIN PlaciRetea P ON S.id=P.id_server
WHERE V.activ = 1
GROUP BY C.nume
ORDER BY AvgSpeed DESC;
