#!/usr/bin/python

import pxssh
import pexpect
import os
from time import time
from multiprocessing import Pool

def pssh((hostname, username, password, cmd)):
    try:
        s = pxssh.pxssh()
        s.login(hostname, username, password)
        s.sendline(cmd)
        s.prompt()
    except (pexpect.EOF, Exception), e:
        print hostname, s.before
        return [hostname, s.exitstatus]
    finally:
        s.close()

if __name__ == '__main__':
    failednodes = []
    starttime = time()
    pool = Pool(processes = 15)
    username = "root"
    password = "root123"
    net = "10.1.0"
    ipstart = 10
    ipend = 180
    cmd = 'service quantum-openvswitch-agent status'
    cmd += '; exit $?'
    res = pool.map_async(pssh, ((net+'.'+str(ip), username, password, cmd) for ip in range(ipstart, ipend)))
    result = res.get()
    for host in result:
        if host[1] != 0:
            failednodes.append(host[0])
    if failednodes:
        print "pxssh failed %s nodes as listed below:" % len(failednodes)
        for node in failednodes:
            print node
    print 'Time elapsed:', time() - starttime
