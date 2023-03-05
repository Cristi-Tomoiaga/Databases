USE WebHosting;
GO

INSERT INTO FirmeHosting(nume,descriere,cif) VALUES
	('SC WebHosting SRL','Cele mai bune oferte de cartier', 'RO9988771119'),
	('SC ServersPlusPlus SRL','Preturi mici si calitate deosebita', 'RO9988771129'),
	('SC TotallyNotAScam SRL','Cele mai bune oferte numai la noi', 'RO9988771139'),
	('SC ServerPentruToti SRL',NULL, 'RO9988771149'),
	('SC ProfessionalWeb SRL','Servicii profesioniste', 'RO9988771159'),
	('SC AlexHost SRL','Cele mai mici preturi din Romania', 'RO9988771169');

INSERT INTO Clienti(nume,cif) VALUES
	('SC Cleansoft SRL', 'RO5588772219'),
	('SC Coding4Ever SRL', 'RO5588772229'),
	('SC NewSoftware SRL', 'RO5588772239'),
	('SC SquareIO SRL', 'RO5588772249'),
	('SC Adventure SRL', 'RO5588772259');

INSERT INTO Producatori(nume,tara) VALUES 
	('Dell', 'SUA'),
	('Intel', 'SUA'),
	('AMD', 'SUA'),
	('Gigabyte', 'Taiwan'),
	('Asrock', 'Taiwan'),
	('Kingston', 'SUA'),
	('Micron', NULL),
	('Samsung', 'Coreea de Sud'),
	('Seagate', 'SUA'),
	('Broadcom', 'SUA'),
	('Fujitsu', 'Japonia'),
	('HP', 'SUA'),
	('Western Digital', 'SUA'),
	('Lenovo', 'China');

INSERT INTO Servere(marca,denumire,id_producator,id_firma) VALUES
	('Rackmount','U12LL',5,1),
	('Rackmount','U15-H',5,2),
	('ThinkSystem','ST50',14,3),
	('MyCloud','WD1000HL',13,4),
	('PowerEdge','T40',1,5),
	('ThinkSystem','ST4000',14,5),
	('PowerEdge','T50Ultra',1,6),
	('Rack','R282L',4,6);

INSERT INTO Procesoare(serie,denumire,familie,nr_cores,frecventa,data_fabricatie,id_producator,id_server) VALUES
	('P1115','Cascade Lake 5218','Xeon',16,3.9,'2021-07-30',2,1),
	('P1116','Cascade Lake 6226R','Xeon',32,4.0,'2020-01-01',2,2),
	('P1117','Silver 4214','Xeon',16,2.8,'2019-05-20',2,3),
	('P1118','Cascade Lake 6225R','Xeon',32,4.0,'2020-02-14',2,4),
	('P1119','Cascade Lake 6225R','Xeon',32,4.0,'2020-02-20',2,4),
	('A345C3','7302P','Epyc',16,3.5,'2021-03-20',3,5),
	('A345C4','7352P','Epyc',32,4.5,'2021-03-20',3,6),
	('A345C5','7302P','Epyc',16,3.5,'2021-05-03',3,7),
	('A345C6','7352P','Epyc',32,4.5,'2021-05-03',3,8);

INSERT INTO Stocare(serie,denumire,capacitate,tehnologie,data_fabricatie,id_producator,id_server) VALUES
	('S7531','PM881',1000,'SSD','2018-07-08',8,1),
	('S7532','PM881',1000,'SSD','2018-07-08',8,2),
	('S7533','PM981',500,'SSD','2019-07-08',8,3),
	('S7534','PM981',500,'SSD','2019-07-08',8,4),
	('WD101','751',1000,'HDD','2020-03-10',13,5),
	('WD102','751',1000,'HDD','2020-03-20',13,6),
	('E11F2','Exos 7E',2000,'HDD','2020-06-30',9,7),
	('E11F3','Exos 6F',2000,'HDD','2020-06-15',9,8);

INSERT INTO Memorii(serie,denumire,capacitate,frecventa,tip,data_fabricatie,id_producator,id_server) VALUES
	('M5431','Memorie server Kingston',32,2800,'DDR4','2020-06-06',6,1),
	('M5432','Memorie server Kingston',32,2666,'DDR4','2020-06-06',6,2),
	('M5433','Memorie server Kingston',16,2800,'DDR4','2020-06-06',6,2),
	('M5434','Memorie server Kingston',16,2000,'DDR3','2020-06-06',6,3),
	('M5435','Memorie server HP',16,2800,'DDR4','2020-06-06',12,4),
	('M5436','Memorie server HP',16,3200,'DDR4','2020-06-06',12,4),
	('M5437','Memorie server HP',64,2100,'DDR3','2020-06-06',12,5),
	('M5438','Memorie server HP',64,2666,'DDR4','2020-06-06',12,6),
	('M5439','Dell A799910',16,3100,'DDR4','2020-06-06',1,7),
	('M5440','Dell B760001',32,2800,'DDR4','2020-06-06',1,8);

INSERT INTO PlaciRetea(serie,denumire,nr_porturi,viteza_max,data_fabricatie,id_producator,id_server) VALUES
	('AFBR430','NC1234',2,1000,'2020-05-20',12,1),
	('AFBR431','NC1234',2,1000,'2020-05-20',12,2),
	('AFBR432','NC7300',4,100,'2020-01-03',12,3),
	('AFBR433','NC7300',4,100,'2020-01-03',12,4),
	('AFBR434','AP70R',4,1000,'2021-05-20',12,5),
	('AFBR435','AP70R',4,1000,'2021-05-20',12,6),
	('AFBR436','D277',2,100,'2021-05-15',11,7),
	('AFBR437','D277',2,100,'2021-05-16',11,8);

INSERT INTO Recenzii(nota,descriere,id_client,id_firma) VALUES
	(10, 'Incredibil!',1,1),
	(2, 'Teapa, nu cumparati!',1,3),
	(5, 'Mediocru',2,2),
	(9, 'Recomand',3,5),
	(8, 'Preturi bune, servicii ok',5,6),
	(5, 'Nu recomand',5,2);

INSERT INTO VPS(id_server,id_client,sistem_operare,nr_cores,capacitate_ram,capacitate_storage,activ) VALUES
	(1,1,'Ubuntu Server 16.04',4,4,50,1),
	(3,1,'Ubuntu Server 16.04',4,4,50,1),
	(2,2,'Windows Server 2019',8,8,100,1),
	(5,3,'Ubuntu Server 16.04',4,4,50,0),
	(7,5,'Windows Server 2019',4,24,100,1),
	(8,5,'Windows Server 2019',4,24,100,1),
	(1,5,'Ubuntu Server 16.04',4,4,50,1);

INSERT INTO Facturi(id_client,id_firma,platita) VALUES
	(1,1,1),
	(1,3,1),
	(1,3,1),
	(1,3,0),
	(1,1,0),
	(2,2,0), 
	(2,2,0),
	(3,5,1),
	(5,1,1), 
	(5,6,0);

INSERT INTO IntrariFactura(id_factura,id_vps,pret,uptime) VALUES
	(1,1,400,24),
	(2,2,200,12),
	(3,2,200,12),
	(4,2,1000,50),
	(5,1,400,24),
	(6,3,150,10),
	(7,3,400,24),
	(8,4,600,30),
	(9,7,400,24),
	(10,5,100,5),
	(10,6,1500,60);