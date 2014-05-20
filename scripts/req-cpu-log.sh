#!/bin/sh

echo ---
date +%H:%M:%S
sar -u 1 1
reqs-per-sec.sh -f 1 -l /var/log/apache2/noosfero.access.log
echo ---
