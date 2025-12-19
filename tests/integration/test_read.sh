#!/bin/bash
LOG=logs/integration/read.log

for i in $(seq 1 100); do
  i2cget -y 1 0x27 >> $LOG 2>&1 || exit 1
done

