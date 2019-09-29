/*
2. Выгрузить данные из таблицы StockItems в такой же xml-файл, как StockItems.xml
*/

USE WideWorldImporters;

-- Выполняется при необходимости сконфигурировать сервер на выполнение внешних комманд
-- EXEC sp_configure 'show advanced options', 1;
-- GO
-- RECONFIGURE;
-- GO
-- EXEC sp_configure 'xp_cmdshell', 1;
-- GO
-- RECONFIGURE;
-- GO

DECLARE
    @cmd        nvarchar(max),
    @query      nvarchar(max),
    @bcp        varchar(50) = '/opt/mssql-tools/bin/bcp',
    @path       varchar(50) = '/var/opt/shared/',
    @file       varchar(50) = 'StockItems.xml',
    @dbname     varchar(255),
    @linux      bit         = 1

SET @query = 'SELECT
    [StockItemName]             AS ''@Name''
    ,[SupplierID]               AS ''SupplierID''
    ,[UnitPackageID]            AS ''Package/UnitPackageID''
    ,[OuterPackageID]           AS ''Package/OuterPackageID''
    ,[QuantityPerOuter]         AS ''Package/QuantityPerOuter''
    ,[TypicalWeightPerUnit]     AS ''Package/TypicalWeightPerUnit''
    ,[LeadTimeDays]             AS ''LeadTimeDays''
    ,[IsChillerStock]           AS ''IsChillerStock''
    ,[TaxRate]                  AS ''TaxRate''
    ,[UnitPrice]                AS ''UnitPrice''
FROM Warehouse.StockItems
FOR XML PATH(''Item''), ROOT(''StockItems'');'

SET @dbname = db_name();
SET @cmd = @bcp + ' "'+ @query + '" queryout ' + @path + @file + ' -T -w -t, -S ' + @@SERVERNAME + ' -d ' + @dbname;

-- В версии MS SQL Server 2017 for Linux нет возможности запуска внешних приложений через xp_cmdshell
-- реальный запуск из bash'а:
-- /opt/mssql-tools/bin/bcp "<текст запроса>" queryout  "/var/opt/shared/StockItems.xml" -w -t, -S localhost -d WideWorldImporters -U sa -P 'Pa$$w0rd'
IF @linux = 0
    EXEC master..xp_cmdshell @cmd
ELSE
    PRINT @cmd;
