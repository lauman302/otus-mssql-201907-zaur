/*
2. Для всех клиентов с именем, в котором есть Tailspin Toys вывести все адреса, которые есть в таблице, в одной колонке

    Пример результатов
    ```
    CustomerName AddressLine
    Tailspin Toys (Head Office) Shop 38
    Tailspin Toys (Head Office) 1877 Mittal Road
    Tailspin Toys (Head Office) PO Box 8975
    Tailspin Toys (Head Office) Ribeiroville
    .....
    ```
*/

USE WideWorldImporters;

SELECT CustomerName, AddresLine
FROM (
    SELECT c.CustomerName, c.DeliveryAddressLine1, c.DeliveryAddressLine2, c.PostalAddressLine1, c.PostalAddressLine2
    FROM Sales.Customers AS c
    WHERE c.CustomerName LIKE '%Tailspin Toys%'
) AS cstmrs
UNPIVOT (
    AddresLine FOR Addr IN ([DeliveryAddressLine1], [DeliveryAddressLine2], [PostalAddressLine1], [PostalAddressLine2])
) AS unpvt;
