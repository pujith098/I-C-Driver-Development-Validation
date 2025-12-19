#!/bin/bash
dmesg | tail -200 > logs/system/dmesg.log
journalctl -k | tail -200 >> logs/system/kernel.log

