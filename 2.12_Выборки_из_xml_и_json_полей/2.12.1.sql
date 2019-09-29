/*
1. Загрузить данные из файла StockItems.xml в таблицу StockItems.
Существующие записи в таблице обновить, отсутствующие добавить (искать по `StockItemName`).

    Файл StockItems.xml в личном кабинете.
*/

USE WideWorldImporters;

DECLARE
    @xml        xml,
    @docHandle  int;

set @xml = (SELECT * FROM OPENROWSET
    (BULK '/var/opt/shared/StockItems-188-f89807.xml', SINGLE_BLOB) AS d);

DROP TABLE IF EXISTS #StockItems
CREATE TABLE #StockItems(
     [StockItemName]         [nvarchar](100)     COLLATE database_default NOT NULL
    ,[SupplierID]            [int]               NOT NULL
    ,[UnitPackageID]         [int]               NOT NULL
    ,[OuterPackageID]        [int]               NOT NULL
    ,[LeadTimeDays]          [int]               NOT NULL
    ,[QuantityPerOuter]      [int]               NOT NULL
    ,[IsChillerStock]        [bit]               NOT NULL
    ,[TaxRate]               [decimal](18, 3)    NOT NULL
    ,[UnitPrice]             [decimal](18, 2)    NOT NULL
    ,[TypicalWeightPerUnit]  [decimal](18, 3)    NOT NULL
)

EXEC sp_xml_preparedocument @docHandle OUTPUT, @xml;

INSERT INTO #StockItems
SELECT * FROM OPENXML(@docHandle, N'/StockItems/Item', 3)
WITH (
    [StockItemName]             [nvarchar](100)  '@Name'
    ,[SupplierID]               [int]            'SupplierID'
    ,[UnitPackageID]            [int]            'Package/UnitPackageID'
    ,[OuterPackageID]           [int]            'Package/OuterPackageID'
    ,[LeadTimeDays]             [int]            'LeadTimeDays'
    ,[QuantityPerOuter]         [int]            'Package/QuantityPerOuter'
    ,[IsChillerStock]           [bit]            'IsChillerStock'
    ,[TaxRate]                  [decimal](18, 3) 'TaxRate'
    ,[UnitPrice]                [decimal](18, 2) 'UnitPrice'
    ,[TypicalWeightPerUnit]     [decimal](18, 3) 'Package/TypicalWeightPerUnit'
)
EXEC sp_xml_removedocument @docHandle;

MERGE Warehouse.StockItems AS target
USING (
    SELECT [StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[LeadTimeDays]
            ,[QuantityPerOuter],[IsChillerStock],[TaxRate],[UnitPrice],[TypicalWeightPerUnit]
    FROM #StockItems
) AS source ([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[LeadTimeDays]
            ,[QuantityPerOuter],[IsChillerStock],[TaxRate],[UnitPrice],[TypicalWeightPerUnit])
ON target.StockItemName = source.StockItemName
WHEN MATCHED
    THEN UPDATE SET  [StockItemName]        = source.[StockItemName]
                    ,[SupplierID]           = source.[SupplierID]
                    ,[UnitPackageID]        = source.[UnitPackageID]
                    ,[OuterPackageID]       = source.[OuterPackageID]
                    ,[LeadTimeDays]         = source.[LeadTimeDays]
                    ,[QuantityPerOuter]     = source.[QuantityPerOuter]
                    ,[IsChillerStock]       = source.[IsChillerStock]
                    ,[TaxRate]              = source.[TaxRate]
                    ,[UnitPrice]            = source.[UnitPrice]
                    ,[TypicalWeightPerUnit] = source.[TypicalWeightPerUnit]
                    ,[LastEditedBy]         = 1
WHEN NOT MATCHED
    THEN INSERT ([StockItemName],[SupplierID],[UnitPackageID],[OuterPackageID],[LeadTimeDays]
                ,[QuantityPerOuter],[IsChillerStock],[TaxRate],[UnitPrice],[TypicalWeightPerUnit],[LastEditedBy])
         VALUES (source.[StockItemName],source.[SupplierID],source.[UnitPackageID],source.[OuterPackageID],source.[LeadTimeDays]
                ,source.[QuantityPerOuter],source.[IsChillerStock],source.[TaxRate],source.[UnitPrice],source.[TypicalWeightPerUnit],1)
OUTPUT deleted.*, $action, inserted.*;

DROP TABLE IF EXISTS #StockItems;
