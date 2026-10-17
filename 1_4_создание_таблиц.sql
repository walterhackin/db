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
    CategoryID INT NOT NULL,

    FOREIGN KEY (CategoryID)
        REFERENCES dbo.Categories(CategoryID)
);

CREATE TABLE dbo.Services
(
    ServiceID INT IDENTITY(1,1) PRIMARY KEY,
    ServiceName NVARCHAR(100) NOT NULL UNIQUE,
    ServicePrice DECIMAL(10,2) NOT NULL CHECK (ServicePrice >= 0)
);

CREATE TABLE dbo.Bookings
(
    BookingID INT PRIMARY KEY,
    BookingDate DATE NOT NULL,
    GuestID INT NOT NULL,
    RoomID INT NOT NULL,
    CheckInDate DATE NOT NULL,
    CheckOutDate DATE NOT NULL,
    Total DECIMAL(10,2) NOT NULL CHECK (Total >= 0),

    FOREIGN KEY (GuestID)
        REFERENCES dbo.Guests(GuestID),

    FOREIGN KEY (RoomID)
        REFERENCES dbo.Rooms(RoomID),

    CHECK (CheckOutDate > CheckInDate)
);

CREATE TABLE dbo.BookingServices
(
    BookingServiceID INT IDENTITY(1,1) PRIMARY KEY,
    BookingID INT NOT NULL,
    ServiceID INT NOT NULL,

    FOREIGN KEY (BookingID)
        REFERENCES dbo.Bookings(BookingID),

    FOREIGN KEY (ServiceID)
        REFERENCES dbo.Services(ServiceID),

    UNIQUE (BookingID, ServiceID)
);
GO
