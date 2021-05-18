SET SERVEROUTPUT ON;


VAR b_corte NUMBER;
VAR b_puntos_extra NUMBER;
VAR b_puntos_sin_multa NUMBER;

EXEC :b_corte := 0.1;
EXEC :b_puntos_extra :=200;
EXEC :b_puntos_sin_multa := 100;

DECLARE
    CURSOR cur_socio IS SELECT rut, nombre FROM socio;
    CURSOR cur_prestamos(rut VARCHAR) IS SELECT * FROM prestamo WHERE rut_socio = rut;
    --CURSOR cur_abonos(codigo NUMBER) IS SELECT * FROM abono WHERE cod_prestamo = codigo;
    
    v_total_prestamos NUMBER;
    v_abonos NUMBER;
    v_total_abonos NUMBER := 0;
    v_total_ingresos NUMBER;
    v_puntaje NUMBER;
    v_saldo NUMBER;
    v_corte NUMBER;
    v_total_multas NUMBER;
    v_cod_riesgo NUMBER;
    
    --VAR PARA CARGA DE IMAGEN
    v_file BFILE;
    v_blob BLOB;
    v_nombre VARCHAR(30);
    
    --PARA EXCEPCIONES
    v_proceso VARCHAR(30);
    v_mensaje VARCHAR(255);
    v_codigo NUMBER;
BEGIN 
    
    DELETE FROM evaluacion_socio;
    
    FOR reg_socio IN cur_socio LOOP
    BEGIN
        --DBMS_OUTPUT.PUT_LINE('________________');
        --DBMS_OUTPUT.PUT_LINE(reg_socio.rut);
        v_total_prestamos:=0;
        v_total_abonos:=0;
        v_total_ingresos :=0;
        v_proceso := 'Puntaje de Riesgo';
        FOR reg_prestamo IN cur_prestamos(reg_socio.rut) LOOP
           -- DBMS_OUTPUT.PUT_LINE(reg_prestamo.monto);
            v_total_prestamos := v_total_prestamos + reg_prestamo.monto;
            
            SELECT SUM(monto)
            INTO v_abonos
            FROM abono
            WHERE cod_prestamo = reg_prestamo.cod_prestamo;
            
            v_total_abonos := v_total_abonos + v_abonos;
        END LOOP;
        
        SELECT NVL(SUM(monto),0)
        INTO v_total_ingresos
        FROM ingreso
        WHERE rut_socio = reg_socio.rut;
        
        
        --CALCULO PUNTAJE
        SELECT puntaje
        INTO v_puntaje
        FROM puntaje_prestamo
        WHERE v_total_prestamos BETWEEN monto_min AND monto_max;
        
        -- PUNTOS EXTRA POR BAJO SALDO ADEUDADO
        v_saldo := v_total_prestamos - v_total_abonos;
        v_corte := v_total_prestamos * :b_corte;
        
        IF v_saldo < v_corte THEN
            v_puntaje := v_puntaje + :b_puntos_extra;
        END IF;
        
        
        -- PUNTOS EXTRA POR NO TENER MULTAS
        SELECT NVL(SUM(monto),0)
        INTO v_total_multas
        FROM ingreso
        WHERE rut_socio = reg_socio.rut
        AND cod_actividad = 22 OR cod_actividad = 33;
        
        IF v_total_multas = 0 THEN
            v_puntaje := v_puntaje + :b_puntos_sin_multa;
        END IF;
        
        -- DETERMINAR GRUPO RIESGO
        SELECT cod_grupo_riesgo
        INTO v_cod_riesgo
        FROM grupos_riesgo
        WHERE v_puntaje BETWEEN puntaje_minimo AND puntaje_maximo;
        
        INSERT INTO evaluacion_socio VALUES(
            reg_socio.rut,
            v_total_prestamos,
            v_total_abonos,
            v_total_ingresos,
            v_puntaje,
            v_cod_riesgo
        );
        
        /*
            DBMS_OUTPUT.PUT_LINE('Total Prestamos:  ' || v_total_prestamos);
            DBMS_OUTPUT.PUT_LINE('Total Abonos:     ' ||v_total_abonos);
            DBMS_OUTPUT.PUT_LINE('Monto Corte:      ' ||v_corte);
            DBMS_OUTPUT.PUT_LINE('Saldo Pendiente:  ' ||v_saldo);
            DBMS_OUTPUT.PUT_LINE('Total Ingresos:   ' ||v_total_ingresos);
            DBMS_OUTPUT.PUT_LINE('Puntaje Base:     ' ||v_puntaje);
            DBMS_OUTPUT.PUT_LINE('Riesgo:            ' ||v_cod_riesgo);
            */
        EXCEPTION
                WHEN OTHERS THEN
                    v_mensaje := SQLERRM;
                    v_codigo := SQLCODE;
                    
                    INSERT INTO registro_errores VALUES(
                    SEQ_ERRORES.nextval,
                    sysdate,
                    v_proceso,
                    v_codigo,
                    v_mensaje
                    );
        END;
    -- CARGA FOTO POR DEFECTO PARA CADA USUARIO
        BEGIN
            v_proceso := 'Fotografía';
            UPDATE socio SET fotografia = empty_blob()
            WHERE rut = reg_socio.rut
            RETURNING fotografia INTO v_blob;
            
            v_nombre := 'usuario.png';
            
            v_file := BFILENAME('DIRE_BLOB',v_nombre);
            DBMS_LOB.OPEN(v_file, DBMS_LOB.LOB_READONLY);
            DBMS_LOB.LOADFROMFILE(v_blob, v_file, DBMS_LOB.GETLENGTH(v_file));
            DBMS_LOB.CLOSE(v_file);
        
            EXCEPTION
                WHEN OTHERS THEN
                    v_mensaje := SQLERRM;
                    v_codigo := SQLCODE;
                    
                    INSERT INTO registro_errores VALUES(
                    SEQ_ERRORES.nextval,
                    sysdate,
                    v_proceso,
                    v_codigo,
                    v_mensaje
                    );
        END;
    END LOOP;

END;