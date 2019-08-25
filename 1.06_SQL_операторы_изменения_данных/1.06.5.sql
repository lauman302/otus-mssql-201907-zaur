/*
5. Напишите запрос, который выгрузит данные через bcp out и загрузить через bulk insert
*/

USE WideWorldImporters;

--
-- Подготовительные операции
--

-- Настройка сервера на возможность запуска внешних скриптов (из материалов занятий)
-- Выполняется один раз, поэтому закомментировано.

-- EXEC sp_configure 'show advanced options', 1;
-- GO
-- RECONFIGURE;
-- GO
-- EXEC sp_configure 'xp_cmdshell', 1;
-- GO
-- RECONFIGURE;
-- GO

-- Создание таблицы для загрузки данных
DROP TABLE IF EXISTS [Application].[Cities_bulk];
GO
CREATE TABLE [Application].[Cities_bulk](
	[CityID]                    [int]           NOT NULL,
	[CityName]                  [nvarchar](50)  NOT NULL,
	[StateProvinceID]           [int]           NOT NULL,
	[Location]                  [geography]     NULL,
	[LatestRecordedPopulation]  [bigint]        NULL,
	[LastEditedBy]              [int]           NOT NULL,
	[ValidFrom]                 [datetime2](7)  NOT NULL,
	[ValidTo]                   [datetime2](7)  NOT NULL
);
GO

-- Определение параметров выгрузки
DECLARE
    @cmd        sysname,
    @query      nvarchar(max),
    @bcp        varchar(50) = '/opt/mssql-tools/bin/bcp',
    @path       varchar(50) = '/var/opt/shared/',
    @file       varchar(50) = 'Cities.txt',
    @dbname     varchar(255),
    @batchsize  int         = 1000,
    @linux      bit         = 1

SET @dbname = db_name();
SET @cmd = @bcp + ' "'+@dbname+'.Application.Cities" out ' + @path + @file + ' -T -w -t, -r### -S ' + @@SERVERNAME;

PRINT @cmd;

-- реальный запуск из bash'а:
-- /opt/mssql-tools/bin/bcp "[WideWorldImporters].Application.Cities" out  "/var/opt/shared/Cities.txt" -w -t, -r### -S localhost -U sa -P Pa$$w0rd
if @linux = 0
    exec master..xp_cmdshell @cmd;

-- загрузка
SET @query = 'BULK INSERT ['+@dbname+'].[Application].[Cities_bulk]
                FROM "'+@path+@file+'"
                WITH
                 (
                	BATCHSIZE = '+CAST(@batchsize AS VARCHAR(255))+',
                	DATAFILETYPE = ''widechar'',
                	FIELDTERMINATOR = '','',
                	ROWTERMINATOR =''###'',
                	KEEPNULLS,
                	TABLOCK
                  );';

PRINT @query;

EXEC sp_executesql @query;
PRINT 'Bulk insert '+@file+' is done, current time '+CONVERT(VARCHAR, GETDATE(),120);
