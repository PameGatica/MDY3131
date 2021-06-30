SELECT  
    numrun,
    dvrun, 
    nro_tarjeta, 
    nro_transaccion, 
    fecha_transaccion,
    cod_tptran_tarjeta,
    nombre_tptran_tarjeta tipo_transaccion, 
    monto_transaccion
FROM transaccion_tarjeta_cliente tran
JOIN tipo_transaccion_tarjeta ttt USING (cod_tptran_tarjeta)
JOIN tarjeta_cliente tar USING(nro_tarjeta)
JOIN cliente cli USING (numrun)
WHERE EXTRACT(YEAR FROM fecha_transaccion) = 2020
ORDER BY fecha_transaccion;