/*2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.*/

USE WideWorldImporters;

-- ALL
SELECT
     StockItems.StockItemID
    ,StockItems.StockItemName
    ,StockItems.UnitPrice
FROM
    Warehouse.StockItems
WHERE
    StockItems.UnitPrice <= ALL (SELECT StockItems.UnitPrice FROM Warehouse.StockItems);

-- MIN
SELECT
     StockItems.StockItemID
    ,StockItems.StockItemName
    ,StockItems.UnitPrice
FROM
    Warehouse.StockItems
WHERE
    StockItems.UnitPrice = (SELECT MIN(StockItems.UnitPrice) FROM Warehouse.StockItems);
