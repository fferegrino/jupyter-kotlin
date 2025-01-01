# Base image from Jupyter's official images collection
# Using a specific version tag for reproducibility
FROM quay.io/jupyter/base-notebook:2024-12-31 AS kotlin-kernel

# Switch to root user to install system packages
USER root

# Install OpenJDK 21 which is required for Kotlin execution
RUN apt-get update && apt-get -y install openjdk-21-jdk

# Switch back to the default non-root user for security
USER jovyan

# Install the Kotlin Jupyter kernel
# This allows Jupyter to execute Kotlin code
RUN pip install --user \
    kotlin-jupyter-kernel==0.12.0.322

# Create a directory for storing notebooks
RUN mkdir -p /home/jovyan/notebooks

# Set default notebook arguments:
# --no-browser: Don't open browser automatically
# --notebook-dir: Set the directory where notebooks will be stored
ENV NOTEBOOK_ARGS="--no-browser --notebook-dir=/home/jovyan/notebooks"

# Start second stage build using the previous stage as base
FROM kotlin-kernel

# Install SoS (Script of Scripts) related packages
# SoS allows for multi-language notebooks
RUN pip install --user \
    sos-notebook==0.24.4 \
    jupyterlab-sos==0.11.0 \
    sos==0.25.1 && \
    python -m sos_notebook.install

# Copy custom CSS file for styling the notebook interface
COPY custom.css ${HOME}/.jupyter/custom/custom.css

# Add custom CSS flag to notebook arguments
ENV NOTEBOOK_ARGS="${NOTEBOOK_ARGS} --custom-css"
