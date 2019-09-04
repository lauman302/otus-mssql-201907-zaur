/*
1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:

    Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца
    он будет одинаковый, нарастать будет в течение времени выборки).

    Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом.

    Пример

    ```
    Дата продажи    Нарастающий итог по месяцу
    2015-01-29      4801725.31
    2015-01-30      4801725.31
    2015-01-31      4801725.31
    2015-02-01      9626342.98
    2015-02-02      9626342.98
    2015-02-03      9626342.98
    ```

    Продажи можно взять из таблицы Invoices.
    Нарастающий итог должен быть без оконной функции.
*/

USE WideWorldImporters;


-- Временная таблица
CREATE TABLE #result (
     InvoiceID      int             NOT NULL
    ,CustomerName   varchar(255)    NOT NULL
    ,InvoiceDate    date            NOT NULL
    ,InvoiceSum     decimal(18,2)   NOT NULL
    ,CumulativeSum  decimal(18,2)   NOT NULL
)

SET STATISTICS TIME ON;
GO

INSERT INTO #result (InvoiceID, CustomerName, InvoiceDate, InvoiceSum, CumulativeSum)
SELECT
    i.InvoiceID                     AS [ID продажи]
    ,c.CustomerName                 AS [Название клиента]
    ,i.InvoiceDate                  AS [Дата продажи]
    ,(l.UnitPrice * l.Quantity)     AS [Сумма продажи]
    ,(
        select TOP(1) sum(ll.UnitPrice * ll.Quantity)
        from Sales.Invoices          AS ii
            JOIN Sales.InvoiceLines AS ll ON ii.InvoiceID = ll.InvoiceID
        where
            datediff(month, ii.InvoiceDate, i.InvoiceDate) >= 0
            and ii.InvoiceDate >= convert(date, '2015-01-01', 120)
    ) AS [Сумма продаж за месяц, накопительно]
FROM Sales.Invoices          AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
WHERE
    i.InvoiceDate >= convert(date, '2015-01-01', 120)
ORDER BY
    [Дата продажи], [Название клиента];

SET STATISTICS TIME OFF;
GO

SELECT InvoiceID, CustomerName, InvoiceDate, InvoiceSum, CumulativeSum FROM  #result;

DROP TABLE IF EXISTS #result;
GO

-- Табличная переменная

DECLARE @result  table(
     InvoiceID      int             NOT NULL
    ,CustomerName   varchar(255)    NOT NULL
    ,InvoiceDate    date            NOT NULL
    ,InvoiceSum     decimal(18,2)   NOT NULL
    ,CumulativeSum  decimal(18,2)   NOT NULL
)

INSERT INTO @result (InvoiceID, CustomerName, InvoiceDate, InvoiceSum, CumulativeSum)
SELECT
    i.InvoiceID                     AS [ID продажи]
    ,c.CustomerName                 AS [Название клиента]
    ,i.InvoiceDate                  AS [Дата продажи]
    ,(l.UnitPrice * l.Quantity)     AS [Сумма продажи]
    ,(
        select TOP(1) sum(ll.UnitPrice * ll.Quantity)
        from Sales.Invoices          AS ii
            JOIN Sales.InvoiceLines AS ll ON ii.InvoiceID = ll.InvoiceID
        where
            datediff(month, ii.InvoiceDate, i.InvoiceDate) >= 0
            and ii.InvoiceDate >= convert(date, '2015-01-01', 120)
    ) AS [Сумма продаж за месяц, накопительно]
FROM Sales.Invoices          AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
WHERE
    i.InvoiceDate >= convert(date, '2015-01-01', 120)
ORDER BY
    [Дата продажи], [Название клиента];

SELECT InvoiceID, CustomerName, InvoiceDate, InvoiceSum, CumulativeSum FROM  @result;
