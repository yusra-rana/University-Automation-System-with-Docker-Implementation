-- ============================================================================
-- LAB 03: FUNCTIONAL DEPENDENCIES & NORMALIZATION
-- Database : UAMS
-- Schema   : Academic
-- Note     : Only practice tables are dropped. Original UAMS tables are never touched.
-- HOW TO RUN: select ONE step at a time (from its "STEP" comment down to the
--             last GO of that step) and run it, then take the screenshot.
-- ============================================================================


-- ============================================================================
-- STEP 0: CLEAN START (drops practice tables only, safe to re-run)
-- ============================================================================
USE UAMS;
GO

DROP TABLE IF EXISTS Academic.Enrollment_3NF;
DROP TABLE IF EXISTS Academic.Student_3NF;
DROP TABLE IF EXISTS Academic.Program_3NF;
DROP TABLE IF EXISTS Academic.Department_3NF;
DROP TABLE IF EXISTS Academic.Course_3NF;
DROP TABLE IF EXISTS Academic.Enrollment_2NF;
DROP TABLE IF EXISTS Academic.Course_2NF;
DROP TABLE IF EXISTS Academic.Student_2NF;
DROP TABLE IF EXISTS Academic.StudentInstructor;
DROP TABLE IF EXISTS Academic.InstructorCourse;
DROP TABLE IF EXISTS Academic.Teaching;
DROP TABLE IF EXISTS Academic.CourseEnrollment_Bad;
DROP TABLE IF EXISTS Academic.StudentCourse_UNF;
GO


-- ============================================================================
-- STEP 1: SELECT THE UAMS DATABASE            (Screenshot 1 / Checkpoint 1)
-- ============================================================================
USE UAMS;
GO
SELECT DB_NAME() AS CurrentDatabase;
GO


-- ============================================================================
-- STEP 2: CREATE AND POPULATE StudentCourse_UNF      (Screenshot 2)
-- ============================================================================
CREATE TABLE Academic.StudentCourse_UNF
(
    StudentID      INT           NOT NULL,
    StudentName    VARCHAR(100)  NOT NULL,
    ProgramID      INT           NOT NULL,
    ProgramName    VARCHAR(100)  NOT NULL,
    DepartmentID   INT           NOT NULL,
    DepartmentName VARCHAR(100)  NOT NULL,
    CourseCode     VARCHAR(20)   NOT NULL,
    CourseTitle    VARCHAR(150)  NOT NULL,
    InstructorName VARCHAR(100)  NOT NULL,
    SemesterName   VARCHAR(50)   NOT NULL,
    Marks          DECIMAL(5,2)  NULL
);
GO

INSERT INTO Academic.StudentCourse_UNF
(
    StudentID, StudentName, ProgramID, ProgramName,
    DepartmentID, DepartmentName, CourseCode, CourseTitle,
    InstructorName, SemesterName, Marks
)
VALUES
(101, 'Ali Khan',    1, 'BS Computer Science', 10, 'Computer Science', 'CS302', 'Database Systems',                     'Dr. Ahmed Khan', 'Fall 2026', 85),
(101, 'Ali Khan',    1, 'BS Computer Science', 10, 'Computer Science', 'CS401', 'Advanced Database Management System',  'Dr. Ahmed Khan', 'Fall 2026', 78),
(102, 'Sara Ahmed',  1, 'BS Computer Science', 10, 'Computer Science', 'CS302', 'Database Systems',                     'Dr. Ahmed Khan', 'Fall 2026', 91),
(103, 'Usman Ali',   1, 'BS Computer Science', 10, 'Computer Science', 'CS302', 'Database Systems',                     'Dr. Ahmed Khan', 'Fall 2026', 74);
GO

SELECT * FROM Academic.StudentCourse_UNF;
GO


-- ============================================================================
-- STEP 3: UPDATE ANOMALY DEMONSTRATION               (Screenshot 6)
-- ============================================================================
CREATE TABLE Academic.CourseEnrollment_Bad
(
    StudentID    INT           NOT NULL,
    StudentName  VARCHAR(100)  NOT NULL,
    CourseCode   VARCHAR(20)   NOT NULL,
    CourseTitle  VARCHAR(150)  NOT NULL,
    SemesterName VARCHAR(50)   NOT NULL,
    Marks        DECIMAL(5,2)
);
GO

INSERT INTO Academic.CourseEnrollment_Bad VALUES
(101, 'Ali Khan',    'CS302', 'Database Systems', 'Fall 2026', 85),
(102, 'Sara Ahmed',  'CS302', 'Database Systems', 'Fall 2026', 91),
(103, 'Usman Ali',   'CS302', 'Database Systems', 'Fall 2026', 74);
GO

-- Update only ONE row: the same course code now has two different titles
UPDATE Academic.CourseEnrollment_Bad
SET CourseTitle = 'Database Management Systems'
WHERE StudentID = 101;
GO

SELECT * FROM Academic.CourseEnrollment_Bad WHERE CourseCode = 'CS302';
GO


-- ============================================================================
-- STEP 4: INSERTION ANOMALY DEMONSTRATION            (Screenshot 7a)
-- Expected: this INSERT FAILS (StudentID cannot be NULL).
-- Take a screenshot of the error message.
-- ============================================================================
INSERT INTO Academic.CourseEnrollment_Bad
(StudentID, StudentName, CourseCode, CourseTitle, SemesterName, Marks)
VALUES
(NULL, NULL, 'CS450', 'Artificial Intelligence', 'Fall 2026', NULL);
GO


-- ============================================================================
-- STEP 5: DELETION ANOMALY DEMONSTRATION             (Screenshot 7b)
-- ============================================================================
-- CS450 exists with only one student
INSERT INTO Academic.CourseEnrollment_Bad VALUES
(104, 'Hina Shah', 'CS450', 'Artificial Intelligence', 'Fall 2026', 88);
GO

SELECT * FROM Academic.CourseEnrollment_Bad WHERE CourseCode = 'CS450';
GO

-- Delete that student's enrollment
DELETE FROM Academic.CourseEnrollment_Bad
WHERE StudentID = 104 AND CourseCode = 'CS450';
GO

-- Result is EMPTY: the course information CS450 is lost (deletion anomaly)
SELECT * FROM Academic.CourseEnrollment_Bad WHERE CourseCode = 'CS450';
GO


-- ============================================================================
-- STEP 6: 2NF DECOMPOSITION                          (Screenshot 4 / Checkpoint 2)
-- Partial dependencies removed:
--   StudentID  -> StudentName, ProgramID
--   CourseCode -> CourseTitle, InstructorName
-- ============================================================================
CREATE TABLE Academic.Student_2NF
(
    StudentID   INT           PRIMARY KEY,
    StudentName VARCHAR(100)  NOT NULL,
    ProgramID   INT           NOT NULL
);
GO

CREATE TABLE Academic.Course_2NF
(
    CourseCode     VARCHAR(20)   PRIMARY KEY,
    CourseTitle    VARCHAR(150)  NOT NULL,
    InstructorName VARCHAR(100)  NOT NULL
);
GO

CREATE TABLE Academic.Enrollment_2NF
(
    StudentID    INT           NOT NULL,
    CourseCode   VARCHAR(20)   NOT NULL,
    SemesterName VARCHAR(50)   NOT NULL,
    Marks        DECIMAL(5,2),
    CONSTRAINT PK_Enrollment_2NF
        PRIMARY KEY (StudentID, CourseCode, SemesterName),
    CONSTRAINT FK_Enrollment2NF_Student
        FOREIGN KEY (StudentID)  REFERENCES Academic.Student_2NF(StudentID),
    CONSTRAINT FK_Enrollment2NF_Course
        FOREIGN KEY (CourseCode) REFERENCES Academic.Course_2NF(CourseCode)
);
GO

-- Checkpoint 2: verify the three 2NF tables exist
SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Academic'
  AND TABLE_NAME IN ('Student_2NF', 'Course_2NF', 'Enrollment_2NF');
GO


-- ============================================================================
-- STEP 7: POPULATE 2NF TABLES FROM StudentCourse_UNF   (Screenshot 4b / Part M)
-- ============================================================================
INSERT INTO Academic.Student_2NF (StudentID, StudentName, ProgramID)
SELECT DISTINCT StudentID, StudentName, ProgramID
FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Course_2NF (CourseCode, CourseTitle, InstructorName)
SELECT DISTINCT CourseCode, CourseTitle, InstructorName
FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Enrollment_2NF (StudentID, CourseCode, SemesterName, Marks)
SELECT StudentID, CourseCode, SemesterName, Marks
FROM Academic.StudentCourse_UNF;
GO

SELECT * FROM Academic.Student_2NF;
GO
SELECT * FROM Academic.Course_2NF;
GO
SELECT * FROM Academic.Enrollment_2NF;
GO


-- ============================================================================
-- STEP 8: 3NF DECOMPOSITION                          (Screenshot 5)
-- Transitive dependencies removed:
--   StudentID -> ProgramID -> ProgramName
--   ProgramID -> DepartmentID -> DepartmentName
-- ============================================================================
CREATE TABLE Academic.Department_3NF
(
    DepartmentID   INT           PRIMARY KEY,
    DepartmentName VARCHAR(100)  NOT NULL
);
GO

CREATE TABLE Academic.Program_3NF
(
    ProgramID    INT           PRIMARY KEY,
    ProgramName  VARCHAR(100)  NOT NULL,
    DepartmentID INT           NOT NULL
        REFERENCES Academic.Department_3NF(DepartmentID)
);
GO

CREATE TABLE Academic.Course_3NF
(
    CourseCode  VARCHAR(20)   PRIMARY KEY,
    CourseTitle VARCHAR(150)  NOT NULL
);
GO

CREATE TABLE Academic.Student_3NF
(
    StudentID   INT           PRIMARY KEY,
    StudentName VARCHAR(100)  NOT NULL,
    ProgramID   INT           NOT NULL
        REFERENCES Academic.Program_3NF(ProgramID)
);
GO

CREATE TABLE Academic.Enrollment_3NF
(
    StudentID    INT           NOT NULL
        REFERENCES Academic.Student_3NF(StudentID),
    CourseCode   VARCHAR(20)   NOT NULL
        REFERENCES Academic.Course_3NF(CourseCode),
    SemesterName VARCHAR(50)   NOT NULL,
    Marks        DECIMAL(5,2),
    CONSTRAINT PK_Enrollment_3NF
        PRIMARY KEY (StudentID, CourseCode, SemesterName)
);
GO

-- Populate parent tables first, then child tables
INSERT INTO Academic.Department_3NF
SELECT DISTINCT DepartmentID, DepartmentName FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Program_3NF
SELECT DISTINCT ProgramID, ProgramName, DepartmentID FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Course_3NF
SELECT DISTINCT CourseCode, CourseTitle FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Student_3NF
SELECT DISTINCT StudentID, StudentName, ProgramID FROM Academic.StudentCourse_UNF;

INSERT INTO Academic.Enrollment_3NF
SELECT StudentID, CourseCode, SemesterName, Marks FROM Academic.StudentCourse_UNF;
GO

SELECT * FROM Academic.Department_3NF;
GO
SELECT * FROM Academic.Program_3NF;
GO
SELECT * FROM Academic.Course_3NF;
GO
SELECT * FROM Academic.Student_3NF;
GO
SELECT * FROM Academic.Enrollment_3NF;
GO


-- ============================================================================
-- STEP 9: BCNF ANALYSIS AND DECOMPOSITION            (Screenshot 8)
-- Teaching(Student, Course, Instructor)
-- FDs: (Student, Course) -> Instructor   and   Instructor -> Course
-- Instructor is NOT a superkey, so Teaching violates BCNF.
-- Candidate keys: (Student, Course) and (Student, Instructor)
-- ============================================================================
CREATE TABLE Academic.Teaching
(
    Student    VARCHAR(100) NOT NULL,
    Course     VARCHAR(100) NOT NULL,
    Instructor VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Teaching PRIMARY KEY (Student, Course)
);
GO

INSERT INTO Academic.Teaching VALUES
('Ali Khan',   'Database Systems', 'Dr. Ahmed Khan'),
('Sara Ahmed', 'Database Systems', 'Dr. Ahmed Khan'),
('Usman Ali',  'Database Systems', 'Dr. Ahmed Khan'),
('Ali Khan',   'Networks',         'Dr. Bilal Shah');
GO

-- Redundancy: "Dr. Ahmed Khan teaches Database Systems" is stored 3 times
SELECT * FROM Academic.Teaching;
GO

-- Decomposition
CREATE TABLE Academic.InstructorCourse
(
    Instructor VARCHAR(100) NOT NULL PRIMARY KEY,
    Course     VARCHAR(100) NOT NULL
);
GO

CREATE TABLE Academic.StudentInstructor
(
    Student    VARCHAR(100) NOT NULL,
    Instructor VARCHAR(100) NOT NULL
        REFERENCES Academic.InstructorCourse(Instructor),
    CONSTRAINT PK_StudentInstructor PRIMARY KEY (Student, Instructor)
);
GO

INSERT INTO Academic.InstructorCourse
SELECT DISTINCT Instructor, Course FROM Academic.Teaching;

INSERT INTO Academic.StudentInstructor
SELECT DISTINCT Student, Instructor FROM Academic.Teaching;
GO

SELECT * FROM Academic.InstructorCourse;
GO
SELECT * FROM Academic.StudentInstructor;
GO


-- ============================================================================
-- STEP 10: COMPARE WITH EXISTING UAMS TABLES         (Activity 9 / Checkpoint 3)
-- ============================================================================
SELECT * FROM Academic.Student;
GO
SELECT * FROM Academic.Program;
GO
SELECT * FROM Academic.Department;
GO
SELECT * FROM Academic.Course;
GO
SELECT * FROM Academic.Enrollment;
GO


-- ============================================================================
-- STEP 11: FINAL TABLE LIST                          (Screenshot 9)
-- ============================================================================
SELECT TABLE_SCHEMA, TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Academic'
ORDER BY TABLE_NAME;
GO


-- ============================================================================
-- CLEAN-UP (run ONLY if your teacher asks. Original UAMS tables are not touched)
-- ============================================================================
-- DROP TABLE IF EXISTS Academic.StudentInstructor;
-- DROP TABLE IF EXISTS Academic.InstructorCourse;
-- DROP TABLE IF EXISTS Academic.Teaching;
-- DROP TABLE IF EXISTS Academic.Enrollment_3NF;
-- DROP TABLE IF EXISTS Academic.Student_3NF;
-- DROP TABLE IF EXISTS Academic.Program_3NF;
-- DROP TABLE IF EXISTS Academic.Department_3NF;
-- DROP TABLE IF EXISTS Academic.Course_3NF;
-- DROP TABLE IF EXISTS Academic.Enrollment_2NF;
-- DROP TABLE IF EXISTS Academic.Course_2NF;
-- DROP TABLE IF EXISTS Academic.Student_2NF;
-- DROP TABLE IF EXISTS Academic.CourseEnrollment_Bad;
-- DROP TABLE IF EXISTS Academic.StudentCourse_UNF;
