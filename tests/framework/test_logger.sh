#!/bin/bash
log_info() { echo "[INFO] $*"; }
log_success() { echo "[SUCCESS] $*"; }
log_error() { echo "[ERROR] $*" >&2; }
log_warning() { echo "[WARN] $*" >&2; }
log_test_start() { echo "[TEST START] $1"; }
log_test_pass() { echo "[PASS] ✓ $1"; }
log_test_fail() { echo "[FAIL] ✗ $1: $2" >&2; }
export -f log_info log_success log_error log_warning log_test_start log_test_pass log_test_fail
