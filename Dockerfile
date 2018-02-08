FROM ubuntu:xenial

# core software
#---------------------------------------------------
RUN apt-get update && apt-get install -y \
    build-essential \
    python \
    python-dev \
    python-pip \
    python-gdal \
    python-matplotlib \
    python-numpy \
    python-scipy \
    git \
    openssh-client \
    python3-pip \
    ipython
    
RUN pip install --upgrade pip
RUN pip install cassandra-driver
RUN pip install protobuf


# set up working directory
#---------------------------------------------------
RUN mkdir /home/craydata
WORKDIR /home/craydata
