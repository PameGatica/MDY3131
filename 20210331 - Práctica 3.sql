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

EXEC :run_cliente := 21242003

DECLARE
v_nro_cliente cliente.nro_cliente%TYPE;
v_nombre_cliente VARCHAR(200);
v_cod_tipo cliente.cod_tipo_cliente%TYPE;
v_tipo_cliente tipo_cliente.nombre_tipo_cliente%TYPE;
v_creditos NUMBER;
v_pesos_todo_suma NUMBER;
BEGIN

SELECT nro_cliente, pnombre ||  ' ' || snombre || ' ' || appaterno || ' ' || apmaterno AS nombre_cliente, t.nombre_tipo_cliente, c.cod_tipo_cliente
INTO v_nro_cliente, v_nombre_cliente, v_tipo_cliente,v_cod_tipo
FROM cliente c
JOIN tipo_cliente t USING (cod_tipo_cliente)
WHERE numrun = :run_cliente; 

SELECT sum(monto_solicitado)
INTO v_creditos
FROM credito_cliente
WHERE nro_cliente = v_nro_cliente;

IF v_cod_tipo = 2 THEN  --Trabajador independiente

END IF;

END;


