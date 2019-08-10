/* 
2. Поставщиков, у которых не было сделано ни одного заказа (сделайте через JOIN). 
*/

USE [WideWorldImporters];

SELECT
    *
FROM
    [Purchasing].[Suppliers]                AS sup
    LEFT JOIN [Purchasing].[PurchaseOrders] AS ord  ON sup.SupplierID = ord.SupplierID
WHERE
    ord.SupplierID IS NULL;
