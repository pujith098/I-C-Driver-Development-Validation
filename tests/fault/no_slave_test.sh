#!/bin/bash
LOG=logs/fault/no_slave.log

i2cset -y 1 0x55 0xAA >> $LOG 2>&1 && exit 1
exit 0

