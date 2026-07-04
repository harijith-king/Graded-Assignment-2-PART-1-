-- Task 1.3
-- Data Manipulation (DML)
-- ========================================
-- (a) Insert sample data
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
-- ==========================================
UPDATE Instructors
SET instructor_email = 'vijay.nair.new@university.edu'
WHERE instructor_name = 'Prof. Vijay Nair';

-- ==========================================
-- (c) Delete enrollment records with marks_obtained below 35
-- ==========================================
DELETE FROM Enrollments
WHERE marks_obtained < 35;

-- ==========================================
-- (d) Remove all rows from StudentRecords (the old flat table, pre-normalization)
-- ==========================================

DELETE FROM StudentRecords;

'''DELETE is used instead of TRUNCATE because it is a DML statement that works safely with transactions and supports BEGIN, COMMIT, and ROLLBACK across major database systems. 
  In MySQL, TRUNCATE is treated as a DDL statement and automatically commits the transaction, so it cannot be rolled back. 
  Although PostgreSQL allows TRUNCATE to be rolled back, this behavior is not the same in all database engines. 
  Therefore, DELETE without a WHERE clause is the safer and more portable choice for removing all rows inside a transaction.'''
-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- ===========================================
-- Task 1.4
-- ==========================================
-- (a) Students and courses for a specific set of course codes (IN)
-- ==========================================
SELECT s.student_name, c.course_name
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_code = c.course_code
WHERE c.course_code IN ('CS101', 'CS202', 'CS303');
 
-- ==========================================
-- (b) Students with marks between 60 and 85 whose advisor_email is not null
-- ==========================================
 
SELECT s.student_name, e.marks_obtained, a.advisor_email
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Advisors a ON s.advisor_name = a.advisor_name
WHERE e.marks_obtained BETWEEN 60 AND 85
AND a.advisor_email IS NOT NULL;
 
-- ==========================================
-- (c) Average, min, and max marks per department; only departments
-- ==========================================
 
SELECT s.department,
       AVG(e.marks_obtained) AS avg_marks,
       MIN(e.marks_obtained) AS min_marks,
       MAX(e.marks_obtained) AS max_marks
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
GROUP BY s.department
HAVING AVG(e.marks_obtained) > 55;
 
-- ==========================================
-- (d) INNER JOIN vs LEFT JOIN across Students -> Enrollments -> Courses
-- ==========================================
 
-- INNER JOIN: 
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_code = c.course_code;
 
-- LEFT JOIN: 
SELECT s.student_name, c.course_name, e.marks_obtained
FROM Students s
LEFT JOIN Enrollments e ON s.student_id = e.student_id
LEFT JOIN Courses c ON e.course_code = c.course_code;
 
-- ==========================================
-- (e) Correlated subquery: students who scored above their department average
-- ==========================================
 
SELECT s.student_name, e.marks_obtained
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
WHERE e.marks_obtained > (
    SELECT AVG(e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2 ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
);
 
-- ==========================================
-- (f) student_id values enrolled in 2024 but not in 2025 (EXCEPT)(I use MYSQL)
-- ==========================================
 
SELECT student_id FROM Enrollments WHERE enrollment_year = 2024
EXCEPT
SELECT student_id FROM Enrollments WHERE enrollment_year = 2025;
 
 
-- ==========================================
-- (g) Correlated subquery: student with the second-highest marks per department
-- A student is "second highest" i.e, If two students both have the highest score (e.g., both got 99). e2 looks for the max score less than , which will pull the next unique lower score (e.g., 95). 
-- The query will skip the duplicate 1st place and return the person with 95.
-- ==========================================
SELECT s.department,
       s.student_name,
       e.marks_obtained
FROM Students s
JOIN Enrollments e
ON s.student_id = e.student_id
WHERE e.marks_obtained = (
    SELECT MAX(e2.marks_obtained)
    FROM Students s2
    JOIN Enrollments e2
    ON s2.student_id = e2.student_id
    WHERE s2.department = s.department
      AND e2.marks_obtained < (
          SELECT MAX(e3.marks_obtained)
          FROM Students s3
          JOIN Enrollments e3
          ON s3.student_id = e3.student_id
          WHERE s3.department = s.department
      )
);
 
 
-- ==========================================
-- (h) Window functions: ROW_NUMBER, RANK, DENSE_RANK per department
-- ==========================================
 
SELECT
    s.department,
    s.student_name,
    e.marks_obtained,
    ROW_NUMBER() OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS row_num,
    RANK()       OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS rank_val,
    DENSE_RANK() OVER (PARTITION BY s.department ORDER BY e.marks_obtained DESC) AS dense_rank_val
FROM Students s
JOIN Enrollments e ON s.student_id = e.student_id
ORDER BY s.department, e.marks_obtained DESC;

------------------------------------------------------------------------------------------------------------------------------------------------
-- =========================================
-- Task 1.5
-- Transactions and Concurrency
-- ==========================================
-- (a) Transaction that moves a student from CS101 to CS404
-- ==========================================
BEGIN;
DELETE FROM Enrollments
WHERE student_id = 1 AND course_code = 'CS101';
INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained)
VALUES (1, 'CS404', 2026, NULL);
COMMIT;

-- If the INSERT above fails (for example, CS404 does not yet exist in Courses and the foreign key constraint rejects it), run: ROLLBACK;
-- instead of COMMIT, so the DELETE from CS101 is undone and the student is not left enrolled in neither course.

DO $$
BEGIN
    DELETE FROM Enrollments
    WHERE student_id = 1 AND course_code = 'CS101';

    INSERT INTO Enrollments (student_id, course_code, enrollment_year, marks_obtained)
    VALUES (1, 'CS404', 2026, NULL);

EXCEPTION WHEN OTHERS THEN
    RAISE NOTICE 'Insert into CS404 failed, rolling back transfer.';
    ROLLBACK;
END $$;

-- ==========================================
-- (b) Concurrency anomaly:reading marks_obtained twice, getting two different answers because another transaction updated and committed the row in between the two reads
-- ==========================================  
--   T1: BEGIN;
--   T1: SELECT marks_obtained FROM Enrollments WHERE student_id = 1 AND course_code = 'CS102';  -- returns 30.00
--   T3: BEGIN;
--   T3: UPDATE Enrollments SET marks_obtained = 45.00 WHERE student_id = 1 AND course_code = 'CS102';
--   T3: COMMIT;
--   T1: SELECT marks_obtained FROM Enrollments WHERE student_id = 1 AND course_code = 'CS102';  -- now returns 45.00
--   T1: COMMIT;
-- T1 read the same row twice within one transaction and got two different values. This anomaly is called a NON-REPEATABLE READ (also known as a "fuzzy read").
-- Minimum isolation level that prevents it: REPEATABLE READ.
-- At REPEATABLE READ, T1's snapshot of any row it has already read stays fixed for the rest of its transaction, so the second SELECT would still return 30.00 even after T3 commits its update. 
-- READ COMMITTED does NOT prevent this, since it only guards against reading uncommitted data - it happily lets you see a different, newly-committed value on each read.

-- ==========================================
-- (c) Concurrency anomaly: two transactions both read the same enrollment
-- count, both conclude there is room, and both insert - exceeding capacity
-- ==========================================

-- Sequence of events (assume CS102 has a capacity of 2, currently at 1):
--   T1: BEGIN;
--   T1: SELECT COUNT(*) FROM Enrollments WHERE course_code = 'CS102';  -- returns 1, room for 1 more
--   T2: BEGIN;
--   T2: SELECT COUNT(*) FROM Enrollments WHERE course_code = 'CS102';  -- also returns 1, also thinks there's room
--   T1: INSERT INTO Enrollments (...) VALUES (..., 'CS102', ...);
--   T1: COMMIT;
--   T2: INSERT INTO Enrollments (...) VALUES (..., 'CS102', ...);
--   T2: COMMIT;
--   -- CS102 now has 3 enrollments even though capacity was 2
--
-- Anomaly: PHANTOM READ / WRITE SKEW
-- Occurs when a concurrent transaction inserts new rows, altering aggregate 
-- results (like COUNT(*)) that a running transaction has already relied on. 
-- Both transactions proceed to write based on a count that the other invalidates.
--
-- Minimum Isolation Level: SERIALIZABLE
-- REPEATABLE READ only locks existing rows; it does not prevent new "phantom" 
-- rows from appearing and breaking aggregate logic.


-- ==========================================
-- (d) MVCC and snapshot consistency
-- ==========================================

-- Scenario:
--   Reporting transaction (R):  BEGIN; SELECT marks_obtained ... ;  -- reads 30.00
--   Write transaction (W):      BEGIN; UPDATE ... SET marks_obtained = 90.00 ...; COMMIT;
--   Reporting transaction (R):  SELECT marks_obtained ... again;
--
-- Result: R still sees the old value (30.00), despite W committing 90.00.
--
-- Why (MVCC): Updates create new row versions rather than overwriting in place. 
-- Under REPEATABLE READ/SERIALIZABLE, R relies on a fixed snapshot taken when 
-- its transaction started. W's changes remain invisible until R restarts.
--
-- Minimum Isolation Level: REPEATABLE READ (provides snapshot isolation).
--
-- Trade-offs vs. READ COMMITTED:
-- 1. Stale Data: Reads reflect the transaction start time, not real-time state.
-- 2. Serialization Errors: Concurrent updates to the same rows force app retries.
-- 3. Table Bloat: Long-running snapshots delay cleanup of old row versions.
