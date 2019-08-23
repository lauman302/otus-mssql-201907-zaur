/*4. Выберите города (ид и название), в которые были доставлены товары, входящие
в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял
упаковку заказов*/

USE WideWorldImporters;

-- Subquery
SELECT DISTINCT
     Cities.CityID
    ,Cities.CityName
    ,People.FullName
FROM
    Sales.InvoiceLines
    JOIN Sales.Invoices     ON InvoiceLines.InvoiceID = Invoices.InvoiceID
    JOIN Application.People ON Invoices.PackedByPersonID = People.PersonID
    JOIN Sales.Customers    ON Invoices.CustomerID = Customers.CustomerID
    JOIN Application.Cities ON Customers.DeliveryCityID = Cities.CityID
WHERE
    InvoiceLines.StockItemID IN (
        SELECT TOP(3) StockItems.StockItemID
        FROM Warehouse.StockItems
        ORDER BY StockItems.UnitPrice DESC)
    AND Invoices.ConfirmedDeliveryTime IS NOT NULL;

-- CTE

WITH TopItems AS (
    SELECT TOP(3) StockItems.StockItemID
    FROM Warehouse.StockItems
    ORDER BY StockItems.UnitPrice DESC
),
SoldAndDelivered AS (
    SELECT
         InvoiceLines.StockItemID
        ,Customers.DeliveryCityID
        ,Invoices.PackedByPersonID
    FROM
        Sales.InvoiceLines
        JOIN Sales.Invoices     ON InvoiceLines.InvoiceID = Invoices.InvoiceID
        JOIN Sales.Customers    ON Invoices.CustomerID = Customers.CustomerID
    WHERE
        Invoices.ConfirmedDeliveryTime IS NOT NULL
)

SELECT DISTINCT
     Cities.CityID
    ,Cities.CityName
    ,People.FullName
FROM
    SoldAndDelivered AS sad
    JOIN Application.Cities ON sad.DeliveryCityID = Cities.CityID
    JOIN Application.People ON sad.PackedByPersonID = People.PersonID
WHERE
    sad.StockItemID IN (SELECT StockItemID FROM TopItems);