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

# Start from the kotlin-kernel image
FROM kotlin-kernel

# Install sos-notebook
RUN pip install sos-notebook==0.24.4 \
    jupyterlab-sos==0.11.0 \
    sos==0.25.1

# Install the sos extensions
RUN python -m sos_notebook.install

# Copy the custom.css file
COPY custom.css /root/.jupyter/custom/custom.css

CMD ["jupyter", "lab", \
    "--ip=0.0.0.0", \
    "--port=8888", \
    "--custom-css", \
    "--no-browser", \
    "--allow-root", \
    "--NotebookApp.token=''", \
    "--NotebookApp.password=''", \
    "--notebook-dir=/notebooks"]
