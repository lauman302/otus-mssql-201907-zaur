/*
3. Функции одним запросом:

    Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
    пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
    посчитайте общее количество товаров и выведете полем в этом же запросе
    посчитайте общее количество товаров в зависимости от первой буквы названия товара
    отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
    предыдущий ид товара с тем же порядком отображения (по имени)
    названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
    сформируйте 30 групп товаров по полю вес товара на 1 шт

    Для этой задачи НЕ нужно писать аналог без аналитических функций
*/

USE WideWorldImporters;

SELECT
    si.StockItemID, si.StockItemName, si.Brand, si.UnitPrice
    ,row_number() OVER (PARTITION BY left(si.StockItemName,1) ORDER BY si.StockItemName)  AS AbcRowNumbers
    ,count(*) OVER ()                                                                     AS TotalQty
    ,count(*) OVER (PARTITION BY left(si.StockItemName,1))                                AS AbcQty
    ,lead(si.StockItemID) OVER (ORDER BY si.StockItemName)                                AS NextID
    ,lag(si.StockItemID) OVER (ORDER BY si.StockItemName)                                 AS PrevID
    ,isnull(LAG(si.StockItemName, 2) OVER (ORDER BY si.StockItemName), 'No items')        AS PrevPrevName
    ,ntile(30) OVER (ORDER BY si.TypicalWeightPerUnit)                                    AS WeightGroup
FROM
    Warehouse.StockItems AS si
ORDER BY
    si.StockItemName;
