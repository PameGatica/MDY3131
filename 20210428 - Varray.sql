SET SERVEROUTPUT ON;
DECLARE
    --1. Definición
    TYPE tipo_varray_locations IS VARRAY(6)
    OF locations.city%TYPE;
    
    --2. Declaración
    varray_oficinas tipo_varray_locations;
    
    v_total NUMBER;
    
BEGIN
    --3. Referenciación
    --varray_oficinas := tipo_varray_locations('Bombay','Tokio','Singapur','Oxford');
    varray_oficinas := tipo_varray_locations();
    varray_oficinas.extend;
    varray_oficinas(1) := 'Bombay';
    varray_oficinas.extend;
    varray_oficinas(2) := 'Tokio';
    
    DBMS_OUTPUT.PUT_LINE('Total oficinas:  :' ||   varray_oficinas.count());
    
    v_total :=  varray_oficinas.count();
    FOR i IN 1 ..  v_total LOOP
        DBMS_OUTPUT.PUT_LINE(varray_oficinas(i));
    END LOOP;
    
    varray_oficinas(2) := 'Singapur';
    DBMS_OUTPUT.PUT_LINE(varray_oficinas(2));
    /*
    varray_oficinas.extend;
    
    v_total :=  varray_oficinas.count();
    DBMS_OUTPUT.PUT_LINE('Total oficinas:  :' ||   varray_oficinas.count());
    varray_oficinas(v_total) := 'Valparaíso';
    

    FOR i IN 1 ..  v_total LOOP
        DBMS_OUTPUT.PUT_LINE(varray_oficinas(i));
    END LOOP;
    */
END;

/*
INSERT INTO  especialidad VALUES('100','Cirugía General');
INSERT INTO  especialidad VALUES('200','Ortopedia y Traumatología');
INSERT INTO  especialidad VALUES('300','Dermatología');
INSERT INTO  especialidad VALUES('400','Inmunología');
INSERT INTO  especialidad VALUES('500','Fisiatría');
INSERT INTO  especialidad VALUES('600','Medicina Interna');
INSERT INTO  especialidad VALUES('700','Medicina General');
INSERT INTO  especialidad VALUES('800','Neurología');
INSERT INTO  especialidad VALUES('900','Otorrinolaringología');
INSERT INTO  especialidad VALUES('1000','Oftalmología');
INSERT INTO  especialidad VALUES('1100','Psiquiatría Adultos');
INSERT INTO  especialidad VALUES('1200','Urología');
INSERT INTO  especialidad VALUES('1300','Cirugía Cardiovascular');
INSERT INTO  especialidad VALUES('1400','Cirugía Digestiva');
INSERT INTO  especialidad VALUES('1500','Cardiología');
INSERT INTO  especialidad VALUES('1600','Gastroenterología');
INSERT INTO  especialidad VALUES('1700','Oncología Médica');
INSERT INTO  especialidad VALUES('1800','Reumatología');
INSERT INTO  especialidad VALUES('1900','Cirugía Plástica');

*/

DECLARE
    TYPE tipo_array_montos_multas IS VARRAY(19) OF NUMBER;
    
    varray_montos_multas tipo_array_montos_multas;
BEGIN
    varray_montos_multas := tipo_array_montos_multas(1200,1300,1200,1700,1900,1900,1100,0,1700,0,2000,0,0,2300,0,0,0,2300,0);
    DBMS_OUTPUT.PUT_LINE(varray_montos_multas.count());
    
    FOR i IN 1 .. 19 LOOP
        DBMS_OUTPUT.PUT_LINE('Codigo Especialidad: ' ||  i*100 || 'Monto Multa: $' || varray_montos_multas(i));
    END LOOP;
END;