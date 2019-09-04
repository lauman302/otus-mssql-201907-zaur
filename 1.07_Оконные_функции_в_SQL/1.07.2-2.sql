/*
2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)
*/

USE WideWorldImporters;

WITH cte AS (
    SELECT
        month(i.InvoiceDate)    AS SaleMonth
        ,l.StockItemID
        ,l.[Description]
        ,SUM(l.Quantity)        AS Qty
        ,row_number() OVER (PARTITION BY month(i.InvoiceDate) ORDER BY SUM(l.Quantity) DESC) AS N
    FROM
        Sales.InvoiceLines  AS l
        JOIN Sales.Invoices AS i    ON l.InvoiceID = i.InvoiceID
    WHERE
        year(i.InvoiceDate) = 2016
    GROUP BY
        month(i.InvoiceDate)
        ,l.StockItemID
        ,l.[Description]
)
SELECT   SaleMonth, StockItemID, Description, Qty, N
FROM     cte
WHERE    N <=2
ORDER BY SaleMonth, N;
