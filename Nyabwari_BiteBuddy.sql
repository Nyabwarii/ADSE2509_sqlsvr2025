CREATE DATABASE NyabwariThomas_BiteBuddy;
GO

use NyabwariThomas_BiteBuddy

--Stores information about each restaurant branch

create table Branch
(
  BranchID int not null primary key,
  BranchName varchar(100) not null,
  TownArea varchar(100) not null,
  phone varchar(15) not null unique,
  Email varchar(150) not null unique,
  OpenTime Time not null,
  CloseTime Time not null,
  IsActive bit not null default 1

);

--Groups menu list into categories(e.g. Burgers,Drinks,Sides,Desserts)
create table Category
(
  CategoryID int not null primary key,
  CategoryName varchar(80) not null unique,
  Description varchar(250),
 
);

--Contains every item available on the BiteBuddy menu
create table MenuItem
(
  ItemID int not null primary key,
  CategoryID int not null,
  ItemName varchar(120) not null,
  Description varchar(300),
  Price decimal(8,2) not null,
  CalorieCount int,
  IsAvailable bit not null default 1,
  ImageURL varchar(300)

);

ALTER TABLE MenuItem
ADD CONSTRAINT FK_MenuItem_Category
FOREIGN KEY (CategoryID)
REFERENCES Category(CategoryID);

ALTER TABLE MenuItem
ADD CONSTRAINT CHK_MenuItem_Price
CHECK (Price > 0);

ALTER TABLE MenuItem
ADD CONSTRAINT CHK_MenuItem_CalorieCount
CHECK (CalorieCount >= 0);

--contains all staff members across all branches
create table Staff 
(
  StaffID int not null primary key,
  BranchID int not null,
  NationalID varchar(20) not null,
  FullName varchar(150) not null unique,
  Gender varchar(10) not null,
  Role varchar(60) not null,
  HireDate date not null,
  Phone varchar(15) not null unique,
  Email varchar(150) not null unique,
  Salary decimal(10,2) not null
);

ALTER TABLE Staff
ADD CONSTRAINT CHK_Staff_Gender
CHECK (Gender IN ('Male', 'Female'));

--Trigger for Staff Gender Validation 

CREATE TRIGGER trg_Staff_GenderValidation
ON Staff
INSTEAD OF INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE LOWER(Gender) NOT IN ('male', 'female')
    )
    BEGIN
        RAISERROR ('Invalid Gender. Only Male or Female allowed.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    INSERT INTO Staff (StaffID, BranchID, NationalID, FullName, Gender, Role, HireDate, Phone, Email, Salary)
    SELECT StaffID, BranchID, NationalID, FullName, Gender, Role, HireDate, Phone, Email, Salary
    FROM inserted;
END;



-- HireDate is validated by trg_Staff_HireDateValidation trigger below

--Trigger for Staff HireDate Validation

CREATE TRIGGER trg_Staff_HireDateValidation
ON Staff
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE HireDate > GETDATE()
    )
    BEGIN
        RAISERROR ('HireDate cannot be in the future.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

ALTER TABLE Staff
ADD CONSTRAINT FK_Staff_Branch
FOREIGN KEY (BranchID)
REFERENCES Branch(BranchID);

ALTER TABLE Staff
ADD CONSTRAINT CHK_Staff_Salary
CHECK (Salary > 0);

-- Registered Customers who use the online platform. walk-in customers are recorded as guest orders

create table Customer 
(
 CustomerID int not null primary key,
 FullName varchar(150) not null,
 Phone varchar(15) not null unique,
 Email varchar(150) not null unique,
 PasswordHash varchar(256) not null,
 DateRegistered date not null default GETDATE(),
 LoyaltyPoints int not null default 0,
 IsActive bit not null default 1
);

ALTER TABLE Customer
ADD CONSTRAINT CHK_Customer_LoyaltyPoints
CHECK (LoyaltyPoints >= 0);

--Records each order placed whether eat-in at a branch or online (delivery/collection)
create table Orders 
(
  OrderID int not null primary key,
  BranchID int not null,
  CustomerID int null, -- NULL allowed for guest/walk-in orders
  StaffID int not null,
  OrderType varchar(20) not null,
  OrderDate datetime not null default GETDATE(),
  TableNo varchar(10) null ,
  DeliveryAddress varchar(300) null ,
  Status varchar(30) not null default 'Pending',
  TotalAmount decimal (10,2) not null,
);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Branch
FOREIGN KEY (BranchID)
REFERENCES Branch(BranchID);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Customer
FOREIGN KEY (CustomerID)
REFERENCES Customer(CustomerID);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Staff
FOREIGN KEY (StaffID)
REFERENCES Staff(StaffID);

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_TotalAmount
CHECK (TotalAmount >= 0);

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_OrderType
CHECK (OrderType IN ('Eat-In', 'Collection', 'Delivery'));

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_TableNo_EatIn
CHECK (OrderType <> 'Eat-In' OR TableNo IS NOT NULL);

ALTER TABLE Orders
ADD CONSTRAINT CK_Orders_DeliveryAddress
CHECK (OrderType <> 'Delivery' OR DeliveryAddress IS NOT NULL);

--Trigger for Orders OrderType Validation

CREATE TRIGGER trg_Orders_OrderTypeValidation
ON Orders
AFTER INSERT, UPDATE
AS
BEGIN
    -- Eat-In must have TableNo
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE OrderType = 'Eat-In'
          AND (TableNo IS NULL OR TableNo = '')
    )
    BEGIN
        RAISERROR ('Eat-In orders must have a TableNo.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- Delivery must have DeliveryAddress
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE OrderType = 'Delivery'
          AND (DeliveryAddress IS NULL OR DeliveryAddress = '')
    )
    BEGIN
        RAISERROR ('Delivery orders must have a DeliveryAddress.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;


-- Stores individual line items for each order
create table OrderItem 
(
 OrderItemID int not null primary key,
 OrderID int not null,
 ItemID int not null,
 Quantity int not null ,
 UnitPrice decimal (8,2) not null,
 SpecialRequest varchar(200),
);

ALTER TABLE OrderItem
ADD CONSTRAINT FK_OrderItem_Order
FOREIGN KEY (OrderID)
REFERENCES Orders(OrderID);

ALTER TABLE OrderItem
ADD CONSTRAINT FK_OrderItem_MenuItem
FOREIGN KEY (ItemID)
REFERENCES MenuItem(ItemID);


ALTER TABLE OrderItem
ADD CONSTRAINT CK_OrderItem_Quantity
CHECK (Quantity >= 1);

ALTER TABLE OrderItem
ADD CONSTRAINT CK_OrderItem_UnitPrice
CHECK (Unitprice > 0);


--Records payment details for each order
create table Payment
(
  PaymentID int identity not null primary key,
  OrderID int not null unique,
  PaymentMethod varchar(30) not null, 
  AmountPaid decimal(10,2) not null,  
  PaymentDate Datetime not null default GETDATE(),
  MpesaRef varchar(30) null ,
  ChangeDue decimal(10,2) default 0, 
 
);

ALTER TABLE Payment
ADD CONSTRAINT FK_Payment_Order
FOREIGN KEY (OrderID)
REFERENCES Orders(OrderID);

ALTER TABLE Payment
ADD CONSTRAINT CK_Payment_Method
CHECK (PaymentMethod IN ('Cash', 'MPesa', 'Card', 'Online'));

ALTER TABLE Payment
ADD CONSTRAINT CK_Payment_AmountPaid
CHECK (AmountPaid > 0);

ALTER TABLE Payment
ADD CONSTRAINT CK_Payment_ChangeDue
CHECK (ChangeDue >= 0);

ALTER TABLE Payment
ADD CONSTRAINT CK_Payment_MpesaRef
CHECK (
    PaymentMethod NOT IN ('MPesa', 'Online')
    OR MpesaRef IS NOT NULL
);

--Trigger for Payment Amount Validation
-- Cash payments may exceed the total (change is given); non-cash must match exactly.

CREATE TRIGGER trg_Payment_AmountValidation
ON Payment
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN Orders o
            ON i.OrderID = o.OrderID
        WHERE i.PaymentMethod <> 'Cash'
          AND i.AmountPaid <> o.TotalAmount
    )
    BEGIN
        RAISERROR ('Payment amount does not match order total', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- Trigger to prevent deletion of paid orders (placed here as Payment table must exist first)
CREATE TRIGGER trg_PreventPaidOrderDeletion
ON Orders
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM deleted d
        JOIN Payment p
            ON d.OrderID = p.OrderID
    )
    BEGIN
        RAISERROR ('Cannot delete a paid order because a payment record exists.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END

    -- If no payment exists, allow the deletion to proceed
    DELETE FROM Orders
    WHERE OrderID IN (SELECT OrderID FROM deleted);
END;

-- captures customer ratings and comments for completed orders

create table Feedback
(
  FeedbackID int not null primary key,
  OrderID int not null unique,
  CustomerID int not null,
  Rating tinyint not null,
  Comments varchar(500),
  FeedbackDate datetime not null Default GETDATE()

);

ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_Order
FOREIGN KEY (OrderID)
REFERENCES Orders(OrderID);

ALTER TABLE Feedback
ADD CONSTRAINT FK_Feedback_Customer
FOREIGN KEY (CustomerID)
REFERENCES Customer(CustomerID);

-- Trigger for feedback rating range
CREATE TRIGGER trg_Feedback_RatingRange
ON Feedback
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted
        WHERE Rating < 1 OR Rating > 5
    )
    BEGIN
        RAISERROR ('Reject any rating value below 1 or above 5.', 16, 1);
        ROLLBACK TRANSACTION;
        RETURN;
    END
END;

-- usp_PlaceOrder
CREATE PROCEDURE usp_PlaceOrder
    @BranchID INT,
    @CustomerID INT = NULL,
    @StaffID INT,
    @OrderType VARCHAR(20),
    @TableNo VARCHAR(10) = NULL,
    @DeliveryAddress VARCHAR(300) = NULL,
    @NewOrderID INT OUTPUT
AS
BEGIN
    BEGIN TRY

        INSERT INTO Orders
        (
            BranchID,
            CustomerID,
            StaffID,
            OrderType,
            TableNo,
            DeliveryAddress,
            Status,
            TotalAmount
        )
        VALUES
        (
            @BranchID,
            @CustomerID,
            @StaffID,
            @OrderType,
            @TableNo,
            @DeliveryAddress,
            'Pending',
            0
        );

        SET @NewOrderID = SCOPE_IDENTITY();

    END TRY

    BEGIN CATCH

        PRINT 'Error placing order';

        PRINT ERROR_MESSAGE();

    END CATCH
END;

-- usp_AddOrderItem
CREATE PROCEDURE usp_AddOrderItem
    @OrderID        INT,
    @ItemID         INT,
    @Quantity       INT,
    @SpecialRequest VARCHAR(200) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
 
        -- Check menu item exists and is available
        IF NOT EXISTS (SELECT 1 FROM MenuItem WHERE ItemID = @ItemID AND IsAvailable = 1)
        BEGIN
            RAISERROR('Menu item does not exist or is not available.', 16, 1);
            RETURN;
        END
 
        DECLARE @UnitPrice DECIMAL(8,2);
        SELECT @UnitPrice = Price FROM MenuItem WHERE ItemID = @ItemID;
 
        INSERT INTO OrderItem (OrderID, ItemID, Quantity, UnitPrice, SpecialRequest)
        VALUES (@OrderID, @ItemID, @Quantity, @UnitPrice, @SpecialRequest);
 
        -- Update the order total
        UPDATE Orders
        SET TotalAmount = TotalAmount + (@UnitPrice * @Quantity)
        WHERE OrderID = @OrderID;
 
    END TRY
    BEGIN CATCH
        PRINT 'Error in usp_AddOrderItem: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
 
 
-- usp_ProcessPayment
CREATE PROCEDURE usp_ProcessPayment
    @OrderID       INT,
    @PaymentMethod VARCHAR(30),
    @AmountPaid    DECIMAL(10,2),
    @MpesaRef      VARCHAR(30) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
 
        DECLARE @OrderType   VARCHAR(20);
        DECLARE @TotalAmount DECIMAL(10,2);
        DECLARE @ChangeDue   DECIMAL(10,2);
 
        SELECT @OrderType = OrderType, @TotalAmount = TotalAmount
        FROM Orders WHERE OrderID = @OrderID;
 
        IF @OrderType IS NULL
        BEGIN
            RAISERROR('Order not found.', 16, 1);
            RETURN;
        END
 
        -- Calculate change for cash payments
        SET @ChangeDue = CASE WHEN @PaymentMethod = 'Cash' THEN @AmountPaid - @TotalAmount ELSE 0 END;
 
        INSERT INTO Payment (OrderID, PaymentMethod, AmountPaid, MpesaRef, ChangeDue)
        VALUES (@OrderID, @PaymentMethod, @AmountPaid, @MpesaRef, @ChangeDue);
 
        -- Update order status based on order type
        UPDATE Orders
        SET Status = CASE
                        WHEN @OrderType IN ('Eat-In', 'Collection') THEN 'Ready'
                        WHEN @OrderType = 'Delivery' THEN 'Preparing'
                        ELSE Status
                     END
        WHERE OrderID = @OrderID;
 
    END TRY
    BEGIN CATCH
        PRINT 'Error in usp_ProcessPayment: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
 
ALTER TABLE Orders ADD CancelledAt DATETIME NULL;
 
-- usp_UpdateOrderStatus
CREATE PROCEDURE usp_UpdateOrderStatus
    @OrderID   INT,
    @NewStatus VARCHAR(30)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
 
        IF @NewStatus NOT IN ('Pending', 'Preparing', 'Ready', 'Delivered', 'Cancelled')
        BEGIN
            RAISERROR('Invalid status value.', 16, 1);
            RETURN;
        END
 
        IF @NewStatus = 'Cancelled'
        BEGIN
            UPDATE Orders
            SET Status = @NewStatus, CancelledAt = GETDATE()
            WHERE OrderID = @OrderID;
        END
        ELSE
        BEGIN
            UPDATE Orders
            SET Status = @NewStatus
            WHERE OrderID = @OrderID;
        END
 
    END TRY
    BEGIN CATCH
        PRINT 'Error in usp_UpdateOrderStatus: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO
 
 
-- usp_GenerateDailySalesReport
CREATE PROCEDURE usp_GenerateDailySalesReport
    @BranchID   INT,
    @ReportDate DATE
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
 
        SELECT
            COUNT(DISTINCT o.OrderID)                                                   AS TotalOrders,
            SUM(p.AmountPaid)                                                           AS TotalRevenue,
            AVG(p.AmountPaid)                                                           AS AverageOrderValue,
            SUM(CASE WHEN p.PaymentMethod = 'Cash'   THEN p.AmountPaid ELSE 0 END)     AS TotalCash,
            SUM(CASE WHEN p.PaymentMethod = 'MPesa'  THEN p.AmountPaid ELSE 0 END)     AS TotalMpesa,
            SUM(CASE WHEN p.PaymentMethod = 'Card'   THEN p.AmountPaid ELSE 0 END)     AS TotalCard,
            SUM(CASE WHEN p.PaymentMethod = 'Online' THEN p.AmountPaid ELSE 0 END)     AS TotalOnline
        FROM Orders o
        INNER JOIN Payment p ON o.OrderID = p.OrderID
        WHERE o.BranchID = @BranchID
          AND CAST(o.OrderDate AS DATE) = @ReportDate;
 
    END TRY
    BEGIN CATCH
        PRINT 'Error in usp_GenerateDailySalesReport: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO

-- SECTION D: USER-DEFINED FUNCTIONS

-- D1: fn_GetOrderTotal

CREATE FUNCTION fn_GetOrderTotal (@OrderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    DECLARE @Total DECIMAL(10,2);
 
    SELECT @Total = SUM(Quantity * UnitPrice)
    FROM OrderItem
    WHERE OrderID = @OrderID;
 
    RETURN ISNULL(@Total, 0);
END;
GO
 
 
-- D2: fn_GetCustomerLifetimeSpend
 
CREATE FUNCTION fn_GetCustomerLifetimeSpend (@CustomerID INT)
RETURNS DECIMAL(12,2)
AS
BEGIN
    DECLARE @TotalSpend DECIMAL(12,2);
 
    SELECT @TotalSpend = SUM(p.AmountPaid)
    FROM Payment p
    INNER JOIN Orders o ON p.OrderID = o.OrderID
    WHERE o.CustomerID = @CustomerID
      AND o.Status <> 'Cancelled';
 
    RETURN ISNULL(@TotalSpend, 0);
END;
GO
 
 
-- D3: fn_GetBranchRevenue
 
CREATE FUNCTION fn_GetBranchRevenue (@BranchID INT, @StartDate DATE, @EndDate DATE)
RETURNS DECIMAL(14,2)
AS
BEGIN
    DECLARE @Revenue DECIMAL(14,2);
 
    SELECT @Revenue = SUM(TotalAmount)
    FROM Orders
    WHERE BranchID = @BranchID
      AND Status <> 'Cancelled'
      AND CAST(OrderDate AS DATE) BETWEEN @StartDate AND @EndDate;
 
    RETURN ISNULL(@Revenue, 0);
END;
GO
 
 
-- D4: fn_GetTopSellingItem
 
CREATE FUNCTION fn_GetTopSellingItem (@BranchID INT, @Month INT, @Year INT)
RETURNS TABLE
AS
RETURN
(
    SELECT TOP 5
        mi.ItemName,
        SUM(oi.Quantity) AS TotalQuantitySold
    FROM OrderItem oi
    INNER JOIN Orders o    ON oi.OrderID = o.OrderID
    INNER JOIN MenuItem mi ON oi.ItemID  = mi.ItemID
    WHERE o.BranchID = @BranchID
      AND MONTH(o.OrderDate) = @Month
      AND YEAR(o.OrderDate)  = @Year
      AND o.Status <> 'Cancelled'
    GROUP BY mi.ItemName
    ORDER BY TotalQuantitySold DESC
);
GO
 
 
-- D5: fn_IsMenuItemAvailable
-- Returns 1 if the item exists and is available, 0 otherwise.
 
CREATE FUNCTION fn_IsMenuItemAvailable (@ItemID INT)
RETURNS BIT
AS
BEGIN
    DECLARE @Result BIT;
 
    SELECT @Result = CASE WHEN COUNT(*) > 0 THEN 1 ELSE 0 END
    FROM MenuItem
    WHERE ItemID = @ItemID
      AND IsAvailable = 1;
 
    RETURN @Result;
END;
GO


-- SECTION E: SQL QUERIES

-- Q1: List all menu items that have never been ordered.
 
SELECT ItemName
FROM MenuItem
WHERE ItemID NOT IN (SELECT DISTINCT ItemID FROM OrderItem);
 
 
-- Q2: Full name and total orders processed by each staff member,
--     sorted by order count descending.
 
SELECT s.FullName,
       COUNT(o.OrderID) AS TotalOrders
FROM Staff s
LEFT JOIN Orders o ON s.StaffID = o.StaffID
GROUP BY s.FullName
ORDER BY TotalOrders DESC;


-- Q3: Customers who placed at least 3 online orders (Collection or Delivery)
--     in the last 30 days.
 
SELECT c.FullName, c.Email
FROM Customer c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE o.OrderType IN ('Collection', 'Delivery')
  AND o.OrderDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY c.FullName, c.Email
HAVING COUNT(o.OrderID) >= 3;



-- Q4: For each branch, total revenue and total orders for the current month.
 
SELECT b.BranchName,
       COUNT(o.OrderID)    AS TotalOrders,
       SUM(o.TotalAmount)  AS TotalRevenue
FROM Branch b
LEFT JOIN Orders o ON b.BranchID = o.BranchID
WHERE MONTH(o.OrderDate) = MONTH(GETDATE())
  AND YEAR(o.OrderDate)  = YEAR(GETDATE())
  AND o.Status <> 'Cancelled'
GROUP BY b.BranchName;


-- Q5: All orders where the customer gave a rating of 3 stars or below.
 
SELECT o.OrderID,
       c.FullName AS CustomerName,
       f.Rating,
       f.Comments
FROM Feedback f
INNER JOIN Orders   o ON f.OrderID    = o.OrderID
INNER JOIN Customer c ON f.CustomerID = c.CustomerID
WHERE f.Rating <= 3;


-- Q6: Menu items where total quantity sold this month is less than 5 (slow movers).
 
SELECT mi.ItemName,
       SUM(oi.Quantity) AS TotalSold
FROM MenuItem mi
INNER JOIN OrderItem oi ON mi.ItemID  = oi.ItemID
INNER JOIN Orders    o  ON oi.OrderID = o.OrderID
WHERE MONTH(o.OrderDate) = MONTH(GETDATE())
  AND YEAR(o.OrderDate)  = YEAR(GETDATE())
  AND o.Status <> 'Cancelled'
GROUP BY mi.ItemName
HAVING SUM(oi.Quantity) < 5;
 
 
-- Q7: Customers who have placed orders but never submitted feedback.
 
SELECT DISTINCT c.FullName, c.Email
FROM Customer c
INNER JOIN Orders o ON c.CustomerID = o.CustomerID
WHERE c.CustomerID NOT IN (SELECT DISTINCT CustomerID FROM Feedback);
 
 
-- Q8: Payment summary by method for each branch.
 
SELECT
    b.BranchName,
    SUM(CASE WHEN p.PaymentMethod = 'Cash'   THEN p.AmountPaid ELSE 0 END) AS Cash,
    SUM(CASE WHEN p.PaymentMethod = 'MPesa'  THEN p.AmountPaid ELSE 0 END) AS [M-Pesa],
    SUM(CASE WHEN p.PaymentMethod = 'Card'   THEN p.AmountPaid ELSE 0 END) AS Card,
    SUM(CASE WHEN p.PaymentMethod = 'Online' THEN p.AmountPaid ELSE 0 END) AS Online,
    SUM(p.AmountPaid)                                                        AS [Grand Total]
FROM Branch b
INNER JOIN Orders  o ON b.BranchID = o.BranchID
INNER JOIN Payment p ON o.OrderID  = p.OrderID
GROUP BY b.BranchName;



-- SECTION F: BONUS — DDL Trigger (SecurityLog)

CREATE TABLE SecurityLog
(
    LogID      INT IDENTITY NOT NULL PRIMARY KEY,
    EventType  VARCHAR(50)  NOT NULL,
    ObjectName VARCHAR(150) NOT NULL,
    LoginName  VARCHAR(150) NOT NULL,
    EventDate  DATETIME     NOT NULL DEFAULT GETDATE()
);
GO

CREATE TRIGGER trg_BlockDropTable
ON DATABASE
FOR DROP_TABLE
AS
BEGIN
    INSERT INTO SecurityLog (EventType, ObjectName, LoginName, EventDate)
    VALUES (
        EVENTDATA().value('(/EVENT_INSTANCE/EventType)[1]',  'VARCHAR(50)'),
        EVENTDATA().value('(/EVENT_INSTANCE/ObjectName)[1]', 'VARCHAR(150)'),
        EVENTDATA().value('(/EVENT_INSTANCE/LoginName)[1]',  'VARCHAR(150)'),
        GETDATE()
    );

    RAISERROR('DROP TABLE is not permitted on this database. The attempt has been logged.', 16, 1);
    ROLLBACK;
END;
GO


-- BONUS: vw_OrderSummary VIEW
-- Joins Orders, Customer, Branch, and Payment into a single reporting result set.

CREATE VIEW vw_OrderSummary
AS
SELECT
    o.OrderID,
    o.OrderDate,
    o.OrderType,
    o.Status,
    o.TotalAmount,
    b.BranchName,
    b.TownArea,
    c.FullName      AS CustomerName,
    c.Email         AS CustomerEmail,
    p.PaymentMethod,
    p.AmountPaid,
    p.ChangeDue,
    p.PaymentDate
FROM Orders o
INNER JOIN Branch   b ON o.BranchID   = b.BranchID
LEFT  JOIN Customer c ON o.CustomerID = c.CustomerID
LEFT  JOIN Payment  p ON o.OrderID    = p.OrderID;
GO


-- BONUS: Non-clustered index on OrderItem(OrderID, ItemID)
-- This composite index dramatically speeds up:
--   (1) lookups of all items within a given order (FK join from Orders → OrderItem)
--   (2) lookups of how many times a specific item appears across orders (sales reports, fn_GetTopSellingItem)
-- Without it, every such query causes a full table scan on OrderItem as the table grows.

CREATE NONCLUSTERED INDEX IX_OrderItem_OrderID_ItemID
ON OrderItem (OrderID, ItemID);
GO


-- BONUS: usp_ApplyLoyaltyPoints
-- Awards 1 loyalty point per KES 100 spent on a completed order.
-- If @Redeem = 1, deducts points from the customer (1 point = KES 2 discount)
-- and reduces the order TotalAmount accordingly.

CREATE PROCEDURE usp_ApplyLoyaltyPoints
    @OrderID  INT,
    @Redeem   BIT = 0
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY

        DECLARE @CustomerID  INT;
        DECLARE @TotalAmount DECIMAL(10,2);
        DECLARE @PointsEarned INT;
        DECLARE @CurrentPoints INT;
        DECLARE @Discount     DECIMAL(10,2);

        -- Fetch order details
        SELECT @CustomerID  = CustomerID,
               @TotalAmount = TotalAmount
        FROM Orders
        WHERE OrderID = @OrderID AND Status NOT IN ('Cancelled', 'Pending');

        IF @CustomerID IS NULL
        BEGIN
            RAISERROR('Order not found, is not eligible, or belongs to a guest.', 16, 1);
            RETURN;
        END

        -- Fetch current loyalty points
        SELECT @CurrentPoints = LoyaltyPoints
        FROM Customer
        WHERE CustomerID = @CustomerID;

        IF @Redeem = 1
        BEGIN
            -- Deduct all available points; apply KES 2 discount per point
            SET @Discount = @CurrentPoints * 2.00;

            -- Do not discount more than the order total
            IF @Discount > @TotalAmount
                SET @Discount = @TotalAmount;

            DECLARE @PointsUsed INT = CAST(@Discount / 2 AS INT);

            UPDATE Customer
            SET LoyaltyPoints = LoyaltyPoints - @PointsUsed
            WHERE CustomerID = @CustomerID;

            UPDATE Orders
            SET TotalAmount = TotalAmount - @Discount
            WHERE OrderID = @OrderID;

            PRINT 'Points redeemed: ' + CAST(@PointsUsed AS VARCHAR) +
                  ' | Discount applied: KES ' + CAST(@Discount AS VARCHAR);
        END
        ELSE
        BEGIN
            -- Award 1 point per KES 100 spent
            SET @PointsEarned = CAST(@TotalAmount / 100 AS INT);

            UPDATE Customer
            SET LoyaltyPoints = LoyaltyPoints + @PointsEarned
            WHERE CustomerID = @CustomerID;

            PRINT 'Loyalty points awarded: ' + CAST(@PointsEarned AS VARCHAR);
        END

    END TRY
    BEGIN CATCH
        PRINT 'Error in usp_ApplyLoyaltyPoints: ' + ERROR_MESSAGE();
        THROW;
    END CATCH
END;
GO