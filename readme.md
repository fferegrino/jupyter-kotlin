# Creating a Notebook with Jupyter and Kotlin!

## Introduction

As a software developer, I'm always on the lookout for new tools and languages to enhance my skills. Recently, I began delving into the world of Kotlin, a modern and versatile programming language that has caught my attention.

However, as someone accustomed to the interactive environment of Jupyter, which allows for rapid iterations and fluid code exploration, I wondered if something similar existed for Kotlin.

To my pleasant surprise, I discovered that there is a Jupyter kernel for Kotlin. This tool combines the power and elegance of Kotlin with the interactivity and ease of use of Jupyter, creating an ideal development environment for learning and experimenting with the language.

In this post, I'll share my experience setting up a Jupyter environment with Kotlin support, and I'll even go a step further, creating a notebook that allows working with multiple languages simultaneously.

## Creating a Container with Kotlin

Installing the Kotlin kernel for Jupyter is relatively straightforward, especially if we use Docker to create a controlled and reproducible environment. Let's look at the Dockerfile I've created for this purpose:

```docker
# Start from a base image with python 3.12.1
FROM python:3.12.1 AS kotlin-kernel

# Install Java 21
RUN apt update && apt install wget lsb-release -y && \
    wget https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

RUN apt update && apt -y install msopenjdk-21

# Install Kotlin kernel
RUN pip install \
    jupyterlab==4.3.3 \
    kotlin-jupyter-kernel==0.12.0.322

# Set the working directory
WORKDIR /notebooks

# Specify the command to run
CMD ["jupyter", \
    "lab", \
    "--ip=0.0.0.0", \
    "--port=8888", \
    "--no-browser", \
    "--allow-root", \
    "--NotebookApp.token=''", \
    "--NotebookApp.password=''", \
    "--notebook-dir=/notebooks"]
```

Explanation of the Dockerfile:

1. We start with a base Python 3.12.1 image.
2. We install Java 21, necessary to run Kotlin.
3. We use pip to install JupyterLab and the Kotlin kernel for Jupyter.
4. We set the working directory to `/notebooks`.
5. We specify the command to run JupyterLab with various options:
   - `--ip=0.0.0.0`: Allows connections from any IP.
   - `--port=8888`: Specifies the port on which JupyterLab will run.
   - `--no-browser`: Prevents automatically opening a browser.
   - `--allow-root`: Allows execution as root user.
   - `--NotebookApp.token=''` and `--NotebookApp.password=''`: Disables authentication (for development only).
   - `--notebook-dir=/notebooks`: Sets the notebooks directory.

To build the Docker image, we run:

```bash
docker build --target kotlin-kernel -t kotlin-kernel .
```

This command builds the Docker image and tags it as `kotlin-kernel`.

To run the container:

```bash
docker run \
    -it \
    -p 8888:8888 \
    -v $(pwd)/notebooks:/home/jovyan/notebooks \
    kotlin-kernel
```

This command:
- Runs the container in interactive mode (`-it`).
- Maps port 8888 of the container to port 8888 of the host (`-p 8888:8888`).
- Mounts the local `notebooks` directory to the `/notebooks` directory in the container (`-v $(pwd)/notebooks:/notebooks`).

Once executed, you'll be able to access JupyterLab in your browser and you'll see that the Launcher already has two kernels available: Python and Kotlin.

![Available Kernels](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/two-kernels?updatedAt=1735657648064)

And in fact, we can now create notebooks with Kotlin!

![Notebook with Kotlin](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/running-kotlin?updatedAt=1735657858774)

## The Next Step in Interactivity

As I delved deeper into Kotlin, I noticed some interesting similarities with Python. This led me to want to visualize these similarities in more detail, creating direct comparisons between the two languages. I wondered if it would be possible to run Python and Kotlin code in the same notebook, and it turns out it is possible.

I discovered an extension (and Jupyter kernel) called SoS (Script of Scripts) that allows this functionality. I decided to add it to my container with the Kotlin kernel. Here's the updated Dockerfile:

```docker
# Start from the kotlin-kernel image
FROM kotlin-kernel

# Install sos-notebook
RUN pip install sos-notebook==0.24.4 \
    jupyterlab-sos==0.11.0 \
    sos==0.25.1

# Install the sos extensions
RUN python -m sos_notebook.install
```

With these additions, we can now build and run our enhanced container:

```bash
docker build -t jupyter-kotlin .

docker run \
    -it \
    -p 8888:8888 \
    -v $(pwd)/notebooks:/home/jovyan/notebooks \
    jupyter-kotlin
```

When accessing JupyterLab now, you'll see three kernels available: Python, Kotlin, and SoS.

![Three kernels](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/three-kernels?updatedAt=1735658830005)

And now we can run Kotlin and Python in the same notebook:

![Shared Kernel](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/jupyter-kotlin-indicators?updatedAt=1735659227991)

## Extra Customization

To enhance the visual experience and easily distinguish between cells of different languages, I decided to customize the appearance of the cells. Jupyter Notebook allows adding custom CSS, which enables us to add gradients to the left of each cell, depending on the language.

Here's the CSS I used:

```css
div[class*="sos_lan__python"] { 
    background: linear-gradient(90deg, rgba(255,222,87,1) 10px, rgba(69,132,182,1) 10px, rgba(69,132,182,1) 20px, rgba(254,254,254,1) 20px);
}
div[class*="sos_lan__kotlin"] {
    background: linear-gradient(90deg, rgba(180,140,252,1) 0px, rgba(196,22,224,1) 6px, rgba(223,73,107,1) 16px, rgba(223,73,107,1) 20px, rgba(255,255,255,1) 20px)
}
```

To implement this customization, I saved the CSS in a file called `custom.css` and added it to the Dockerfile:

```docker
# Copy the custom.css file
COPY custom.css ${HOME}/.jupyter/custom/custom.css
```

Additionally, it's necessary to specify to the `jupyter lab` command that we want to use this custom CSS, adding the `--custom-css` flag to the execution command.

![Shared Kernel](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/jupyter-kotlin?updatedAt=1735659227991)

## Errors and How to Hide Them

While using the multi-language kernel, an error occasionally appears when running a Kotlin cell. This error is displayed randomly and, although I haven't yet managed to identify its origin or how to resolve it definitively, I've found a temporary solution to improve the user experience.

![Error](https://ik.imagekit.io/thatcsharpguy/posts/docker/kotlin-kernel/kotlin-with-error)

To hide this annoying error, I decided to use CSS. I added the following line to the `custom.css` file mentioned earlier:

```css
div[class*="sos_lan__kotlin"] div[data-mime-type="application/vnd.jupyter.stderr"] { 
	display: none; 
}
```

This CSS line hides specific Kotlin error messages in the notebook. While it's not an ideal solution, as it could hide important errors, it significantly improves the visual experience when working with Kotlin notebooks, especially when dealing with this recurring and seemingly harmless error.

## Conclusion

In this post, we've explored how to create an interactive development environment for Kotlin using Jupyter Notebooks. We started with the basic setup of a Docker container with Kotlin support, then advanced to a more sophisticated environment that allows code execution in multiple languages within the same notebook.

Additionally, we've seen how to customize the appearance of our notebooks to enhance the visual experience and readability, and how to handle some common errors that may arise during the use of these notebooks.

## Additional Resources

For those interested in exploring further or replicating this environment, I've made all the code used in this project available in my GitHub repository [here you could include the link to the repository].

I hope this guide is useful in your learning journey with Kotlin and Jupyter.
