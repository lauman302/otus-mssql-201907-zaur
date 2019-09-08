/*
4. Перепишите ДЗ из оконных функций через CROSS APPLY
Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

USE WideWorldImporters;

SELECT
    c.CustomerID
    ,c.CustomerName
    ,caSales.StockItemID
    ,caSales.UnitPrice
    ,caSales.InvoiceDate
FROM
    Sales.Customers AS c
    CROSS APPLY (
        SELECT TOP(2) i.InvoiceDate, l.UnitPrice, l.StockItemID
        FROM Sales.Invoices AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        WHERE i.CustomerID = c.CustomerID
        ORDER BY l.UnitPrice DESC
        ) AS caSales;
