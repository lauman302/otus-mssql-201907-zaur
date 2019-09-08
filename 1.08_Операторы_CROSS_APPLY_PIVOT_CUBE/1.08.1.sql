/*
1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
    ```
             | Название клиента
    МесяцГод | Количество покупок
    ```
    * Клиентов взять с ID 2-6, это все подразделение Tailspin Toys;
    * имя клиента нужно поменять так чтобы осталось только уточнение. Например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY;
    * дата должна иметь формат dd.mm.yyyy например 25.12.2019.

    Например, как должны выглядеть результаты:
    ```
    InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
    01.01.2013 3 1 4 2 2
    01.02.2013 7 3 4 2 1
    ```
*/

USE WideWorldImporters;

WITH cteSales AS (
    SELECT
        replace(replace( c.CustomerName, 'Tailspin Toys (', ''), ')','') AS Customer
        , dateadd(month, datediff(month, 0, i.InvoiceDate), 0)  AS YearMonth
        , i.InvoiceID
        -- , *
    FROM
        Sales.Customers          AS c
        LEFT JOIN Sales.Invoices AS i ON c.CustomerID = i.CustomerID

    WHERE c.CustomerID IN (2, 3, 4, 5, 6)
)
SELECT format(YearMonth, 'dd.MM.yyyy') AS [InvoiceMonth], [Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT]
FROM (SELECT Customer, YearMonth, InvoiceID FROM cteSales) AS cte
PIVOT (
    count(InvoiceID)
    FOR Customer IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])
) AS pvt
ORDER BY
    YearMonth;
