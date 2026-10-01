[sql1oct.txt](https://github.com/user-attachments/files/32908514/sql1oct.txt)
I am learning Oracle SQL / Oracle Database from zero to advanced level through hands-on practice. Teach me like a practical mentor: explain concepts simply, show a small example, explain the logical flow, then make me write SQL and predict results. Do NOT immediately give me answers if I can solve the problem myself. Check my SQL, distinguish actual errors from valid alternative solutions, and increase difficulty gradually.

My current progress

I have completed the foundational SQL material (Milestone 1), including:

Database/schema/table basics

CREATE TABLE

INSERT

SELECT

Oracle data types

PRIMARY KEY

FOREIGN KEY

NOT NULL

Inline and table-level constraints

ALTER TABLE

DDL vs DML

INSERT / UPDATE / DELETE

DDL implicit commits in Oracle

COMMIT

ROLLBACK

SAVEPOINT

ROLLBACK TO SAVEPOINT

Basic NULL behavior

IS NULL / IS NOT NULL

NULL in comparisons

COUNT(*) vs COUNT(column)

Basic INNER JOIN / LEFT JOIN

WHERE / LIKE / IN

GROUP BY

COUNT / SUM / AVG / MIN / MAX

DISTINCT inside aggregates

HAVING

ORDER BY

Table aliases

Basic subqueries

Understanding that a subquery can sometimes be replaced by a JOIN

Important transaction understanding

I understand:

COMMIT;


makes the current transaction permanent.

ROLLBACK;


undoes uncommitted changes.

SAVEPOINT A;


does NOT commit anything. It creates a rollback position/bookmark inside the current transaction.

ROLLBACK TO A;


undoes changes made after SAVEPOINT A, but does not end the transaction.

Important mental model:

SAVEPOINT = bookmark
COMMIT = permanently save transaction
ROLLBACK = undo uncommitted transaction

Also remember that Oracle DDL such as:

CREATE
ALTER
DROP
TRUNCATE


causes an implicit commit.

Current Milestone 2 topics

I am currently studying:

Complex JOINs

SELF JOINs

OUTER JOINs

Correlated subqueries

EXISTS and IN

CASE and DECODE

Common Table Expressions (CTEs)

Analytical/window functions

ROW_NUMBER, RANK, DENSE_RANK

LEAD and LAG

Hierarchical queries

Views

Introduction to materialized views

We are currently on:

Milestone 2 — Complex JOINs / OUTER JOIN reasoning
Current practice tables

I created these tables for practice:

CREATE TABLE DEPARTMENT
(
    DEPT_ID INT PRIMARY KEY,
    DEPT_NAME VARCHAR2(30)
);

INSERT INTO DEPARTMENT VALUES(1,'IT');
INSERT INTO DEPARTMENT VALUES(2,'SALES');
INSERT INTO DEPARTMENT VALUES(3,'HR');


Employee table:

CREATE TABLE EMPLOYEE(
    EMP_ID INT PRIMARY KEY,
    EMP_NAME VARCHAR2(20),
    EMP_AGE INT,
    EMP_DEPT_ID INT REFERENCES DEPARTMENT(DEPT_ID)
);


Current employee data:

INSERT INTO EMPLOYEE VALUES (1,'TAHA',25,1);
INSERT INTO EMPLOYEE VALUES (2,'ZAID',35,2);
INSERT INTO EMPLOYEE VALUES (3,'SAIF',27,1);


Projects:

CREATE TABLE projects (
    project_id NUMBER PRIMARY KEY,
    project_name VARCHAR2(50),
    dept_id NUMBER
);

INSERT INTO projects VALUES (101, 'CRM System', 1);
INSERT INTO projects VALUES (102, 'Sales Dashboard', 2);
INSERT INTO projects VALUES (103, 'Network Upgrade', 1);
INSERT INTO projects VALUES (104, 'Sales Analysis', 2);


Current logical data:

DEPARTMENT:

1 | IT
2 | SALES
3 | HR


EMPLOYEE:

1 | TAHA | 25 | 1
2 | ZAID | 35 | 2
3 | SAIF | 27 | 1


PROJECTS:

101 | CRM System       | 1
102 | Sales Dashboard  | 2
103 | Network Upgrade  | 1
104 | Sales Analysis   | 2

Complex JOIN understanding

I understand that I can JOIN more than two tables.

For example:

SELECT e.emp_name,
       d.dept_name,
       p.project_name
FROM employee e
JOIN department d
    ON e.emp_dept_id = d.dept_id
JOIN projects p
    ON d.dept_id = p.dept_id;


Important mental model:

Each individual JOIN connects two row sources.

For example:

EMPLOYEE
   +
DEPARTMENT
   ↓
result
   +
PROJECTS
   ↓
final result


The second side does not have to be an original physical table. The result of previous JOIN operations can become a row source for the next JOIN.

For learning, I can think of JOINs as being built from left to right.

However, remember that Oracle's optimizer can choose a different physical execution order internally. The left-to-right model is a logical learning model, not a guarantee of the physical execution plan.

Important JOIN concept discovered

A JOIN does NOT necessarily produce one result row per employee.

For example:

IT has two employees:

TAHA
SAIF


and two projects:

CRM System
Network Upgrade


Therefore a JOIN can produce:

TAHA | CRM System
TAHA | Network Upgrade
SAIF | CRM System
SAIF | Network Upgrade


So 2 employees × 2 matching projects = 4 result rows.

This is an important many-to-many-style result multiplication effect caused by the JOIN conditions.

INNER JOIN

Mental model:

INNER JOIN
→ keep matching rows
→ unmatched rows disappear


Example:

SELECT ...
FROM employee e
JOIN department d
    ON e.emp_dept_id = d.dept_id;

LEFT JOIN

Mental model:

LEFT JOIN
→ determine matches using ON
→ preserve every row from the LEFT side
→ unmatched right-side columns become NULL


Example:

SELECT d.dept_name,
       e.emp_name
FROM department d
LEFT JOIN employee e
    ON d.dept_id = e.emp_dept_id;


HR has no employees, so HR still appears:

HR | NULL

RIGHT JOIN

Mental model:

RIGHT JOIN
→ determine matches using ON
→ preserve every row from the RIGHT side
→ unmatched left-side columns become NULL


I discovered that these can express the same preservation logic:

FROM department d
LEFT JOIN employee e
    ON e.emp_dept_id = d.dept_id


and:

FROM employee e
RIGHT JOIN department d
    ON e.emp_dept_id = d.dept_id


The second version preserves DEPARTMENT because DEPARTMENT is on the right side.

For readability, starting with the table whose rows I want to preserve and using LEFT JOIN is often clearer.

VERY IMPORTANT: ON vs WHERE

This is the current concept I am studying deeply.

Core mental model:

ON
→ determines whether rows from the two sides are allowed to MATCH

WHERE
→ filters the rows produced by the FROM/JOIN portion


Another way to remember:

ON  = matching rule
WHERE = final-result filter


Example:

SELECT d.dept_name,
       e.emp_name
FROM department d
LEFT JOIN employee e
    ON d.dept_id = e.emp_dept_id
   AND e.emp_name = 'TAHA';


The condition:

e.emp_name = 'TAHA'


is part of the MATCHING RULE.

It means:

Only employees named TAHA are allowed to match a department.

For example:

IT + TAHA → match
IT + SAIF → no match
SALES + ZAID → no match
HR + nobody → no match


Because this is a LEFT JOIN, departments that fail to find a matching employee are still preserved:

IT    | TAHA
SALES | NULL
HR    | NULL


But if I write:

SELECT d.dept_name,
       e.emp_name
FROM department d
LEFT JOIN employee e
    ON d.dept_id = e.emp_dept_id
WHERE e.emp_name = 'TAHA';


the JOIN first produces something conceptually like:

IT    | TAHA
IT    | SAIF
SALES | ZAID
HR    | NULL


Then WHERE filters the final result.

It evaluates:

TAHA = TAHA → TRUE
SAIF = TAHA → FALSE
ZAID = TAHA → FALSE
NULL = TAHA → UNKNOWN


WHERE keeps TRUE rows, so the result becomes:

IT | TAHA


Therefore, putting a condition in WHERE can remove the NULL rows created by an OUTER JOIN.

Critical NULL connection

Remember:

NULL = 'TAHA'


does NOT return TRUE or FALSE.

It results in UNKNOWN.

And WHERE keeps rows only when the condition is TRUE.

This is why:

LEFT JOIN ...
WHERE right_table.column = 'something'


can remove rows that the LEFT JOIN initially preserved.

Current deep mental model

For an OUTER JOIN, always ask:

What makes two rows match?

Which side is preserved?

What happens to rows that don't match?

Is my additional condition part of the matching rule (ON) or a final-result filter (WHERE)?

Think:

ON
↓
Which rows MATCH?

JOIN TYPE
↓
What happens to UNMATCHED rows?

WHERE
↓
Which final rows SURVIVE?

Current unfinished exercise

We were discussing:

SELECT d.dept_name, e.emp_name
FROM department d
LEFT JOIN employee e
    ON d.dept_id = e.emp_dept_id
   AND e.emp_age > 30;


Current employees:

TAHA → 25
ZAID → 35
SAIF → 27


I should be asked to predict the result before being given the answer.

The important reasoning is:

IT has TAHA and SAIF, but neither is over 30 → no matching employee → IT is preserved with NULL.

SALES has ZAID, who is over 30 → ZAID matches.

HR has no employee → HR is preserved with NULL.

Expected conceptual result:

IT    | NULL
SALES | ZAID
HR    | NULL

Teaching style for future sessions

Continue from this exact point.

Do NOT restart the course.

Do NOT give long theoretical lectures without exercises.

For every new concept:

Explain simply.

Give a small example.

Explain the logical flow.

Make me predict the result.

Make me write SQL.

Check my answer.

If wrong, explain exactly why.

Let me retry when appropriate.

Point out small improvements separately from actual errors.

Distinguish:

WRONG

VALID BUT DIFFERENT FROM WHAT WAS ASKED

VALID AND CORRECT

Increase difficulty gradually.

Occasionally give combined challenges.

I learn best when I have to reason about what Oracle is doing rather than memorize syntax.

Continue with OUTER JOIN / ON vs WHERE until I clearly demonstrate that I understand it, then proceed to SELF JOINs and the rest of Milestone 2.
