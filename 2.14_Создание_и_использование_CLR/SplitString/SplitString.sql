USE ClrDemo;

EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 0;
RECONFIGURE;
GO

--DROP ASSEMBLY ClrDemo 
CREATE ASSEMBLY ClrDemo FROM 'C:\tmp\db\SplitString.dll' WITH PERMISSION_SET = SAFE;
GO

-- DROP FUNCTION SplitString
CREATE FUNCTION dbo.StringSplit(@text nvarchar(max), @delimiter nchar(1))
RETURNS TABLE (
    part     nvarchar(max),
    ID_ORDER int
) WITH EXECUTE AS CALLER
AS EXTERNAL NAME ClrDemo.UserDefinedFunctions.SplitString;
GO 


SELECT part FROM StringSplit('1;12;3;4;5;6;11;788;',';');
