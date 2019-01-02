# Stimpack

## ¿Qué es stimpack?

Stimpack es una herramienta que permite realizar experimentos electrofisiológicos y de comportamiento en primates despiertos que involucran la presentación de estímulos visuales

Stimpack se ejecuta sobre Matlab haciendo uso de la librería Psychtoolbox

## Instalación y ejecución del programa

Stimpack esta pensado para ejecutarse sobre Matlab 2015b, no está probado en otras versiones de Matlab, por lo que no se asegura su funcionamiento.

Depende de  [Psychtoolbox](http://psychtoolbox.org/), la toolbox de [Datapixx](http://vpixx.com/products/tools-for-mri/visual-testing-software/toolbox/), y de la toolbox del [Eyelink](https://es.mathworks.com/matlabcentral/fileexchange/3176-eyelink-toolbox)

Una vez descargado Stimpack, se debe añadir la carpeta descargada y sus subcarpetas al path de Matlab.

Para ejecutar la herramienta simplemente escribir "stimpack" en la linea de comandos de Matlab y arrancará la interfaz principal de la aplicación.

## Pantalla principal

![Interfaz principal de la aplicación](https://github.com/Shiul93/stimpack/blob/master/docs/latex/figures/main_gui.png?raw=true)

Desde la pantalla principal de la aplicación se pueden configurar los parámetros generales de la aplicación y lanzar las diferentes tareas implementadas en Stimpack.

Hay 3 categorías de configuración diferentes:

- **Hardware enable**: Permite activar o desactivar los distintos sistemas hardware que se integran con Stimpack, estas opciones son útiles en caso de necesitar depurar el código sin tener acceso a los equipos necesarios. En el caso de desactivar el Eyelink, se realiza una emulación usando el ratón, si se desactivan las otras dos opciones se mostraran mensajes de log en la consola de Matlab.
- **Screen**: Permite configurar las características de la pantalla donde se mostraran los estímulos, tanto las dimensiones de la pantalla como la distancia a la que se encuentra el sujeto de pruebas.
- **Psychtoolbox**: Permite configurar algunos parámetros propios de la librería, cómo desactivar los test de sincronía del monitor o escoger el monitor de estimulación.

En la zona izquierda de la ventana se muestran los botones para iniciar las tareas.

## Tarea de fijación

![Interfaz de la tarea de fijación](https://github.com/Shiul93/stimpack/blob/master/docs/latex/figures/fixation_gui.png?raw=true)

En la tarea de fijación se muestra al sujeto una pantalla con un  punto central donde debe fijar la mirada.

La interfaz de la tarea consta de dos partes, la izquierda donde se ajustan los parámetros de la tarea, y la derecha que permite controlar la ejecución de la tarea.

Los parámetros configurables son los siguientes:

- Tiempo de fijación: Tiempo que el sujeto debe fijar para considerar un ensayo correcto.
- Tiempo de espera para fijación: Tiempo que tiene el sujeto para fijar la mirada en el punto.
- Tiempo de recompensa: Cantidad de tiempo durante el que se administrará la recompensa.
- Numero de ensayos: Número de ciclos del experimento.
- Intervalo entre ensayos: Tiempo de espera entre ensayos
- Variación de tiempo entre ensayos: Variabilidad en el tiempo entre ensayos.
- Nombre del archivo EDF: Nombre del archivo generado por el eyelink con los datos del experimento.
- Tamaño del punto de fijación: Tamaño del punto de fijación, definido en grados del sistema visual.
- Tamaño de la ventana de fijación: Tamaño de la ventana de fijación, definida en grados del sistema visual.
- Color del punto de fijación: Definido en RGBA.
- Color del fondo: Definido en RGBA.

![](https://github.com/Shiul93/stimpack/blob/master/docs/latex/figures/fixation.png?raw=true)

## Tarea de mapeo
![Interfaz de la tarea de mapeo](https://github.com/Shiul93/stimpack/blob/master/docs/latex/figures/mapping_gui.png?raw=true)
En esta tarea se le muestran al sujeto diferentes cuadrantes de color para buscar los campos receptores en la corteza visual.

Los parámetros configurables son los siguientes:

- Tiempo de fijación: Tiempo que el sujeto debe fijar para considerar un ensayo correcto.
- Tiempo de espera para fijación: Tiempo que tiene el sujeto para fijar la mirada en el punto.
- Tiempo de recompensa: Cantidad de tiempo durante el que se administrará la recompensa.
- Numero de ensayos: Número de ciclos del experimento.
- Intervalo entre ensayos: Tiempo de espera entre ensayos
- Variación de tiempo entre ensayos: Variabilidad en el tiempo entre ensayos.
- Nombre del archivo EDF: Nombre del archivo generado por el eyelink con los datos del experimento.
- Tamaño del punto de fijación: Tamaño del punto de fijación, definido en grados del sistema visual.
- Tamaño de la ventana de fijación: Tamaño de la ventana de fijación, definida en grados del sistema visual.
- Color del punto de fijación: Definido en RGBA.
- Color del fondo: Definido en RGBA.
- Tiempo de estimulación: Tiempo que se le muestra el estimulo al sujeto, en milisegundos.
- Color del estimulo: Color del estimulo en RGBA
- Repetición de abortos: Si está activado, en caso de estar ciclando los cuadrantes, no se cambia de cuadrante hasta que se supere el ensayo correctamente.

Además de estos parámetros se puede seleccionar el cuadrante y el subcuadrante que se mostrará al sujeto utilizando los botones de la parte inferior, así como activar el ciclado automático de los mismos.


