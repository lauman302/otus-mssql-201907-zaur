/*
4. Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post, 
добавьте название поставщика, имя контактного лица принимавшего заказ
*/

USE [WideWorldImporters];

SELECT
    [st].SupplierTransactionID
   ,[st].PurchaseOrderID
   ,[st].SupplierInvoiceNumber
   ,[st].TransactionDate
   ,[st].FinalizationDate
   ,[st].AmountExcludingTax
   ,[st].TaxAmount
   ,[st].TransactionAmount
   ,[su].SupplierName
   ,[dm].DeliveryMethodID
   ,[dm].DeliveryMethodName
   ,[pp].PersonID
   ,[pp].FullName
FROM 
    Purchasing.SupplierTransactions     AS [st]
    JOIN Purchasing.Suppliers           AS [su]     ON st.SupplierID = su.SupplierID
    JOIN Application.DeliveryMethods    AS [dm]     ON su.DeliveryMethodID = dm.DeliveryMethodID
                                                    AND dm.DeliveryMethodID in (1,7)
    JOIN Application.People             AS [pp]     ON su.PrimaryContactPersonID = pp.PersonID

WHERE
    datepart(year, st.FinalizationDate) = 2014;
