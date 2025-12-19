#!/bin/bash
for i in {1..50}; do
    i2cdetect -y 1 > /dev/null
done
echo "Stress test completed"

