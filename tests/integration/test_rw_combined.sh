#!/bin/bash
LOG=logs/integration/rw.log

for i in $(seq 1 500); do
  i2cset -y 1 0x27 0x01 >> $LOG
  i2cget -y 1 0x27 >> $LOG
done

