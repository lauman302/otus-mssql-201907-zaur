/*
3. В таблице StockItems в колонке CustomFields есть данные в json.
Написать select для вывода:
    - StockItemID
    - StockItemName
    - CountryOfManufacture (из CustomFields)
    - Range (из CustomFields)
*/

USE WideWorldImporters;

SELECT
    si.StockItemID
    ,si.StockItemName
    ,JSON_VALUE(si.CustomFields, '$.CountryOfManufacture')  AS [CountryOfManufacture]
    ,JSON_VALUE(si.CustomFields, '$.Range')                 AS [Range]
FROM
    Warehouse.StockItems as si;

---------------------------------------------------

/*
4. Найти в StockItems строки, где есть тэг "Vintage".
Запрос написать через функции работы с JSON.
Тэги искать в поле CustomFields, а не в Tags.
*/

SELECT
    si.StockItemID
    ,si.StockItemName
    ,JSON_VALUE(si.CustomFields, '$.CountryOfManufacture')  AS [CountryOfManufacture]
    ,JSON_VALUE(si.CustomFields, '$.Range')                 AS [Range]
    ,JSON_QUERY(si.CustomFields, '$.Tags')                  AS [Tags]
    ,si.CustomFields
FROM
    Warehouse.StockItems as si
WHERE
    JSON_QUERY(si.CustomFields, '$.Tags') LIKE '%Vintage%';
