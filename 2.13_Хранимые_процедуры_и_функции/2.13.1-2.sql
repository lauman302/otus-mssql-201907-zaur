/*
1. Написать функцию возвращающую Клиента с наибольшей суммой покупки.

2. Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
    Использовать таблицы :
    - Sales.Customers
    - Sales.Invoices
    - Sales.InvoiceLines

*/

USE WideWorldImporters;
GO

-- Функция
IF OBJECT_ID ( 'Sales.getMaxSellClientId' , 'FN' ) IS NOT NULL
    DROP FUNCTION Sales.getMaxSellClientId;
GO

CREATE FUNCTION Sales.getMaxSellClientId ()
RETURNS int
AS
BEGIN
    DECLARE @CustomerID int;
    SELECT @CustomerID = (
        SELECT TOP (1)
            c.CustomerID
        FROM
            Sales.Customers as c
            JOIN Sales.Invoices     AS iv ON c.CustomerID = iv.CustomerID
            JOIN Sales.InvoiceLines AS il ON iv.InvoiceID = il.InvoiceID
        GROUP BY
            c.CustomerID, iv.InvoiceID
        ORDER BY
            sum(il.UnitPrice * il.Quantity) DESC
    )
    RETURN (@CustomerID)
END;
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Функция возвращает CustomerID клиента, совершившего максимальную покупку',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'FUNCTION',  @level1name = 'getMaxSellClientId';
GO

-- Процедура
-- При выполнении процедуры в транзакции достаточно уровня изоляции READ COMMITED, т.к. шансы изменения данных между чтениями
-- трёх таблиц крайне невелики. Шансов получить неконсистентные данные тоже нет, таблицы связаны по FK по полям сопоставления.

IF OBJECT_ID ( 'Sales.getMaxClientSell' , 'P' ) IS NOT NULL
    DROP PROCEDURE Sales.getMaxClientSell;
GO
CREATE PROCEDURE Sales.getMaxClientSell
    @ClientID int
AS
BEGIN
    SELECT TOP (1)
            sum(il.UnitPrice * il.Quantity) AS SellSum
        FROM
            Sales.Customers as c
            JOIN Sales.Invoices     AS iv ON c.CustomerID = iv.CustomerID
            JOIN Sales.InvoiceLines AS il ON iv.InvoiceID = il.InvoiceID
        WHERE
            c.CustomerID = @ClientID
        GROUP BY
            c.CustomerID, iv.InvoiceID
        ORDER BY
            sum(il.UnitPrice * il.Quantity) DESC
END;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Процедура возвращает максимальную покупку клиента по его ID',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'PROCEDURE',  @level1name = 'getMaxClientSell';
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID клиента',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'PROCEDURE',  @level1name = 'getMaxClientSell',
                                @level2type = N'PARAMETER',  @level2name = '@ClientID';
GO

-- Пример запуска
DECLARE @cl_id int;
SELECT @cl_id = Sales.getMaxSellClientId();
EXECUTE Sales.getMaxClientSell @ClientID = @cl_id;
GO
