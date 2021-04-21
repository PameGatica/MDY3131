SET SERVEROUTPUT ON;

DECLARE
    TYPE tipo_emp IS RECORD(
        id NUMBER,
        nombre VARCHAR(20),
        apellido VARCHAR(30)
    );
    
    reg_emp tipo_emp;
       
    reg_emp3 employees%ROWTYPE;
    
BEGIN

FOR i IN 100 .. 161 LOOP
    SELECT employee_id, first_name, last_name
    --INTO v_id, v_nombre, v_apellido
    INTO reg_emp
    FROM employees
    WHERE employee_id = i;
   
    DBMS_OUTPUT.PUT_LINE('ID:       ' || reg_emp.id);
    DBMS_OUTPUT.PUT_LINE('Nombre:   ' || reg_emp.nombre);
    DBMS_OUTPUT.PUT_LINE('Apellido: ' || reg_emp.apellido);
    DBMS_OUTPUT.PUT_LINE('------------------------');
END LOOP;

--USANDO ROWTYPE
FOR i IN 100 .. 161 LOOP
    SELECT *
    --INTO v_id, v_nombre, v_apellido
    INTO reg_emp3
    FROM employees
    WHERE employee_id = i;
   
    DBMS_OUTPUT.PUT_LINE('ID:       ' || reg_emp3.employee_id);
    DBMS_OUTPUT.PUT_LINE('Nombre:   ' || reg_emp3.first_name);
    DBMS_OUTPUT.PUT_LINE('Apellido: ' || reg_emp3.last_name);
    DBMS_OUTPUT.PUT_LINE('------------------------');
END LOOP;
END;