#!/bin/bash

for FREQ in 100000 400000; do
  ./scripts/set_i2c_freq.sh $FREQ
  sleep 60
  ./tests/stress/i2c_stress_rw.sh
done

