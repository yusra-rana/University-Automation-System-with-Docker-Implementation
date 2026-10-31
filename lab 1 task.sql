-- 1. Create a database
CREATE DATABASE CompanyDB;
GO

-- 2. Switch to the new database and create a table
USE CompanyDB;
GO

CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY IDENTITY(1,1),
    FirstName NVARCHAR(50) NOT NULL, 
    LastName NVARCHAR(50) NOT NULL,
    Department NVARCHAR(50),
    Salary DECIMAL(10,2)
);
GO

-- 3. Insert data rows
INSERT INTO Employees (FirstName, LastName, Department, Salary)
VALUES
('Ayesha', 'Khan', 'Engineering', 95000.00),
('Bilal', 'Ahmed', 'Sales', 62000.00),
('Sara', 'Malik', 'Marketing', 58000.00);
GO

-- 4. Query the data to display results
SELECT * FROM Employees;
GO
