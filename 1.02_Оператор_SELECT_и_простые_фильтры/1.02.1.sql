/* 
1. Все товары, в которых в название есть пометка urgent или название начинается с Animal. 
*/

USE [WideWorldImporters];

SELECT TOP(100) 
    * 
FROM 
    [Warehouse].[StockItems] AS si
WHERE
    [si].StockItemName LIKE '%urgent%'
    OR [si].StockItemName LIKE 'Animal%';
