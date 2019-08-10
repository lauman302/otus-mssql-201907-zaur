/*
3. Продажи с названием месяца, в котором была продажа, номером квартала, 
к которому относится продажа, включите также к какой трети года относится 
дата - каждая треть по 4 месяца, дата забора заказа должна быть задана, 
с ценой товара более 100$ либо количество единиц товара более 20. 
*/

USE [WideWorldImporters];

SET LANGUAGE Russian;

SELECT
    datename(month, orders.OrderDate)              AS [Месяц]
   ,datepart(quarter, orders.OrderDate)            AS [Квартал]
   ,(datepart(month, orders.OrderDate)-1)/4 + 1    AS [Треть]
   ,*
FROM
    [Sales].[Orders]            AS orders
    JOIN [Sales].[OrderLines]   AS lines    ON orders.OrderID = lines.OrderID
WHERE
    orders.PickingCompletedWhen IS NOT NULL
    AND (
        lines.Quantity > 20
        OR lines.UnitPrice > 100
    )
;

----

/*
Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000
и отобразив следующие 100 записей. Соритровка должна быть по номеру квартала,
трети года, дате продажи. 
*/

SELECT
    datename(month, orders.OrderDate)              AS [Месяц]
   ,datepart(quarter, orders.OrderDate)            AS [Квартал]
   ,(datepart(month, orders.OrderDate)-1)/4 + 1    AS [Треть]
   ,*
FROM
    [Sales].[Orders]            AS orders
    JOIN [Sales].[OrderLines]   AS lines    ON orders.OrderID = lines.OrderID
WHERE
    orders.PickingCompletedWhen IS NOT NULL
    AND (
        lines.Quantity > 20
        OR lines.UnitPrice > 100
    )
ORDER BY
    [Квартал]
   ,[Треть]
   ,orders.OrderDate
OFFSET 1000 ROWS FETCH NEXT 100 ROWS ONLY;
