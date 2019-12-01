/*
Вариант 2. Оптимизируйте запрос по БД WorldWideImporters.
Приложите текст запроса со статистиками по времени и операциям ввода вывода, опишите кратко ход рассуждений
при оптимизации.
*/

/* Исходный запрос
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID) FROM Sales.Orders AS ord
JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID
JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID JOIN Warehouse.StockItemTransactions AS ItemTrans
ON ItemTrans.StockItemID = det.StockItemID WHERE Inv.BillToCustomerID != ord.CustomerID AND (Select SupplierId
FROM Warehouse.StockItems AS It Where It.StockItemID = det.StockItemID) = 12 AND (SELECT SUM(Total.UnitPrice*Total.Quantity)
FROM Sales.OrderLines AS Total Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID
= Inv.CustomerID) > 250000 AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID
*/

--3619

-- DBCC FREEPROCCACHE;
-- DBCC FREESYSTEMCACHE ('ALL');

-- USE WideWorldImporters;

-- SET STATISTICS TIME,IO ON;


WITH cteBigCustomers AS (
    SELECT ordTotal.CustomerID
    FROM Sales.OrderLines AS Total
        JOIN Sales.Orders AS ordTotal ON ordTotal.OrderID = Total.OrderID
    GROUP BY ordTotal.CustomerID
    HAVING SUM(Total.UnitPrice*Total.Quantity) > 250000
)
SELECT
    ord.CustomerID
    , det.StockItemID
    , SUM(det.UnitPrice)
    , SUM(det.Quantity)
    , COUNT(ord.OrderID)
FROM
    Sales.Orders                         AS ord
    JOIN Sales.OrderLines                AS det       ON ord.OrderID = det.OrderID
    JOIN Warehouse.StockItems            AS It        ON det.StockItemID = It.StockItemID
    JOIN Sales.Invoices                  AS Inv       ON ord.OrderID = Inv.OrderID AND ord.OrderDate = Inv.InvoiceDate
WHERE
    Inv.BillToCustomerID != ord.CustomerID
    AND It.SupplierId = 12
    AND det.StockItemID IN (SELECT ItemTrans.StockItemID FROM Warehouse.StockItemTransactions AS ItemTrans)
    AND Inv.InvoiceID IN (SELECT Trans.InvoiceID FROM Sales.CustomerTransactions AS Trans)
    AND Inv.CustomerID IN (SELECT bc.CustomerID FROM cteBigCustomers AS bc)
GROUP BY ord.CustomerID, det.StockItemID
ORDER BY ord.CustomerID, det.StockItemID;

-- SET STATISTICS TIME,IO OFF;
