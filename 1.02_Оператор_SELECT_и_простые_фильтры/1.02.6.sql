/*
6. Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
*/

USE [WideWorldImporters];

SELECT DISTINCT
    Customers.CustomerID
    ,Customers.CustomerName
    ,Customers.PhoneNumber
    -- ,*
FROM
    [Sales].[Orders]            AS Orders
    JOIN [Sales].[OrderLines]   AS Lines        ON Orders.OrderID = Lines.OrderID
    JOIN [Sales].[Customers]    AS Customers    ON Orders.CustomerID = Customers.CustomerID
WHERE
    -- По этому полю нет индекса
    [Lines].[Description] = 'Chocolate frogs 250g'
;

----

DECLARE @StockItemID    int;

-- Если уникальность имён не ограничена, то может сломаться (сonstrain'ы читаю пока плохо).
SELECT  @StockItemID = si.StockItemID 
FROM    [Warehouse].[StockItems] AS si 
WHERE   si.StockItemName = 'Chocolate frogs 250g'; -- По этому полю индекс есть.

SELECT DISTINCT
    Customers.CustomerID
    ,Customers.CustomerName
    ,Customers.PhoneNumber
FROM
    [Sales].[Orders]            AS Orders
    JOIN [Sales].[OrderLines]   AS Lines        ON Orders.OrderID = Lines.OrderID
    JOIN [Sales].[Customers]    AS Customers    ON Orders.CustomerID = Customers.CustomerID
WHERE
    -- По этому полю индекс тоже есть.
    [Lines].[StockItemID] = @StockItemID
;

----

SELECT DISTINCT
    Customers.CustomerID
    ,Customers.CustomerName
    ,Customers.PhoneNumber
FROM
    [Sales].[Orders]            AS Orders
    JOIN [Sales].[OrderLines]   AS Lines        ON Orders.OrderID = Lines.OrderID
    JOIN [Sales].[Customers]    AS Customers    ON Orders.CustomerID = Customers.CustomerID
WHERE
    -- Без лишней переменной, но IN рекомендуют менять на (NOT) EXISTS.
    Lines.StockItemID IN (
        SELECT  si.StockItemID 
        FROM    [Warehouse].[StockItems] AS si 
        WHERE   si.StockItemName = 'Chocolate frogs 250g'
    )
;
