
set serveroutput on
declare 
v_name VARCHAR2(50) ;
BEGIN
    DBMS_OUTPUT.PUT_LINE('enter your name');
v_name := '&v_name' ;
DBMS_OUTPUT.PUT_LINE('hello ' || v_name);
end;

basic loop

declare 
v_counter number := 0;
BEGIN

loop 

DBMS_OUTPUT.PUT_LINE(8 * v_counter);
v_counter := v_counter + 1;
exit WHEN (v_counter = 13);
end loop;

end;



--while loop
declare 
v_counter number := 0;
BEGIN

while v_counter <13 loop 

DBMS_OUTPUT.PUT_LINE(9 * v_counter);
v_counter := v_counter + 1;
end loop;

end;


--for loop
begin 

for i in 1..15 loop

DBMS_OUTPUT.PUT_LINE(10 * i);
end loop;

    end ;




--rowtype



declare 


v_emp employee%rowtype;



begin

select *  into v_emp from employee  WHERE emp_id = 1;

DBMS_OUTPUT.PUT_LINE('emp id = '|| v_emp.emp_id || 'name = '|| v_emp.emp_name);

end;






declare 
v_num_of_emps number ;
type emps_names_arr is table of employee.emp_name%type index by pls_integer;
 arr emps_names_arr ;
begin
select count(emp_id) into v_num_of_emps from employee;
for i in 0..v_num_of_emps - 1
loop
select EMP_NAME into arr(i) from employee where emp_id = i+1;
DBMS_OUTPUT.PUT_LINE('number '|| (i + 1) || ' emp name is '|| arr(i) );
end loop;
end ;




declare 
cursor c_emps is select *from employee;
v_record  c_emps%rowtype;


begin
    open c_emps; 

    loop

        fetch c_emps into v_record;
        exit when (c_emps%notfound);
        DBMS_OUTPUT.PUT_LINE(v_record.emp_name);

    end loop;

    close c_emps;
end;



declare 
cursor c_emp is select *from employee for update;
begin
for v_emp in c_emp loop
DBMS_OUTPUT.PUT_LINE('emp number ' || v_emp.emp_id || ' name is '|| v_emp.emp_name);
end loop;
end;




declare 
cursor c_emps is select e.emp_name from employee e; 
begin
    DBMS_OUTPUT.PUT_LINE('emps names after adding dot at last are: ');
for v_emp in c_emps loop
v_emp.emp_name := (v_emp.emp_name || '.');
DBMS_OUTPUT.PUT_LINE(v_emp.emp_name);
end loop;
end; 



CREATE OR REPLACE PROCEDURE INCREASE_ALL_EMPS_AGE(AMOUNT NUMBER DEFAULT 1)
AS

BEGIN
UPDATE EMPLOYEE 
SET 
EMP_AGE =EMP_AGE + AMOUNT;
COMMIT;
END;
/





BEGIN
    INCREASE_ALL_EMPS_AGE (5);
END;

CREATE OR REPLACE TYPE ARR_OF_INT IS TABLE OF NUMBER ;


CREATE OR REPLACE PROCEDURE FILL_ARRAY(NUMBERS_COUNT NUMBER ,ARR IN OUT ARR_OF_INT)
AS 

BEGIN
ARR := ARR_OF_INT();
FOR I IN 0..NUMBERS_COUNT -1
LOOP
ARR(I) := I;
END loop; 
END;
/
CREATE OR REPLACE TYPE ARR_OF_INT IS TABLE OF NUMBER ;
CREATE OR REPLACE PROCEDURE PRINT_ARRAY (ARR_SIZE NUMBER,ARR ARR_OF_INT)
AS

BEGIN 

FOR I IN 0..ARR_SIZE
LOOP
DBMS_OUTPUT.PUT_LINE(ARR(I));
END LOOP;

END;
/

DECLARE 
ARR ARR_OF_INT := ARR_OF_INT();
BEGIN 
FILL_ARRAY (5,ARR_OF_INT);
PRINT_ARRAY(ARR);
END;
select * from employee;
----------------


Here is the FULL CODE, ready to copy and run in Oracle SQL Developer using F5 (Run Script).

sql
-- 1. Create the array type
CREATE OR REPLACE TYPE ARR_OF_INT AS TABLE OF NUMBER;
/

-- 2. Create the procedure that fills the array
CREATE OR REPLACE PROCEDURE FILL_ARRAY(
    NUMBERS_COUNT IN NUMBER,
    ARR IN OUT ARR_OF_INT
)
AS
BEGIN
    ARR := ARR_OF_INT();

    FOR I IN 0 .. NUMBERS_COUNT - 1 LOOP
        ARR.EXTEND;
        ARR(ARR.COUNT) := I;
    END LOOP;
END;
/

-- 3. Create the procedure that prints the array
CREATE OR REPLACE PROCEDURE PRINT_ARRAY(
    ARR_SIZE IN NUMBER,
    ARR IN ARR_OF_INT
)
AS
BEGIN
    FOR I IN 1 .. ARR_SIZE LOOP
        DBMS_OUTPUT.PUT_LINE(ARR(I));
    END LOOP;
END;
/

-- 4. Call both procedures
DECLARE
    V_ARR ARR_OF_INT := ARR_OF_INT();
BEGIN
    FILL_ARRAY(5, V_ARR);

    PRINT_ARRAY(5, V_ARR);
END;
/