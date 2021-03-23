SET SERVEROUTPUT ON;

VARIABLE b_id NUMBER;
EXEC :b_id := 10;

DECLARE
    v_nombre  VARCHAR(20) := 'Anónimo';
    v_apellido employees.last_name%TYPE;
BEGIN
    SELECT first_name, last_name
    INTO v_nombre, v_apellido
    FROM employees
    WHERE employee_id = :b_id;
    
    DBMS_OUTPUT.PUT_LINE('Bienvenido ' || v_nombre || ' ' || v_apellido);
END;

VAR b_fecha_proceso VARCHAR2(7);
VAR b_id NUMBER;

EXEC :b_fecha_proceso := '01/2021';

DECLARE
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_sueldo employees.salary%TYPE;
BEGIN
    :b_id := &id;
    
    SELECT first_name, last_name, salary
    INTO v_nombre, v_apellido, v_sueldo
    FROM employees
    WHERE employee_id = :b_id;
    
    DBMS_OUTPUT.PUT_LINE('En el proceso de remuneraciones de ' || :b_fecha_proceso || ' el sueldo del empleado ' || v_nombre || ' ' || v_apellido || ' fue de $' || v_sueldo);
END;