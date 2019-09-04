/*
4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал.
В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки
*/

USE WideWorldImporters;

-- без CTE/подзапроса.
SELECT TOP(1) WITH TIES
    p.PersonID
    ,p.FullName                 AS [ФИО]
    ,c.CustomerID
    ,c.CustomerName             AS [Название клиента]
    ,i.InvoiceDate              AS [Дата продажи]
    ,(l.UnitPrice * l.Quantity) AS [Сумма сделки]
    -- ,*
FROM
    Application.People          AS p
    -- Я знаю, что группировка JOIN'ов встречается редко. Но я попробовал оба варианта,
    -- и план запроса для сгруппированного варианта понравился мне чуть больше.
    LEFT JOIN Sales.Invoices    AS i
        JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
        JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
    ON p.PersonID = i.SalespersonPersonID
WHERE
    p.IsEmployee = 1
ORDER BY
    row_number() OVER (PARTITION BY p.PersonID ORDER BY i.InvoiceDate DESC);

-- с CTE. Более универсальный вариант.
WITH sales_cte AS (
    SELECT
        p.PersonID
        ,p.FullName
        ,c.CustomerID
        ,c.CustomerName
        ,i.InvoiceDate
        ,(l.UnitPrice * l.Quantity) AS Summ
        ,row_number() OVER (PARTITION BY p.PersonID ORDER BY i.InvoiceDate DESC) AS N
    FROM
        Application.People          AS p
        LEFT JOIN Sales.Invoices    AS i
            JOIN Sales.InvoiceLines AS l ON i.InvoiceID = l.InvoiceID
            JOIN Sales.Customers    AS c ON i.CustomerID = c.CustomerID
        ON p.PersonID = i.SalespersonPersonID
    WHERE
        p.IsEmployee = 1
)
SELECT  cte.PersonID, cte.FullName, cte.CustomerID, cte.CustomerName, cte.InvoiceDate, cte.Summ
FROM    sales_cte  AS cte
WHERE   N <= 1;
