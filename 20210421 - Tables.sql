SET SERVEROUTPUT ON;
DECLARE
    TYPE tipo_tabla_emp IS TABLE OF
        employees%ROWTYPE
        INDEX BY PLS_INTEGER;
        
    
    tabla_emp tipo_tabla_emp;
    
    v_index NUMBER := 1;
    
BEGIN
    SELECT *
    INTO tabla_emp(v_index)
    FROM employees
    WHERE employee_id = 100;
    
    
    
    DBMS_OUTPUT.PUT_LINE('ID:       ' || tabla_emp(1).employee_id);
    DBMS_OUTPUT.PUT_LINE('Nombre:   ' || tabla_emp(1).first_name);
    DBMS_OUTPUT.PUT_LINE('Apellido: ' || tabla_emp(1).last_name);
    DBMS_OUTPUT.PUT_LINE('------------------------');

END;