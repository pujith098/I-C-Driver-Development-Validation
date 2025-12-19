#!/bin/bash
set -euo pipefail

LOG_DIR="logs/system"
mkdir -p "${LOG_DIR}"

dmesg > "${LOG_DIR}/dmesg.log" || true
journalctl -k --no-pager > "${LOG_DIR}/kernel.log" || true

