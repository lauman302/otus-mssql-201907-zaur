/*
4. Написать MERGE, который вставит вставит запись в клиенты, если ее там нет, и изменит если она уже есть
*/

USE WideWorldImporters;

-- Таблица с "внешними" данными
DROP TABLE IF EXISTS #CustomerSource;
GO

CREATE TABLE #CustomerSource(
	[CustomerName]                [nvarchar](100)   NOT NULL,
	[BillToCustomerID]            [int]             NOT NULL,
	[CustomerCategoryID]          [int]             NOT NULL,
	[PrimaryContactPersonID]      [int]             NOT NULL,
	[DeliveryMethodID]            [int]             NOT NULL,
	[DeliveryCityID]              [int]             NOT NULL,
	[PostalCityID]                [int]             NOT NULL,
    [AccountOpenedDate]           [date]            NOT NULL,
	[StandardDiscountPercentage]  [decimal](18, 3)  NOT NULL,
	[IsStatementSent]             [bit]             NOT NULL,
	[IsOnCreditHold]              [bit]             NOT NULL,
	[PaymentDays]                 [int]             NOT NULL,
	[PhoneNumber]                 [nvarchar](20)    NOT NULL,
	[FaxNumber]                   [nvarchar](20)    NOT NULL,
	[WebsiteURL]                  [nvarchar](256)   NOT NULL,
	[DeliveryAddressLine1]        [nvarchar](60)    NOT NULL,
	[DeliveryPostalCode]          [nvarchar](10)    NOT NULL,
	[PostalAddressLine1]          [nvarchar](60)    NOT NULL,
	[PostalPostalCode]            [nvarchar](10)    NOT NULL,
	[LastEditedBy]                [int]             NOT NULL
);
GO

-- Генерируем "внешние" тестовые данные из существующих
INSERT INTO #CustomerSource
SELECT TOP(30)
     [CustomerName]
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
FROM Sales.Customers
ORDER BY hashbytes('sha1', Customers.DeliveryAddressLine1 + CustomerName);

WITH StringsForUpdate AS (
    SELECT TOP(10) *
    FROM #CustomerSource
)
UPDATE StringsForUpdate SET CustomerName = CustomerName + ' (Duplicated)';

-- select * from #CustomerSource

-- Условием соедниения будет название клиента, т.к. оно в рамках таблицы уникально,
-- а внешние данные совершенно не обязательно должны оперировать теми же ключами.
--
-- В реальной жизни я бы так делать не стал т.к. названия часто заносят люди,
-- малейший пробел "не там", и совпадения не будет. Скорее где-то дополнительно
-- хранил бы ключи внешней таблицы для последующих слияний или использовал
-- "естественные" идентификаторы типа ИНН (хотя и они не очень хороши).

-- В MERGE нельзя использовать SEQUENCE, как задавать CustomerID?
-- По результатам экспериментов, он просто присвоился сам, но где описано такое
-- поведение я не нашёл (в скрипт генерации таблицы посмотрел).

MERGE Sales.Customers AS target
USING #CustomerSource AS source
-- Нужен COLLATE, видимо какие-то расхождения в настройке MS SQL из Docker
-- и БД WideWorldImporters.
ON (source.CustomerName = target.CustomerName COLLATE Latin1_General_100_CI_AS)
WHEN MATCHED
    THEN UPDATE SET  [BillToCustomerID]             = source.[BillToCustomerID]
                    -- [CustomerCategoryID] обновляться (например) не должен
                    ,[PrimaryContactPersonID]       = source.[PrimaryContactPersonID]
                    ,[DeliveryMethodID]             = source.[DeliveryMethodID]
                    ,[DeliveryCityID]               = source.[DeliveryCityID]
                    ,[PostalCityID]                 = source.[PostalCityID]
                    ,[AccountOpenedDate]            = source.[AccountOpenedDate]
                    ,[StandardDiscountPercentage]   = source.[StandardDiscountPercentage]
                    ,[IsStatementSent]              = source.[IsStatementSent]
                    ,[IsOnCreditHold]               = source.[IsOnCreditHold]
                    ,[PaymentDays]                  = source.[PaymentDays]
                    ,[PhoneNumber]                  = source.[PhoneNumber]
                    ,[FaxNumber]                    = source.[FaxNumber]
                    ,[WebsiteURL]                   = source.[WebsiteURL]
                    ,[DeliveryAddressLine1]         = source.[DeliveryAddressLine1]
                    ,[DeliveryPostalCode]           = source.[DeliveryPostalCode]
                    ,[PostalAddressLine1]           = source.[PostalAddressLine1]
                    ,[PostalPostalCode]             = source.[PostalPostalCode]
                    ,[LastEditedBy]                 = 1 -- Data Conversion Only
WHEN NOT MATCHED
    THEN INSERT (
        [CustomerName]
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
    ) VALUES (
        source.[CustomerName]
        ,source.[BillToCustomerID]
        ,source.[CustomerCategoryID]
        ,source.[PrimaryContactPersonID]
        ,source.[DeliveryMethodID]
        ,source.[DeliveryCityID]
        ,source.[PostalCityID]
        ,source.[AccountOpenedDate]
        ,source.[StandardDiscountPercentage]
        ,source.[IsStatementSent]
        ,source.[IsOnCreditHold]
        ,source.[PaymentDays]
        ,source.[PhoneNumber]
        ,source.[FaxNumber]
        ,source.[WebsiteURL]
        ,source.[DeliveryAddressLine1]
        ,source.[DeliveryPostalCode]
        ,source.[PostalAddressLine1]
        ,source.[PostalPostalCode]
        ,1 -- Data Conversion Only
    )
OUTPUT
    $action, 'before', deleted.*, 'after', inserted.*;

DROP TABLE IF EXISTS #CustomerSource;
GO
