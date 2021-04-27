SET SERVEROUTPUT ON;
/*
DECLARE
    CURSOR cur_empleados IS SELECT employee_id, first_name, last_name, salary FROM employees ORDER BY employee_id;
    
    TYPE tipo_reg_empleado IS RECORD(
        id employees.employee_id%TYPE,
        nombre employees.first_name%TYPE,
        apellido employees.last_name%TYPE,
        sueldo employees.salary%TYPE);
    
    reg_empleado tipo_reg_empleado;
    
    v_id employees.employee_id%TYPE;
    v_nombre employees.first_name%TYPE;
    v_apellido employees.last_name%TYPE;
    v_sueldo employees.salary%TYPE;

BEGIN
    
    OPEN cur_empleados;
  
    LOOP
        FETCH cur_empleados INTO reg_empleado;
        EXIT WHEN cur_empleados%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(reg_empleado.nombre || ' ' || reg_empleado.apellido);
    
    --FETCH cur_empleados INTO v_id, v_nombre, v_apellido, v_sueldo;
   -- DBMS_OUTPUT.PUT_LINE(v_nombre || ' ' || v_apellido);
    END LOOP;
   
    
    FETCH cur_empleados INTO reg_empleado;
    WHILE cur_empleados%FOUND LOOP
    
        DBMS_OUTPUT.PUT_LINE(reg_empleado.nombre || ' ' || reg_empleado.apellido);
    
        FETCH cur_empleados INTO reg_empleado;
    END LOOP;
    CLOSE cur_empleados;

END;

*/

--Manejo de cursores con For

DECLARE
    CURSOR cur_empleados IS SELECT employee_id id, first_name nombre, last_name apellido, salary sueldo FROM employees ORDER BY employee_id;
BEGIN
    FOR reg_empleado IN cur_empleados LOOP
    
        DBMS_OUTPUT.PUT_LINE(reg_empleado.nombre || ' ' || reg_empleado.apellido);    
    
    END LOOP;
END;

