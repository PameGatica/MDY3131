# Manejo de archivos BLOB en Oracle Cloud DB usando un bucket

> **NOTA :**  Requieres iniciar sesión con tu cuenta Oracle Cloud antes de comenzar.
 
## 1. Crear un bucket (cubo)
:pushpin: Un bucket es un contenedor para almacenar archivos en la nube. (Como una cuenta en Google Drive)

```
Menú Principal > Object Storage > Create Bucket
```
Presionar el botón `Create Bucket` con la configuración por defecto


## 2. Subir archivo al bucket
Ingresar al Bucket y cargar un archivo con el botón `Upload`


## 3. Autorizar archivo para ser leído
:pushpin: El archivo requiere permisos para ser accedido desde afuera del Bucket.
```
Menú de tres puntos del objeto > Create Pre-Authenticated Request > Access Type: Permit object reads and writes
```
***El proceso generará una URL para el objeto. Debes guardarla, la necesitarás más adelante.***

Ejemplo:

https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/Vdho5U_x499pDea7XllPNMOJxbAadzwAl05N5r_Dp9N-7LEBlwyiSadOUqofjpIY/n/gr2bsmst5zux/b/MiBucket/o/oracle_cloud.jpg

## 4. Obtener datos de la cuenta para construír la credencial
:pushpin: Para conectar al bucket desde SQL Developer necesitaremos algunos datos de la cuenta.

### 1. Obtener Oracle Identity Cloud Service
```
Profile > Copiar id Cloudservice

Ejemplo: oracleidentitycloudservice/pam.gatica@profesor.duoc.cl
```
### 2. Obtener Token de Autenticación
```
Profile > Resources > Auth Tokens > Generate Token
```
***Debes guardar este token, por motivos de seguridad, Oracle no vuelve a mostrarlo***

## 5. Generar un acceso al bucket desde SQL Developer
### Paso 1: Crear Credencial
:pushpin: __En cuenta de admin__
```sql
    BEGIN
        DBMS_CLOUD.CREATE_CREDENTIAL(
            credential_name => '<NOMBRE_CREDENCIAL>',
            username => '<CLOUDSERVICE ID>',
            password => 'TOKEN'
        );
    END;

    Ejemplo:
    BEGIN
        DBMS_CLOUD.CREATE_CREDENTIAL(
            credential_name => 'CRED_BLOB',
            username => 'oracleidentitycloudservice/pam.gatica@profesor.duoc.cl',
            password => '12dds+123p'
        );
    END;
```

### Paso 2: Crear directorio local
:pushpin: Si el directorio fuese local (No en la nube), el directorio se crearía apuntando al path donde se almacenarán los archivos.

#### PARA ORACLE CLOUD
```sql
   CREATE DIRECTORY <NOMBRE> AS 'ALIAS';
   
   Ejemplo:
   CREATE DIRECTORY DIR_BLOB AS 'DIR_BLOB';
```

#### PARA ORACLE ON PREMISE (Local)
```sql
    CREATE DIRECTORY <NOMBRE> AS 'Path'

    Ejemplo:
    CREATE DIRECTORY FOTOGRAFIAS AS 'C:\oracle\blob\super'
```

### Paso 3: Vincular Bucket a Archivo
```sql
    BEGIN
        DBMS_CLOUD.GET_OBJECT(
            credential_name => '<CREDENCIAL>',
            object_uri => '<URL del objeto>',
            directory_name => 'DIRECTORIO'
        );
    END;

    Ejemplo:
    BEGIN
        DBMS_CLOUD.GET_OBJECT(
            credential_name => 'CRED_BLOB',
            object_uri => 'https://objectstorage.sa-saopaulo-1.oraclecloud.com/p/Vdho5U_x499pDea7XllPNMOJxbAadzwAl05N5r_Dp9N-7LEBlwyiSadOUqofjpIY/n/gr2bsmst5zux/b/MiBucket/o/oracle_cloud.jpg',
            directory_name => 'DIR_BLOB'
        );
    END;
```

:pushpin: Podemos verificar que el archivo se ha enlazado correctamente al directorio usando la siguiente sentencia SELECT


```sql
    SELECT * FROM DBMS_CLOUD.LIST_FILES('<DIRECTORIO>')
    ORDER BY object_name;

    Ejemplo:
    SELECT * FROM DBMS_CLOUD.LIST_FILES('DIR_BLOB')
    ORDER BY object_name;
```


### Paso 4: Otorgar permisos
:pushpin: El usuario que hará uso de los objetos debe tener permisos de lectura y escritura sobre el directorio. **El permiso debe otorgarlo el usuario ADMIN**

```sql
    GRANT READ, WRITE ON DIRECTORY '<DIRECTORIO>'
    TO <usuario_que_manipulará_el_blob>;

    Ejemplo:
    GRANT READ, WRITE ON DIRECTORY 'DIR_BLOB'
    TO 'Practica8';
```