SET SERVEROUTPUT ON;

DECLARE
    CURSOR cur_socios IS 
        SELECT * FROM socio 
        ORDER BY rut;
        
    CURSOR cur_prestamos(rut VARCHAR) IS 
        SELECT cod_prestamo, monto
        FROM prestamo
        WHERE rut_socio = rut;
    
    CURSOR cur_abonos(cod NUMBER) IS
        SELECT sum(monto)
        FROM abono
        WHERE cod_prestamo = cod;
    
    CURSOR cur_ingresos(rut VARCHAR) IS
        SELECT NVL(sum(monto),0)
        FROM ingreso
        WHERE rut_socio = rut;
        
        v_total_prestamos evaluacion_socio.total_prestamo%TYPE := 0;
        v_abonos_prestamo evaluacion_socio.total_abonos%TYPE;
        v_total_abonos NUMBER := 0;
        v_ingresos evaluacion_socio.total_ingresos%TYPE;
        v_saldo NUMBER;
        
        v_puntaje NUMBER;
BEGIN
    FOR reg_socio IN cur_socios LOOP
            DBMS_OUTPUT.PUT_LINE(reg_socio.rut);
            v_total_prestamos := 0;
            v_total_abonos:= 0;
            
       FOR reg_prestamo IN cur_prestamos(reg_socio.rut) LOOP
            v_total_prestamos := v_total_prestamos + reg_prestamo.monto;
            
            OPEN cur_abonos(reg_prestamo.cod_prestamo);
            FETCH cur_abonos INTO v_abonos_prestamo;
            CLOSE cur_abonos;
            
            v_total_abonos := v_total_abonos + v_abonos_prestamo;
            
        END LOOP;
        
        OPEN cur_ingresos(reg_socio.rut);
        FETCH cur_ingresos INTO v_ingresos;
        CLOSE cur_ingresos;
        
        --OBTENCIÓN DE PUNTAJE BASE
        SELECT puntaje
        INTO v_puntaje
        FROM puntaje_prestamo
        WHERE v_total_prestamos BETWEEN monto_min AND monto_max;
        
        --CALCULO DE PUNTAJE
        v_saldo := v_total_prestamos - v_total_abonos;
        
        DBMS_OUTPUT.PUT_LINE('P'||TO_CHAR(v_total_prestamos,'$999,999,999'));
        DBMS_OUTPUT.PUT_LINE('A'||TO_CHAR(v_total_abonos,'$999,999,999'));
        DBMS_OUTPUT.PUT_LINE('S'||TO_CHAR(v_saldo,'$999,999,999'));
        DBMS_OUTPUT.PUT_LINE('10%'||TO_CHAR(v_total_prestamos*0.1,'$999,999,999'));
        DBMS_OUTPUT.PUT_LINE('I'||TO_CHAR(v_ingresos,'$999,999,999'));
        DBMS_OUTPUT.PUT_LINE('PI'||v_puntaje);
        
    END LOOP;
END;

