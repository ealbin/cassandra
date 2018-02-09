# updates cassandra with current data
# keeps track of data that's been processed in the `ingested` directory

import ingest
import os
import sys

data_dir = '/data/daq.crayfis.io/raw/'
ingested_dir = './ingested'

tarfiles = []
for path, directories, files in os.walk( data_dir ):
    if '_old/' in path: continue

    for filename in files:
        if filename.endswith('.tar.gz'):
            tarfiles.append( os.path.join(path,filename) )
tarfiles = sorted( tarfiles, key=lambda k: k.lower(), reverse=True ) # most recent first

# Don't repeat what's done already
target = 0
n = float(len(tarfiles))
for i, file in enumerate(tarfiles):

    if (i+1)/n > (target/100.):
        print '\r>> working... {0}%, current file: {1}'.format( target, file ),
        sys.stdout.flush()
        if target < 1:
            target += .1
        elif target < 10:
            target += 1
        elif target < 90:
            target += 5
        elif target < 99:
            target += 1
        else:
            target += .1
    
    if os.path.isfile( os.path.join( ingested_dir, file.replace('/','_') ) ):
        continue
        
    did_it_work = ingest.from_tarfile(file)
    if did_it_work == True:
        open( os.path.join( ingested_dir, file.replace('/','_') ), 'a' ).close()
    else:
        print '\nfail: {0}'.format(file)
