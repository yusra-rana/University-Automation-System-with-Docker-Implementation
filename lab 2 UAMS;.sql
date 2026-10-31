USE UAMS;
GO

-- ===================================================================
-- LAB 1 TABLES (Fresh Docker Environment ke liye zaroori hain)
-- ===================================================================
CREATE TABLE Academic.Department (
    DepartmentID INT IDENTITY(1,1) NOT NULL,
    DepartmentName VARCHAR(100) NOT NULL,
    CONSTRAINT PK_Department PRIMARY KEY (DepartmentID)
);
GO

CREATE TABLE Academic.Program (
    ProgramID INT IDENTITY(1,1) NOT NULL,
    ProgramName VARCHAR(100) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT PK_Program PRIMARY KEY (ProgramID),
    CONSTRAINT FK_Program_Department FOREIGN KEY (DepartmentID) REFERENCES Academic.Department(DepartmentID)
);
GO

CREATE TABLE Academic.Student (
    StudentID INT IDENTITY(1,1) NOT NULL,
    StudentName VARCHAR(100) NOT NULL,
    ProgramID INT NOT NULL,
    CONSTRAINT PK_Student PRIMARY KEY (StudentID),
    CONSTRAINT FK_Student_Program FOREIGN KEY (ProgramID) REFERENCES Academic.Program(ProgramID)
);
GO

-- ===================================================================
-- LAB 2 TABLES: Step 1 (Instructor) aur Step 2 (Course)
-- ===================================================================
CREATE TABLE Academic.Instructor(
    InstructorID INT IDENTITY(1,1) NOT NULL,
    InstructorName VARCHAR(100) NOT NULL,
    Email VARCHAR(150) NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT PK_Instructor PRIMARY KEY (InstructorID),
    CONSTRAINT UQ_Instructor_Email UNIQUE (Email),
    CONSTRAINT FK_Instructor_Department FOREIGN KEY (DepartmentID) REFERENCES Academic.Department(DepartmentID)
);
GO

CREATE TABLE Academic.Course(
    CourseID INT IDENTITY(1,1) NOT NULL,
    CourseCode VARCHAR(20) NOT NULL,
    CourseTitle VARCHAR(150) NOT NULL,
    CreditHours INT NOT NULL,
    DepartmentID INT NOT NULL,
    CONSTRAINT PK_Course PRIMARY KEY (CourseID),
    CONSTRAINT UQ_Course_CourseCode UNIQUE (CourseCode),
    CONSTRAINT CK_Course_CreditHours CHECK (CreditHours BETWEEN 1 AND 6),
    CONSTRAINT FK_Course_Department FOREIGN KEY (DepartmentID) REFERENCES Academic.Department(DepartmentID)
);
GO

-- ===================================================================
-- LAB 2 TABLES: Step 3 (CoursePrerequisite) se Step 5 (Section)
-- ===================================================================
CREATE TABLE Academic.CoursePrerequisite(
    CourseID INT NOT NULL,
    PrerequisiteCourseID INT NOT NULL,
    CONSTRAINT PK_CoursePrerequisite PRIMARY KEY (CourseID, PrerequisiteCourseID),
    CONSTRAINT CK_CoursePrerequisite_NotSame CHECK (CourseID <> PrerequisiteCourseID),
    CONSTRAINT FK_CoursePrerequisite_Course FOREIGN KEY (CourseID) REFERENCES Academic.Course(CourseID),
    CONSTRAINT FK_CoursePrerequisite_Prerequisite FOREIGN KEY (PrerequisiteCourseID) REFERENCES Academic.Course(CourseID)
);
GO

CREATE TABLE Academic.Semester(
    SemesterID INT IDENTITY(1,1) NOT NULL,
    SemesterName VARCHAR(50) NOT NULL,
    StartDate DATE NOT NULL,
    EndDate DATE NOT NULL,
    CONSTRAINT PK_Semester PRIMARY KEY (SemesterID),
    CONSTRAINT UQ_Semester_Name UNIQUE (SemesterName),
    CONSTRAINT CK_Semester_Dates CHECK (EndDate >= StartDate)
);
GO

CREATE TABLE Academic.Section(
    SectionID INT IDENTITY(1,1) NOT NULL,
    CourseID INT NOT NULL,
    InstructorID INT NOT NULL,
    SemesterID INT NOT NULL,
    SectionCode VARCHAR(20) NOT NULL,
    RoomNo VARCHAR(30),
    Capacity INT NOT NULL,
    CONSTRAINT PK_Section PRIMARY KEY (SectionID),
    CONSTRAINT UQ_Section UNIQUE (SemesterID, CourseID, SectionCode),
    CONSTRAINT CK_Section_Capacity CHECK (Capacity > 0),
    CONSTRAINT FK_Section_Course FOREIGN KEY (CourseID) REFERENCES Academic.Course(CourseID),
    CONSTRAINT FK_Section_Instructor FOREIGN KEY (InstructorID) REFERENCES Academic.Instructor(InstructorID),
    CONSTRAINT FK_Section_Semester FOREIGN KEY (SemesterID) REFERENCES Academic.Semester(SemesterID)
);
GO
-- ===================================================================
-- LAB 2 TABLES: Step 6 (Enrollment) se Step 10 (Fee)
-- ===================================================================
CREATE TABLE Academic.Enrollment(
    EnrollmentID INT IDENTITY(1,1) NOT NULL,
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    EnrollmentDate DATE NOT NULL 
        CONSTRAINT DF_Enrollment_Date DEFAULT (CONVERT(DATE, GETDATE())),
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Enrollment PRIMARY KEY (EnrollmentID),
    CONSTRAINT UQ_Enrollment UNIQUE (StudentID, SectionID),
    CONSTRAINT CK_Enrollment_Status CHECK (Status IN ('Active', 'Dropped', 'Completed')),
    CONSTRAINT FK_Enrollment_Student FOREIGN KEY (StudentID) REFERENCES Academic.Student(StudentID),
    CONSTRAINT FK_Enrollment_Section FOREIGN KEY (SectionID) REFERENCES Academic.Section(SectionID)
);
GO

CREATE TABLE Academic.Assessment(
    AssessmentID INT IDENTITY(1,1) NOT NULL,
    SectionID INT NOT NULL,
    AssessmentType VARCHAR(30) NOT NULL,
    TotalMarks DECIMAL(6,2) NOT NULL,
    AssessmentDate DATE,
    CONSTRAINT PK_Assessment PRIMARY KEY (AssessmentID),
    CONSTRAINT CK_Assessment_TotalMarks CHECK (TotalMarks > 0),
    CONSTRAINT FK_Assessment_Section FOREIGN KEY (SectionID) REFERENCES Academic.Section(SectionID)
);
GO

CREATE TABLE Academic.Result(
    ResultID INT IDENTITY(1,1) NOT NULL,
    AssessmentID INT NOT NULL,
    StudentID INT NOT NULL,
    ObtainedMarks DECIMAL(6,2) NOT NULL,
    CONSTRAINT PK_Result PRIMARY KEY (ResultID),
    CONSTRAINT UQ_Result UNIQUE (AssessmentID, StudentID),
    CONSTRAINT CK_Result_Marks CHECK (ObtainedMarks >= 0),
    CONSTRAINT FK_Result_Assessment FOREIGN KEY (AssessmentID) REFERENCES Academic.Assessment(AssessmentID),
    CONSTRAINT FK_Result_Student FOREIGN KEY (StudentID) REFERENCES Academic.Student(StudentID)
);
GO

CREATE TABLE Academic.Attendance(
    AttendanceID INT IDENTITY(1,1) NOT NULL,
    StudentID INT NOT NULL,
    SectionID INT NOT NULL,
    AttendanceDate DATE NOT NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Attendance PRIMARY KEY (AttendanceID),
    CONSTRAINT UQ_Attendance UNIQUE (StudentID, SectionID, AttendanceDate),
    CONSTRAINT CK_Attendance_Status CHECK (Status IN ('Present', 'Absent', 'Late')),
    CONSTRAINT FK_Attendance_Student FOREIGN KEY (StudentID) REFERENCES Academic.Student(StudentID),
    CONSTRAINT FK_Attendance_Section FOREIGN KEY (SectionID) REFERENCES Academic.Section(SectionID)
);
GO

CREATE TABLE Academic.Fee(
    FeeID INT IDENTITY(1,1) NOT NULL,
    StudentID INT NOT NULL,
    SemesterID INT NOT NULL,
    Amount DECIMAL(12,2) NOT NULL,
    DueDate DATE NOT NULL,
    PaidDate DATE NULL,
    Status VARCHAR(20) NOT NULL,
    CONSTRAINT PK_Fee PRIMARY KEY (FeeID),
    CONSTRAINT CK_Fee_Amount CHECK (Amount >= 0),
    CONSTRAINT CK_Fee_Status CHECK (Status IN ('Pending', 'Paid', 'Overdue')),
    CONSTRAINT FK_Fee_Student FOREIGN KEY (StudentID) REFERENCES Academic.Student(StudentID),
    CONSTRAINT FK_Fee_Semester FOREIGN KEY (SemesterID) REFERENCES Academic.Semester(SemesterID)
);
GO
SELECT * FROM Academic.Department;
GO
SELECT * FROM Academic.Program;
GO
SELECT * FROM Academic.Student;
GO
-- ===================================================================
-- PART H: Step 1 to Step 5 - Insert Parent Data
-- ===================================================================
-- 1. Insert Department (Lab 1 Parent)
INSERT INTO Academic.Department (DepartmentName) 
VALUES ('Computer Science');
GO

-- 2. Insert Program (Lab 1 Parent)
INSERT INTO Academic.Program (ProgramName, DepartmentID) 
VALUES ('BSCS', 1);
GO

-- 3. Insert Student (Lab 1 Parent)
INSERT INTO Academic.Student (StudentName, ProgramID) 
VALUES ('Yusra Khan', 1);
GO

-- 4. Step 2 - Insert an Instructor (Using DepartmentID = 1)
INSERT INTO Academic.Instructor (InstructorName, Email, DepartmentID)
VALUES ('Dr. Ahmed Khan', 'ahmed.khan@uams.edu', 1);
GO

-- 5. Step 3 - Insert Courses (Using DepartmentID = 1)
INSERT INTO Academic.Course (CourseCode, CourseTitle, CreditHours, DepartmentID)
VALUES 
('CS302', 'Database Systems', 3, 1),
('CS401', 'Advanced Database Management System', 3, 1);
GO

-- 6. Step 4 - Create a Course Prerequisite (CS401 requires CS302)
-- (Yahan hum check karenge ke kis dynamic id par save hue hain)
INSERT INTO Academic.CoursePrerequisite (CourseID, PrerequisiteCourseID)
VALUES (2, 1);
GO

-- 7. Step 5 - Insert a Semester
INSERT INTO Academic.Semester (SemesterName, StartDate, EndDate)
VALUES ('Fall 2026', '2026-09-01', '2027-01-15');
GO
-- ===================================================================
-- PART H: Step 6 to Step 12 - Child Tables Data Insertion
-- ===================================================================
-- 1. Step 6 - Create a Section (CourseID=1, InstructorID=1, SemesterID=1)
INSERT INTO Academic.Section (CourseID, InstructorID, SemesterID, SectionCode, RoomNo, Capacity)
VALUES (1, 1, 1, 'A', 'Lab-1', 40);
GO

-- 2. Step 7 - Enroll a Student (StudentID=1, SectionID=1)
INSERT INTO Academic.Enrollment (StudentID, SectionID, Status)
VALUES (1, 1, 'Active');
GO

-- 3. Step 9 - Create an Assessment
INSERT INTO Academic.Assessment (SectionID, AssessmentType, TotalMarks, AssessmentDate)
VALUES (1, 'Midterm', 30, '2026-11-15');
GO

-- 4. Step 10 - Insert a Result (AssessmentID=1, StudentID=1)
INSERT INTO Academic.Result (AssessmentID, StudentID, ObtainedMarks)
VALUES (1, 1, 25);
GO

-- 5. Step 11 - Insert Attendance
INSERT INTO Academic.Attendance (StudentID, SectionID, AttendanceDate, Status)
VALUES (1, 1, '2026-09-10', 'Present');
GO

-- 6. Step 12 - Insert Fee
INSERT INTO Academic.Fee (StudentID, SemesterID, Amount, DueDate, Status)
VALUES (1, 1, 50000, '2026-09-30', 'Pending');
GO

-- ===================================================================
-- Checkpoint 3: Demonstrate M:N Relationship (Student to Section)
-- ===================================================================
SELECT 
    S.StudentName, 
    C.CourseCode, 
    C.CourseTitle, 
    SEC.SectionCode, 
    E.Status
FROM Academic.Enrollment E
JOIN Academic.Student S ON E.StudentID = S.StudentID
JOIN Academic.Section SEC ON E.SectionID = SEC.SectionID
JOIN Academic.Course C ON SEC.CourseID = C.CourseID;
GO
-- ===================================================================
-- PART I: Test Referential Integrity (Controlled Error Demo)
-- ===================================================================
-- Yeh command intentionally error degi kyunki CourseID 9999 exist nahi karta
INSERT INTO Academic.Section (CourseID, InstructorID, SemesterID, SectionCode, RoomNo, Capacity)
VALUES (9999, 1, 1, 'X', 'Room-999', 30);
GO

-- Proving no invalid record was inserted
SELECT * FROM Academic.Section WHERE SectionCode = 'X';
GO

-- ===================================================================
-- PART J: Display All Foreign Keys (Metadata Query)
-- ===================================================================
SELECT 
    fk.name AS ForeignKeyName,
    OBJECT_NAME(fk.parent_object_id) AS ChildTable,
    COL_NAME(fkc.parent_object_id, fkc.parent_column_id) AS ChildColumn,
    OBJECT_NAME(fk.referenced_object_id) AS ParentTable,
    COL_NAME(fkc.referenced_object_id, fkc.referenced_column_id) AS ParentColumn
FROM sys.foreign_keys fk
JOIN sys.foreign_key_columns fkc ON fk.object_id = fkc.constraint_object_id
WHERE OBJECT_SCHEMA_NAME(fk.parent_object_id) = 'Academic'
ORDER BY ChildTable;
GO

-- ===================================================================
-- PART K: Final Verification (List All 13 Tables)
-- ===================================================================
SELECT 
    TABLE_SCHEMA, 
    TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = 'Academic'
ORDER BY TABLE_NAME;
GO