/*
4. Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

*/

USE WideWorldImporters;

IF OBJECT_ID ( 'Sales.fGetLines' , 'IF' ) IS NOT NULL
    DROP FUNCTION Sales.fGetLines
GO

CREATE FUNCTION Sales.fGetLines (@inv_id int)
RETURNS TABLE
AS
RETURN
(
    SELECT il.StockItemID, il.Quantity, il.UnitPrice, (il.Quantity + il.UnitPrice) AS SumOfRow
    FROM Sales.InvoiceLines AS il
    WHERE il.InvoiceID = @inv_id
);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Функция возвращает все строки с/ф по ID',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'FUNCTION',  @level1name = 'fGetLines';
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ID с/ф',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'FUNCTION',  @level1name = 'fGetLines',
                                @level2type = N'PARAMETER',  @level2name = '@inv_id';
GO

-- Запрос с использованием табличной функции.
-- Также использована функция fGetInvoices из задания 3.
select
    iv.InvoiceID, iv.CustomerID, iv.OrderID, iv.DeliveryMethodID, iv.ContactPersonID, iv.SalespersonPersonID, iv.InvoiceDate, iv.TotalDryItems
  , il.StockItemID, il.Quantity, il.UnitPrice, il.SumOfRow
from
    Sales.fGetInvoices (2016) AS iv
    cross apply Sales.fGetLines(iv.InvoiceID) as il
order by
    InvoiceID;
