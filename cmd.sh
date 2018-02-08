#!/bin/env bash

# Variables
CASSANDRA_IMAGE="cassandra:latest"
CLUSTER_NAME="crayvault"
HOST_CASSANDRA_DIR="/data/cassandra"
HOST_IMAGE="ubuntu:daq"
HOST_NAME="craydata"
HOST_DATA="/data/daq.crayfis.io/raw"
HOST_SRC="$PWD/src"

PS3="Select Command: "
commands=("Set Variables" "Boot up ${CASSANDRA_IMAGE}" "Build and Boot ${HOST_IMAGE}" "Log into ${CLUSTER_NAME}" "Quit")
select opt in "${commands[@]}"
do
    case $opt in
        "Set Paths")
            echo "haha you can't yet, edit the damn file"
            ;;
        "Boot up ${CASSANDRA_IMAGE}")
	    cmd="docker run --name ${CLUSTER_NAME} -v ${HOST_CASSANDRA_DIR}:/var/lib/cassandra -d ${CASSANDRA_IMAGE}"
	    echo
	    echo $cmd
	    eval $cmd
            echo
	    break
            ;;
        "Build and Boot ${HOST_IMAGE}")
	    cmd="docker build -t ${HOST_IMAGE} ."
	    echo
	    echo $cmd
	    eval $cmd
	    exit_code=$?
	    echo
            if [[ $exit_code != 0 ]]; then break; fi
	    cmd="docker run --rm --name ${HOST_NAME} -v ${HOST_DATA}:/data/daq.crayfis.io/raw -v ${HOST_SRC}:/home/${HOST_NAME}/src --link ${CLUSTER_NAME}:cassandra -it ${HOST_IMAGE}"
	    echo $cmd
	    eval $cmd
	    echo
	    break
            ;;
	"Log into ${CLUSTER_NAME}")
	    cmd="docker run --it --link ${CLUSTER_NAME}:cassandra --rm cassandra cqlsh cassandra"
	    echo 
	    echo $cmd
	    eval $cmd
	    echo
	    break
	    ;;
        "Quit")
	    echo "done."
	    break
            ;;
        *) echo invalid option;;
    esac
done
