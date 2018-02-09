# updates cassandra with current data
# keeps track of data that's been processed in the `ingested` directory

import ingest
import os
import sys
import time

data_dir = '/data/daq.crayfis.io/raw/'
ingested_dir = './ingested'

print '>> starting...'
sys.stdout.flush()

tarfiles = []
for path, directories, files in os.walk( data_dir ):
    if '_old/' in path: continue

    for filename in files:
        if filename.endswith('.tar.gz'):
            tarfiles.append( os.path.join(path,filename) )
tarfiles = sorted( tarfiles, key=lambda k: k.lower(), reverse=True ) # most recent first

print '>> found {0} tarfiles in {1}'.format( len(tarfiles), data_dir )

target = 0.
n = float(len(tarfiles))
elapsed = 0.
absolute_start = time.time()
n_skipped = 0.
n_completed = 0.
for i, file in enumerate(tarfiles):

    # Don't repeat what's done already
    if os.path.isfile( os.path.join( ingested_dir, file.replace('/','_') ) ):
        print '    skipping {0}, already ingested'.format(file)
        n_skipped += 1.
        continue

    start = time.time()    
    did_it_work = ingest.from_tarfile(file)

    if did_it_work == True:
        elapsed += time.time() - start
        open( os.path.join( ingested_dir, file.replace('/','_') ), 'a' ).close()
        n_completed += 1.
    else:
        print '\nfail: {0}'.format(file)
        n_skipped += 1.
        continue

    if (n_completed > 0) and ( (i+1.)/n > (target/100.) or n_completed < 48 ):
        total_minutes = ( time.time() - absolute_start ) / 60.
        rate = n_completed / elapsed # files / second
        hours_remaining = (n - n_skipped - n_completed) / rate / 3600.
        print '\r>> working... {0}%, current file: {1}, ave time/file: {2:.3} s, elapsed time: {3:.3} m, eta: {4:.5} hrs        '.format( target, file, 1./rate, total_minutes, hours_remaining),
        sys.stdout.flush()
        if (i+1.)/n > (target/100.):
            if target < 1:
                target += .1
            elif target < 10:
                target += 1.
            elif target < 90:
                target += 5.
            elif target < 99:
                target += 1.
            else:
                target += .1
