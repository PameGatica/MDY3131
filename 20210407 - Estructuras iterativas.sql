SET SERVEROUTPUT ON;

DECLARE
    v_x NUMBER := 10;
BEGIN
    LOOP
        DBMS_OUTPUT.PUT_LINE(v_x);
        v_x := v_x + 10;
    EXIT WHEN v_x > 50;
    END LOOP;
    
    DBMS_OUTPUT.PUT_LINE('Despues de terminar el loop: ' || v_x);

END;
-- EJEMPLO LOOP
DECLARE
    v_id_min NUMBER;
    v_id_max NUMBER;
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_dep_id NUMBER;
BEGIN

    SELECT MIN(employee_id), MAX(employee_id)
    INTO v_id_min, v_id_max
    FROM employees;

    LOOP
        SELECT first_name, last_name, department_id
        INTO v_nombre, v_apellido, v_dep_id
        FROM employees
        WHERE employee_id = v_id_min;
        
        IF v_dep_id = 30 THEN
            DBMS_OUTPUT.PUT_LINE(v_id_min || ' - ' || v_nombre || ' '  || v_apellido);
            
        END IF;
        
        v_id_min := v_id_min +1;
        EXIT WHEN v_id_min > v_id_max;
    END LOOP;
END;

--EJEMPLO FOR LOOP
DECLARE
    v_id_min NUMBER;
    v_id_max NUMBER;
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_dep_id NUMBER;
BEGIN

    SELECT MIN(employee_id), MAX(employee_id)
    INTO v_id_min, v_id_max
    FROM employees;

    FOR id IN v_id_min .. v_id_max LOOP
        SELECT first_name, last_name, department_id
        INTO v_nombre, v_apellido, v_dep_id
        FROM employees
        WHERE employee_id = id;
        
        IF v_dep_id = 30 THEN
            DBMS_OUTPUT.PUT_LINE(id || ' - ' || v_nombre || ' '  || v_apellido);
        END IF;
    
    END LOOP;
END;


DECLARE
    v_id_min NUMBER;
    v_id_max NUMBER;
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_dep_id NUMBER;
    v_department_name departments.department_name%TYPE;
BEGIN
    FOR id_dept IN 1..27 LOOP
        SELECT department_name
        INTO v_department_name
        FROM departments
        WHERE department_id = (id_dept*10);
        DBMS_OUTPUT.PUT_LINE('Departamento: ' || v_department_name);
       
        FOR id_emp IN 100 .. 206 LOOP
            SELECT first_name, last_name, department_id
            INTO v_nombre, v_apellido, v_dep_id
            FROM employees
            WHERE employee_id = id_emp;
            
            IF v_dep_id = (id_dept*10) THEN
                DBMS_OUTPUT.PUT_LINE(v_nombre || ' ' || v_apellido);
            END  IF;
        END LOOP;
        
        DBMS_OUTPUT.PUT_LINE('______________________________________');
    END LOOP;

END;


