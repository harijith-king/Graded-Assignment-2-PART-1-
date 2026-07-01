## Task 1.1 – Normalization

# a) identify the dependencies.
The composite key given are :

```
StudentRecords(
    student_id,student_name,department,advisor_name,advisor_email,
    course_code,course_name,instructor_name,instructor_email,enrollment_year,
    marks_obtained
)
```
# Partial Dependencies
A partial dependency occurs when a non-key attribute depends on only part of the composite primary key.
And the primary key given is "(student_id, course_code)"

* course_code → course_name
* course_code → instructor_name
* course_code → instructor_email


---

# Transitive Dependencies

It is defined occurs when a non key attribute depends on another non-key attribute.

* advisor_name → advisor_email
* instructor_name → instructor_email
* course_code → instructor_name → instructor_email


---

# b) Decomposing into BCNF

## 1. Advisors

**Primary Key:** advisor_name

**Attributes:** advisor_name, advisor_email

keep advisor in the seperate column.

---

## 2. Instructors

**Primary Key:** instructor_name

**Attributes:** instructor_name, instructor_email

similar to the advisor 

---

## 3. Courses

**Primary Key:** course_code

**Foreign Key:** instructor_name → Instructors(instructor_name)

**Attributes:** course_code, course_name, instructor_name

Each course is stored once, and it links back to whoever teaches it.

---

## 4. Students

**Primary Key:** student_id

**Foreign Key:** advisor_name → Advisors(advisor_name)

**Attributes:** student_id, student_name, department, advisor_name

Student info lives on its own, separate from whatever courses they're enrolled in.

---

## 5. Enrollments

**Primary Key:** (student_id, course_code)

**Foreign Keys:**
* student_id → Students(student_id)
* course_code → Courses(course_code)

**Attributes:** student_id, course_code, enrollment_year, marks_obtained

This table just captures the relationship between a student and a course — the year they enrolled and the marks they got. Nothing else.

---

# c) Checking Data Integrity

##     Entity Integrity ✅

Every table has its own primary key, and none of those key values can be NULL, so each row is uniquely identifiable.

##     Referential Integrity ✅

The foreign keys make sure:
* every student points to a real advisor
* every course points to a real instructor
* every enrollment points to a real student and a real course

So there's no risk of orphaned records floating around with broken references.

## Domain Integrity ✅

Each column uses a sensible data type:

* student_id → INT
* course_code → VARCHAR
* marks_obtained → DECIMAL
* advisor_email → VARCHAR

This stops obviously invalid data (like text in a marks field) from ever being entered.

## User-Defined Integrity ✅

A few business rules can be enforced with constraints:

* marks_obtained should fall between 0 and 100
* enrollment_year needs to be a valid year
* advisor_email and instructor_email should be unique
* the composite key on Enrollments already stops a student from enrolling in the same course twice

---
