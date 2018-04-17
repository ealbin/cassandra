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

prompt[0]="Boot up ${CASSANDRA_IMAGE}"
prompt[1]="Build and Boot ${HOST_IMAGE} (debug)"
prompt[2]="Update Cassandra with latest data"
prompt[3]="csql> ${CLUSTER_NAME}"
prompt[4]="bash ${CLUSTER_NAME}"
prompt[5]="kill all"
prompt[6]="Cleanup docker images"
prompt[7]="Make environment"

PS3="Select Command: "
select opt in "${prompt[@]}"
do
    case $opt in ${prompt[0]}) # boot up cassandra image
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

        ${prompt[1]}) # build and boot host image for debug
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

         ${prompt[2]}) # update cassandra with latest data
            update
	        break
            ;;

         ${prompt[3]}) # csql cassandra
	        cmd="docker run -it --link ${CLUSTER_NAME}:cassandra --rm cassandra cqlsh cassandra"
	        echo
	        echo $cmd
	        eval $cmd
	        echo
	        break
	        ;;

         ${prompt[4]}) # bash cassandra
	        cmd="docker run -it --link ${CLUSTER_NAME}:cassandra --rm cassandra bash"
	        echo
	        echo $cmd
	        eval $cmd
	        echo
            break
            ;;

         ${prompt[5]}) # kill all
            check=`docker ps | egrep -c "${CLUSTER_NAME}"`
            if [ $check -gt 0 ]; then docker kill $CLUSTER_NAME; fi

            check=`docker ps | egrep -c "${HOST_NAME}"`
            if [ $check -gt 0 ]; then docker kill $HOST_NAME; fi
            break
            ;;

	     ${prompt[6]}) # cleanup docker images
    	    for id in `docker images | egrep "^<none>" | awk '{print $3}'`; do docker rmi $id; done
    	    break
    	    ;;

         ${prompt[7]}) # make environment
            export CASSANDRA_IMAGE=$CASSANDRA_IMAGE
            export CLUSTER_NAME=$CLUSTER_NAME
            export HOST_CASSANDRA_DIR=$HOST_CASSANDRA_DIR
            export HOST_IMAGE=$HOST_IMAGE
            export HOST_NAME=$HOST_NAME
            export HOST_DATA=$HOST_DATA
            export HOST_SRC=$HOST_SRC
            break
            ;;

        *) echo invalid option;;
    esac
done
