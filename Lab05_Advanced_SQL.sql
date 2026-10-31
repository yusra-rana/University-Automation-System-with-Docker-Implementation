-- =============================================
-- ADBMS Lab 05
-- Advanced SQL Queries
-- Name: Yusra Rana
-- Database: UAMS
-- =============================================

USE UAMS;
GO
SELECT DepartmentID
FROM Academic.Department
WHERE DepartmentName = 'Computer Science';
SELECT ProgramID, ProgramName
FROM Academic.Program
WHERE DepartmentID IN
(
    SELECT DepartmentID
    FROM Academic.Department
    WHERE DepartmentName = 'Computer Science'
);

SELECT StudentID, StudentName, ProgramID
FROM Academic.Student
WHERE ProgramID IN
(
    SELECT ProgramID
    FROM Academic.Program
    WHERE DepartmentID IN
    (
        SELECT DepartmentID
        FROM Academic.Department
        WHERE DepartmentName = 'Computer Science'
    )
);


-- =============================================
-- Activity 2: EXISTS
-- Programs Having At Least One Student
-- =============================================

SELECT P.ProgramID, P.ProgramName
FROM Academic.Program AS P
WHERE EXISTS
(
    SELECT 1
    FROM Academic.Student AS S
    WHERE S.ProgramID = P.ProgramID
);

SELECT D.DepartmentID, D.DepartmentName
FROM Academic.Department AS D
WHERE EXISTS
(
    SELECT 1
    FROM Academic.Program AS P
    WHERE P.DepartmentID = D.DepartmentID
);


SELECT P.ProgramID, P.ProgramName
FROM Academic.Program AS P
WHERE NOT EXISTS
(
    SELECT 1
    FROM Academic.Student AS S
    WHERE S.ProgramID = P.ProgramID
);

SELECT D.DepartmentID, D.DepartmentName
FROM Academic.Department AS D
WHERE NOT EXISTS
(
    SELECT 1
    FROM Academic.Program AS P
    WHERE P.DepartmentID = D.DepartmentID
);



SELECT 
    ProgramID,
    ProgramName,
    CASE
        WHEN ProgramName LIKE 'BS%' THEN 'Undergraduate'
        WHEN ProgramName LIKE 'MS%' THEN 'Graduate'
        WHEN ProgramName LIKE 'PhD%' THEN 'Doctoral'
        ELSE 'Other'
    END AS ProgramCategory
FROM Academic.Program;



SELECT 
    StudentID,
    SectionID,
    Marks,
    CASE
        WHEN Marks >= 80 THEN 'Excellent'
        WHEN Marks >= 70 THEN 'Good'
        WHEN Marks >= 50 THEN 'Pass'
        ELSE 'Fail'
    END AS ResultCategory
FROM Academic.Result;

SELECT TOP 5 *
FROM Academic.Student;


SELECT
    StudentID,
    StudentName,
    DateOfBirth,
    CASE
        WHEN DateOfBirth >= '2005-01-01' THEN 'Young'
        WHEN DateOfBirth >= '2000-01-01' THEN 'Adult'
        WHEN DateOfBirth >= '1995-01-01' THEN 'Older Adult'
        ELSE 'Other'
    END AS AgeCategory
FROM Academic.Student;


SELECT ProgramID
FROM Academic.Program
WHERE DepartmentID = 1

UNION

SELECT ProgramID
FROM Academic.Student;

SELECT ProgramID
FROM Academic.Program
WHERE DepartmentID = 1

UNION ALL

SELECT ProgramID
FROM Academic.Student;

SELECT ProgramID
FROM Academic.Program

INTERSECT

SELECT ProgramID
FROM Academic.Student;

SELECT ProgramID
FROM Academic.Program

EXCEPT

SELECT ProgramID
FROM Academic.Student;


SELECT TOP 5 *
FROM Academic.Result;

SELECT
    R.ResultID,
    R.AssessmentID,
    R.StudentID,
    R.ObtainedMarks
FROM Academic.Result AS R
WHERE R.ObtainedMarks >
(
    SELECT AVG(R2.ObtainedMarks)
    FROM Academic.Result AS R2
    WHERE R2.AssessmentID = R.AssessmentID
);

SELECT *
FROM Academic.Result;

INSERT INTO Academic.Result
    (AssessmentID, StudentID, ObtainedMarks)
VALUES
    (1, 2, 18),
    (1, 3, 22),
    (1, 4, 30),
    (1, 5, 15);

SELECT *
FROM Academic.Result;

SELECT
    R.ResultID,
    R.AssessmentID,
    R.StudentID,
    R.ObtainedMarks
FROM Academic.Result AS R
WHERE R.ObtainedMarks >
(
    SELECT AVG(R2.ObtainedMarks)
    FROM Academic.Result AS R2
    WHERE R2.AssessmentID = R.AssessmentID
);
SELECT StudentID, StudentName
FROM Academic.Student;

SELECT
    ResultID,
    AssessmentID,
    StudentID,
    ObtainedMarks
FROM Academic.Result
WHERE ObtainedMarks >
(
    SELECT AVG(ObtainedMarks)
    FROM Academic.Result
);

SELECT TOP 5 *
FROM Academic.Course;
SELECT TOP 5 *
FROM Academic.Section;


-- Exercise 8: Courses Without Sections

SELECT
    C.CourseID,
    C.CourseCode,
    C.CourseTitle
FROM Academic.Course AS C
WHERE NOT EXISTS
(
    SELECT 1
    FROM Academic.Section AS S
    WHERE S.CourseID = C.CourseID
);

SELECT TOP 5 *
FROM Academic.Enrollment;
SELECT TOP 5 *
FROM Academic.Assessment;

SELECT DISTINCT
    S.StudentID,
    S.StudentName
FROM Academic.Student AS S
INNER JOIN Academic.Enrollment AS E
    ON S.StudentID = E.StudentID
WHERE NOT EXISTS
(
    SELECT 1
    FROM Academic.Result AS R
    INNER JOIN Academic.Assessment AS A
        ON R.AssessmentID = A.AssessmentID
    WHERE R.StudentID = E.StudentID
      AND A.SectionID = E.SectionID
);


SELECT DISTINCT
    S.StudentID,
    S.StudentName
FROM Academic.Student AS S
INNER JOIN Academic.Enrollment AS E
    ON S.StudentID = E.StudentID
WHERE NOT EXISTS
(
    SELECT 1
    FROM Academic.Result AS R
    INNER JOIN Academic.Assessment AS A
        ON R.AssessmentID = A.AssessmentID
    WHERE R.StudentID = E.StudentID
      AND A.SectionID = E.SectionID
);