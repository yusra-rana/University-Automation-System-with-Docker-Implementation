USE UAMS;
GO
SELECT COUNT(*) AS Students FROM Academic.Student;
SELECT COUNT(*) AS Programs FROM Academic.Program;
SELECT COUNT(*) AS Courses  FROM Academic.Course;
SELECT *
FROM Academic.Student;
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Academic'
  AND TABLE_NAME = 'Student';
SELECT StudentID, StudentName
FROM Academic.Student;
SELECT CourseID, CreditHours
FROM Academic.Course;

-- 2.1 Students from a specific program
SELECT *
FROM Academic.Student
WHERE ProgramID = 1;

-- 2.2 Students born after 2004 (only if you have a DateOfBirth column)
SELECT StudentID, StudentName, DateOfBirth
FROM Academic.Student
WHERE DateOfBirth > '2004-01-01';

-- 2.3 Courses with at least 3 credit hours
SELECT CourseID, CourseName, CreditHours
FROM Academic.Course
WHERE CreditHours >= 3;

-- 2.4 Combining conditions
SELECT *
FROM Academic.Course
WHERE CreditHours >= 3
  AND CreditHours <= 4;


  SELECT TABLE_NAME, COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Academic'
  AND TABLE_NAME IN ('Student', 'Course')
ORDER BY TABLE_NAME, ORDINAL_POSITION;


ALTER TABLE Academic.Student ADD DateOfBirth DATE NULL;
GO
WITH Numbered AS (
    SELECT StudentID,
           ROW_NUMBER() OVER (ORDER BY StudentID) AS rn
    FROM Academic.Student
)
UPDATE S
SET DateOfBirth = DATEADD(MONTH, -(N.rn * 5), '2005-06-01')
FROM Academic.Student AS S
JOIN Numbered AS N ON S.StudentID = N.StudentID;
GO

SELECT * FROM Academic.Student;

-- 2.1
SELECT *
FROM Academic.Student
WHERE ProgramID = 1;

-- 2.2
SELECT StudentID, StudentName, DateOfBirth
FROM Academic.Student
WHERE DateOfBirth > '2004-01-01';

-- 2.3
SELECT CourseID, CourseTitle, CreditHours
FROM Academic.Course
WHERE CreditHours >= 3;

-- 2.4
SELECT *
FROM Academic.Course
WHERE CreditHours >= 3
  AND CreditHours <= 4;

-- TASK: ProgramID = 1 and born after 2004
SELECT *
FROM Academic.Student
WHERE ProgramID = 1
  AND DateOfBirth > '2004-01-01';

SELECT StudentID, StudentName
FROM Academic.Student
ORDER BY StudentName;

SELECT * FROM Academic.Program;
SELECT * FROM Academic.Department;
INSERT INTO Academic.Program (ProgramID, ProgramName, DepartmentID)
VALUES
(2, 'BSSE', 1),
(3, 'BSIT', 1),
(4, 'BBA',  1);   -- yeh program mein koi student nahi hoga (LEFT JOIN ke liye)
GO

SELECT * FROM Academic.Program;

INSERT INTO Academic.Program (ProgramName, DepartmentID)
VALUES
('BSSE', 1),
('BSIT', 1),
('BBA',  1);
GO

SELECT * FROM Academic.Program;
SELECT * FROM Academic.Student;

SELECT COLUMNPROPERTY(OBJECT_ID('Academic.Student'), 'StudentID', 'IsIdentity') AS IsIdentity;

INSERT INTO Academic.Student (StudentName, ProgramID, DateOfBirth)
VALUES
('Ayesha Khan',   1, '2005-03-15'),
('Ali Raza',      1, '2003-07-22'),
('Sara Ahmed',    1, '2004-11-05'),
('Hassan Malik',  2, '2005-01-30'),
('Fatima Noor',   2, '2004-06-18'),
('Usman Tariq',   2, '2003-09-09'),
('Zainab Ali',    3, '2005-08-12'),
('Bilal Hussain', 3, '2004-02-27'),
('Hira Shahid',   1, '2005-05-05');
GO

SELECT * FROM Academic.Student;

-- 3.1 Students ko naam se sort karein (A to Z)
SELECT StudentID, StudentName
FROM Academic.Student
ORDER BY StudentName;
-- 3.2 Descending order (Z to A)
SELECT StudentID, StudentName
FROM Academic.Student
ORDER BY StudentName DESC;

-- 3.3 Courses ko credit hours ke hisaab se sort karein (zyada se kam)
SELECT CourseID, CourseTitle, CreditHours
FROM Academic.Course
ORDER BY CreditHours DESC;

SELECT CourseID, CourseTitle, CreditHours
FROM Academic.Course
ORDER BY CreditHours ASC, CourseTitle ASC;

SELECT * FROM Academic.Department;

-- 4.1 Department aur Program
SELECT D.DepartmentID, D.DepartmentName,
       P.ProgramID, P.ProgramName
FROM Academic.Department AS D
INNER JOIN Academic.Program AS P
    ON D.DepartmentID = P.DepartmentID;


-- 4.2 Department -> Program -> Student (Email nahi hai, isliye hata di)
SELECT D.DepartmentName, P.ProgramName,
       S.StudentID, S.StudentName
FROM Academic.Department AS D
INNER JOIN Academic.Program AS P
    ON D.DepartmentID = P.DepartmentID
INNER JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
ORDER BY D.DepartmentName, P.ProgramName, S.StudentName;

-- 5.1 Programs aur Students (BBA bhi aaye ga)
SELECT P.ProgramID, P.ProgramName,
       S.StudentID, S.StudentName
FROM Academic.Program AS P
LEFT JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
ORDER BY P.ProgramName;

-- 5.2 Programs jin mein koi student nahi
SELECT P.ProgramID, P.ProgramName
FROM Academic.Program AS P
LEFT JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
WHERE S.StudentID IS NULL;


-- 6.1 Total students
SELECT COUNT(*) AS TotalStudents
FROM Academic.Student;

-- 6.2 Har program ke students
SELECT ProgramID, COUNT(*) AS StudentCount
FROM Academic.Student
GROUP BY ProgramID;

SELECT SUM(CreditHours) AS TotalCredits,
       AVG(CreditHours) AS AvgCredits,
       MIN(CreditHours) AS MinCredits,
       MAX(CreditHours) AS MaxCredits
FROM Academic.Course;


SELECT P.ProgramID, P.ProgramName,
       COUNT(S.StudentID) AS StudentCount
FROM Academic.Program AS P
LEFT JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
GROUP BY P.ProgramID, P.ProgramName
ORDER BY StudentCount DESC;


-- 8: Programs jin mein 2 se zyada students hain
SELECT ProgramID, COUNT(*) AS StudentCount
FROM Academic.Student
GROUP BY ProgramID
HAVING COUNT(*) > 2;

-- 8.1: Program name ke saath
SELECT P.ProgramID, P.ProgramName,
       COUNT(S.StudentID) AS StudentCount
FROM Academic.Program AS P
INNER JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
GROUP BY P.ProgramID, P.ProgramName
HAVING COUNT(S.StudentID) > 2
ORDER BY StudentCount DESC;


SELECT D.DepartmentName, P.ProgramName,
       S.StudentID, S.StudentName
FROM Academic.Department AS D
INNER JOIN Academic.Program AS P
    ON D.DepartmentID = P.DepartmentID
INNER JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
ORDER BY D.DepartmentName, P.ProgramName, S.StudentName;

-- 1. BSCS students
SELECT S.StudentID, S.StudentName, P.ProgramName
FROM Academic.Student AS S
INNER JOIN Academic.Program AS P
    ON S.ProgramID = P.ProgramID
WHERE P.ProgramName = 'BSCS';

-- 2. Students born after 2004
SELECT StudentID, StudentName, DateOfBirth
FROM Academic.Student
WHERE DateOfBirth > '2004-01-01';

-- 3. Departments and Programs (INNER JOIN)
SELECT D.DepartmentName, P.ProgramName
FROM Academic.Department AS D
INNER JOIN Academic.Program AS P
    ON D.DepartmentID = P.DepartmentID;

-- 4. Students per Program
SELECT ProgramID, COUNT(*) AS StudentCount
FROM Academic.Student
GROUP BY ProgramID;

-- 5. Programs with more than 2 students
SELECT P.ProgramID, P.ProgramName,
       COUNT(S.StudentID) AS StudentCount
FROM Academic.Program AS P
INNER JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
GROUP BY P.ProgramID, P.ProgramName
HAVING COUNT(S.StudentID) > 2;

-- 6. Courses with >= 3 credit hours
SELECT CourseID, CourseTitle, CreditHours
FROM Academic.Course
WHERE CreditHours >= 3;

-- 7. Students in each department (three-table join)
SELECT D.DepartmentName, P.ProgramName,
       S.StudentID, S.StudentName
FROM Academic.Department AS D
INNER JOIN Academic.Program AS P
    ON D.DepartmentID = P.DepartmentID
INNER JOIN Academic.Student AS S
    ON P.ProgramID = S.ProgramID
ORDER BY D.DepartmentName, P.ProgramName, S.StudentName;