/*
3. Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
*/

USE WideWorldImporters;

-- функция
IF OBJECT_ID ( 'Sales.fGetInvoices' , 'IF' ) IS NOT NULL
    DROP FUNCTION Sales.fGetInvoices;
GO

CREATE FUNCTION Sales.fGetInvoices (@year int)
RETURNS TABLE
AS
RETURN
(
    SELECT iv.InvoiceID, iv.CustomerID, iv.OrderID, iv.DeliveryMethodID, iv.ContactPersonID, iv.SalespersonPersonID, iv.InvoiceDate, iv.TotalDryItems
    FROM Sales.Invoices AS iv
    WHERE year(iv.InvoiceDate) = @year
);
GO

EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Функция возвращает все с/ф за указанный год',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'FUNCTION',  @level1name = 'fGetInvoices';
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'год выборки с/ф',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'FUNCTION',  @level1name = 'fGetInvoices',
                                @level2type = N'PARAMETER',  @level2name = '@year';
GO

-- процедура
-- При выполнении процедуры в транзакции достаточно уровня изоляции READ COMMITED т.к. она выполняет простую выборку данных.
IF OBJECT_ID ( 'Sales.pGetInvoices' , 'P' ) IS NOT NULL
    DROP PROCEDURE Sales.pGetInvoices;
GO
CREATE PROCEDURE Sales.pGetInvoices
    @year int
AS
BEGIN
    SELECT iv.InvoiceID, iv.CustomerID, iv.OrderID, iv.DeliveryMethodID, iv.ContactPersonID, iv.SalespersonPersonID, iv.InvoiceDate, iv.TotalDryItems
    FROM Sales.Invoices AS iv
    WHERE year(iv.InvoiceDate) = @year
END;
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Процедура возвращает все с/ф за указанный год',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'PROCEDURE',  @level1name = 'pGetInvoices';
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Год выборки с/ф',
                                @level0type = N'SCHEMA', @level0name = 'Sales', @level1type = N'PROCEDURE',  @level1name = 'pGetInvoices',
                                @level2type = N'PARAMETER',  @level2name = '@year';
GO

SET STATISTICS TIME,IO ON

print '-[F]---------------------'
select * from Sales.fGetInvoices (2016);
print '-[SP]--------------------'
EXEC Sales.pGetInvoices @year = 2016;

-- и в обратном порядке
print '-[SP]--------------------'
EXEC Sales.pGetInvoices @year = 2016;
print '-[F]---------------------'
select * from Sales.fGetInvoices (2016);

print '----------------------'

SET STATISTICS TIME,IO OFF
