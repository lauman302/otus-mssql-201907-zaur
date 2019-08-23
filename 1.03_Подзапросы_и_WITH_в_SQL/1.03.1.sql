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


-- WITH (Для этого кейса разумного применения не придумал)
