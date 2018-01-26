#!/bin/env bash

# change this:
username=ealbin

# download data in Jan 01 2018
data_folder=data/daq.crayfis.io/raw/2018/01/01/
mkdir -p ${data_folder}

scp -r ${username}@craydata.ps.uci.edu:/${data_folder} ${data_folder%01/}
