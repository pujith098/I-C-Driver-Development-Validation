#!/bin/bash
LOG=logs/stress/rw_stress.log
FAIL=0

for i in $(seq 1 10000); do
  i2cset -y 1 0x27 0xAA >> $LOG 2>&1 || FAIL=1
done

[ $FAIL -eq 0 ] || exit 1

