import ingest

stop = 24

path = '/data/daq.crayfis.io/raw/2018/01/01/i-070d126bc6ed5e7c1/'

for hh in xrange(0,stop):
    ingest.from_tarfile( path + '{0:02}.tar.gz'.format(hh) )

