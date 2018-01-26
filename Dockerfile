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

# mimick craydata.ps.uci.edu
#---------------------------------------------------
COPY ./craydata/ /

# load ingest module
#---------------------------------------------------
RUN mkdir /home/src
WORKDIR /home/src
COPY ./src /home/src

# add back symbolic links docker drops
#---------------------------------------------------
RUN cd /home/src/ingest/Cassandra/raw_keyspace && ln -s ../writer .
RUN cd /home/src/ingest/CrayonMessage && ln -s ../crayfis_data_pb2.py .
RUN cd /home/src/ingest/CrayonMessage/DataChunk && ln -s ../../crayfis_data_pb2.py .
