/*
6. Bonus из предыдущей темы
Напишите запрос, который выбирает 10 клиентов, которые сделали больше 30 заказов и последний заказ был не позднее апреля 2016.
*/

USE WideWorldImporters;

SELECT TOP (10)
    c.CustomerID
    ,c.CustomerName
    ,count(1)           AS OrderQty
    ,max(o.OrderDate)   AS LastOrder
FROM
    Sales.Orders            AS o
    JOIN Sales.Customers    AS c ON o.CustomerID = c.CustomerID
GROUP BY
    c.CustomerID
    ,c.CustomerName
HAVING
    count(1) > 30 AND max(o.OrderDate) < convert(date, '2016-05-01', 120)
-- Порядок сортировки в задании не указан. Выбран произвольно, чтобы TOP(10) не были случайными.
ORDER BY
    OrderQty DESC;
