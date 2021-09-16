# AudioReverb

## Requerimientos
* Sistema Linux, su usó Ubuntu 20.04
* NodeJs
* DotNet 5.0
* Nasm
## Instrucciones
### Con Cliente
1. Clonar el repositorio o consiga los archivos del programa.
2. Compilar en la carpeta client con el comando: 
    ```
    npm i
    // o con
    npm install
    ```
2. Iniciar el servidor en la carpeta server con el comando:
    ```
    dotnet run
    ```
3. Inicializar el cliente con:
    ```
    npm run dev
    ```
4. Aprete los botones para reproducir las piezas, las llamadas al sistema se ejecutan apenas se inicializa la aplicación.
### Sin Cliente, solo el código de Ensamblador
1. Clonar el repositorio. Solo se necesita dentro la carpeta server la carpeta asm.
2. Para ejecutar el reverb se ejecuta el script, `reverb.sh` el cual contiene los comandos de nasm y linux para ejecutar de código `reverb.asm`.
3. En caso de ejecutar el Dereverb se hace con el script `dereverb.sh`, el cual contiene los comandos de nasm y linux para ejecutar el código `dereverb.asm`.
