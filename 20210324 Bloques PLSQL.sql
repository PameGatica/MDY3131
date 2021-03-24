SET SERVEROUTPUT ON;

DECLARE
    v_apellido employees.last_name%TYPE;
    v_nombre employees.first_name%TYPE;
    v_comision employees.commission_pct%TYPE;
    v_sueldo employees.salary%TYPE;
    
    v_id employees.employee_id%TYPE := 110;
    
BEGIN
    SELECT first_name, last_name, salary, commission_pct
    INTO v_nombre, v_apellido, v_sueldo, v_comision
    FROM employees
    WHERE employee_id = v_id;
    
    IF v_sueldo < 15000 THEN
        UPDATE employees
        SET salary = salary * 1.25
        WHERE employee_id = v_id;
    ELSE
        DBMS_OUTPUT.PUT_LINE('No califica para aumento de sueldo');
    END IF;

END;