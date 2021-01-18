USE master
GO

--===============================================================
--Author: Néstor Cuéllar
--Create Date: 2021-01-14
--Description:Importacion y arreglo de la data fuente a la base de datos.
--===============================================================

--https://www.datos.gov.co/Minas-y-Energ-a/Asignaci-n-de-Recursos-de-Incentivos-a-la-Producci/ufap-23y8
--Validando existencia de la base de datos


PRINT'INICIO PROCESO'
PRINT'VALIDACION EXISTENCIA BASE DE DATOS'

IF DB_ID('Propuesta') IS NOT NULL
	DROP DATABASE Propuesta
GO

--creando la base de datos

CREATE DATABASE Propuesta
GO

PRINT'FIN CREACION BASE DE DATOS'


USE Propuesta
GO


PRINT 'INICIO: CREACION DE TABLAS NECESARIAS DEL PROCESO'
--validando existencia de la tabla

IF OBJECT_ID ('Muestra') IS NOT NULL
	DROP TABLE Muestra
GO

--creando tabla

CREATE TABLE Muestra
(
Region              VARCHAR(100)  NOT NULL,
CodigoDepartamento  INT           NOT NULL,
Departamento        VARCHAR(100)  NOT NULL,
CodigoMunicipio     INT           NOT NULL,
Municipio           VARCHAR(100)  NOT NULL,
ValorIncentivo      NUMERIC(18,0) NOT NULL,
Periodo             INT           NOT NULL
)

GO

--Lectura del archivo descargado para la propuesta


CREATE TABLE #tmptbMuestra
(
Region              VARCHAR(100)  NOT NULL,
CodigoDepartamento  VARCHAR(100)  NOT NULL,
Departamento        VARCHAR(100)  NOT NULL,
CodigoMunicipio     VARCHAR(100)  NOT NULL,
Municipio           VARCHAR(100)  NOT NULL,
ValorIncentivo      VARCHAR(100)  NOT NULL,
Periodo             VARCHAR(100)  NOT NULL
)

GO

PRINT 'FIN: CREACION DE TABLAS NECESARIAS DEL PROCESO'

PRINT 'INICIO: IMPORTACION DE LA DATA DESDE LA RUTA'

BULK INSERT #tmptbMuestra
FROM 'C:\Users\NESTOR\Documents\ESTUDIO\Mision TIC\Ejemplo Propuesta\Asignacion_de_Recursos_de_Incentivos_a_la_Produccion_-_MinEnergia.csv'
WITH (FORMAT = 'CSV', FIRSTROW = 2, FIELDTERMINATOR = ',',	ROWTERMINATOR = '0x0a', KEEPNULLS)

PRINT 'FIN: IMPORTACION DE LA DATA DESDE LA RUTA'


PRINT 'INICIO: ARREGLO DE LOS DATOS CON CARACTERES ESPECIALES'

UPDATE #tmptbMuestra
SET Departamento = REPLACE('Boyac+í','+í','a')
WHERE Departamento = 'Boyac+í'

UPDATE #tmptbMuestra
SET Departamento = REPLACE('Atl+íntico','+í','a')
WHERE Departamento = 'Atl+íntico'

UPDATE #tmptbMuestra
SET Departamento = REPLACE('Bol+¡var','+¡','i')
WHERE Departamento = 'Bol+¡var'

UPDATE #tmptbMuestra
SET Departamento = REPLACE('Nari+¦o','+¦','ñ')
WHERE Departamento = 'Nari+¦o'

UPDATE #tmptbMuestra
SET Departamento = REPLACE('C+¦rdoba','+¦','o')
WHERE Departamento = 'C+¦rdoba'

PRINT 'FIN: ARREGLO DE LOS DATOS CON CARACTERES ESPECIALES'
--Insercion en la tabla Muestra

PRINT 'INICIO: INSERCION EN TABLA FINAL'

INSERT INTO [dbo].[Muestra]
(
Region, CodigoDepartamento, Departamento, CodigoMunicipio, Municipio, ValorIncentivo, Periodo
)
SELECT Region, CodigoDepartamento, Departamento, CodigoMunicipio, Municipio, ValorIncentivo, Periodo
FROM #tmptbMuestra WITH (NOLOCK)

PRINT 'FIN: INSERCION EN TABLA FINAL'

DROP TABLE #tmptbMuestra

SELECT * FROM [dbo].[Muestra] WITH (NOLOCK)
