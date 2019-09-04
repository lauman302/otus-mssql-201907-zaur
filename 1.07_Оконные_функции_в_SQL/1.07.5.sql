/*
5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
*/

USE WideWorldImporters;

-- Из условия неясно, должны ли быть два товара уникальными или покупка
-- одного и того же дорогого товара дважды засчитывается.
-- Сделан второй вариант (буз уникальности).
WITH sales_cte AS (
    SELECT
        c.CustomerID
        ,c.CustomerName
        ,l.StockItemID
        ,l.UnitPrice
        ,i.InvoiceDate
        ,row_number() OVER (PARTITION BY c.CustomerID ORDER BY l.UnitPrice DESC) AS N
    FROM
        Sales.Invoices    AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
)
SELECT  cte.CustomerID, cte.CustomerName, cte.StockItemID, cte.UnitPrice, cte.InvoiceDate
FROM    sales_cte  AS cte
WHERE   N <= 2;
