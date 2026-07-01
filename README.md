# Assignment 2 – Database Normalization and Design

## Task 1.1 – Normalization

### Starting Point

I started with a single flat table that holds everything related to students, their advisors, the courses they take, and the instructors teaching those courses:

```
StudentRecords(
    student_id,
    student_name,
    department,
    advisor_name,
    advisor_email,
    course_code,
    course_name,
    instructor_name,
    instructor_email,
    enrollment_year,
    marks_obtained
)
```

Since a student can take multiple courses, the natural primary key here is the composite key `(student_id, course_code)`.

### Functional Dependencies

Looking at the data, these are the functional dependencies I identified:

* advisor_name → advisor_email
* instructor_name → instructor_email
* course_code → course_name, instructor_name, instructor_email

---

## Partial Dependencies

Because the primary key is composite, a few attributes only depend on `course_code` rather than on the full `(student_id, course_code)` pair:

* course_code → course_name
* course_code → instructor_name
* course_code → instructor_email

That's a problem — it means these attributes are partially dependent on the key, which breaks Second Normal Form (2NF).

---

## Transitive Dependencies

There are also some dependencies between non-key attributes themselves:

* advisor_name → advisor_email
* instructor_name → instructor_email
* course_code → instructor_name → instructor_email

This is a textbook transitive dependency — instructor_email depends on instructor_name, which itself depends on course_code rather than directly on the key. That violates Third Normal Form (3NF).

---

# Decomposing into BCNF

To get rid of the redundancy caused by these dependencies, I split the original table into five smaller relations.

## 1. Advisors

**Primary Key:** advisor_name

**Attributes:** advisor_name, advisor_email

Keeps advisor info in one place instead of repeating it for every student they advise.

---

## 2. Instructors

**Primary Key:** instructor_name

**Attributes:** instructor_name, instructor_email

Same idea as above, but for instructors — no more repeated instructor emails across every course they teach.

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

# Checking Data Integrity

## Entity Integrity ✅

Every table has its own primary key, and none of those key values can be NULL, so each row is uniquely identifiable.

## Referential Integrity ✅

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

# Why I Designed It This Way

* I decomposed everything down to BCNF to cut out redundancy as much as possible.
* Advisors and instructors got their own tables so their emails aren't duplicated everywhere.
* Courses reference instructors, and students reference advisors, both through foreign keys.
* Enrollments only store what's specific to that student-course pairing — year and marks — nothing that belongs elsewhere.

The end result avoids the classic update, insertion, and deletion anomalies you'd run into with the original flat table.

---

# Conclusion

The original `StudentRecords` table mixed together student, advisor, course, and instructor data in a way that caused both partial and transitive dependencies — and a lot of redundant data as a result. By splitting it into **Students**, **Advisors**, **Instructors**, **Courses**, and **Enrollments**, every determinant in the schema is now a candidate key, which satisfies BCNF. The resulting design holds up against entity, referential, domain, and user-defined integrity checks, giving a cleaner and more maintainable database structure overall.
