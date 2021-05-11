SET SERVEROUTPUT ON;
BEGIN
    DBMS_CLOUD.CREATE_CREDENTIAL(
        credential_name => 'CRED_BLOB',
        username => 'oracleidentitycloudservice/pam.gatica@profesor.duoc.cl',
        password => 'u7+7t97XjFq;{c)e{Hx-'
   );
END;

DECLARE
    v_location_uri VARCHAR2(255) := 'https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/SMWXbef00UEmVtoIxGijrDRqyVXFFc_ERdJqaM_sNWWtqDggX60Cs04qHNQ_AfTh/n/gr2bsmst5zux/b/MiBucket/o/';
    v_object_uri VARCHAR2(255);
    CURSOR bucket IS SELECT object_name 
    FROM table(dbms_cloud.list_objects(
             credential_name => 'CRED_BLOB', 
             location_uri => 'https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/SMWXbef00UEmVtoIxGijrDRqyVXFFc_ERdJqaM_sNWWtqDggX60Cs04qHNQ_AfTh/n/gr2bsmst5zux/b/MiBucket/o/'
           ));
BEGIN
    FOR archivo IN bucket LOOP
        
        v_object_uri := v_location_uri || archivo.object_name;
        DBMS_OUTPUT.PUT_LINE(archivo.object_name);
        DBMS_CLOUD.GET_OBJECT(
        credential_name => 'CRED_BLOB',
        object_uri => v_object_uri,
        directory_name => 'DIR_BLOB'
    );
    END LOOP;
END;

DECLARE
    CURSOR superheroes IS SELECT * FROM superheroe;
    v_file BFILE;
    v_blob BLOB;
    v_nombre_archivo VARCHAR(30);
BEGIN
    DBMS_OUTPUT.PUT_LINE('Carga de imágenes de superhéroes');
    FOR reg_superheroe IN superheroes LOOP
        DBMS_OUTPUT.PUT_LINE('Cargando imagen para ' || reg_superheroe.nombre_superheroe);
        v_nombre_archivo := LOWER(reg_superheroe.nombre_superheroe)||'.png';
        DBMS_OUTPUT.PUT_LINE('Nombre archivo: ' || v_nombre_archivo);
        DBMS_OUTPUT.PUT_LINE('....................................');
        
        UPDATE superheroe SET imagen = empty_blob() WHERE id = reg_superheroe.id
        RETURNING imagen INTO v_blob;
        
        v_file := BFILENAME('DIR_BLOB',v_nombre_archivo);
        DBMS_LOB.OPEN(v_file,DBMS_LOB.LOB_READONLY);
        DBMS_LOB.LOADFROMFILE(v_blob,v_file,DBMS_LOB.GETLENGTH(v_file));
        DBMS_LOB.CLOSE(v_file);
        COMMIT;
    END LOOP;
END;