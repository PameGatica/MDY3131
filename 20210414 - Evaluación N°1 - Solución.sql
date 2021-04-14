SET SERVEROUTPUT ON;
-- PROBLEMA 1
/*
VAR b_cat_ban NUMBER;
VAR b_monto_tope NUMBER;
VAR b_punt_tope NUMBER;


EXEC :b_cat_ban := 3;
EXEC :b_monto_tope := 10000000;
EXEC :b_punt_tope := 90;


DECLARE
    v_fecha_ini DATE;  --01/01/2021
    v_fecha_fin DATE;  --31/03/2021
    v_mes NUMBER;
    v_anno NUMBER;
    v_cor_ini NUMBER;
    v_cor_fin NUMBER;
    
    v_fecha proyecto.fecha_postulacion%TYPE;
    v_monto proyecto.monto%TYPE;
    v_puntaje proyecto.puntaje%TYPE;
    v_cod_categoria proyecto.cod_categoria%TYPE;
    
    v_estado NUMBER;
BEGIN
    
      --  Primer trimestre:  ene - feb - mar
      --  Segundo trimestre: abr - may - jun 4-5-6
      --  Tercer trimestre:  jul - ago - sep 7-8-9
    -- Cuarto trimestre:  oct - nov - dic 10-11-12
    
   
    
    v_mes := EXTRACT(MONTH FROM sysdate);
    v_anno := EXTRACT(YEAR FROM sysdate);
    
    CASE    
     WHEN v_mes BETWEEN 4 AND 6 THEN
        v_fecha_ini := TO_DATE('01/01/' || v_anno ,'DD/MM/RR');
        v_fecha_fin := TO_DATE('31/03/' ||v_anno , 'DD/MM/RR');
    WHEN v_mes BETWEEN 7 AND 9 THEN
        v_fecha_ini := TO_DATE('01/04/' || v_anno ,'DD/MM/RR');
        v_fecha_fin := TO_DATE('30/06/' ||v_anno , 'DD/MM/RR');
    WHEN v_mes BETWEEN 10 AND 12 THEN
        v_fecha_ini := TO_DATE('01/07/' || v_anno ,'DD/MM/RR');
        v_fecha_fin := TO_DATE('30/09/' ||v_anno , 'DD/MM/RR');
    WHEN v_mes BETWEEN 1 AND 3 THEN
        v_fecha_ini := TO_DATE('01/10/' || v_anno-1 ,'DD/MM/RR');
        v_fecha_fin := TO_DATE('31/12/' ||v_anno-1 , 'DD/MM/RR');
    END CASE;
    
    SELECT MIN(correlativo), MAX(correlativo)
    INTO v_cor_ini, v_cor_fin
    FROM proyecto;
    
    FOR cor IN v_cor_ini .. v_cor_fin LOOP
        SELECT fecha_postulacion, monto, puntaje, cod_categoria
        INTO v_fecha, v_monto, v_puntaje, v_cod_categoria
        FROM proyecto
        WHERE correlativo = cor;
        
        IF v_fecha BETWEEN v_fecha_ini AND v_fecha_fin THEN
                
                IF v_cod_categoria = :b_cat_ban THEN
                    v_estado := 20;
                ELSE
                    IF v_monto <= :b_monto_tope THEN
                        v_estado := 10;
                    
                    ELSE
                        IF v_puntaje >= :b_punt_tope THEN
                            v_estado := 10;
                        ELSE
                            v_estado := 20;
                        END IF;
                    END IF;
                END IF;
            
                UPDATE proyecto SET cod_estado = v_estado WHERE correlativo = cor;
        END IF;
    
    END LOOP;
END;
*/

-- PROBLEMA 2
/*
VAR b_puntaje NUMBER;
EXEC :b_puntaje := 90;

DECLARE
    v_fecha_ini DATE;  --01/01/2021
    v_fecha_fin DATE;  --31/03/2021
    v_cor_ini NUMBER;
    v_cor_fin NUMBER;
    v_fecha proyecto.fecha_postulacion%TYPE;
    v_puntaje proyecto.puntaje%TYPE;
    v_estado NUMBER;
    
BEGIN
    v_fecha_ini := TO_DATE('01/07/20','DD/MM/RR');
    v_fecha_fin := TO_DATE('31/12/20','DD/MM/RR');
    
    SELECT MIN(correlativo), MAX(correlativo)
    INTO v_cor_ini, v_cor_fin
    FROM proyecto;
    
    FOR cor IN v_cor_ini .. v_cor_fin LOOP
        SELECT fecha_postulacion, puntaje
        INTO v_fecha, v_puntaje
        FROM proyecto
        WHERE correlativo = cor;
        
         IF v_fecha BETWEEN v_fecha_ini AND v_fecha_fin THEN
            IF v_puntaje >= :b_puntaje THEN
                v_estado :=10;
            ELSE
                v_estado :=20;
            END IF;
            
            UPDATE proyecto SET cod_estado = v_estado WHERE correlativo = cor;
         END IF;
    END LOOP;
END;
*/

--PROBLEMA 3

VAR b_reajuste NUMBER;
EXEC :b_reajuste := 0.2;

DECLARE
    v_cor_min NUMBER;
    v_cor_max NUMBER;
    v_proyecto proyecto.proyecto%TYPE;
    v_cod_cat proyecto.cod_categoria%TYPE;
    v_monto proyecto.monto%TYPE;
    v_comuna comuna.nom_comuna%TYPE;
    
BEGIN
    SELECT MIN(correlativo), MAX(correlativo)
    INTO v_cor_min, v_cor_max
    FROM proyecto;
    
    DELETE FROM proyectos_culturales_2021;
    
    FOR cor IN v_cor_min .. v_cor_max LOOP
        SELECT proyecto, cod_categoria, monto, nom_comuna
        INTO v_proyecto, v_cod_cat , v_monto, v_comuna
        FROM proyecto
        JOIN organizacion USING(cod_org)
        JOIN comuna USING(cod_comuna)
        WHERE correlativo = cor;
        
        IF v_cod_cat = 4 OR v_cod_cat = 6 THEN
            v_monto := v_monto + (v_monto * :b_reajuste);
            
            INSERT INTO proyectos_culturales_2021 VALUES(
                v_proyecto,
                v_comuna,
                ROUND(v_monto)
            );
        END IF;
    
    END LOOP;



END;