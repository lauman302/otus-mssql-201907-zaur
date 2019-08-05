# Домашнее задание

## 1. Установите программу SQL Server 2016\2017

Поскольку основной рабочей станцией является машина с ОС Linux Debian 10,
буду использовать MS SQL Server 2017 for Linux ([http://bit.ly/2OUXcXV][microsoft_01]).
Проще всего развернуть его с помощью docker-контейнера.

1. Заберём контейнер с сервера:

    ```bash
    docker pull mcr.microsoft.com/mssql/server:2017-latest
    ```

2. Создадим том для хранения данных:

    ```bash
    docker volume create mssql-test
    ```

3. Напишем скрипт запуска с предопределёнными параметрами. Строка с паролем нужна только при первом старте контейнера:

    ```bash
    #!/bin/bash
    # start_docker_mssql_otus

    VOLUME=mssql-test
    SA_PASSWORD=Pa$$w0rd
    SHARED_FOLDER=/placeholder/for/local/server/folder

    docker run --rm --name sql_otus\
      -e 'ACCEPT_EULA=Y' \
      -e 'MSSQL_SA_PASSWORD=$SA_PASSWORD' \
      -e 'TZ=Europe/Moscow'\
      -p 1433:1433 \
      -v $VOLUME:/var/opt/mssql \
      -v $SHARED_FOLDER:/var/opt/shared \
      -d mcr.microsoft.com/mssql/server:2017-latest
    ```

4. Запустим сервер:

    ```bash
    ./start_docker_mssql_otus
    ```

5. Для работы с базой установим рекомендованный Microsoft Visual Studio Code по следующей инструкции: [http://bit.ly/2OzW7UT][microsoft_02].

## 2. Разверните у себя бэкап базы WideWorldImporters

Развёрывание БД было сделано с участием специфичных для Linux замечаний следующей инструкции: [http://bit.ly/2MEo4Zp][microsoft_03]

```sql
RESTORE
    DATABASE WideWorldImporters
    FROM DISK = '/var/opt/shared/WideWorldImporters-Full.bak'
    WITH
        MOVE 'WWI_Primary'         TO '/var/opt/mssql/data/    WideWorldImporters.mdf'
      , MOVE 'WWI_UserData'        TO '/var/opt/mssql/data/    WideWorldImporters_UserData.ndf'
      , MOVE 'WWI_Log'             TO '/var/opt/mssql/data/    WideWorldImporters.ldf'
      , MOVE 'WWI_InMemory_Data_1' TO '/var/opt/mssql/data/    WideWorldImporters_InMemory_Data_1'
```

Результат:

![Скриншот развёрнутого бекапа][screen_01]

## 3. Поставьте SQL Sentry Plan Explorer

Приложение было установлено в рабочем окружении. Способы установки на Linux пока изыскиваются.

## 4. Сделайте проект для курса на github, пришлите ссылку на него

* Текущий проект: [https://github.com/zaur45/otus-mssql-201907-zaur][github_01];
* проект для последующего развития: [https://github.com/zaur45/ingress-operations-database][github_02]

## 5. Придумайте и сделайте описание проекта, который будете делать в рамках всего курса

Описание проекта размещено в фале [README.md][github_03] его репозитория.

## 6*. Найдите, какую СУБД использует любимый вами проект

TBD

* Название проекта:
* Используемые базы данных:
  * БД: (иерархическая, сетевая, реляционная, объектно-ориентированная, NoSql)
  * БД: NoSQL (колоночная, key-value, документарная, in-memory, графовая)
* Количество серверов БД:
* Ссылка на источник:

[screen_01]: images/WideWorldImporters_screenshot.png
[github_01]: https://github.com/zaur45/otus-mssql-201907-zaur
[github_02]: https://github.com/zaur45/ingress-operations-database
[github_03]: https://github.com/zaur45/ingress-operations-database/blob/master/README.md
[microsoft_01]: http://bit.ly/2OUXcXV
[microsoft_02]: http://bit.ly/2OzW7UT
[microsoft_03]: http://bit.ly/2MEo4Zp
