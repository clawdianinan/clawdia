#!/bin/bash
# Fix for Python OpenMP crashes on macOS
# Set OMP environment variables before running Python

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export VECLIB_MAXIMUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

# Run the original Python command
exec python3 "$@"