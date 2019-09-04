/*
2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
*/

USE WideWorldImporters;

SET STATISTICS TIME ON;
GO

SELECT
    i.InvoiceID                     AS [ID продажи]
    ,c.CustomerName                 AS [Название клиента]
    ,i.InvoiceDate                  AS [Дата продажи]
    ,(l.UnitPrice * l.Quantity)     AS [Сумма продажи]
    ,SUM(l.UnitPrice * l.Quantity) OVER (ORDER BY dateadd(month, datediff(month, 0, i.InvoiceDate), 0)) AS [Сумма продаж за месяц, накопительно]
FROM Sales.Invoices          AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
WHERE
    i.InvoiceDate >= convert(date, '2015-01-01', 120)
ORDER BY
    [Дата продажи], [Название клиента];

SET STATISTICS TIME OFF;
GO
