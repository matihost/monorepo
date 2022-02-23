#!/usr/bin/env python
"""
Import API proxy into Apigee and retrieving API proxy deployments.

A fork of https://github.com/apigee/api-platform-samples/blob/master/tools/deploy.py
limited to importing API proxy only and updated to Python3

To debug under VS Code:

Add Run and Debug configuration (https://code.visualstudio.com/docs/python/debugging):
{
  "name": "Python: Attach",
  "type": "python",
  "request": "attach",
  "connect": {
    "host": "localhost",
    "port": 5678
  }
}

And run app with:

python -m debugpy --listen 5678 --wait-for-client ./uploadApiProxy.py -n echoserver \
  -e dev-1 -t `gcloud auth print-access-token` -o `gcloud config get-value project` -d src/echoserver
"""
import getopt
import http.client
import json
import re
import os
import sys
import io
import urllib.parse
import zipfile


def httpCall(verb, uri, headers, body):
    """Call Apigee API endpoint."""
    if httpScheme == 'https':
        conn = http.client.HTTPSConnection(httpHost)
    else:
        conn = http.client.HTTPConnection(httpHost)

    hdrs = dict() if headers is None else headers

    hdrs['Authorization'] = 'Bearer %s' % Token
    conn.request(verb, uri, body, hdrs)

    return conn.getresponse()


def pathContainsDot(p):
    """
    Check whether path contains a dot.

    Return TRUE if any component of the file path contains a directory name that
    starts with a "." like '.svn', but not '.' or '..'.
    """
    c = re.compile(r'\.\w+')

    for pc in p.split('/'):
        if c.match(pc) is not None:
            return True

    return False


def getDeployments():
    """Print info about proxy deployments."""
    hdrs = {'Accept': 'application/json'}
    resp = httpCall('GET', '/v1/organizations/%s/apis/%s/deployments' % (Organization, Name), hdrs, None)

    if resp.status != 200:
        return None

    ret = list()
    parsed_response = json.load(resp)
    if 'deployments' in parsed_response:
        deployments = parsed_response['deployments']
        for deployment in deployments:
            envName = deployment['environment']
            revNum = deployment['revision']
            deployStartTime = deployment['deployStartTime']
            status = {'environment': envName, 'revision': revNum, 'deployStartTime': deployStartTime}
            ret.append(status)
    return ret


def printDeployments(dep):
    """Print proxy deployment on the screen."""
    for d in dep:
        print(('Environment: %s' % d['environment']))
        print(('  Revision: %s DeploymentStartTime = %s' % (d['revision'], d['deployStartTime'])))


ApigeeHost = 'https://apigee.googleapis.com'
Token = None
Directory = None
Organization = None
Environment = None
Name = None
BasePath = '/'

Options = 'n:o:h:d:e:t:z:'

opts = getopt.getopt(sys.argv[1:], Options)[0]

for o in opts:
    if o[0] == '-n':
        Name = o[1]
    elif o[0] == '-o':
        Organization = o[1]
    elif o[0] == '-h':
        ApigeeHost = o[1]
    elif o[0] == '-d':
        Directory = o[1]
    elif o[0] == '-e':
        Environment = o[1]
    elif o[0] == '-t':
        Token = o[1]
    elif o[0] == '-z':
        ZipFile = o[1]

if Token is None or \
        (Directory is None and ZipFile is None) or \
        Environment is None or \
        Name is None or \
        Organization is None:
    print("""Usage: uploadNewRevision -n [name] (-d [directory name] | -z [zipfile])
              -e [environment] -t [token] -o [organization]
    """)
    sys.exit(1)

url = urllib.parse.urlparse(ApigeeHost)
httpScheme = url[0]
httpHost = url[1]

body = None

if Directory is not None:
    # Construct a ZIPped copy of the bundle in memory
    tf = io.BytesIO()
    zipout = zipfile.ZipFile(tf, 'w')

    dirList = os.walk(Directory)
    for dirEntry in dirList:
        if not pathContainsDot(dirEntry[0]):
            for fileEntry in dirEntry[2]:
                if not fileEntry.endswith('~'):
                    fn = os.path.join(dirEntry[0], fileEntry)
                    en = os.path.join(os.path.relpath(dirEntry[0], Directory), fileEntry)
                    zipout.write(fn, en)

    zipout.close()
    body = tf.getvalue()
elif ZipFile is not None:
    f = open(ZipFile, 'r')
    body = f.read()
    f.close()

# Upload the bundle to the API
hdrs = {'Content-Type': 'application/octet-stream',
        'Accept': 'application/json'}
uri = '/v1/organizations/%s/apis?action=import&name=%s' % (Organization, Name)
resp = httpCall('POST', uri, hdrs, body)

if resp.status != 200 and resp.status != 201:
    print('Import failed to %s with status %i:\n%s' % (uri, resp.status, resp.read()))
    sys.exit(2)

deployment = json.load(resp)
revision = int(deployment['revision'])

print(('Imported new proxy version %i' % revision))

deps = getDeployments()
printDeployments(deps)
