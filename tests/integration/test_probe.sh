#!/bin/bash
LOG=logs/integration/probe.log

i2cdetect -y 1 | tee $LOG

grep -q "27" $LOG || exit 1

