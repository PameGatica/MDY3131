/*EN ADMIN*/
/*
BEGIN
        DBMS_CLOUD.GET_OBJECT(
            credential_name => 'CREDENCIAL_BLOB',
            object_uri => 'https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/ZimIaEDaFZ9m-eaQfpDTiaK62vZzw9WeWaLcTgjlqXchmXYN5-LjYLKA9V4q3FKa/n/gr2bsmst5zux/b/MiBucket/o/automovil.png',
            directory_name => 'DIRE_BLOB'
        );
END;
*/
/*EN USUARIO */
SET SERVEROUTPUT ON;

VARIABLE b_uf NUMBER;
EXEC :b_uf := 27000;

DECLARE
    CURSOR cur_clientes IS 
    SELECT C.RUN, V.PATENTE,S.PRIMA_MENSUAL,MO.CODIGO AS COD_MODELO, MA.CODIGO AS COD_MARCA
    FROM CLIENTE C
    JOIN SEGURO S ON (C.RUN = S.CLIENTE_RUN)
    JOIN VEHICULO V ON (S.VEHICULO_PATENTE = V.PATENTE)
    JOIN MODELO MO ON (V.MODELO_CODIGO = MO.CODIGO)
    JOIN MARCA MA ON (MO.MARCA_CODIGO = MA.CODIGO);
   
    CURSOR cur_eventos(run VARCHAR) IS 
    SELECT S.CLIENTE_RUN, E.EVENTO_CODIGO AS CODIGO, COSTO 
    FROM EVENTO E JOIN SEGURO S ON (S.NUMERO_POLIZA = E.NUMERO_POLIZA)
    WHERE S.CLIENTE_RUN = run;
    
    v_run CLIENTE.RUN%TYPE;
    v_siniestros NUMBER;
    v_eventos NUMBER;
    v_costos NUMBER;
    v_pagos_uf NUMBER;
    v_pagos_pesos NUMBER;
    v_prop NUMBER;
    v_dif NUMBER;
    
    v_aumento_prima NUMBER;
    v_modelo_ref MODELO.CODIGO%TYPE;
    v_marca_ref MARCA.CODIGO%TYPE;
    v_siniestros_max NUMBER;
    v_asistencias_max NUMBER;
    
    v_mensaje_error VARCHAR(50);
    v_sentencia_error VARCHAR(100);
    
    --CARGA IMAGEN
    CURSOR cur_seguros IS SELECT numero_poliza, foto_inspeccion FROM seguro; 
    v_file BFILE;
    v_blob BLOB;
    v_foto_nombre VARCHAR(30);


BEGIN 

    DELETE FROM ANALISIS_CLIENTE;

    SELECT  MAX(COUNT(E.CORRELATIVO))
    INTO v_siniestros_max
    FROM EVENTO E
    JOIN SEGURO S ON (E.NUMERO_POLIZA = S.NUMERO_POLIZA)
    JOIN VEHICULO V ON (S.VEHICULO_PATENTE = V.PATENTE)
    JOIN MODELO M ON (M.CODIGO = V.MODELO_CODIGO)
    WHERE EVENTO_CODIGO = 4 
    GROUP BY M.CODIGO;

    SELECT MAX(COUNT(E.CORRELATIVO))  
    INTO v_asistencias_max
    FROM EVENTO E
    JOIN SEGURO S ON (E.NUMERO_POLIZA = S.NUMERO_POLIZA)
    JOIN VEHICULO V ON (S.VEHICULO_PATENTE = V.PATENTE)
    JOIN MODELO M ON (M.CODIGO = V.MODELO_CODIGO)
    JOIN MARCA MA ON (MA.CODIGO = M.MARCA_CODIGO)
    WHERE EVENTO_CODIGO = 1 
    GROUP BY Ma.NOMBRE;

    SELECT M.CODIGO  
    INTO v_modelo_ref
    FROM EVENTO E
    JOIN SEGURO S ON (E.NUMERO_POLIZA = S.NUMERO_POLIZA)
    JOIN VEHICULO V ON (S.VEHICULO_PATENTE = V.PATENTE)
    JOIN MODELO M ON (M.CODIGO = V.MODELO_CODIGO)
    WHERE EVENTO_CODIGO = 4 
    GROUP BY M.CODIGO
    HAVING COUNT(E.CORRELATIVO) = v_siniestros_max;

    SELECT MA.CODIGO  
    INTO v_marca_ref
    FROM EVENTO E
    JOIN SEGURO S ON (E.NUMERO_POLIZA = S.NUMERO_POLIZA)
    JOIN VEHICULO V ON (S.VEHICULO_PATENTE = V.PATENTE)
    JOIN MODELO M ON (M.CODIGO = V.MODELO_CODIGO)
    JOIN MARCA MA ON (MA.CODIGO = M.MARCA_CODIGO)
    WHERE EVENTO_CODIGO = 1 
    GROUP BY Ma.CODIGO
    HAVING COUNT(E.CORRELATIVO) = v_asistencias_max;

    
    DBMS_OUTPUT.PUT_LINE('Modelo más siniestrado: ' || v_modelo_ref);
    DBMS_OUTPUT.PUT_LINE('Marca más asistencias: ' || v_marca_ref);

    FOR reg_cliente IN cur_clientes LOOP
        v_eventos :=0;
        v_siniestros :=0;
        v_costos :=0;
        
        --DBMS_OUTPUT.PUT_LINE(reg_cliente.nombre || ' -- ' || reg_cliente.marca  || ' '  || reg_cliente.modelo);
        
        -- ANALISIS DE EVENTOS
        FOR reg_evento IN cur_eventos(reg_cliente.run) LOOP
        --DBMS_OUTPUT.PUT_LINE(reg_evento.codigo || ' $' || reg_evento.costo);
            v_eventos := v_eventos +1;
            
                IF(reg_evento.codigo = 4) THEN -- evento es un siniestro
                    v_siniestros := v_siniestros +1;
                END IF;
            
            v_costos := v_costos + reg_evento.costo;
        END LOOP;
          --  DBMS_OUTPUT.PUT_LINE('Total Eventos: ' || v_eventos);
          --  DBMS_OUTPUT.PUT_LINE('Total Siniestros: ' || v_siniestros);
          --  DBMS_OUTPUT.PUT_LINE('Total Costos: $' || v_costos);
   
    
            -- ANALISIS DE PAGOS
            SELECT SUM(P.MONTO)
            INTO v_pagos_uf
            FROM PAGO P
            JOIN SEGURO S ON (S.NUMERO_POLIZA = P.NUMERO_POLIZA)
            GROUP BY S.CLIENTE_RUN
            HAVING S.CLIENTE_RUN = reg_cliente.run;
            
            v_pagos_pesos := v_pagos_uf * :b_uf;
            
           -- DBMS_OUTPUT.PUT_LINE('Total Pagos: $' || v_pagos_pesos);
    
            IF(v_costos > v_pagos_pesos)THEN
            v_dif := v_costos - v_pagos_pesos;
            v_prop:= v_dif * 100 / v_pagos_pesos;
            ELSE
            v_prop := 0;
            END IF;
    
          --  DBMS_OUTPUT.PUT_LINE('Diferencia: ' || v_dif);
           -- DBMS_OUTPUT.PUT_LINE('Proporción: ' || v_prop);
   
            --ANALISIS AUMENTO DE PRIMA
           
            v_aumento_prima :=0;
            IF v_siniestros > 0 THEN
                 v_aumento_prima :=  v_aumento_prima + 0.1;
            END IF;
            
            IF v_prop >= 100 THEN
                 v_aumento_prima :=  v_aumento_prima + 0.5;
            END IF;
            
            IF reg_cliente.cod_modelo = v_modelo_ref THEN
                 v_aumento_prima :=  v_aumento_prima + 0.2;
            END IF;
            
            IF reg_cliente.cod_marca = v_marca_ref THEN
                 v_aumento_prima:=  v_aumento_prima + 0.05;
            END IF;
    
    
            INSERT INTO ANALISIS_CLIENTE
            (CLIENTE_RUN,FECHA, TOTAL_EVENTOS, TOTAL_SINIESTROS, TOTAL_COSTOS, TOTAL_PAGOS, AUMENTO_PRIMA)
            VALUES
            (reg_cliente.run, sysdate, v_eventos, v_siniestros, v_costos, v_pagos_pesos, v_aumento_prima);
            
            UPDATE SEGURO SET PRIMA_MENSUAL = PRIMA_MENSUAL + v_aumento_prima WHERE CLIENTE_RUN = reg_cliente.run;
   
    END LOOP;
    
    -- CARGA IMAGEN
    FOR reg_seguro IN cur_seguros LOOP
        SELECT foto_inspeccion 
        INTO v_blob 
        FROM seguro 
        WHERE numero_poliza = reg_seguro.numero_poliza
        FOR UPDATE;
                
       -- v_foto_nombre := reg_poliza.patente || '-' || reg_poliza.modelo || '-' || reg_poliza.anno || '.jpeg'; 
       v_foto_nombre:= 'automovil.png';
                
        v_file := BFILENAME('DIRE_BLOB',v_foto_nombre);
                 
        DBMS_LOB.FILEOPEN( v_file, DBMS_LOB.file_readonly);
        DBMS_LOB.LOADFROMFILE(v_blob, v_file , DBMS_LOB.GETLENGTH(v_file));
        DBMS_LOB.FILECLOSE(v_file);
    END LOOP;

    EXCEPTION
        WHEN OTHERS THEN 
        
        v_sentencia_error := 'Ha ocurrido un error';
        v_mensaje_error :=  SQLERRM;
        INSERT INTO ERRORES_PROCESO VALUES(SEQ_ERRORES.NEXTVAL,TO_DATE(sysdate, 'dd/mm/yyyy hh24:mi:ss'),v_sentencia_error, v_mensaje_error); 
        

END;