-- ==========================================
-- queries.sql
-- Assignment 2 - Task 1.3
-- Data Manipulation (DML)
-- ==========================================

-- ==========================================
-- (a) Insert sample data
-- ==========================================

-- Advisors (at least two)
INSERT INTO Advisors (advisor_name, advisor_email) VALUES
('Dr. Ramesh Kumar', 'ramesh.kumar@university.edu'),
('Dr. Anita Sharma', 'anita.sharma@university.edu');

-- Instructors (needed before Courses, since Courses references them)
INSERT INTO Instructors (instructor_name, instructor_email) VALUES
('Prof. Vijay Nair', 'vijay.nair@university.edu'),
('Prof. Meera Iyer', 'meera.iyer@university.edu');

-- Courses (at least two)
INSERT INTO Courses (course_code, course_name, instructor_name) VALUES
('CS101', 'Introduction to Programming', 'Prof. Vijay Nair'),
('CS102', 'Database Systems', 'Prof. Meera Iyer');

-- Students (at least three)
INSERT INTO Students (student_id, student_name, department, advisor_name) VALUES
(1, 'Arjun Mehta', 'Computer Science', 'Dr. Ramesh Kumar'),
(2, 'Priya Das', 'Computer Science', 'Dr. Anita Sharma'),
(3, 'Karthik Rajan', 'Information Technology', 'Dr. Ramesh Kumar');

-- Enrollments (linking students to courses, with a mix of marks for Task c)
INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained) VALUES
(1, 'CS101', 2026, 78.50),
(1, 'CS102', 2026, 30.00),
(2, 'CS101', 2026, 25.00),
(3, 'CS102', 2026, 90.00);


-- ==========================================
-- (b) Update an instructor's email
-- Targets exactly one row via the primary key (instructor_name)
-- ==========================================

UPDATE Instructors
SET instructor_email = 'vijay.nair.new@university.edu'
WHERE instructor_name = 'Prof. Vijay Nair';


-- ==========================================
-- (c) Delete enrollment records with marks_obtained below 35
-- Only removes the enrollment (relationship) rows;
-- the corresponding Students and Courses records are left untouched
-- ==========================================

DELETE FROM Enrollments
WHERE marks_obtained < 35;


-- ==========================================
-- (d) Remove all rows from StudentRecords (the old flat table, pre-normalization)
-- ==========================================

DELETE FROM StudentRecords;

-- Why DELETE instead of TRUNCATE for this bulk removal:
-- DELETE is a DML statement, so it respects BEGIN / ROLLBACK / COMMIT
-- transaction control consistently across all major database engines.
-- TRUNCATE, on the other hand, behaves inconsistently across databases:
--   - In MySQL, TRUNCATE is treated as DDL and implicitly commits any
--     open transaction, so it CANNOT be rolled back.
--   - In PostgreSQL, TRUNCATE is transactional and can be rolled back,
--     but this behavior is not guaranteed on every database system.
-- Since we want a safe, transaction-controlled bulk removal that behaves
-- the same way no matter which database engine is used, DELETE (without
-- a WHERE clause) is the safer and more portable choice, even though it
-- is typically slower than TRUNCATE on very large tables.
