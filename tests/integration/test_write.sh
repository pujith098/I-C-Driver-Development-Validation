#!/bin/bash
LOG=logs/integration/write.log

for i in $(seq 1 100); do
  i2cset -y 1 0x27 0x80 >> $LOG 2>&1 || exit 1
done

