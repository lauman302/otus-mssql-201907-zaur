/*
4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
*/

USE WideWorldImporters;

-- Дано
DROP TABLE IF EXISTS dbo.MyEmployees;
GO

CREATE TABLE dbo.MyEmployees
(
    EmployeeID smallint NOT NULL
    ,FirstName nvarchar(30) NOT NULL
    ,LastName nvarchar(40) NOT NULL
    ,Title nvarchar(50) NOT NULL
    ,DeptID smallint NOT NULL
    ,ManagerID int NULL
    ,CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
);

INSERT INTO dbo.MyEmployees
VALUES
    (1 ,N'Ken' ,N'Sánchez' ,N'Chief Executive Officer' ,16 ,NULL)
    ,(273 ,N'Brian' ,N'Welcker' ,N'Vice President of Sales' ,3 ,1)
    ,(274 ,N'Stephen' ,N'Jiang' ,N'North American Sales Manager' ,3 ,273)
    ,(275 ,N'Michael' ,N'Blythe' ,N'Sales Representative' ,3 ,274)
    ,(276 ,N'Linda' ,N'Mitchell' ,N'Sales Representative' ,3 ,274)
    ,(285 ,N'Syed' ,N'Abbas' ,N'Pacific Sales Manager' ,3 ,273)
    ,(286 ,N'Lynn' ,N'Tsoflias' ,N'Sales Representative' ,3 ,285)
    ,(16 ,N'David' ,N'Bradley' ,N'Marketing Manager' ,4 ,273)
    ,(23 ,N'Mary' ,N'Gibson' ,N'Marketing Specialist' ,4 ,16);

-- Временная таблица
-- Вариант `SELECT ... INTO` не рассматривается сознательно.

CREATE TABLE #emps
(
    [EmployeeID]        INT          NOT NULL PRIMARY KEY CLUSTERED
    ,[Name]             NVARCHAR(80) NOT NULL
    ,[Title]            NVARCHAR(50) NOT NULL
    ,[EmployeeLevel]    INT          NOT NULL
);
GO

WITH
    cteRecurse
    AS
    (
        SELECT
            me1.EmployeeID
            ,me1.FirstName + ' ' + me1.Lastname   AS [Name]
            ,me1.Title
            ,1                                    AS EmployeeLevel
            ,me1.ManagerID
        FROM
            dbo.MyEmployees AS me1
        WHERE me1.ManagerID IS NULL

        UNION ALL

        SELECT
            me2.EmployeeID
            ,me2.FirstName + ' ' + me2.Lastname   AS [Name]
            ,me2.Title
            ,cr.EmployeeLevel + 1                 AS EmployeeLevel
            ,me2.ManagerID
        FROM
            dbo.MyEmployees AS me2
            JOIN cteRecurse cr ON me2.ManagerID = cr.EmployeeID
    )

INSERT INTO #emps ([EmployeeID] ,[Name] ,[Title] ,[EmployeeLevel])
SELECT
    EmployeeID
    ,REPLICATE('| ', EmployeeLevel - 1) + [Name]
    ,Title
    ,EmployeeLevel
FROM
    cteRecurse AS cr;

SELECT [EmployeeID], [Name] ,[Title] ,[EmployeeLevel] FROM #emps;

DROP TABLE IF EXISTS #emps;

-- Табличная переменная

DECLARE @emps AS table (
    [EmployeeID]        INT          NOT NULL PRIMARY KEY CLUSTERED
    ,[Name]             NVARCHAR(80) NOT NULL
    ,[Title]            NVARCHAR(50) NOT NULL
    ,[EmployeeLevel]    INT          NOT NULL
);

WITH
    cteRecurse
    AS
    (
        SELECT
            me1.EmployeeID
            ,me1.FirstName + ' ' + me1.Lastname   AS [Name]
            ,me1.Title
            ,1                                    AS EmployeeLevel
            ,me1.ManagerID
        FROM
            dbo.MyEmployees AS me1
        WHERE me1.ManagerID IS NULL

        UNION ALL

        SELECT
            me2.EmployeeID
            ,me2.FirstName + ' ' + me2.Lastname   AS [Name]
            ,me2.Title
            ,cr.EmployeeLevel + 1                 AS EmployeeLevel
            ,me2.ManagerID
        FROM
            dbo.MyEmployees AS me2
            JOIN cteRecurse cr ON me2.ManagerID = cr.EmployeeID
    )

INSERT INTO @emps ([EmployeeID], [Name], [Title], [EmployeeLevel])
SELECT
    EmployeeID
    ,REPLICATE('| ', EmployeeLevel - 1) + [Name]
    ,Title
    ,EmployeeLevel
FROM
    cteRecurse AS cr;

SELECT [EmployeeID], [Name], [Title], [EmployeeLevel] FROM @emps;

DROP TABLE IF EXISTS dbo.MyEmployees;
GO
