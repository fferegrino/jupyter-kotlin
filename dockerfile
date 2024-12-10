FROM python:3.12.1

RUN apt update && apt install wget lsb-release -y && \
    wget https://packages.microsoft.com/config/debian/$(lsb_release -rs)/packages-microsoft-prod.deb -O packages-microsoft-prod.deb && \
    dpkg -i packages-microsoft-prod.deb

RUN apt update && apt -y install msopenjdk-21

RUN pip install jupyterlab==4.3.3 kotlin-jupyter-kernel==0.12.0.322

# Set the working directory
WORKDIR /notebooks

# Update the CMD instruction to use the working directory
CMD [ \ 
    "jupyter", "lab", \
    "--ip=0.0.0.0", \
    "--port=8888", \
    "--no-browser", \
    "--allow-root", \
    "--NotebookApp.token=''", \
    "--NotebookApp.password=''", \
    "--notebook-dir=/notebooks"]
