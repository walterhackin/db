-- 1. JOIN минимум трёх таблиц
SELECT
    b.BookingID,
    g.GuestName,
    r.RoomNumber,
    c.CategoryName,
    s.ServiceName,
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


-- 2. GROUP BY + HAVING
-- Категории номеров, в которых больше одной брони
SELECT
    c.CategoryName,
    COUNT(b.BookingID) AS BookingCount
FROM dbo.Bookings b
JOIN dbo.Rooms r ON r.RoomID = b.RoomID
JOIN dbo.Categories c ON c.CategoryID = r.CategoryID
GROUP BY c.CategoryName
HAVING COUNT(b.BookingID) > 1;


-- 3. Подзапрос
-- Брони с итоговой стоимостью выше средней
SELECT
    BookingID,
    Total
FROM dbo.Bookings
WHERE Total >
(
    SELECT AVG(Total)
    FROM dbo.Bookings
);
