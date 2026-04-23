-- ============================================================
-- FOOD DELIVERY SERVICE - DATABASE SCHEMA (MySQL)
-- Group: Calvin Lin, Anna Chapko, Jung Chen
-- ============================================================

-- ============================================================
-- DROP EXISTING TABLES (Reverse Dependency Order)
-- ============================================================
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS Deliveries;
DROP TABLE IF EXISTS OrderItems;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS MenuItems;
DROP TABLE IF EXISTS RestaurantAddresses;
DROP TABLE IF EXISTS Restaurants;
DROP TABLE IF EXISTS PaymentMethods;
DROP TABLE IF EXISTS CustomerAddresses;
DROP TABLE IF EXISTS Customers;
DROP TABLE IF EXISTS DeliveryPersonnel;

SET FOREIGN_KEY_CHECKS = 1;

-- ============================================================
-- CREATE TABLES
-- ============================================================

CREATE TABLE Customers (
    CustomerID INT AUTO_INCREMENT PRIMARY KEY,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber VARCHAR(20) NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE CustomerAddresses (
    AddressID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE
);

CREATE TABLE PaymentMethods (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    BillingAddressID INT,
    Method VARCHAR(50) NOT NULL,               -- e.g., 'Card', 'Digital Wallet'
    Provider VARCHAR(100),                     -- e.g., 'Visa', 'Mastercard', 'Paypal'
    Token VARCHAR(500) NOT NULL,               -- Reference to Card
    LastFour CHAR(4),
    MonthExpire SMALLINT,
    YearExpire SMALLINT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID) ON DELETE CASCADE,
    FOREIGN KEY (BillingAddressID) REFERENCES CustomerAddresses(AddressID) ON DELETE SET NULL
);

CREATE TABLE Restaurants (
    RestaurantID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    Email VARCHAR(255) NOT NULL UNIQUE,
    CuisineCategory VARCHAR(100)
);

CREATE TABLE RestaurantAddresses (
    RestaurantAddressID INT AUTO_INCREMENT PRIMARY KEY,
    RestaurantID INT NOT NULL,
    Street VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State VARCHAR(100) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID) ON DELETE CASCADE
);

CREATE TABLE MenuItems (
    ItemID INT AUTO_INCREMENT PRIMARY KEY,
    RestaurantID INT NOT NULL,
    Name VARCHAR(255) NOT NULL,
    Description TEXT,
    Price DECIMAL(10, 2) NOT NULL,
    Availability BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID) ON DELETE CASCADE
);

CREATE TABLE DeliveryPersonnel (
    DeliveryPersonID INT AUTO_INCREMENT PRIMARY KEY,
    Name VARCHAR(255) NOT NULL,
    PhoneNumber VARCHAR(20) NOT NULL,
    AvailabilityStatus VARCHAR(50) NOT NULL DEFAULT 'Unavailable', 
    PasswordHash VARCHAR(255) NOT NULL
);

CREATE TABLE Orders (
    OrderID INT AUTO_INCREMENT PRIMARY KEY,
    CustomerID INT NOT NULL,
    RestaurantID INT NOT NULL,
    AddressID INT NOT NULL,
    PaymentID INT,
    OrderDate DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    OrderStatus ENUM('Preparing', 'Out For Delivery', 'Delivered') NOT NULL DEFAULT 'Preparing',
    PaymentStatus ENUM('Paid', 'Pending', 'Refunded') NOT NULL DEFAULT 'Pending',
    SubTotal DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    DeliveryFee DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    TaxAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    DiscountAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    TipAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    TotalAmount DECIMAL(10, 2) NOT NULL DEFAULT 0.00,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (RestaurantID) REFERENCES Restaurants(RestaurantID),
    FOREIGN KEY (AddressID) REFERENCES CustomerAddresses(AddressID),
    FOREIGN KEY (PaymentID) REFERENCES PaymentMethods(PaymentID)
);

CREATE TABLE OrderItems (
    OrderItemID INT AUTO_INCREMENT PRIMARY KEY,
    OrderID INT NOT NULL,
    ItemID INT NOT NULL,
    Quantity INT NOT NULL DEFAULT 1,
    SpecialInstructions TEXT,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE,
    FOREIGN KEY (ItemID) REFERENCES MenuItems(ItemID)
);

CREATE TABLE Deliveries (
    DeliveryID INT AUTO_INCREMENT PRIMARY KEY,
    DeliveryPersonID INT NOT NULL,
    OrderID INT NOT NULL UNIQUE,
    AssignedTime DATETIME,
    DeliveryTime DATETIME,
    EstimatedTime DATETIME,
    CurrentLocation VARCHAR(255),
    FOREIGN KEY (DeliveryPersonID) REFERENCES DeliveryPersonnel(DeliveryPersonID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE
);


-- SAMPLE DATA: PART 1 - Jung Chen


-- ============================================================
-- SAMPLE DATA: Customers
-- ============================================================
INSERT INTO Customers (FirstName, LastName, Email, PhoneNumber, PasswordHash) VALUES
('Alice', 'Johnson', 'alice.johnson@example.com', '123-555-0101', '$2b$10$abcdefghijklmnopqrstuv'),
('Bob', 'Smith', 'bob.smith@example.com', '321-555-0102', '$2b$10$bcdefghijklmnopqrstuvw'),
('Charlie', 'Brown', 'charlie.brown@example.com', '555-555-0103', '$2b$10$cdefghijklmnopqrstuvwx'),
('Diana', 'Prince', 'diana.prince@example.com', '132-555-0104', '$2b$10$defghijklmnopqrstuvwxy'),
('Ethan', 'Hunt', 'ethan.hunt@example.com', '333-555-0105', '$2b$10$efghijklmnopqrstuvwxyz'),
('Fiona', 'Gallagher', 'fiona.g@example.com', '534-555-0106', '$2b$10$fghijklmnopqrstuvwxyza'),
('George', 'Costanza', 'g.costanza@example.com', '345-555-0107', '$2b$10$ghijklmnopqrstuvwxyzab'),
('Hannah', 'Abbott', 'hannah.a@example.com', '553-555-0108', '$2b$10$hijklmnopqrstuvwxyzabc'),
('Ian', 'Malcolm', 'ian.malcolm@example.com', '312-555-0109', '$2b$10$ijklmnopqrstuvwxyzabcd'),
('Julia', 'Child', 'julia.c@example.com', '312-555-0110', '$2b$10$jklmnopqrstuvwxyzabcde');


-- ============================================================
-- SAMPLE DATA: CustomerAddresses
-- ============================================================
-- Note: customer_id matches the sequential order of the Customers inserted above (1-10).
INSERT INTO CustomerAddresses (CustomerID, Street, City, State, ZipCode) VALUES
(1, '350 5th Ave', 'New York', 'NY', '10118'),
(2, '11 Wall St', 'New York', 'NY', '10005'),
(3, '20 W 34th St', 'New York', 'NY', '10001'),
(4, '89 E 42nd St', 'New York', 'NY', '10017'),
(5, '221 B Baker St', 'New York', 'NY', '10014'),
(6, '1 Times Sq', 'New York', 'NY', '10036'),
(7, '200 Eastern Pkwy', 'Brooklyn', 'NY', '11238'),
(8, '111 W 57th St', 'New York', 'NY', '10019'),
(9, '10 Columbus Cir', 'New York', 'NY', '10019'),
(10, '30 Rockefeller Plaza', 'New York', 'NY', '10112');


-- ============================================================
-- SAMPLE DATA: PaymentMethods
-- ============================================================
-- Note: customer_id and billing_address_id map to the previously inserted data (1-10).
-- Some use Cards (requiring expiration/last four), others use Digital Wallets.
INSERT INTO PaymentMethods (CustomerID, BillingAddressID, Method, Provider, Token, LastFour, MonthExpire, YearExpire) VALUES
(1, 1, 'Card', 'Visa', 'tok_1A2b3C4d5E6f', '4242', 12, 2025),
(2, 2, 'Digital Wallet', 'Paypal', 'tok_paypal_xyz987', NULL, NULL, NULL),
(3, 3, 'Card', 'Mastercard', 'tok_9Z8y7X6w5V4u', '5555', 10, 2026),
(4, 4, 'Card', 'Amex', 'tok_amex_123abc', '3210', 05, 2024),
(5, 5, 'Digital Wallet', 'Apple Pay', 'tok_applepay_999', NULL, NULL, NULL),
(6, 6, 'Card', 'Visa', 'tok_visa_456def', '1111', 08, 2027),
(7, 7, 'Card', 'Discover', 'tok_disc_789ghi', '6011', 01, 2025),
(8, 8, 'Digital Wallet', 'Google Pay', 'tok_gpay_321jkl', NULL, NULL, NULL),
(9, 9, 'Card', 'Visa', 'tok_visa_654mno', '4321', 11, 2028),
(10, 10, 'Card', 'Mastercard', 'tok_mc_987pqr', '9876', 03, 2026);


-- SAMPLE DATA: PART 2 - Calvin Lin


-- ============================================================
-- SAMPLE DATA: Restaurants
-- ============================================================
INSERT INTO Restaurants (RestaurantID, Name, PhoneNumber, Email, CuisineCategory) VALUES
(1, 'Papa Johns', '347-123-5235', 'papajohns@yahoo.com', 'Italian'),
(2, 'Hot Dogma', '124-623-1252', 'hotdoggs@gmail.com', 'American'),
(3, 'Dim Summit', '282-352-5123', 'dimsummit23@gmail.com', 'Chinese'),
(4, 'Urban Bites', '623-626-5625', 'urbanbites@gmail.com', 'Mediterranean'),
(5, 'Wings Wonder', '915-612-1235', 'wonderwings@yahoo.com', 'American'),
(6, 'Steak Em', '412-324-7455', 'steakem31@gmail.com', 'American'),
(7, 'Patty Parlor', '125-753-1255', 'pattysparlor@yahoo.com', 'American'),
(8, 'City Barbecue', '123-757-8922', 'citybbq@gmail.com', 'American/French'),
(9, 'Creme', '876-246-6235', 'cremebrulea@yahoo.com', 'French'),
(10, 'La Mexicana', '651-622-8523', 'lamexicana2@gmail.com', 'Mexican');

-- ============================================================
-- SAMPLE DATA: RestaurantAddresses
-- ============================================================
INSERT INTO RestaurantAddresses (RestaurantAddressID, RestaurantID, Street, City, State, ZipCode) VALUES
(1, 1, '800 Locust Lane', 'Brooklyn', 'NY', '11210'),
(2, 2, '26 White Street', 'Brooklyn', 'NY', '11225'),
(3, 3, '403 Beech Street', 'New York', 'NY', '10009'),
(4, 4, '8591 Columbia Street', 'South Ozone Park', 'NY', '11420'),
(5, 5, '946 Clinton Street', 'Brooklyn', 'NY', '11236'),
(6, 6, '34 14th Street', 'Astoria', 'NY', '11105'),
(7, 7, '81 Prospect Avenue', 'Brooklyn', 'NY', '11207'),
(8, 8, '9794 Country Lane', 'Bronx', 'NY', '10453'),
(9, 9, '2 Creek Road', 'New York', 'NY', '10031'),
(10, 10, '283 College Street', 'Tonawanda', 'NY', '14150');


-- ============================================================
-- SAMPLE DATA: MenuItems
-- ============================================================
INSERT INTO MenuItems (ItemID, RestaurantID, Name, Description, Price, Availability) VALUES
(1, 2, 'Hot Dog', 'Just a plain Hot Dog with ketchup,mustard,relish', 2.50, true),
(2, 9, 'Creme Brulee', 'Signature Dessert, Custard with caramelized sugar crust', 7.50, true),
(3, 6, 'Ribeye', 'Prime Ribeye with Mash/Veggies', 29.99, false),
(4, 5, 'BBQ Wings', '6 House Special Wings coated in BBQ Sauce', 10.50, false),
(5, 5, 'Plain Fried Wings', '6 Plain Bone-In Wings', 9.50, true),
(6, 7, 'Cheeseburger', 'Simple Hamburger with Beef, Lettuce, Tomato, and Cheese ', 8.25 , false),
(7, 10, 'Beef Quesadilla', '2 corn tortillas with beef and cheese inside ', 5.25, true),
(8, 7, 'Champion Burger', 'Burger with 2 Beef Patties, 2 Bacon Strips, Tomatoes, Onion, Pickles, Lettuce, Cheese, House Special Sauce', 10.00, false),
(9, 1, 'Pepperoni Pizza', 'Plain Cheese Pizza topped with Pepperoni', 8.25, true),
(10, 8, 'Braised Short Ribs', 'Boneless Short Ribs braised in red wine and beef broth + extras for 4 hours', 20.50, true);


-- SAMPLE DATA: PART 3 - Anna Chapo


-- ============================================================
-- SAMPLE DATA: DeliveryPersonnel
-- ============================================================
INSERT INTO DeliveryPersonnel (Name, PhoneNumber, AvailabilityStatus, PasswordHash) VALUES
('Marcus Rivera',  '718-555-0201', 'Available',    '$2b$10$delpersonhash0001xxxxx'),
('Priya Sharma',   '718-555-0202', 'On Delivery',  '$2b$10$delpersonhash0002xxxxx'),
('Kevin Torres',   '917-555-0203', 'Available',    '$2b$10$delpersonhash0003xxxxx'),
('Jada Williams',  '646-555-0204', 'Offline',      '$2b$10$delpersonhash0004xxxxx'),
('Liam Chen',      '718-555-0205', 'Available',    '$2b$10$delpersonhash0005xxxxx'),
('Sofia Reyes',    '917-555-0206', 'On Delivery',  '$2b$10$delpersonhash0006xxxxx'),
('Darnell Brooks', '646-555-0207', 'Available',    '$2b$10$delpersonhash0007xxxxx'),
('Hana Kobayashi', '718-555-0208', 'Offline',      '$2b$10$delpersonhash0008xxxxx'),
('Tomas Vega',     '917-555-0209', 'Available',    '$2b$10$delpersonhash0009xxxxx'),
('Naomi Patel',    '646-555-0210', 'On Delivery',  '$2b$10$delpersonhash0010xxxxx');


-- ============================================================
-- SAMPLE DATA: Orders
-- ============================================================
-- TotalAmount = SubTotal + DeliveryFee + TaxAmount - DiscountAmount + TipAmount
INSERT INTO Orders (CustomerID, RestaurantID, AddressID, PaymentID, OrderDate, OrderStatus, PaymentStatus, SubTotal, DeliveryFee, TaxAmount, DiscountAmount, TipAmount, TotalAmount) VALUES
(1,  2,  1,  1,  '2026-03-01 12:15:00', 'Delivered',        'Paid',     10.00, 2.99, 0.89, 0.00, 1.00, 14.88),
(2,  5,  2,  2,  '2026-03-02 18:30:00', 'Delivered',        'Paid',     19.00, 3.49, 1.71, 2.00, 2.00, 24.20),
(3,  1,  3,  3,  '2026-03-03 13:00:00', 'Out For Delivery', 'Pending',  16.50, 2.99, 1.49, 0.00, 0.00, 20.98),
(4,  7,  4,  4,  '2026-03-04 19:45:00', 'Delivered',        'Paid',     18.25, 3.99, 1.64, 0.00, 3.00, 26.88),
(5,  9,  5,  5,  '2026-03-05 20:00:00', 'Delivered',        'Refunded',  7.50, 2.99, 0.68, 0.00, 0.00, 11.17),
(6,  6,  6,  6,  '2026-03-06 14:30:00', 'Preparing',        'Pending',  29.99, 4.99, 2.70, 0.00, 5.00, 42.68),
(7,  10, 7,  7,  '2026-03-07 17:00:00', 'Delivered',        'Paid',     10.50, 2.99, 0.95, 1.00, 1.00, 14.44),
(8,  3,  8,  8,  '2026-03-08 11:30:00', 'Out For Delivery', 'Pending',  22.00, 3.99, 1.98, 0.00, 2.00, 29.97),
(9,  8,  9,  9,  '2026-03-09 21:00:00', 'Delivered',        'Paid',     20.50, 2.99, 1.85, 0.00, 4.00, 29.34),
(10, 4,  10, 10, '2026-03-10 16:15:00', 'Preparing',        'Pending',  14.00, 3.49, 1.26, 0.00, 0.00, 18.75);


-- ============================================================
-- SAMPLE DATA: OrderItems
-- ============================================================
INSERT INTO OrderItems (OrderID, ItemID, Quantity, SpecialInstructions) VALUES
(1,  1,  2, 'Extra mustard please'),
(2,  4,  1, NULL),
(2,  5,  1, 'Extra crispy'),
(3,  9,  2, 'Well done'),
(4,  6,  1, 'No tomatoes'),
(4,  8,  1, 'Add extra sauce'),
(5,  2,  1, NULL),
(6,  3,  1, 'Medium rare'),
(7,  7,  2, 'No onions'),
(8,  1,  3, NULL),
(9,  10, 1, 'No substitutions'),
(10, 7,  2, 'Extra cheese');


-- ============================================================
-- SAMPLE DATA: Deliveries
-- ============================================================
INSERT INTO Deliveries (DeliveryPersonID, OrderID, AssignedTime, DeliveryTime, EstimatedTime, CurrentLocation) VALUES
(1, 1,  '2026-03-01 12:20:00', '2026-03-01 12:55:00', '2026-03-01 12:50:00', 'Delivered'),
(2, 2,  '2026-03-02 18:35:00', '2026-03-02 19:10:00', '2026-03-02 19:00:00', 'Delivered'),
(3, 3,  '2026-03-03 13:05:00', NULL,                   '2026-03-03 13:40:00', '403 Beech St - En Route'),
(5, 4,  '2026-03-04 19:50:00', '2026-03-04 20:30:00', '2026-03-04 20:25:00', 'Delivered'),
(6, 5,  '2026-03-05 20:05:00', '2026-03-05 20:45:00', '2026-03-05 20:40:00', 'Delivered'),
(7, 7,  '2026-03-07 17:05:00', '2026-03-07 17:50:00', '2026-03-07 17:45:00', 'Delivered'),
(9, 8,  '2026-03-08 11:35:00', NULL,                   '2026-03-08 12:10:00', 'Manhattan Bridge - En Route'),
(1, 9,  '2026-03-09 21:05:00', '2026-03-09 21:45:00', '2026-03-09 21:40:00', 'Delivered'),
(3, 10, '2026-03-10 16:20:00', NULL,                   '2026-03-10 16:55:00', 'Preparing - Not Yet Dispatched'),
(2, 6,  '2026-03-06 14:35:00', NULL,                   '2026-03-06 15:10:00', 'Preparing - Not Yet Dispatched');
