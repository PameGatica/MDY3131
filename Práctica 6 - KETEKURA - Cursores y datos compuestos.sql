SET SERVEROUTPUT ON;
--CASO1

DECLARE
     TYPE tipo_array_montos_multas IS VARRAY(19) OF NUMBER;
     varray_montos_multas tipo_array_montos_multas;
     
     CURSOR cur_morosos 
     IS SELECT 
            pac_run run, 
            p.dv_run dv, 
            p.pnombre || ' '|| p.snombre || ' ' || p.apaterno || ' ' || p.amaterno paciente,
            TRUNC((sysdate-fecha_nacimiento)/365) edad,
            ate_id ate_id,
            pa.fecha_venc_pago fecha_vto,
            pa.fecha_pago fecha_pago,
            pa.fecha_pago-pa.fecha_venc_pago dias_morosidad,
            esp_id esp_id,
            e.nombre especialidad
            FROM atencion a
            JOIN pago_atencion pa USING(ate_id)
            JOIN paciente p USING(pac_run)
            JOIN especialidad e USING (esp_id)
            WHERE EXTRACT(YEAR FROM pa.fecha_venc_pago) = EXTRACT(YEAR FROM sysdate) -1 
            ORDER BY pa.fecha_venc_pago, p.apaterno;

     v_indice NUMBER;
     v_multa NUMBER;
     v_deuda pago_moroso.monto_multa%TYPE;
     v_descuento NUMBER := 0;
    
     
BEGIN
    varray_montos_multas := tipo_array_montos_multas(1200,1300,1200,1700,1900,1900,1100,0,1700,0,2000,0,0,2300,0,0,0,2300,0);
    DELETE FROM pago_moroso;
    
    FOR reg_moroso IN cur_morosos LOOP
      
        IF reg_moroso.dias_morosidad > 0 THEN
            
            v_indice := (reg_moroso.esp_id)/100;
            v_multa := varray_montos_multas(v_indice);
            v_deuda := v_multa * reg_moroso.dias_morosidad;
            
            v_descuento := 0;
            --CALCULANDO DESCUENTO TERCERA EDAD
            IF reg_moroso.edad >= 65 THEN
                SELECT porcentaje_descto
                INTO v_descuento
                FROM porc_descto_3ra_edad
                WHERE reg_moroso.edad BETWEEN anno_ini AND anno_ter;
                
                v_deuda :=  v_deuda - v_deuda*v_descuento/100;
                
            END IF;
            
            --DBMS_OUTPUT.PUT_LINE(reg_moroso.ate_id || ' ' || reg_moroso.edad || ' ' || v_deuda  || ' ' || v_descuento);
            INSERT INTO pago_moroso VALUES(
                reg_moroso.run,
                reg_moroso.dv,
                reg_moroso.paciente,
                reg_moroso.ate_id,
                reg_moroso.fecha_vto,
                reg_moroso.fecha_pago,
                reg_moroso.dias_morosidad,
                reg_moroso.especialidad,
                v_deuda
            );
            
        END IF;
    END LOOP;
END;