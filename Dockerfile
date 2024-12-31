# Start from a base image with python 3.12.1
FROM quay.io/jupyter/base-notebook:2024-12-31 AS kotlin-kernel

USER root

RUN apt-get update && apt-get -y install openjdk-21-jdk

USER jovyan

# Install Kotlin kernel
RUN pip install --user \
    kotlin-jupyter-kernel==0.12.0.322

RUN mkdir -p /home/jovyan/notebooks

ENV NOTEBOOK_ARGS="--no-browser --notebook-dir=/home/jovyan/notebooks"

# Start from the kotlin-kernel image
FROM kotlin-kernel

# Install sos-notebook
RUN pip install --user \
    sos-notebook==0.24.4 \
    jupyterlab-sos==0.11.0 \
    sos==0.25.1

# Install the sos extensions
RUN python -m sos_notebook.install

# Copy the custom.css file
COPY custom.css ${HOME}/.jupyter/custom/custom.css

ENV NOTEBOOK_ARGS="${NOTEBOOK_ARGS} --custom-css"
