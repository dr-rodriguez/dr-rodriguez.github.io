#!/usr/bin/python

import sys
from sampy import *
#hub = SAMPHubServer()
#hub.start()

ra = sys.argv[1]
dec = sys.argv[2]

hub = SAMPIntegratedClient(metadata = {"samp.name":"Python SAMPy"})
hub.connect()
id = hub.getPublicId()

script="reset; get aladin,simbad " + ra + " " + dec
print script

hub.callAll("script.aladin.send", {"samp.mtype": "script.aladin.send", "samp.params":{"script":script}})

hub.disconnect()

""""
In TOPCAT
Adding a column runme as:
concat("aladinvo.py ",toString(_RAJ2000)," ",toString(_DEJ2000))
or
concat("aladinvo.py ",toString(ucd$pos_eq_ra)," ",toString(ucd$pos_eq_dec))
and then setting the Activation Action to:
exec(runme)
will work
"""



