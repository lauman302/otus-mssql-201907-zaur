# Популярные Hint'ы и подсказки оптимизатору

## Оптимизируем запрос

Цель: Используем все свои полученные знания для оптимизации сложного запроса.

Вариант 1. Вы можете взять запрос со своей работы с планом и показать, что было до оптимизации,
какие решения вы применили, и что стало после. В этом случае нужно приложить Текст запроса,
актуальный план и статистики по времени и операциям ввода\вывода до оптимизации и после оптимизации.
Опишите кратко ход рассуждений при оптимизации.

Вариант 2. Оптимизируйте запрос по БД WorldWideImporters. Приложите текст запроса со статистиками
по времени и операциям ввода вывода, опишите кратко ход рассуждений при оптимизации.
```
Select ord.CustomerID, det.StockItemID, SUM(det.UnitPrice), SUM(det.Quantity), COUNT(ord.OrderID) FROM Sales.Orders AS ord JOIN Sales.OrderLines AS det ON det.OrderID = ord.OrderID JOIN Sales.Invoices AS Inv ON Inv.OrderID = ord.OrderID JOIN Sales.CustomerTransactions AS Trans ON Trans.InvoiceID = Inv.InvoiceID JOIN Warehouse.StockItemTransactions AS ItemTrans ON ItemTrans.StockItemID = det.StockItemID WHERE Inv.BillToCustomerID != ord.CustomerID AND (Select SupplierId FROM Warehouse.StockItems AS It Where It.StockItemID = det.StockItemID) = 12 AND (SELECT SUM(Total.UnitPrice*Total.Quantity) FROM Sales.OrderLines AS Total Join Sales.Orders AS ordTotal On ordTotal.OrderID = Total.OrderID WHERE ordTotal.CustomerID = Inv.CustomerID) > 250000 AND DATEDIFF(dd, Inv.InvoiceDate, ord.OrderDate) = 0 GROUP BY ord.CustomerID, det.StockItemID ORDER BY ord.CustomerID, det.StockItemID
```

Используем DMV, хинты и все прочее для сложных случаев

## Решение

Выбран вариант с оптимизацией запроса WWI.

Статистики до начала оптимизации после `DBCC FREEPROCCACHE`:

```
SQL Server parse and compile time:
   CPU time = 314 ms, elapsed time = 470 ms.
(3619 rows affected)
Table 'OrderLines'. Scan count 6, logical reads 9467, physical reads 2, read-ahead reads 7214, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Orders'. Scan count 6, logical reads 1293, physical reads 4, read-ahead reads 877, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 2, physical reads 1, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 3, logical reads 11580, physical reads 405, read-ahead reads 11364, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 3, logical reads 514, physical reads 1, read-ahead reads 171, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItemTransactions'. Scan count 7554, logical reads 61250, physical reads 11, read-ahead reads 33, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 4003 ms,  elapsed time = 14329 ms.
Total execution time: 00:00:14.810
```

Отобрано 3619 строк.

1. Уберём первый подзапрос в WHERE в JOIN. Скорее всего, это не улучшит производительность, но упростит читаемость.
2. И InvoiceDate и OrderDate имеют тип date. Можно убрать вычисление datediff в днях и провести простое сравнение.
Кроме того, это условие больше похоже на условие объединения, чем на фильтр, поэтому вынесем его в JOIN.
В целом, между заказами и с/ф есть прямая связь по ID, и это условие выглядит избыточным, но не зная бизнес-задачи
просто убирать его не стоит.
3. Вынесем подзапрос на сумму заказов из WHERE в CTE.
4. JOIN с таблицами `Sales.CustomerTransactions` и `StockItemTransactions` нигде дальше не используются для выборки полей.
Заменим их на условие IN в WHERE.

В целом, после этих изменений статистики выглядят так:
```
SQL Server parse and compile time:
   CPU time = 165 ms, elapsed time = 172 ms.
(3619 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 2, logical reads 96, physical reads 4, read-ahead reads 92, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 1, logical reads 173, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Orders'. Scan count 2, logical reads 883, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'OrderLines'. Scan count 2, logical reads 9262, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItemTransactions'. Scan count 1, logical reads 49, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.

 SQL Server Execution Times:
   CPU time = 483 ms,  elapsed time = 513 ms.
Total execution time: 00:00:00.727
```

Дальнейшую оптимизацию проводить можно, но затраченные усилия не кажутся адекватными возможному результату.
Оптимизированный скрипт в файле `3.25.1.sql`, план выполнения в файле `3.25.1.xml`

Сервер предлагает добавить отсутствующий индекс на таблицу `OrderLines`, но после добавления индекса время выполнения почти не меняются, хотя некоторые операции изменяются со scan на seek:
```
SQL Server parse and compile time:
   CPU time = 121 ms, elapsed time = 139 ms.
(3619 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 2, logical reads 96, physical reads 4, read-ahead reads 92, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 1, logical reads 173, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 11400, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Orders'. Scan count 2, logical reads 882, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'OrderLines'. Scan count 16, logical reads 1011, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItemTransactions'. Scan count 15, logical reads 59, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
(1 row affected)

 SQL Server Execution Times:
   CPU time = 476 ms,  elapsed time = 495 ms.
Total execution time: 00:00:01.429
```
План запроса в файле `3.25.1_w_index.xml`.

После добавления покрывающего индекса на `Sales.Invoices`:
```sql
CREATE NONCLUSTERED INDEX IX_Invoices_OrderID_with_Include
ON Sales.Invoices (OrderID ASC, InvoiceDate ASC)
INCLUDE (
    BillToCustomerID
    ,CustomerID
    ,InvoiceID
    );
```
количество логических чтений уменьшилось:
```
SQL Server parse and compile time:
   CPU time = 101 ms, elapsed time = 126 ms.
(3619 rows affected)
Table 'Worktable'. Scan count 0, logical reads 0, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Workfile'. Scan count 2, logical reads 96, physical reads 4, read-ahead reads 92, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'CustomerTransactions'. Scan count 1, logical reads 173, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Invoices'. Scan count 1, logical reads 221, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'OrderLines'. Scan count 16, logical reads 1011, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItemTransactions'. Scan count 15, logical reads 59, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'StockItems'. Scan count 1, logical reads 2, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
Table 'Orders'. Scan count 2, logical reads 882, physical reads 0, read-ahead reads 0, lob logical reads 0, lob physical reads 0, lob read-ahead reads 0.
(1 row affected)

 SQL Server Execution Times:
   CPU time = 483 ms,  elapsed time = 494 ms.
Total execution time: 00:00:00.789
```
