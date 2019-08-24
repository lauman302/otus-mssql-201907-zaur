/*
2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
*/

USE WideWorldImporters;

-- Простой вариант
SELECT
    DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) AS [Month]
    ,AVG(iln.UnitPrice)                                             AS AveragePrice
    ,SUM(iln.UnitPrice * iln.Quantity)                              AS SalesSum
FROM
    [Sales].[InvoiceLines]  AS iln
    JOIN Sales.Invoices     AS inv ON iln.InvoiceID = inv.InvoiceID
GROUP BY
    DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate)
HAVING
    SUM(iln.UnitPrice * iln.Quantity) > 10000;


-- Сложный вариант, все месяца
--
-- Не очень понятно как трактовать одновременно условия "месяцы, где общая сумма больше..." и
-- "если за какой-то месяц не было продаж, то этот месяц тоже должен быть в результате".
-- Сейчас сделано, что для месяцев, не удовлетворяющих условиям, выводятся нули.

DECLARE
    @FirstDate  date = CONVERT(date, '2012-11-01', 120)
   ,@LastDate   date = CONVERT(date, '2016-12-01', 120)
   ,@treshhold  int  = 10000;

WITH
-- Генерируем последовательность месяцев
Months AS (
    SELECT @FirstDate AS [Month]

    UNION ALL

    SELECT DATEADD(month, 1, [Month])  AS [Month]
    FROM [Months]
    WHERE DATEADD(month, 1, [Month]) <= @LastDate
),
-- Вычисляем данные о продажах
SalesData AS (
    SELECT
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate) AS [Month]
        ,AVG(iln.UnitPrice)                                             AS AveragePrice
        ,SUM(iln.UnitPrice * iln.Quantity)                              AS SalesSum
    FROM
        [Sales].[InvoiceLines]  AS iln
        JOIN Sales.Invoices     AS inv ON iln.InvoiceID = inv.InvoiceID
    GROUP BY
        DATEADD(day, 1-DATEPART(day, inv.InvoiceDate), inv.InvoiceDate)
    HAVING
        SUM(iln.UnitPrice * iln.Quantity) > @treshhold
)
-- Собираем отчёт
SELECT
    mm.[Month]
    ,ISNULL(sa.SalesSum, 0)     AS SalesSum
    ,ISNULL(sa.AveragePrice, 0) AS AveragePrice
FROM
    Months              AS mm
    LEFT JOIN SalesData AS sa ON mm.[Month] = sa.[Month]
ORDER BY
    mm.[Month];
