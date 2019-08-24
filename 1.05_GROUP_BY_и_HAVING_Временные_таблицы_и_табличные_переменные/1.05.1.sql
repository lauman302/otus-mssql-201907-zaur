/*
1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
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
ORDER BY
    [Month];

-- Сложный вариант, все месяца
DECLARE
    @FirstDate  date = NULL
   ,@LastDate   date = NULL;

-- Если даты не переданы, то определяем минимальную и максимальную из таблицы
SELECT
    @FirstDate = ISNULL(@FirstDate, MIN(Invoices.InvoiceDate))
   ,@LastDate  = ISNULL(@LastDate,  MAX(Invoices.InvoiceDate))
FROM
    Sales.Invoices;

-- Приводим даты к месяцам
SELECT
    @FirstDate = DATEADD(day, 1-DATEPART(day, @FirstDate), @FirstDate)
   ,@LastDate  = DATEADD(day, 1-DATEPART(day, @LastDate),  @LastDate);


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
