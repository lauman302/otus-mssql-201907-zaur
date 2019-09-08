/*
3. В таблице стран есть поля с кодом страны цифровым и буквенным. Сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код. Пример выдачи:
    ```
    CountryId CountryName Code
    1 Afghanistan AFG
    1 Afghanistan 4
    3 Albania ALB
    3 Albania 8
    ```
*/

USE WideWorldImporters;

WITH cteCountries AS (
    SELECT
        c.CountryID
       ,c.CountryName
       ,cast(c.IsoNumericCode as varchar(3)) AS IsoNumericCode
       -- https://stackoverflow.com/q/11158017/6118628
       ,cast(c.IsoAlpha3Code COLLATE database_default AS varchar(3)) AS IsoAlpha3Code
    FROM Application.Countries AS c
)
SELECT CountryID, CountryName, Code FROM (
    SELECT CountryID, CountryName, IsoNumericCode, IsoAlpha3Code FROM cteCountries
) AS cntrs
UNPIVOT (Code FOR CodeType IN ([IsoAlpha3Code], [IsoNumericCode])) as unpvt;
