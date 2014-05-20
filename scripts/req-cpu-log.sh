#!/bin/sh

echo ---
sar -u 1 1 | tail -n 3 | head -n 2
reqs-per-sec.sh -f 1 -l /var/log/apache2/noosfero.access.log
echo
echo ---
