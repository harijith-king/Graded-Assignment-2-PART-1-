
-- Assignment 2 - Task 1.2
-- BCNF Schema Implementation

-- ==========================================
-- Advisors Table
-- ==========================================
CREATE TABLE Advisors (
    advisor_name VARCHAR(100) PRIMARY KEY,
    advisor_email VARCHAR(100) NOT NULL UNIQUE
);

-- ==========================================
-- Instructors Table
-- ==========================================
CREATE TABLE Instructors (
    instructor_name VARCHAR(100) PRIMARY KEY,
    instructor_email VARCHAR(100) NOT NULL UNIQUE
);

-- ==========================================
-- Courses Table
-- ==========================================
CREATE TABLE Courses (
    course_code VARCHAR(10) PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    instructor_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_course_instructor
        FOREIGN KEY (instructor_name)
        REFERENCES Instructors(instructor_name)
);

-- ==========================================
-- Students Table
-- ==========================================
CREATE TABLE Students (
    student_id INT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    department VARCHAR(50) NOT NULL,
    advisor_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_student_advisor
        FOREIGN KEY (advisor_name)
        REFERENCES Advisors(advisor_name)
);

-- ==========================================
-- Enrollments Table
-- ==========================================
CREATE TABLE Enrollments (
    student_id INT NOT NULL,
    course_code VARCHAR(10) NOT NULL,
    enrollment_year INT DEFAULT 2026,
    marks_obtained DECIMAL(5,2)
        CHECK (marks_obtained BETWEEN 0 AND 100),
    PRIMARY KEY (student_id, course_code),
    CONSTRAINT fk_enrollment_student
        FOREIGN KEY (student_id)
        REFERENCES Students(student_id),
    CONSTRAINT fk_enrollment_course
        FOREIGN KEY (course_code)
        REFERENCES Courses(course_code)
);
