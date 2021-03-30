--SET SERVEROUTPUT ON;

-- EJEMPLO IF ELSE
DECLARE
    v_sueldo_min employees.salary%TYPE;
BEGIN
    SELECT MIN(salary)
    INTO v_sueldo_min
    FROM employees;
    
    DBMS_OUTPUT.PUT_LINE('El sueldo mínimo es de: '|| TO_CHAR(v_sueldo_min,'$999G999'));
    
    IF (v_sueldo_min > 3000) THEN
        DBMS_OUTPUT.PUT_LINE('El sueldo se encuentra dentro del rango normal');
    ELSE
        DBMS_OUTPUT.PUT_LINE('El sueldo debe ser aumentado');    
    END IF;
END;

-- EJEMPLO IF THEN ELSIF ELSE
VAR b_id_emp NUMBER;
EXEC :b_id_emp := 104

DECLARE
    v_sueldo_emp employees.salary%TYPE;
    v_sueldo_min v_sueldo_emp%TYPE;
    v_sueldo_avg v_sueldo_emp%TYPE;
BEGIN
    SELECT MIN(salary), ROUND(AVG(salary))
    INTO v_sueldo_min, v_sueldo_avg
    FROM employees;
    
    SELECT salary
    INTO v_sueldo_emp
    FROM employees
    WHERE employee_id = :b_id_emp;
    
    DBMS_OUTPUT.PUT_LINE('El sueldo del empleado es: ' || TO_CHAR(v_sueldo_emp,'$999G999')); 
    
    IF v_sueldo_emp < v_sueldo_min THEN
        --AUMENTO 50%
        DBMS_OUTPUT.PUT_LINE('El sueldo será aumentado en un 50%');  
        DBMS_OUTPUT.PUT_LINE('Nuevo sueldo: '|| v_sueldo_emp*1.5);  
        UPDATE employees SET salary = salary*1.5 WHERE employee_id = :b_id_emp;
        
    ELSIF v_sueldo_emp < v_sueldo_avg THEN
        --AUMENTO 30%
        DBMS_OUTPUT.PUT_LINE('El sueldo será aumentado en un 30%');
        DBMS_OUTPUT.PUT_LINE('Nuevo sueldo: '|| v_sueldo_emp*1.3); 
        UPDATE employees SET salary = salary*1.3 WHERE employee_id = :b_id_emp;
    ELSE
        --NO NECESITA AUMENTO
        DBMS_OUTPUT.PUT_LINE('El sueldo no será aumentado');
    END IF;
END;

DECLARE 
    v_a NUMBER := NULL;
    v_b NUMBER := NULL;
BEGIN
    IF v_a IS NOT NULL AND v_b IS NOT NULL THEN
        IF v_a = v_b THEN
            DBMS_OUTPUT.PUT_LINE('a es igual a b');
        ELSE
            DBMS_OUTPUT.PUT_LINE('a y b son nulos por lo que la comparación entre ambos es NOT TRUE');
        END IF;
    ELSE
        DBMS_OUTPUT.PUT_LINE('a y b son nulos no se pueden comparar');
    END IF;
END;

DECLARE 
    v_calidad VARCHAR(1) := 'W';
    v_valoracion VARCHAR(20);
BEGIN
    v_valoracion :=
                    CASE v_calidad
                    WHEN 'A' THEN 'Excelente'
                    WHEN 'B' THEN 'Muy Bueno'
                    WHEN 'C' THEN 'Bueno'
                    ELSE 'No existe calidad'
                    END;
     DBMS_OUTPUT.PUT_LINE('Calidad: '|| v_calidad);
     DBMS_OUTPUT.PUT_LINE('Valoración: '|| v_valoracion);
END;


-- EJEMPLO EXPRESIÓN CASE
VAR b_id_emp NUMBER;
EXEC :b_id_emp := 103

DECLARE
    v_sueldo_emp employees.salary%TYPE;
    v_reajuste NUMBER;
BEGIN
    
    SELECT salary
    INTO v_sueldo_emp
    FROM employees
    WHERE employee_id = :b_id_emp;
    
    DBMS_OUTPUT.PUT_LINE('El sueldo del empleado es: ' || TO_CHAR(v_sueldo_emp,'$999G999')); 
    
    v_reajuste :=   CASE
                        WHEN v_sueldo_emp BETWEEN 0 AND 5000 THEN 0.4
                        WHEN v_sueldo_emp BETWEEN 5001 AND 12000 THEN 0.2
                        WHEN v_sueldo_emp BETWEEN 12001 AND 18000 THEN 0.1
                        ELSE 0
                    END;
     DBMS_OUTPUT.PUT_LINE('Le corresponde un reajuste de : ' || v_reajuste *100 || '%'); 
     DBMS_OUTPUT.PUT_LINE('Nuevo Sueldo : ' || TO_CHAR(v_sueldo_emp + v_sueldo_emp *v_reajuste,'$999G999')); 
     UPDATE employees SET salary = salary + ROUND(salary * v_reajuste)
     WHERE employee_id = :b_id_emp;
END;


-- EJEMPLO SENTENCIA CASE
VAR b_id_emp NUMBER;
EXEC :b_id_emp := 107

DECLARE
    v_sueldo_avg NUMBER;
    v_sueldo_emp NUMBER;
BEGIN
    SELECT ROUND(AVG(salary))
    INTO v_sueldo_avg
    FROM employees;
    
    SELECT salary
    INTO v_sueldo_emp
    FROM employees
    WHERE employee_id = :b_id_emp;
    
    CASE 
         WHEN v_sueldo_emp < v_sueldo_avg THEN
            DBMS_OUTPUT.PUT_LINE('Le corresponde un reajuste de 50%'); 
         WHEN v_sueldo_emp < 18000 THEN
            DBMS_OUTPUT.PUT_LINE('Le corresponde un reajuste de 20%'); 
         ELSE
             DBMS_OUTPUT.PUT_LINE('No le corresponde un reajuste'); 
    END CASE;
END;
    