
### 1.1 Анализ исходных данных

Исходный файл содержит данные о гостях, номерах, категориях, бронированиях и услугах.

Выделенные сущности:

```text
Guests
Categories
Rooms
Bookings
Services
BookingServices
```

Связи:

```text
Categories 1:N Rooms
Guests 1:N Bookings
Rooms 1:N Bookings
Bookings 1:N BookingServices
Services 1:N BookingServices
```

Связь `Bookings` и `Services` — `N:M` через `BookingServices`.

### 1.2 Нормализация до 3НФ

Текст для отчёта:

> Исходные данные содержали повторяющиеся сведения о гостях, номерах, категориях, бронированиях и услугах. Для устранения избыточности данные были разделены на отдельные сущности. Связь многие-ко-многим между бронированиями и услугами реализована через таблицу BookingServices. Стоимость услуги хранится в BookingServices, так как в исходных данных стоимость одной и той же услуги может различаться. Полученная структура соответствует третьей нормальной форме.

### 1.3 импорт
Из Excel в CSV
1. Открой файл в Excel.
2. Файл → Сохранить как.
3. Тип: CSV UTF-8 (*.csv).
4. Сохрани файл.
Из CSV в SQL Server
1. В SSMS: ПКМ по базе → Задачи → Импорт данных...
2. Источник: Flat File Source.
3. Выбери .csv.
4. Укажи правильный разделитель: ;, , или Tab — как в самом файле.
5. Отметь, что первая строка содержит названия столбцов.
6. Назначение — база SQL Server.
7. Таблицу назови, RawImport.
8. Далее → Готово.

И потом уже в БД
```sql
INSERT INTO dbo.Guests(GuestName, Passport, Phone)
SELECT DISTINCT Gost, Pasport, Telefon
FROM dbo.RawImport;

INSERT INTO dbo.Categories(CategoryName, PricePerDay)
SELECT DISTINCT Kategoriya, Cena_za_sutki
FROM dbo.RawImport;

INSERT INTO dbo.Rooms(RoomNumber, CategoryID)
SELECT DISTINCT
    r.Nomer_komnaty,
    c.CategoryID
FROM dbo.RawImport r
JOIN dbo.Categories c ON c.CategoryName = r.Kategoriya;

INSERT INTO dbo.Services(ServiceName, ServicePrice)
SELECT DISTINCT Usluga, Stoimost_uslugi
FROM dbo.RawImport;

INSERT INTO dbo.Bookings(BookingID, BookingDate, GuestID, RoomID, CheckInDate, CheckOutDate, Total)
SELECT DISTINCT
    r.Nomer_broni,
    r.Data_broni,
    g.GuestID,
    rm.RoomID,
    r.Data_zaezda,
    r.Data_vyezda,
    r.Itogo
FROM dbo.RawImport r
JOIN dbo.Guests g ON g.Passport = r.Pasport
JOIN dbo.Rooms rm ON rm.RoomNumber = r.Nomer_komnaty;

INSERT INTO dbo.BookingServices(BookingID, ServiceID)
SELECT
    r.Nomer_broni,
    s.ServiceID
FROM dbo.RawImport r
JOIN dbo.Services s ON s.ServiceName = r.Usluga;

SELECT * FROM dbo.Guests;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Rooms;
SELECT * FROM dbo.Services;
SELECT * FROM dbo.Bookings;
SELECT * FROM dbo.BookingServices;
```
### 1.4 Создание таблиц

```sql
USE [ИМЯ_БАЗЫ];
GO

DROP TABLE IF EXISTS dbo.BookingServices;
DROP TABLE IF EXISTS dbo.Bookings;
DROP TABLE IF EXISTS dbo.Services;
DROP TABLE IF EXISTS dbo.Rooms;
DROP TABLE IF EXISTS dbo.Guests;
DROP TABLE IF EXISTS dbo.Categories;
GO

CREATE TABLE dbo.Guests
(
    GuestID INT IDENTITY(1,1) PRIMARY KEY,
    GuestName NVARCHAR(100) NOT NULL,
    Passport NVARCHAR(20) NOT NULL UNIQUE,
    Phone NVARCHAR(30) NOT NULL
);

CREATE TABLE dbo.Categories
(
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(50) NOT NULL UNIQUE,
    PricePerDay DECIMAL(10,2) NOT NULL CHECK (PricePerDay > 0)
);

CREATE TABLE dbo.Rooms
(
    RoomID INT IDENTITY(1,1) PRIMARY KEY,
    RoomNumber INT NOT NULL UNIQUE,
    CategoryID INT NOT NULL REFERENCES dbo.Categories(CategoryID)
);

CREATE TABLE dbo.Services
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE dbo.Bookings
(
    BookingID INT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    GuestID INT NOT NULL REFERENCES dbo.Guests(GuestID),
    RoomID INT NOT NULL REFERENCES dbo.Rooms(RoomID),
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0),
    CHECK (CheckOutDate > CheckInDate)
);

CREATE TABLE dbo.BookingServices
(
    BookingServiceID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL REFERENCES dbo.Bookings(BookingID),
    ServiceID INT NOT NULL REFERENCES dbo.Services(ServiceID),
    ServicePrice DECIMAL(10,2) NOT NULL CHECK (ServicePrice >= 0),
    UNIQUE (BookingID, ServiceID)
);
GO
```

### 1.5 Импорт данных

Сначала исходный файл импортировать в таблицу `RawImport`.

После импорта выполнить:

```sql
INSERT INTO dbo.Guests(GuestName, Passport, Phone)
SELECT DISTINCT Gost, Pasport, Telefon
FROM dbo.RawImport;

INSERT INTO dbo.Categories(CategoryName, PricePerDay)
SELECT DISTINCT Kategoriya, TRY_CONVERT(DECIMAL(10,2), Cena_za_sutki)
FROM dbo.RawImport;

INSERT INTO dbo.Rooms(RoomNumber, CategoryID)
SELECT DISTINCT
    TRY_CONVERT(INT, r.Nomer_komnaty),
    c.CategoryID
FROM dbo.RawImport r
JOIN dbo.Categories c ON c.CategoryName = r.Kategoriya;

INSERT INTO dbo.Services(ServiceName)
SELECT DISTINCT Usluga
FROM dbo.RawImport;

INSERT INTO dbo.Bookings(BookingID, BookingDate, GuestID, RoomID, CheckInDate, CheckOutDate, Total)
SELECT DISTINCT
    TRY_CONVERT(INT, r.Nomer_broni),
    TRY_CONVERT(DATE, r.Data_broni),
    g.GuestID,
    rm.RoomID,
    TRY_CONVERT(DATE, r.Data_zaezda),
    TRY_CONVERT(DATE, r.Data_vyezda),
    TRY_CONVERT(DECIMAL(10,2), r.Itogo)
FROM dbo.RawImport r
JOIN dbo.Guests g ON g.Passport = r.Pasport
JOIN dbo.Rooms rm ON rm.RoomNumber = TRY_CONVERT(INT, r.Nomer_komnaty);

INSERT INTO dbo.BookingServices(BookingID, ServiceID, ServicePrice)
SELECT DISTINCT
    TRY_CONVERT(INT, r.Nomer_broni),
    s.ServiceID,
    TRY_CONVERT(DECIMAL(10,2), r.Stoimost_uslugi)
FROM dbo.RawImport r
JOIN dbo.Services s ON s.ServiceName = r.Usluga;
GO
```

Проверка:

```sql
SELECT * FROM dbo.Guests;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Rooms;
SELECT * FROM dbo.Services;
SELECT * FROM dbo.Bookings;
SELECT * FROM dbo.BookingServices;
```

### 1.6 Проверка связей

```sql
SELECT
    b.BookingID,
    g.GuestName,
    r.RoomNumber,
    c.CategoryName,
    s.ServiceName,
    bs.ServicePrice,
    b.CheckInDate,
    b.CheckOutDate,
    b.Total
FROM dbo.BookingServices bs
JOIN dbo.Bookings b ON b.BookingID = bs.BookingID
JOIN dbo.Guests g ON g.GuestID = b.GuestID
JOIN dbo.Rooms r ON r.RoomID = b.RoomID
JOIN dbo.Categories c ON c.CategoryID = r.CategoryID
JOIN dbo.Services s ON s.ServiceID = bs.ServiceID
ORDER BY b.BookingID;
```

---

## Задание 2

### 2.1 SELECT с JOIN

```sql
SELECT
    b.BookingID,
    g.GuestName,
    r.RoomNumber,
    c.CategoryName,
    b.CheckInDate,
    b.CheckOutDate,
    b.Total
FROM dbo.Bookings b
JOIN dbo.Guests g
    ON g.GuestID = b.GuestID
JOIN dbo.Rooms r
    ON r.RoomID = b.RoomID
JOIN dbo.Categories c
    ON c.CategoryID = r.CategoryID
ORDER BY b.BookingID;
```

### 2.2 SELECT с GROUP BY и HAVING

```sql
SELECT
    c.CategoryName,
    COUNT(b.BookingID) AS BookingCount
FROM dbo.Bookings b
JOIN dbo.Rooms r ON r.RoomID = b.RoomID
JOIN dbo.Categories c ON c.CategoryID = r.CategoryID
GROUP BY c.CategoryName
HAVING COUNT(b.BookingID) > 1;
```

### 2.3 SELECT с подзапросом

```sql
SELECT
    BookingID,
    Total
FROM dbo.Bookings
WHERE Total >
(
    SELECT AVG(Total)
    FROM dbo.Bookings
);
```

### 2.4 Экспорт результатов в CSV

Экспортировать результаты минимум двух запросов:

```text
ПКМ по результату → Сохранить результаты как... → CSV
```

Например:

```text
query1.csv
query2.csv
```

### 2.5 Полная резервная копия

В SSMS:

```text
ПКМ по базе → Задачи → Резервное копирование → Тип: Полная
```

Сохранить как:

```text
hotel_full.bak
```

### 2.6 Изменение 3–5 записей

```sql
UPDATE dbo.Categories
SET PricePerDay = PricePerDay + 100
WHERE CategoryID IN (1, 2, 3);

UPDATE dbo.Guests
SET Phone = N'7-999-000-00-00'
WHERE GuestID = 1;

UPDATE dbo.Bookings
SET Total = Total + 500
WHERE BookingID = 4001;
```

### 2.7 Разностная резервная копия

В SSMS:

```text
ПКМ по базе → Задачи → Резервное копирование → Тип: Разностная
```

Сохранить как:

```text
hotel_diff.bak
```

### 2.8 Моделирование потери данных

```sql
DELETE FROM dbo.BookingServices;

SELECT * FROM dbo.BookingServices;
```

### 2.9 Восстановление базы данных

Сначала восстановить:

```text
hotel_full.bak
```

с режимом:

```text
NORECOVERY
```

Затем восстановить:

```text
hotel_diff.bak
```

с режимом:

```text
RECOVERY
```

Проверка:

```sql
SELECT * FROM dbo.BookingServices;
SELECT * FROM dbo.Categories;
SELECT * FROM dbo.Guests;
SELECT * FROM dbo.Bookings;
```

### 2.10 Создание триггера

```sql
CREATE TABLE dbo.BookingTotalAudit
(
    AuditID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    OldTotal DECIMAL(10,2),
    NewTotal DECIMAL(10,2),
    ChangedAt DATETIME2 NOT NULL DEFAULT GETDATE()
);
GO

CREATE TRIGGER dbo.trg_BookingTotalAudit
ON dbo.Bookings
AFTER UPDATE
AS
BEGIN
    INSERT INTO dbo.BookingTotalAudit(BookingID, OldTotal, NewTotal)
    SELECT
        i.BookingID,
        d.Total,
        i.Total
    FROM inserted i
    JOIN deleted d ON d.BookingID = i.BookingID
    WHERE i.Total <> d.Total;
END;
GO
```

### 2.11 Проверка триггера

```sql
UPDATE dbo.Bookings
SET Total = Total + 100
WHERE BookingID = 4001;

SELECT * FROM dbo.BookingTotalAudit;
```

### 2.12 Что добавить в отчёт

Для задания 1:

```text
ER-диаграмма
структура таблиц
RawImport
заполненные таблицы
контрольный JOIN
```

Для задания 2:

```text
3 SELECT-запроса и результаты
2 CSV-файла
полная резервная копия
изменённые данные
разностная резервная копия
удалённые данные
восстановленные данные
код триггера
результат работы триггера
```
