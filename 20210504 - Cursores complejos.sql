SET SERVEROUTPUT ON;

DECLARE
    CURSOR cur_empleados IS 
        SELECT first_name, last_name, department_id
        FROM employees 
        ORDER BY employee_id
    ;
    --reg_empleado cur_empleados%ROWTYPE;
BEGIN
    
    FOR reg_empleado IN cur_empleados LOOP
        DBMS_OUTPUT.PUT_LINE(reg_empleado.first_name || ' ' || reg_empleado.last_name || ' ' || reg_empleado.department_id);
    
    END LOOP;
END;

BEGIN
    FOR reg_empleado IN (SELECT first_name, last_name, department_id FROM employees ORDER BY employee_id) LOOP
        DBMS_OUTPUT.PUT_LINE(reg_empleado.first_name || ' ' || reg_empleado.last_name || ' ' || reg_empleado.department_id);
    END LOOP;
END;


VAR b_id_depto NUMBER;
EXEC :b_id_depto := 30;

DECLARE
    CURSOR cur_emp_pordepto(p_id_depto NUMBER) IS 
        SELECT first_name, last_name, department_id
        FROM employees
        WHERE department_id = p_id_depto
        ORDER BY employee_id;
BEGIN
    FOR reg_empleado IN cur_emp_pordepto(:b_id_depto) LOOP
        DBMS_OUTPUT.PUT_LINE(reg_empleado.first_name || ' ' || reg_empleado.last_name || ' ' || reg_empleado.department_id);
    END LOOP;
    
    FOR reg_empleado IN cur_emp_pordepto(40) LOOP
        DBMS_OUTPUT.PUT_LINE(reg_empleado.first_name || ' ' || reg_empleado.last_name || ' ' || reg_empleado.department_id);
    END LOOP;
END;

DECLARE
    CURSOR cur_deptos IS 
        SELECT DISTINCT(department_id), department_name 
        FROM departments 
        ORDER BY department_id ;
        
    CURSOR cur_emp_pordepto(p_id_depto NUMBER) IS 
        SELECT first_name, last_name 
        FROM employees 
        WHERE department_id = p_id_depto
        ORDER BY employee_id;
BEGIN
    FOR reg_depto IN cur_deptos LOOP
        DBMS_OUTPUT.PUT_LINE(reg_depto.department_id || ' ' || reg_depto.department_name);
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
        
        FOR reg_emp IN cur_emp_pordepto(reg_depto.department_id) LOOP
             DBMS_OUTPUT.PUT_LINE('     ' || reg_emp.first_name || ' ' || reg_emp.last_name);
        END LOOP;
        DBMS_OUTPUT.PUT_LINE('--------------------------------');
    END LOOP;
END;

SELECT DISTINCT(department_id), department_name FROM departments ORDER BY department_id;