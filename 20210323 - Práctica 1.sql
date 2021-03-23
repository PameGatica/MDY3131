 /*
MARCO OGAZ VARAS 11846972
MARIA BARRERA ONETO 18560875
 
 */
 
 SET SERVEROUTPUT ON;
 
 SELECT appaterno_emp, apmaterno_emp, nombre_emp, sueldo_emp,dvrut_emp
 FROM empleado
 WHERE numrut_emp = '18560875';
 
 VAR b_bono NUMBER;
 VAR b_rut NUMBER;
 
 EXEC b_bono := 40;
 EXEC b_rut := 18560875;
 
 DECLARE
    v_apaterno empleado.appaterno_emp%TYPE;
    v_amaterno empleado.apmaterno_emp%TYPE;
    v_nombre empleado.nombre_emp%TYPE;
    v_sueldo empleado.sueldo_emp%TYPE;
    v_dv empleado.dvrut_emp%TYPE;
    
    v_bono NUMBER;
 BEGIN
    SELECT appaterno_emp, apmaterno_emp, nombre_emp, sueldo_emp,dvrut_emp
    INTO v_apaterno, v_amaterno, v_nombre, v_sueldo, v_dv
    FROM empleado
    WHERE numrut_emp = :b_rut;
    
    v_bono := v_sueldo * &b_bono / 100;
    
    DBMS_OUTPUT.PUT_LINE('DATOS CALCULO BONIFICACION EXTRA DEL ' || :b_bono || '% DEL SUELDO');
    DBMS_OUTPUT.PUT_LINE('Nombre Empleado: ' || v_nombre || ' ' || v_apaterno || ' ' || v_amaterno);
    DBMS_OUTPUT.PUT_LINE('RUN: ' || :b_rut || '-' || v_dv);
    DBMS_OUTPUT.PUT_LINE('Sueldo: ' || v_sueldo);
    DBMS_OUTPUT.PUT_LINE('Bonificación Extra: ' || v_bono);
    
 END;
 