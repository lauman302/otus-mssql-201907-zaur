/* 1. Выберите сотрудников, которые являются продажниками, и еще не сделали
ни одной продажи. */

USE WideWorldImporters;

-- Вложенный запрос
SELECT
     [People].[PersonID]
    ,[People].[FullName]
FROM
    [Application].[People]
WHERE
    [People].[IsSalesperson] = 1
    AND [People].[PersonID] NOT IN
        (SELECT [Orders].[SalespersonPersonID] FROM [Sales].[Orders]);


-- WITH (Странный способ)
WITH UnsucceedSalesPersons AS (
    SELECT People.PersonID
    FROM Application.People
    WHERE People.IsSalesperson = 1
    EXCEPT
    SELECT [Orders].[SalespersonPersonID] AS PersonID
    FROM [Sales].[Orders]
)
SELECT
     [usp].[PersonID]
    ,[People].[FullName]
FROM
    UnsucceedSalesPersons AS usp
    JOIN [Application].[People] ON usp.PersonID = People.PersonID;
