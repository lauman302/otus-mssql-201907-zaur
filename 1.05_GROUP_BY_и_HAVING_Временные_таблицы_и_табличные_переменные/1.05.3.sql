/*
3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
Группировка должна быть по году и месяцу.
*/

USE WideWorldImporters;

-- Простой вариант
WITH LowQtyGoods AS (
    SELECT
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) AS [month]
        ,iln.StockItemID
    FROM [Sales].[InvoiceLines] AS iln
        JOIN Sales.Invoices     AS inv ON iln.InvoiceID = inv.InvoiceID
    GROUP BY
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate)
        ,iln.StockItemID
    HAVING
        SUM(iln.Quantity) < 50
)

SELECT
     YEAR(inv.InvoiceDate)              AS [year]
    ,MONTH(inv.InvoiceDate)             AS [month]
    ,SUM(iln.UnitPrice * iln.Quantity)  AS SalesSum
    ,MIN(inv.InvoiceDate)               AS FirstSaleDate
    ,SUM(iln.Quantity)                  AS SoldQty
FROM
    [Sales].[InvoiceLines]  AS iln
    JOIN Sales.Invoices     AS inv  ON iln.InvoiceID = inv.InvoiceID
    JOIN LowQtyGoods        AS lqg  ON DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) = lqg.[month]
                                       AND iln.StockItemID = lqg.StockItemID
GROUP BY
     YEAR(inv.InvoiceDate)
    ,MONTH(inv.InvoiceDate)
ORDER BY
     [year]
    ,[month];

-- Сложный вариант, все месяца

DECLARE
    @FirstDate  date = CONVERT(date, '2012-11-01', 120)
   ,@LastDate   date = CONVERT(date, '2016-12-01', 120)
   ,@treshhold  int  = 50;

WITH
-- Генерируем последовательность месяцев
Months AS (
    SELECT @FirstDate AS [Month]

    UNION ALL

    SELECT DATEADD(month, 1, [Month])  AS [Month]
    FROM [Months]
    WHERE DATEADD(month, 1, [Month]) <= @LastDate
),
-- Вычисляем данные о месяцах и товарах с низким спросом
LowQtyGoods AS (
    SELECT
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) AS [month]
        ,iln.StockItemID
    FROM [Sales].[InvoiceLines] AS iln
        JOIN Sales.Invoices     AS inv ON iln.InvoiceID = inv.InvoiceID
    GROUP BY
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate)
        ,iln.StockItemID
    HAVING
        SUM(iln.Quantity) < @treshhold
)
-- Собираем отчёт
SELECT
     Months.[month]                               AS AllMonths
    ,YEAR(inv.InvoiceDate)                        AS [year]
    ,MONTH(inv.InvoiceDate)                       AS [month]
    ,isnull(SUM(iln.UnitPrice * iln.Quantity),0)  AS SalesSum
    ,MIN(inv.InvoiceDate)                         AS FirstSaleDate
    ,isnull(SUM(iln.Quantity),0)                  AS SoldQty
FROM
    [Sales].[InvoiceLines]  AS iln
    JOIN Sales.Invoices     AS inv  ON iln.InvoiceID = inv.InvoiceID
    JOIN LowQtyGoods        AS lqg  ON DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) = lqg.[month]
                                       AND iln.StockItemID = lqg.StockItemID
    RIGHT JOIN Months               ON DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) = Months.[month]
GROUP BY
     Months.[month]
    ,YEAR(inv.InvoiceDate)
    ,MONTH(inv.InvoiceDate)
ORDER BY
     Months.[month];
