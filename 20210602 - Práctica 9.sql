CREATE OR REPLACE PROCEDURE SP_CONSULTA_GC
(periodo NUMBER, edif NUMBER, depto NUMBER) AS
v_monto NUMBER := 0;
BEGIN
    SELECT monto_cancelado_pgc
    INTO v_monto
    FROM pago_gasto_comun
    WHERE   anno_mes_pcgc = periodo AND
            id_edif = edif AND
            nro_depto = depto;
    EXCEPTION 
        WHEN NO_DATA_FOUND THEN
            v_monto := 0;
    DBMS_OUTPUT.PUT_LINE(v_monto);
END;

CREATE OR REPLACE PROCEDURE SP_REGISTRA_NO_PAGO
(periodo NUMBER, edif NUMBER, depto NUMBER) AS
--declarar variables into
BEGIN
SELECT gc.numrun_rpgc, rpgc.pnombre_rpgc, rpgc.appaterno_rpgc, e.nombre_edif, a.pnombre_adm
INTO 
FROM gasto_comun gc
JOIN responsable_pago_gasto_comun rpgc ON gc.numrun_rpgc = rpgc.numrun_rpgc
JOIN edificio e USING(id_edif)
JOIN administrador a USING (numrun_adm)
WHERE anno_mes_pcgc = periodo AND
            id_edif = idedif AND
            nro_depto = depto;
            
INSERT INTO GASTO_COMUN_PAGO_CERO....
END;


SET SERVEROUTPUT ON;
EXEC SP_CONSULTA_GC(202104,40,20);