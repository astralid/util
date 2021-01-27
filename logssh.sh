#!/bin/sh
LOGFILE=$1
TRG_SRV=$2

echo "\n\nTIMESTAMP: $(date)\n" >> $LOGFILE
ssh -o ClearAllForwardings=yes $TRG_SRV | tee -a $LOGFILE
