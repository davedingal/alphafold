import sys
import http.client
import time
import getopt

threshold_mb = 10
one_megabyte = 1048576

use_ssl = False
uri = None
host = None

try:
  arguments, values = getopt.getopt(sys.argv[1:], 'h:', ['uri=', 'ssl'])

  for arg, value in arguments:
    if (arg == '-h'):
      host = value

    if (arg == '--ssl'):
      use_ssl = True

    if (arg == '--uri'):
      uri = value

except getopt.error as err:
  sys.stderr.write('Unable to parse arguments: %s\n', str(err))
  quit(1)

if (use_ssl == True):
  h1 = http.client.HTTPSConnection(host, 443)
else:
  h1 = http.client.HTTPConnection(host, 80)

received_length = 0
next_threshold = one_megabyte * threshold_mb
finished = False
start = time.time()

while finished == False:
  h1.request('GET', uri, body=None, headers = {'Range': 'bytes=' + str(received_length) + '-'})
  res1 = h1.getresponse()
  sys.stderr.write('HTTP status code is %d\n' % res1.status)
  if res1.status != 206:
    sys.stderr.write('Unable to continue.  This server might not support the range header.\n')
    quit(1)

  total_length = res1.getheader('Content-Length')
  if (total_length != None):
    sys.stderr.write('Processing response.  Total size %.3f GB\n' % (float(total_length) / (one_megabyte * 1024)))
  else:
    sys.stderr.write('Processing response.  Total size is unknown\n')

  while 1:
    try:
      data = res1.read(65535)
    except:
      sys.stderr.write('Connection ended while reading data.  Breaking out to pickup where we left off.\n')
      break

    if (len(data) <= 0):
      finished = True
      break

    sys.stdout.buffer.write(data)

    received_length += len(data)
    if (received_length > next_threshold):
      end = time.time()
      sys.stderr.write('Received %.3f MB in totoal.  %.3f MB/s\n' % (received_length / one_megabyte, threshold_mb / (end - start)))
      start = time.time()
      next_threshold += one_megabyte * threshold_mb
