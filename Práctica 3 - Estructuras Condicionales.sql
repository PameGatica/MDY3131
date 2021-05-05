SET SERVEROUTPUT ON;

--CASO 1
/*
VAR t1 NUMBER;
VAR t2 NUMBER;
VAR t3 NUMBER;

VAR pnorm NUMBER;
VAR pext1 NUMBER;
VAR pext2 NUMBER;
VAR pext3 NUMBER;

VAR run_cliente NUMBER;

EXEC :t1 := 1000000;
EXEC :t2 := 3000000;

EXEC :pnorm := 1200;
EXEC :pext1 := 100
EXEC :pext2 := 300
EXEC :pext3 := 550

EXEC :run_cliente := 22558061

DECLARE
v_nro_cliente cliente.nro_cliente%TYPE;
v_dv cliente.dvrun%TYPE;
v_nombre_cliente VARCHAR(200);
v_cod_tipo cliente.cod_tipo_cliente%TYPE;
v_tipo_cliente tipo_cliente.nombre_tipo_cliente%TYPE;
v_creditos NUMBER;
v_pesos_todo_suma NUMBER;
v_factor NUMBER;
BEGIN

SELECT nro_cliente, dvrun, pnombre ||  ' ' || snombre || ' ' || appaterno || ' ' || apmaterno AS nombre_cliente, t.nombre_tipo_cliente, c.cod_tipo_cliente
INTO v_nro_cliente, v_dv, v_nombre_cliente, v_tipo_cliente,v_cod_tipo
FROM cliente c
JOIN tipo_cliente t ON (t.cod_tipo_cliente=c.cod_tipo_cliente)
WHERE numrun = :run_cliente; 

SELECT sum(monto_solicitado)
INTO v_creditos
FROM credito_cliente
WHERE nro_cliente = v_nro_cliente;

IF v_cod_tipo = 2 THEN  --Trabajador independiente
    v_factor :=  CASE
                    WHEN v_creditos < :t1 THEN :pext1
                    WHEN v_creditos BETWEEN :t1 AND :t2 THEN :pext2
                    ELSE :pext3
                END;
    v_factor := v_factor + :pnorm;
ELSE    --trabajador dependiente o pensionado
    v_factor := :pnorm;
    
END IF;

v_pesos_todo_suma := TRUNC(v_creditos / 100000)* v_factor;


DELETE FROM cliente_todosuma WHERE nro_cliente = v_nro_cliente;

INSERT INTO cliente_todosuma VALUES(
v_nro_cliente,
TO_CHAR(:run_cliente,'99G999G999')||'-'||v_dv,
v_nombre_cliente,
v_tipo_cliente,
v_creditos,
v_pesos_todo_suma
);
END;
*/

-- CASO 2
/*
VAR t1 NUMBER;
VAR t2 NUMBER;
VAR t3 NUMBER;
VAR t4 NUMBER;
VAR t5 NUMBER;

VAR gc1 NUMBER;
VAR gc2 NUMBER;
VAR gc3 NUMBER;
VAR gc4 NUMBER;
VAR gc5 NUMBER;

VAR run_cliente NUMBER;

EXEC :t1 := 900000;
EXEC :t2 := 2000000;
EXEC :t3 := 5000000;
EXEC :t4 := 8000000;
EXEC :t5 := 15000000;

EXEC :gc1 := 0;
EXEC :gc2 := 50000;
EXEC :gc3 := 100000;
EXEC :gc4 := 200000;
EXEC :gc5 := 300000;

EXEC :run_cliente := 08925537

DECLARE
v_nro_cliente cumpleanno_cliente.nro_cliente%TYPE;
v_dv cliente.dvrun%TYPE;
v_nombre_cliente cumpleanno_cliente.nombre_cliente%TYPE;
v_profesion cumpleanno_cliente.profesion_oficio%TYPE;
v_fecha_nac cliente.fecha_nacimiento%TYPE;
v_dia_cumpleanno cumpleanno_cliente.dia_cumpleano%TYPE;
v_monto_giftcard cumpleanno_cliente.monto_gifcard%TYPE;
v_observacion cumpleanno_cliente.observacion%TYPE;
v_monto_ahorrado NUMBER;
BEGIN

    SELECT nro_cliente, dvrun, INITCAP(pnombre) || ' ' ||  INITCAP(snombre) || ' ' ||  INITCAP(appaterno) || ' ' || INITCAP(apmaterno), fecha_nacimiento, nombre_prof_ofic
    INTO v_nro_cliente, v_dv, v_nombre_cliente, v_fecha_nac, v_profesion
    FROM cliente
    JOIN profesion_oficio USING (cod_prof_ofic)
    WHERE numrun = :run_cliente;
    
    
    SELECT NVL(SUM(monto_total_ahorrado),0)
    INTO v_monto_ahorrado
    FROM producto_inversion_cliente
    WHERE nro_cliente = v_nro_cliente;
    
    
    
    v_dia_cumpleanno := TO_CHAR(v_fecha_nac,'DD')|| ' de ' || TO_CHAR(v_fecha_nac,'Month');
    --DBMS_OUTPUT.PUT_LINE('Cumpleaños : '|| v_dia_cumpleanno);
    
    IF EXTRACT(MONTH FROM v_fecha_nac) = EXTRACT(MONTH FROM sysdate)+1 THEN
    --cumpleaños el proximo mes, hay que calcular monto giftcard
    v_monto_giftcard := CASE
                           WHEN v_monto_ahorrado < :t1 THEN :gc1                    -- 900000
                           WHEN v_monto_ahorrado BETWEEN :t1 AND :t2 THEN :gc2      -- 900001 y 2000000
                           WHEN v_monto_ahorrado BETWEEN :t2 AND :t3 THEN :gc3      -- 2000001 y 5000000
                           WHEN v_monto_ahorrado BETWEEN :t3 AND :t4 THEN :gc4     -- 5000001 y 8000000
                           WHEN v_monto_ahorrado BETWEEN :t4 AND :t5 THEN :gc5      -- 8000001 y 15000000
                       END;
    v_observacion := null;
    ELSE
        --no cumpleaños el proximo mes
        v_monto_giftcard := null;
        v_observacion := 'El cliente no está de cumpleaños en el mes procesado';
    END IF;
    
    DELETE FROM cumpleanno_cliente WHERE nro_cliente = v_nro_cliente;
    
    INSERT INTO cumpleanno_cliente VALUES(
        v_nro_cliente,
        TO_CHAR(:run_cliente,'99G999G999')||'-'||v_dv,
        v_nombre_cliente,
        v_profesion,
        v_dia_cumpleanno,
        v_monto_giftcard,
        v_observacion
    );
    
END;
*/

--CASO 3
VAR b_nro_cliente NUMBER;
VAR b_nro_credito NUMBER;
VAR b_cuotas_postergar NUMBER;

EXEC :b_nro_cliente := 13;
EXEC :b_nro_credito := 2004;
EXEC :b_cuotas_postergar := 1;

DECLARE
v_tipo_credito NUMBER;
v_interes NUMBER;

BEGIN
SELECT cod_credito
INTO v_tipo_credito
FROM credito_cliente
WHERE nro_solic_credito = :b_nro_credito; 

CASE
    WHEN v_tipo_credito = 1 THEN    --Hipotecario
        IF :b_cuotas_postergar = 1 THEN
            v_interes := 0;
        ELSE
            v_interes := 0.05;
        END IF;
    WHEN v_tipo_credito = 2 THEN    --Consumo
        
    WHEN v_tipo_credito = 3 THEN    --Automotriz
        
END CASE;

-- VERIFICAR CUANTOS CREDITOS PIDIO EL AÑO PASADO

DBMS_OUTPUT.PUT_LINE('Tipo credito: ' || v_tipo_credito);
END;

