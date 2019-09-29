/*
5. Пишем динамический PIVOT.

    По заданию из 8го занятия про CROSS APPLY и PIVOT
    Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:

    ```
            Название клиента
    МесяцГод Количество покупок
    ```

    Нужно написать запрос, который будет генерировать результаты для всех клиентов.
    - имя клиента указывать полностью из CustomerName
    - дата должна иметь формат dd.mm.yyyy например 25.12.2019
*/

USE WideWorldImporters;

DECLARE
    @limit      int = 50        -- ограничение количества клиентов. Клиентов слишком много,
                                -- со всеми клиентами строка превышает 8000 символов и запрос ломается.
    ,@customers nvarchar(max)   -- строка со списком клиентов
    ,@query     nvarchar(max)   -- текст запроса
    ,@run_mode  tinyint = 0;    -- 0 -- debug, 1 -- exec, 2 -- sp_executesql


WITH cte AS (
    SELECT DISTINCT TOP (@limit) c.CustomerName FROM Sales.Customers AS c
)
SELECT @customers = '[' + string_agg(CustomerName, '],[') + ']' FROM cte;

SET @query='WITH cteSales AS (
    SELECT
        c.CustomerName
      , dateadd(month, datediff(month, 0, i.InvoiceDate), 0)  AS YearMonth
      , i.InvoiceID
    FROM
        Sales.Customers          AS c
        LEFT JOIN Sales.Invoices AS i ON c.CustomerID = i.CustomerID
)
SELECT format(YearMonth, ''dd.MM.yyyy'') AS ' + @customers + '
FROM (SELECT CustomerName, YearMonth, InvoiceID FROM cteSales) AS cte
PIVOT (
    count(InvoiceID)
    FOR CustomerName IN (' + @customers + ')
) AS pvt
ORDER BY
    YearMonth;';

if @run_mode = 0
    print @query;

if @run_mode = 1
    EXEC (@query);

if @run_mode = 2
    EXEC sp_executesql @query;

GO
