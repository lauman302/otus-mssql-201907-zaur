/*3. Выберите информацию по клиентам, которые перевели компании 5 максимальных
платежей из `[Sales].[CustomerTransactions]` представьте 3 способа (в том числе
с CTE)*/

USE WideWorldImporters;

-- 1
WITH TopAmountClients AS (
    SELECT TOP(3) CustomerTransactions.CustomerID
    FROM        Sales.CustomerTransactions
    ORDER BY    CustomerTransactions.TransactionAmount DESC
)

SELECT
    Customers.CustomerID
   ,Customers.CustomerName
FROM
    Sales.Customers
    JOIN TopAmountClients
        ON Customers.CustomerID = TopAmountClients.CustomerID;

-- 2
SELECT
    Customers.CustomerID
   ,Customers.CustomerName
FROM
    Sales.Customers
WHERE
    Customers.CustomerID IN (
        SELECT TOP(3) CustomerTransactions.CustomerID
        FROM        Sales.CustomerTransactions
        ORDER BY    CustomerTransactions.TransactionAmount DESC
    );

-- 3
SELECT
    Customers.CustomerID
   ,Customers.CustomerName
FROM
    Sales.Customers
    JOIN (
        SELECT TOP(3) CustomerTransactions.CustomerID
        FROM        Sales.CustomerTransactions
        ORDER BY    CustomerTransactions.TransactionAmount DESC
    ) AS TopAmountClients ON Customers.CustomerID = TopAmountClients.CustomerID;
