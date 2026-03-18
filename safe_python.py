#!/usr/bin/env python3
"""
Safe Python wrapper that sets OpenMP environment variables
to prevent crashes on macOS with Python 3.14
"""

import os
import sys
import subprocess

def main():
    # Set OpenMP environment variables
    os.environ['OMP_NUM_THREADS'] = '1'
    os.environ['OPENBLAS_NUM_THREADS'] = '1'
    os.environ['MKL_NUM_THREADS'] = '1'
    os.environ['VECLIB_MAXIMUM_THREADS'] = '1'
    os.environ['NUMEXPR_NUM_THREADS'] = '1'
    
    # Import torch early to initialize OpenMP with single thread
    try:
        import torch
        torch.set_num_threads(1)
        print("✓ PyTorch initialized with single thread", file=sys.stderr)
    except ImportError:
        pass
    
    # Run the actual Python script
    if len(sys.argv) > 1:
        script = sys.argv[1]
        args = sys.argv[2:]
        
        # Read and execute the script
        with open(script, 'r') as f:
            code = f.read()
        
        # Create a new namespace
        namespace = {
            '__name__': '__main__',
            '__file__': script
        }
        
        # Execute the script
        exec(code, namespace)
    else:
        print("Usage: safe_python.py <script.py> [args...]", file=sys.stderr)
        sys.exit(1)

if __name__ == '__main__':
    main()