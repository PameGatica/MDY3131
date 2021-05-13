SET SERVEROUTPUT ON;

DECLARE
    FK_NO_EXISTE EXCEPTION;
    PRAGMA EXCEPTION_INIT(FK_NO_EXISTE,-02291);  
    LOC_NO_VALIDA EXCEPTION;   
    v_mensaje_error VARCHAR(255);
    v_codigo_error NUMBER;
    v_location NUMBER := 1700;    
BEGIN
    BEGIN
    IF v_location <> 1700 THEN
        RAISE LOC_NO_VALIDA;
    END IF;
    INSERT INTO departments VALUES(290,'Departamento Nuevo',200,v_location);
    DBMS_OUTPUT.PUT_LINE('Departamento Creado Exitosamente');
    EXCEPTION
        WHEN FK_NO_EXISTE THEN
            v_mensaje_error := SQLERRM;
            v_codigo_error := SQLCODE;
            
            DBMS_OUTPUT.PUT_LINE('ERROR '|| v_codigo_error ||' :  '  || v_mensaje_error);
        
        WHEN LOC_NO_VALIDA THEN
            DBMS_OUTPUT.PUT_LINE('ERROR: Departamento no puede crearse en esa ciudad ');
    END;    
    DBMS_OUTPUT.PUT_LINE('Procedimiento Terminado');
END;