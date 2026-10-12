
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



