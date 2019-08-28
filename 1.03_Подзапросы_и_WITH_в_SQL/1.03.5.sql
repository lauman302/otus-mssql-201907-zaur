/*
5. Объясните, что делает и оптимизируйте запрос.

Приложите план запроса и его анализ, а также ход ваших рассуждений по поводу
оптимизации.

Можно двигаться как в сторону улучшения читабельности запроса (что уже было
в материале лекций), так и в сторону упрощения плана\ускорения.
*/

USE WideWorldImporters;

-- Исходный запрос
SELECT
    Invoices.InvoiceID
    ,Invoices.InvoiceDate
    ,(SELECT
        People.FullName
    FROM
        Application.People
    WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName
    ,SalesTotals.TotalSumm AS TotalSummByInvoice
    ,(SELECT
        SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
    FROM
        Sales.OrderLines
    WHERE OrderLines.OrderId = (SELECT
        Orders.OrderId
    FROM
        Sales.Orders
    WHERE Orders.PickingCompletedWhen IS NOT NULL
        AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM
    Sales.Invoices
    JOIN
    (SELECT
        InvoiceId
        ,SUM(Quantity*UnitPrice) AS TotalSumm
    FROM
        Sales.InvoiceLines
    GROUP BY InvoiceId
    HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
    ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC;

-- оптимизированный
WITH
-- Сумма продаж на каждый счёт-фактуру
SalesTotals AS (
    SELECT   il.InvoiceId, SUM(il.Quantity * il.UnitPrice) AS TotalSumm
    FROM     Sales.InvoiceLines AS il
    GROUP BY il.InvoiceId
    HAVING   SUM(il.Quantity * il.UnitPrice) > 27000
),
-- Сумма для доставленных заказов
TotalSummForPickedItems AS (
    SELECT   ol.OrderID,
             SUM(ol.PickedQuantity * ol.UnitPrice) AS PickedTotalSumm
    FROM     Sales.OrderLines AS ol
             JOIN Sales.Orders ON ol.OrderId = Orders.OrderID
    WHERE    Orders.PickingCompletedWhen IS NOT NULL
    GROUP BY ol.OrderID
)
-- Список счетов-фактур с суммой "по документам" и суммой для доставленных заказов
SELECT
    Invoices.InvoiceID,
    Invoices.InvoiceDate,
    People.FullName                         AS SalesPersonName,
    SalesTotals.TotalSumm                   AS TotalSummByInvoice,
    TotalSummForPickedItems.PickedTotalSumm AS TotalSummForPickedItems
FROM
    Sales.Invoices
    JOIN SalesTotals             ON Invoices.InvoiceID = SalesTotals.InvoiceID
    JOIN TotalSummForPickedItems ON Invoices.OrderId = TotalSummForPickedItems.OrderId
    JOIN Application.People      ON Invoices.SalespersonPersonID = People.PersonID
ORDER BY
    SalesTotals.TotalSumm DESC;
