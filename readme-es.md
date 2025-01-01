# Creando un notebook con Jupyter y Kotlin!

## Introducción

Recientemente, comencé a sumergirme en el mundo de Kotlin, un lenguaje de programación moderno y versátil que ha captado mi atención. Sin embargo, como alguien acostumbrado al entorno interactivo de Jupyter, que permite iteraciones rápidas y una exploración fluida del código, me preguntaba si existía algo similar para Kotlin.

Para mi agradable sorpresa, descubrí que existe un kernel de Jupyter para Kotlin. Esta herramienta combina la potencia y elegancia de Kotlin con la interactividad y facilidad de uso de Jupyter, creando un ambiente de desarrollo ideal para aprender y experimentar con el lenguaje.

En este post, compartiré mi experiencia configurando un entorno de Jupyter con soporte para Kotlin, e incluso iré un paso más allá, creando un notebook que permite trabajar con múltiples lenguajes simultáneamente.

## Creando un contenedor con Kotlin

La instalación del kernel de Kotlin para Jupyter es relativamente sencilla, especialmente si utilizamos Docker para crear un entorno controlado y reproducible. Veamos el Dockerfile que he creado para este propósito – revisa los comentarios para entender cada paso:

### Dockerfile

Comenzamos con una imagen oficial de Jupyter descargada de quay.io. Usamos una versión específica para asegurar la reproducibilidad y etiquetamos la imagen como `kotlin-kernel` para identificarla fácilmente.

```docker
FROM quay.io/jupyter/base-notebook:2024-12-31 AS kotlin-kernel
```

Instalamos OpenJDK 21, necesario para ejecutar Kotlin, la instalación se realiza como root para evitar problemas de permisos y luego cambiamos al usuario no-root para asegurar la seguridad de la imagen.

```docker
USER root

RUN apt-get update && apt-get -y install openjdk-21-jdk

USER jovyan
```

Instalamos el kernel de Kotlin para Jupyter, esto nos permitirá ejecutar código Kotlin en nuestro notebook.

```docker
RUN pip install --user \
    kotlin-jupyter-kernel==0.12.0.322
```

Creamos un directorio para almacenar los notebooks.

```docker
RUN mkdir -p /home/jovyan/notebooks
```

Por último, establecemos la variable de entorno `NOTEBOOK_ARGS` que permite configurar el notebook con las opciones que necesitemos, en este caso, no queremos que se abra un navegador automáticamente y queremos que el directorio de notebooks sea `/home/jovyan/notebooks`.

```docker
ENV NOTEBOOK_ARGS="--no-browser --notebook-dir=/home/jovyan/notebooks"
```

Para construir la imagen Docker, ejecutamos:

```bash
docker build --target kotlin-kernel -t kotlin-kernel .
```

Este comando construye la imagen Docker y la etiqueta como `kotlin-kernel`.

Para ejecutar el contenedor:

```bash
docker run \
    -it \
    -p 8888:8888 \
    -v $(pwd)/notebooks:/home/jovyan/notebooks \
    kotlin-kernel
```

Este comando:
- Ejecuta el contenedor en modo interactivo (`-it`).
- Mapea el puerto 8888 del contenedor al puerto 8888 del host (`-p 8888:8888`).
- Monta el directorio local `notebooks` en el directorio `:/home/jovyan/notebooks` del contenedor (`-v $(pwd)/notebooks::/home/jovyan/notebooks`).

Una vez ejecutado, podrás acceder a JupyterLab en tu navegador y verás que el Launcher ya tiene dos kernels disponibles: Python y Kotlin.

![Kernels disponibles](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/two-kernels?updatedAt=1735657648064)

Y de hecho, ya podemos crear notebooks con Kotlin!

![Notebook con Kotlin](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/running-kotlin?updatedAt=1735657858774)

## El siguiente paso en interactividad

Al profundizar en Kotlin, noté algunas similitudes interesantes con Python. Esto me llevó a querer visualizar estas similitudes de manera más detallada, creando comparaciones directas entre los dos lenguajes. Me pregunté si sería posible ejecutar código Python y Kotlin en el mismo notebook, y resulta que sí es posible.

Descubrí una extensión (y kernel de Jupyter) llamada SoS (Script of Scripts) que permite esta funcionalidad. Decidí agregarla a mi contenedor con el kernel de Kotlin. Aquí están las adiciones al Dockerfile:

### Actualización del Dockerfile

Instalamos SoS, que nos permitirá ejecutar código Python y Kotlin en el mismo notebook.

```docker
RUN pip install --user \
    sos-notebook==0.24.4 \
    jupyterlab-sos==0.11.0 \
    sos==0.25.1 && \
    python -m sos_notebook.install
```

Con estas adiciones, ahora podemos construir y ejecutar nuestro contenedor mejorado:

```bash
docker build -t jupyter-kotlin .

docker run \
    -it \
    -p 8888:8888 \
    -v $(pwd)/notebooks:/home/jovyan/notebooks \
    jupyter-kotlin
```

Al acceder a JupyterLab ahora, verás tres kernels disponibles: Python, Kotlin y SoS.

![Kernels disponibles](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/three-kernels?updatedAt=1735658830005)

Y ahora podemos ejecutar código Python y Kotlin en el mismo notebook:

![Notebook con Python y Kotlin](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/jupyter-kotlin-indicators?updatedAt=1735659227991)

## Personalización extra

Para mejorar la experiencia visual y distinguir fácilmente entre las celdas de diferentes lenguajes, decidí personalizar la apariencia de las celdas.

Jupyter Notebook permite agregar CSS personalizado, lo que nos permite añadir gradientes a la izquierda de cada celda, dependiendo del lenguaje.

Aquí está el CSS que utilicé:

```css
div[class*="sos_lan__python"] { 
    background: linear-gradient(90deg, rgba(255,222,87,1) 10px, rgba(69,132,182,1) 10px, rgba(69,132,182,1) 20px, rgba(254,254,254,1) 20px);
}
div[class*="sos_lan__kotlin"] {
    background: linear-gradient(90deg, rgba(180,140,252,1) 0px, rgba(196,22,224,1) 6px, rgba(223,73,107,1) 16px, rgba(223,73,107,1) 20px, rgba(255,255,255,1) 20px)
}
```

Para implementar esta personalización, guardé el CSS en un archivo llamado `custom.css` y lo agregué al Dockerfile:

```docker
# Copy the custom.css file
COPY custom.css ${HOME}/.jupyter/custom/custom.css
```

Además, es necesario especificar al comando `jupyter lab` que queremos usar este CSS personalizado, añadiendo la bandera `--custom-css` al comando de ejecución.

```docker
ENV NOTEBOOK_ARGS="${NOTEBOOK_ARGS} --custom-css"
```

![Notebook con CSS personalizado](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/jupyter-kotlin?updatedAt=1735659227973)

## Errores y cómo esconderlos

Durante el uso del kernel de múltiples lenguajes, ocasionalmente aparece un error cuando se ejecuta una celda de Kotlin. Este error se muestra de forma aleatoria y, aunque aún no he logrado identificar su origen ni cómo resolverlo de manera definitiva, he encontrado una solución temporal para mejorar la experiencia del usuario.

![Error de Kotlin](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/kotlin-with-error?updatedAt=1735659310180)

Para ocultar este error molesto, decidí utilizar CSS. Agregué la siguiente línea al archivo `custom.css` mencionado anteriormente:

```css
div[class*="sos_lan__kotlin"] div[data-mime-type="application/vnd.jupyter.stderr"] { 
	display: none; 
}
```

Esta línea de CSS oculta los mensajes de error específicos de Kotlin en el notebook. Aunque no es una solución ideal, ya que podría ocultar errores importantes, mejora significativamente la experiencia visual al trabajar con notebooks de Kotlin, especialmente cuando se trata de este error recurrente y aparentemente inofensivo.

## Conclusión

En este post, hemos explorado cómo crear un entorno de desarrollo interactivo para Kotlin utilizando Jupyter Notebooks.

Comenzamos con la configuración básica de un contenedor Docker con soporte para Kotlin, luego avanzamos hacia un entorno más sofisticado que permite la ejecución de código en múltiples lenguajes dentro del mismo notebook.

Además, hemos visto cómo personalizar la apariencia de nuestros notebooks para mejorar la experiencia visual y la legibilidad, y cómo _"esconder"_ algunos errores comunes que pueden surgir durante el uso de estos notebooks.

Esto no solo facilita el aprendizaje de Kotlin, sino que también permite realizar comparaciones directas con otros lenguajes como Python, lo cual puede ser extremadamente útil para desarrolladores que están haciendo la transición a Kotlin o que trabajan regularmente con múltiples lenguajes de programación.

## Recursos adicionales

Para aquellos interesados en explorar más a fondo o replicar este entorno, he puesto a disposición todo el código utilizado en [este proyecto en mi repositorio de GitHub](https://github.com/fferegrino/jupyter-kotlin).

Espero que esta guía te sea útil en tu viaje de aprendizaje con Kotlin y Jupyter.
