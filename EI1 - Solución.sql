SET SERVEROUTPUT ON;

DECLARE
v_id NUMBER;
v_id_min NUMBER;
v_id_max NUMBER;

v_codpasajero PASAJERO.CODPASAJERO%TYPE;
v_nombres PASAJERO.NOMBRES%TYPE;
v_apellidos PASAJERO.APELLIDOS%TYPE;
v_total_vuelos NUMBER;
v_descuento PROMOCION_PASAJERO.DESCUENTO%TYPE;

v_millasminimas CATEGORIA.MILLASMINIMAS%TYPE;
v_nuevasmillas CATEGORIA.MILLASMINIMAS%TYPE;
b_millas CATEGORIA.MILLASMINIMAS%TYPE;

v_millasacumuladas NUMBER;
v_codcategoria CATEGORIA.CODCATEGORIA%TYPE;

v_codruta RUTA.CODRUTA%TYPE;

BEGIN

SELECT MIN(id), MAX(id) 
INTO v_id_min, v_id_max
FROM pasajero;
DELETE FROM promocion_pasajero;
FOR v_id IN v_id_min .. v_id_max LOOP
    SELECT pa.codpasajero, pa.nombres, pa.apellidos, COUNT(ps.codvuelo)
    INTO v_codpasajero, v_nombres, v_apellidos, v_total_vuelos
    FROM pasajero pa
    JOIN pasaje ps ON pa.codpasajero = ps.codpasajero
    WHERE pa.id = v_id
    GROUP BY pa.id, pa.codpasajero, pa.nombres, pa.apellidos
    ORDER BY pa.id;   
    
    --DBMS_OUTPUT.PUT_LINE(v_codpasajero || ' ' || v_total_vuelos);
    
    v_descuento := 
    CASE v_total_vuelos
        WHEN 1 THEN 10
        WHEN 2 THEN 20
        WHEN 3 THEN 20
        ELSE 30
    END;
    
    INSERT INTO promocion_pasajero
    VALUES(v_codpasajero, v_nombres, v_apellidos, v_descuento);
    
END LOOP;
--*************** FIN EJERCICIO 1
SELECT MIN(id), MAX(id) 
INTO v_id_min, v_id_max
FROM categoria;

FOR v_id IN v_id_min .. v_id_max LOOP
    SELECT millasminimas 
    INTO v_millasminimas
    FROM categoria
    WHERE id = v_id;
   /* 
    v_nuevasmillas := v_millasminimas - &b_millas;
    --DBMS_OUTPUT.PUT_LINE(v_millasminimas || ' ' || v_nuevasmillas);
    UPDATE categoria
    SET millasminimas = v_nuevasmillas
    WHERE id=v_id;
    */
END LOOP;
--****************************************
--EJERCICIO 3
SELECT MIN(id), MAX(id) 
INTO v_id_min, v_id_max
FROM pasajero;

FOR v_id IN v_id_min .. v_id_max LOOP
    SELECT SUM(ru.distancia)
    INTO v_millasacumuladas
    FROM pasajero pa
    JOIN pasaje ps ON pa.codpasajero=ps.codpasajero
    JOIN vuelo vu ON vu.codvuelo = ps.codvuelo
    JOIN ruta ru ON ru.codruta = vu.codruta
    WHERE pa.id=v_id
    GROUP BY pa.id, pa.codpasajero;
    
    SELECT codcategoria
    INTO v_codcategoria
    FROM categoria
    WHERE millasminimas > v_millasacumuladas
    AND id = (SELECT MIN(id) FROM categoria WHERE millasminimas > v_millasacumuladas);
    
    UPDATE pasajero
    SET codcategoria = v_codcategoria
    WHERE id = v_id;
    
END LOOP;
--***************************
--EJERCICIO 4
SELECT MIN(id), MAX(id) 
INTO v_id_min, v_id_max
FROM ruta;

    FOR v_id IN v_id_min .. v_id_max LOOP
        SELECT ru.codruta, COUNT(vu.codvuelo)
        INTO v_codruta, v_total_vuelos
        FROM ruta ru
        JOIN vuelo vu ON ru.codruta = vu.codruta
        WHERE ru.id= v_id
        GROUP BY ru.id, ru.codruta
        ORDER BY ru.id;
        
        v_descuento :=
        CASE v_total_vuelos
            WHEN 1 THEN 50
            WHEN 2 THEN 25
            ELSE 0
        END;
        
        INSERT INTO oferta_ruta
        VALUES(v_codruta, v_descuento);
        
    END LOOP;
END;