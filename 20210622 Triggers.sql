SET SERVEROUTPUT ON;

BEGIN
    INSERT INTO employees
    VALUES (302,'Smith','Rob','RSMITH1','234243',SYSDATE,'IT_PROG',4500,null,103,60);
     --EXCEPTION
   --     WHEN OTHERS THEN
    --       DBMS_OUTPUT.PUT_LINE('ERROR');
 
END;

UPDATE employees SET
    last_name = 'Garrido',
    job_id = 'AD_ASST'
WHERE employee_id = 302;

DELETE FROM employees WHERE employee_id = 302;

SELECT TO_CHAR(SYSDATE,'HH24:MI') FROM dual;

/*TRIGGERS*/

CREATE OR REPLACE TRIGGER TRG_TEST 
BEFORE INSERT ON EMPLOYEES 
BEGIN
  IF(TO_CHAR(SYSDATE,'HH24:MI') NOT BETWEEN '08:00' AND '13:00')THEN
    RAISE_APPLICATION_ERROR (
          num => -20500,
          msg => 'Se debe insertar en tabla EMPLEADOS sólo durante horas de trabajo');
  END IF;
END;

CREATE OR REPLACE TRIGGER TRG_VALIDA_DML_EMP 
BEFORE DELETE OR INSERT OR UPDATE ON EMPLOYEES 
BEGIN
   IF(TO_CHAR(SYSDATE,'HH24:MI') NOT BETWEEN '08:00' AND '13:00')THEN
        IF DELETING THEN
             RAISE_APPLICATION_ERROR (
              num => -20502,
              msg => 'Se debe eliminar en tabla EMPLEADOS sólo durante horas de trabajo');
      
        ELSIF INSERTING THEN
             RAISE_APPLICATION_ERROR (
              num => -20500,
              msg => 'Se debe insertar en tabla EMPLEADOS sólo durante horas de trabajo');
         
        ELSIF UPDATING('SALARY') THEN
             RAISE_APPLICATION_ERROR (
              num => -20503,
              msg => 'Se debe actualizar el sueldo sólo durante horas de trabajo');
        END IF;
    END IF;
END;

CREATE OR REPLACE TRIGGER TRG_AUDIT_EMP 
AFTER DELETE OR INSERT OR UPDATE ON EMPLOYEES 
FOR EACH ROW 
BEGIN
  INSERT INTO audit_emp VALUES(
    USER,
    :OLD.employee_id,
    :NEW.employee_id,
    :OLD.last_name,
    :NEW.last_name,
    :OLD.job_id,
    :NEW.job_id,
    :OLD.salary,
    :NEW.salary
  );
END;

/*CREAR TABLAS*/

CREATE TABLE audit_emp
(user_name        VARCHAR2(30), 
 old_employee_id  NUMBER(5),
 new_employee_id  NUMBER(5),
 old_last_name    VARCHAR2(30), 
 new_last_name    VARCHAR2(30), 
 old_job_id       VARCHAR2(10), 
 new_job_id       VARCHAR2(10), 
 old_salary       NUMBER(8,2), 
 new_salary       NUMBER(8,2));

