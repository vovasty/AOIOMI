#! /usr/bin/env python

from __future__ import print_function
import sys
from iosCertTrustManager import simulators, Certificate, TrustStore

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)

def main():
    if len(sys.argv) != 3:
        eprint(sys.argv[0] + " " + "simulator name" + " " + "certificate path")
        exit(1)

    simulator_name = sys.argv[1]
    certificate_filepath = sys.argv[2]
    simulator = None

    for candidate in simulators():
        if candidate.title.startswith(simulator_name + " "):
            simulator = candidate
            break
    
    if simulator is None:
        eprint(simulator_name + " not found")
        exit(1)
    
    cert = Certificate()
    cert.load_PEMfile(certificate_filepath)
    tstore = TrustStore(simulator.truststore_file)
    tstore.add_certificate(cert)
    
    
if __name__ == "__main__":
    main()