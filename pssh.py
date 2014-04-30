#!/usr/bin/python

import pxssh
import pexpect
import os
from multiprocessing import Process, Queue

def pssh(hostname, username, password, cmd, queue):
    try:
        s = pxssh.pxssh()
        s.login(hostname, username, password)
        s.sendline(cmd)
        s.prompt()

    except (pexpect.EOF, Exception), e:
        print hostname, s.before
        queue.put([hostname, s.exitstatus])

if __name__ == '__main__':
    procs = []
    q = Queue()
    username = "root"
    password = "root"
    ipstart = 154
    ipend = 159
    cmd = 'service quantum-openvswitch-agent status; exit $?'

    for ip in range(ipstart, ipend):
        hostname = "10.145.88.%s" % ip
        p = Process(target=pssh, args=(hostname, username, password, cmd, q,))
        p.start()
        procs.append(p)

    for subproc in procs:
        subproc.join()

    fail = False
    while not q.empty():
        result = q.get()
        if result[1] == 1:
            if not fail:
                print "pxssh failed nodes list:"
                fail = True
            print result[0]

