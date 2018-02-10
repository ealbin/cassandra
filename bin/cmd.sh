#!/bin/env bash

# Variables
CASSANDRA_IMAGE="cassandra:latest"
CLUSTER_NAME="crayvault"
HOST_CASSANDRA_DIR="/data/cassandra"
HOST_IMAGE="ubuntu:daq"
HOST_NAME="craydata"
HOST_DATA="/data/daq.crayfis.io/raw"
HOST_SRC="$PWD/src"

update() {
    check=`docker ps | egrep -c "${HOST_NAME}"`
    if [ $check -gt 0 ]; then docker kill ${HOST_NAME}; docker rm ${HOST_NAME}; fi
    cmd="docker build -t ${HOST_IMAGE} ."
    echo
    echo $cmd
    eval $cmd
    exit_code=$?
    echo
    if [[ $exit_code != 0 ]]; then break; fi
    data_map="${HOST_DATA}:/data/daq.crayfis.io/raw"
    src_map="${HOST_SRC}:/home/${HOST_NAME}/src"
    ingested_map="${HOST_SRC}/ingested"
    cmd="docker run --rm --name ${HOST_NAME} -v ${data_map} -v ${src_map} -v ${ingested_map} --link ${CLUSTER_NAME}:cassandra -dt ${HOST_IMAGE}"
    echo $cmd
    eval $cmd
    echo
    cmd="docker exec ${HOST_NAME} python /home/${HOST_NAME}/src/update.py"
    echo $cmd
    eval $cmd
    echo
    docker kill ${HOST_NAME}
}

if [ $# -eq 1 ]; then
    if [ "$1" = "update" ]; then
        update
    else
        echo 'invalid option'
        exit
    fi
fi

PS3="Select Command: "
commands=("Boot up ${CASSANDRA_IMAGE}" "Build and Boot ${HOST_IMAGE} (for debug)" "Update Cassandra" "Log into ${CLUSTER_NAME}" "Cleanup docker images")
select opt in "${commands[@]}"
do
    case $opt in
        "Boot up ${CASSANDRA_IMAGE}")
            check=`docker ps | egrep -c "${CLUSTER_NAME}"`
            if [ $check -gt 0 ]; then echo "instance of ${CLUSTER_NAME} already running..."; break; fi
            eval "docker rm ${CLUSTER_NAME}"
	        cmd="docker run --rm --name ${CLUSTER_NAME} -v ${HOST_CASSANDRA_DIR}:/var/lib/cassandra -d ${CASSANDRA_IMAGE}"
	        echo
	        echo $cmd
	        eval $cmd
            echo
	        break
            ;;

        "Build and Boot ${HOST_IMAGE} (for debug)")
            check=`docker ps | egrep -c "${HOST_NAME}"`
            if [ $check -gt 0 ]; then docker kill ${HOST_NAME}; docker rm ${HOST_NAME}; fi
	        cmd="docker build -t ${HOST_IMAGE} ."
	        echo
	        echo $cmd
	        eval $cmd
	        exit_code=$?
	        echo
            if [[ $exit_code != 0 ]]; then break; fi
            data_map="${HOST_DATA}:/data/daq.crayfis.io/raw"
            src_map="${HOST_SRC}:/home/${HOST_NAME}/src"
            ingested_map="${HOST_SRC}/ingested"
	        cmd="docker run --rm --name ${HOST_NAME} -v ${data_map} -v ${src_map} -v ${ingested_map} --link ${CLUSTER_NAME}:cassandra -it ${HOST_IMAGE}"
	        echo $cmd
            eval $cmd
	        echo
	        break
            ;;

         "Update Cassandra")
            update
	        break
            ;;

        "Log into ${CLUSTER_NAME}")
	        cmd="docker run -it --link ${CLUSTER_NAME}:cassandra --rm cassandra cqlsh cassandra"
	        echo 
	        echo $cmd
	        eval $cmd
	        echo
	        break
	        ;;
	    "Cleanup docker images")
    	    for id in `docker images | egrep "^<none>" | awk '{print $3}'`; do docker rmi $id; done
    	    break
    	    ;;
        *) echo invalid option;;
    esac
done
