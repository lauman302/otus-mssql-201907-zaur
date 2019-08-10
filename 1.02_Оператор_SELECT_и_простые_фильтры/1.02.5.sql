/*
5. 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
*/

USE [WideWorldImporters];

SELECT  TOP(10)
     Orders.OrderDate
    ,Orders.OrderID
    ,Customers.CustomerName
    ,People.FullName                AS SalespersonPersonName
    -- ,Orders.*
    -- ,*
FROM
    [Sales].[Orders]        AS Orders
    JOIN Sales.Customers    AS Customers    ON Orders.CustomerID = Customers.CustomerID
    JOIN Application.People AS People       ON Orders.SalespersonPersonID = People.PersonID
ORDER BY
    orders.OrderDate DESC; -- Продаж на последнюю дату больше 10, выбраны будут произвольные