USE UAMS;
GO
USE UAMS;
GO

SELECT * FROM Academic.Student;
GO

SELECT * FROM Academic.Program;
GO

SELECT * FROM Academic.Result;
GO

SELECT * FROM Academic.Fee;
GO


;WITH ProgramStudentCount AS
(
    SELECT ProgramID, COUNT(*) AS StudentCount
    FROM Academic.Student
    GROUP BY ProgramID
)
SELECT P.ProgramName, C.StudentCount
FROM ProgramStudentCount AS C
INNER JOIN Academic.Program AS P ON C.ProgramID = P.ProgramID
WHERE C.StudentCount >= 3
ORDER BY C.StudentCount DESC;

;WITH ProgramStudentCount AS
(
    SELECT ProgramID, COUNT(*) AS StudentCount
    FROM Academic.Student
    GROUP BY ProgramID
)
SELECT P.ProgramName, COALESCE(C.StudentCount, 0) AS StudentCount
FROM Academic.Program AS P
LEFT JOIN ProgramStudentCount AS C ON P.ProgramID = C.ProgramID
ORDER BY StudentCount DESC;



SELECT TOP 5 * FROM Academic.Result;
SELECT AssessmentID, StudentID, ObtainedMarks,
       RANK() OVER (PARTITION BY AssessmentID
                    ORDER BY ObtainedMarks DESC) AS AssessmentRank
FROM Academic.Result
ORDER BY AssessmentID, AssessmentRank;


;WITH RankedResults AS
(
    SELECT AssessmentID, StudentID, ObtainedMarks,
           RANK() OVER (PARTITION BY AssessmentID
                        ORDER BY ObtainedMarks DESC) AS AssessmentRank
    FROM Academic.Result
)
SELECT AssessmentID, StudentID, ObtainedMarks, AssessmentRank
FROM RankedResults
WHERE AssessmentRank <= 3
ORDER BY AssessmentID, AssessmentRank;


SELECT StudentID, SemesterID, Amount,
       SUM(Amount) OVER (PARTITION BY StudentID
                         ORDER BY SemesterID
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Academic.Fee
ORDER BY StudentID, SemesterID;

SELECT StudentID, SUM(Amount) AS TotalFees
FROM Academic.Fee
GROUP BY StudentID;

SELECT StudentID, FeeID, SemesterID, Amount,
       SUM(Amount) OVER (PARTITION BY StudentID
                         ORDER BY FeeID
                         ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS RunningTotal
FROM Academic.Fee
ORDER BY StudentID, FeeID;


SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Academic'
  AND TABLE_NAME IN ('Student', 'Program')
ORDER BY TABLE_NAME, ORDINAL_POSITION;

ALTER TABLE Academic.Student ADD Email NVARCHAR(100) NULL;
GO

CREATE OR ALTER VIEW Academic.vw_StudentProgram
AS
SELECT S.StudentID, S.StudentName, S.Email, P.ProgramID, P.ProgramName
FROM Academic.Student AS S
INNER JOIN Academic.Program AS P ON S.ProgramID = P.ProgramID;
GO


CREATE OR ALTER PROCEDURE Academic.GetStudentsByProgram
    @ProgramID INT,
    @BornAfter DATE = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT StudentID, StudentName, Email, ProgramID, DateOfBirth
    FROM Academic.Student
    WHERE ProgramID = @ProgramID
      AND (@BornAfter IS NULL OR DateOfBirth > @BornAfter)
    ORDER BY StudentName;
END;
GO


CREATE OR ALTER TRIGGER Academic.trg_Student_EmailAudit
ON Academic.Student
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT UPDATE(Email) RETURN;

    INSERT INTO Academic.StudentAudit (StudentID, AuditAction, AuditDetails)
    SELECT I.StudentID, 'EMAIL UPDATE',
           CONCAT('Old email: ', COALESCE(D.Email, 'NULL'),
                  '; New email: ', COALESCE(I.Email, 'NULL'))
    FROM inserted AS I
    INNER JOIN deleted AS D ON I.StudentID = D.StudentID
    WHERE I.Email <> D.Email
       OR (I.Email IS NULL AND D.Email IS NOT NULL)
       OR (I.Email IS NOT NULL AND D.Email IS NULL);
END;
GO


CREATE TABLE Academic.StudentAudit
(
    AuditID      INT IDENTITY(1,1) PRIMARY KEY,
    StudentID    INT NOT NULL,
    AuditAction  VARCHAR(20) NOT NULL,
    AuditDate    DATETIME2 NOT NULL DEFAULT SYSDATETIME(),
    AuditDetails NVARCHAR(500) NULL
);
GO


UPDATE Academic.Student
SET Email = 'student.test@example.com'
WHERE StudentID = 1;

SELECT * FROM Academic.StudentAudit
WHERE AuditAction = 'EMAIL UPDATE'
ORDER BY AuditID DESC;

INSERT INTO Academic.Student (StudentName, Email, ProgramID, DateOfBirth)
VALUES ('Test Student', 'test.student@example.com', 1, '2004-05-10');

SELECT * FROM Academic.StudentAudit ORDER BY AuditID DESC;

SELECT TABLE_NAME, COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_SCHEMA = 'Academic'
  AND TABLE_NAME IN ('Result', 'Fee', 'Assessment')
ORDER BY TABLE_NAME, ORDINAL_POSITION;



CREATE OR ALTER TRIGGER Academic.trg_Student_InsertAudit
ON Academic.Student
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO Academic.StudentAudit (StudentID, AuditAction, AuditDetails)
    SELECT I.StudentID, 'INSERT', CONCAT('Student inserted: ', I.StudentName)
    FROM inserted AS I;
END;
GO

INSERT INTO Academic.Student (StudentName, Email, ProgramID, DateOfBirth)
VALUES ('Test Student 2', 'test.student2@example.com', 1, '2004-05-10');

SELECT * FROM Academic.StudentAudit ORDER BY AuditID DESC;