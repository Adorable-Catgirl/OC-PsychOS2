#!/bin/bash
for f in service/*; do
 nf=$(echo $f | cut -d '/' -f 2)
 echo $nf
 echo os.spawn\(function\(\) >mod-service/$nf
 cat $f >> mod-service/$nf
 echo end,\"$nf\"\) >> mod-service/$nf
done
