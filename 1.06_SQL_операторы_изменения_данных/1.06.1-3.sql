-- подготовительные операции

USE WideWorldImporters;

DECLARE @history TABLE (
    RecordID    int        NOT NULL,
    Operation   varchar(3) NOT NULL,
    [timestamp] datetime2  NOT NULL
);

/*
1. Довставлять в базу 5 записей используя insert в таблицу Customers или Suppliers
*/

INSERT INTO Sales.Customers(
    [CustomerID]
    ,[CustomerName]
    ,[BillToCustomerID]
    ,[CustomerCategoryID]
    ,[PrimaryContactPersonID]
    ,[DeliveryMethodID]
    ,[DeliveryCityID]
    ,[PostalCityID]
    ,[AccountOpenedDate]
    ,[StandardDiscountPercentage]
    ,[IsStatementSent]
    ,[IsOnCreditHold]
    ,[PaymentDays]
    ,[PhoneNumber]
    ,[FaxNumber]
    ,[WebsiteURL]
    ,[DeliveryAddressLine1]
    ,[DeliveryPostalCode]
    ,[PostalAddressLine1]
    ,[PostalPostalCode]
    ,[LastEditedBy]
)
OUTPUT inserted.CustomerID, 'ins', getdate()
    INTO @history (RecordID, Operation, [timestamp])
VALUES
    (NEXT VALUE FOR Sequences.CustomerID, 'TestCustomer 001', 1, 1, 1113,  3, 18514, 18514, GETDATE(), 0.0, 0, 0, 7,
        '+7 (999) 555-0001', '+7 (999) 555-0002', 'http://www.ru', '1-13, Nowhere lane', '99555', '1-13, Nowhere lane', '99555', 7)
    ,(NEXT VALUE FOR Sequences.CustomerID, 'TestCustomer 002', 1, 1, 1115, 3, 18514, 18514, GETDATE(), 0.0, 0, 0, 7,
        '+7 (999) 555-0003', '+7 (999) 555-0004', 'http://www.ru', '1-14, Nowhere lane', '99555', '1-14, Nowhere lane', '99555', 7)
    ,(NEXT VALUE FOR Sequences.CustomerID, 'TestCustomer 003', 1, 1, 1117, 3, 18514, 18514, GETDATE(), 0.0, 0, 0, 7,
        '+7 (999) 555-0005', '+7 (999) 555-0006', 'http://www.ru', '1-15, Nowhere lane', '99555', '1-15, Nowhere lane', '99555', 7)
    ,(NEXT VALUE FOR Sequences.CustomerID, 'TestCustomer 004', 1, 1, 1119, 3, 18514, 18514, GETDATE(), 0.0, 0, 0, 7,
        '+7 (999) 555-0007', '+7 (999) 555-0008', 'http://www.ru', '1-16, Nowhere lane', '99555', '1-16, Nowhere lane', '99555', 7)
    ,(NEXT VALUE FOR Sequences.CustomerID, 'TestCustomer 005', 1, 1, 1121, 3, 18514, 18514, GETDATE(), 0.0, 0, 0, 7,
        '+7 (999) 555-0009', '+7 (999) 555-0010', 'http://www.ru', '1-17, Nowhere lane', '99555', '1-17, Nowhere lane', '99555', 7);


/* 2. удалите 1 запись из Customers, которая была вами добавлена */

DELETE FROM Sales.Customers
OUTPUT deleted.CustomerID, 'del', getdate()
    INTO @history (RecordID, Operation, [timestamp])
WHERE CustomerID IN (SELECT TOP(1) h.RecordID FROM @history AS h);


/* 3. изменить одну запись, из добавленных через UPDATE */
UPDATE Sales.Customers
SET WebsiteURL = 'http://www.net'
OUTPUT inserted.CustomerID, 'upd', getdate()
    INTO @history (RecordID, Operation, [timestamp])
WHERE CustomerID IN (
    SELECT TOP(1) h.RecordID
    FROM   @history AS h
    WHERE  Operation = 'ins'
           AND NOT EXISTS (
               SELECT 1
               FROM @history AS h1
               WHERE h1.Operation = 'del'
                 AND h1.RecordID = h.RecordID
            )
);

-- Удалим все оставшиеся тестовые записи
DELETE FROM Sales.Customers
OUTPUT deleted.CustomerID, 'del', getdate()
    INTO @history (RecordID, Operation, [timestamp])
WHERE CustomerName like 'TestCustomer%';

-- Покажем историю изменений
SELECT h.RecordID, h.Operation, h.[timestamp] FROM @history AS h;
