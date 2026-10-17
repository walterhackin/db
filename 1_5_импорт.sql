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
