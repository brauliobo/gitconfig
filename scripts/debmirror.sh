#### Start script to automate building of Ubuntu mirror #####
## THE NEXT LINE IS NEEDED THE REST OF THE LINES STARTING WITH A # CAN BE DELETED

#!/bin/bash

## Setting variables with explanations.

arch=i386

section=main
release=saucy,saucy-security,saucy-updates

server=br.archive.ubuntu.com
inPath=/ubuntu

proto=rsync

outPath=$HOME/mirror

# The --nosource option only downloads debs and not deb-src's
# The --progress option shows files as they are downloaded
# --source \ in the place of --no-source \ if you want sources also.
# --nocleanup  Do not clean up the local mirror after mirroring is complete. Use this option to keep older repository
# Start script
#
debmirror -a $arch \
  --no-source \
  --no-check-gpg \
  -s $section \
  -h $server \
  -d $release \
  -r $inPath \
  --progress \
  -e $proto \
  $outPath


#### End script to automate building of Ubuntu mirror ####
