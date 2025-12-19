#!/bin/bash
LOG=logs/fault/invalid_addr.log

i2cset -y 1 0x00 0xFF >> $LOG 2>&1 && exit 1
exit 0

