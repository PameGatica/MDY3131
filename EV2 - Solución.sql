SET SERVEROUTPUT ON;

/*CREATE SEQUENCE seq_errores
START WITH 1 INCREMENT BY 1;*/

DECLARE
    CURSOR cur_pedidos IS   SELECT p.codigo, carrito_codigo, transportista_codigo, t.costo_por_gr, boleta_codigo, b.medio_pago_codigo, mp.costo
                            FROM pedido p
                            JOIN transportista t ON t.codigo = p.transportista_codigo
                            JOIN boleta b ON b.codigo = p.boleta_codigo
                            JOIN medio_pago mp ON mp.codigo = b.medio_pago_codigo
                            ORDER BY codigo;
                            
    CURSOR cur_detalle(cod_carrito NUMBER) IS   SELECT carrito_codigo, producto_codigo, cantidad, precio, puntos,peso
                            FROM detalle_carrito dc
                            JOIN producto p ON dc.producto_codigo = p.codigo
                            WHERE carrito_codigo = cod_carrito;
                            
                            
    v_totalventa NUMBER := 0;
    v_totalcostos NUMBER := 0;
    v_totalcantidad NUMBER;
    v_totalpeso NUMBER;
    v_totaltransporte NUMBER;
    
    v_ganancia NUMBER;
    v_transportecosto NUMBER;
    v_puntaje NUMBER;
    v_pagocosto NUMBER;
    v_logistica NUMBER;
    
    v_valorproducto NUMBER;
    v_costotransporte NUMBER;
    v_puntos NUMBER;    
    
    v_codigoerror NUMBER;
    v_mensajeerror VARCHAR(255);
    v_entorno VARCHAR(100);
    
BEGIN
    DELETE FROM ventas;
    v_entorno := 'Analisis de ventas';
    FOR reg_pedido IN cur_pedidos LOOP
       -- DBMS_OUTPUT.PUT_LINE(reg_pedido.codigo);
        v_totalventa := 0;
        v_totalcostos := 0;
        v_puntaje := 0;
        v_totalcantidad := 0;
        v_totalpeso := 0;
        v_totaltransporte:=0;
    
        FOR reg_carro IN cur_detalle(reg_pedido.carrito_codigo) LOOP
            
            v_valorproducto := reg_carro.precio * reg_carro.cantidad;
            v_costotransporte := reg_carro.peso * reg_pedido.costo_por_gr * reg_carro.cantidad;
            v_puntos := reg_carro.puntos * reg_carro.cantidad;
            
            --ACUMULADORES
            v_totalventa := v_totalventa + v_valorproducto;
            --v_total_costos := v_total_costos + v_costo_transporte;
            v_puntaje := v_puntaje + v_puntos;
            v_totaltransporte := v_totaltransporte + v_costotransporte;
            
            v_totalcantidad := v_totalcantidad + reg_carro.cantidad;
            v_totalpeso := v_totalpeso + (reg_carro.peso * reg_carro.cantidad);
        --    DBMS_OUTPUT.PUT_LINE(reg_carro.producto_codigo || ' ' || v_valorproducto || ' ' || v_costotransporte || ' '  || v_puntos );
        END LOOP;
        --FECHA ANALISIS
        --SYSDATE
        
        -- CODIGO PEDIDO
        -- DESDE EL RECORD
        
        -- TOTAL_VENTA
        -- v_total_venta
        
        -- TRANSPORTE_COSTO
        --v_totaltransporte
        
        --PUNTAJE
        --v_puntaje
        
         --PAGO_COSTO
        v_pagocosto := v_totalventa * reg_pedido.costo;
        
        --LOGISTICA
        v_logistica := v_totalcantidad * 500;
        IF v_totalpeso> 20000 THEN
            v_logistica := v_logistica + 5000;
        END IF;
        
        --TOTAL COSTOS
        v_totalcostos :=  v_totaltransporte + v_pagocosto + v_logistica;
        
        --GANANCIA
        v_ganancia := v_totalventa - v_totalcostos;
        
        INSERT INTO ventas VALUES (
            sysdate,
            reg_pedido.codigo,
            v_totalventa,
            v_totaltransporte,
            v_puntaje,
            ROUND(v_pagocosto),
            v_logistica,
             ROUND(v_totalcostos),
             ROUND(v_ganancia)
        );
        
    END LOOP;
    
    EXCEPTION
        WHEN OTHERS THEN
            v_codigoerror := SQLCODE;
            v_mensajeerror := SQLERRM;
            
            INSERT INTO errores VALUES (seq_errores.nextval,v_entorno,v_codigoerror || ':' || v_mensajeerror);
    
    

END;