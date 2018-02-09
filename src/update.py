import ingest
import os


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
for file in tarfiles:
    print file
#    if ingested_dir has tarfile, 
#        continue
#    ingest.from_tarfile( path + '{0:02}.tar.gz'.format(hh) )
