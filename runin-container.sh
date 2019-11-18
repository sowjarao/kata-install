#!/bin/bash

#copy installation script to host
cp /install.sh /host

# Give execute priv to script
/usr/bin/nsenter -m/proc/1/ns/mnt -- chmod u+x /tmp/install/install.sh

# If the /tmp folder is mounted on the host then it can run the script
/usr/bin/nsenter -m/proc/1/ns/mnt /tmp/install/install.sh

# Sleep so that the Pod in the DaemonSet does not exit
sleep infinity
