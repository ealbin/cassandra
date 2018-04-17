#!/bin/env python

# an example to accessing Cassandra from python
#-----------------------------------------------

# (1) get the IP address of the Cassandra server
# ref: https://docker-py.readthedocs.io/en/stable/
import docker
client = docker.from_env()
# below will error if the container is not already running
# kick it off as needed: bash /home/crayfis-data/cassandra/bin/cmd.sh
server = client.containers.get('crayvault')
ipaddr = server.attrs['NetworkSettings']['IPAddress']


# (2) connect with the Cassandra server
# ref: https://datastax.github.io/python-driver/index.html
from cassandra.cluster import Cluster
cluster = Cluster([ipaddr])
session = cluster.connect()
help(session) # to wit: default_timeout and row_factory


# (3) explore the current keyspaces and tables
# ref: https://datastax.github.io/python-driver/api/cassandra/metadata.html
meta = cluster.metadata
keyspaces = meta.keyspaces
# raw: where raw data goes, right now that's the only data keyspace
# system_xxxx: cluster info
raw = keyspaces['raw']
tables = raw.tables
# etc, e.g.
events = raw.tables['events']
columns = events.columns
columns.keys()
# etc..


# (4) submit CQL searches to the database
# ref: https://docs.datastax.com/en/cql/3.1/cql/cql_reference/cqlCommandsTOC.html
# e.g. get all events and all info 
results = session.execute( 'select * from raw.events' )
while results.has_more_pages:
    for event in results.current_rows():
        pass # do whatever
    results.fetch_next_page()

# e.g. get only device_id and pixels
results = session.execute( 'select device_id, pixels from raw.events' )

