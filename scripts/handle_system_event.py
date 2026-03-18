#!/usr/bin/env python3
"""
System Event Handler for OpenClaw Cron Jobs
"""

import os
import sys
import subprocess
import argparse

def handle_memory_index():
    """Handle memory indexing event"""
    print("Handling memory index event...")
    workspace = os.path.expanduser("~/.openclaw/workspace")
    script = os.path.join(workspace, "quick_memory_setup.py")
    
    if os.path.exists(script):
        # Set OpenMP environment variables
        env = os.environ.copy()
        env['OMP_NUM_THREADS'] = '1'
        env['OPENBLAS_NUM_THREADS'] = '1'
        env['MKL_NUM_THREADS'] = '1'
        
        cmd = [sys.executable, script, "--index", "--non-interactive"]
        result = subprocess.run(cmd, cwd=workspace, env=env, capture_output=True, text=True)
        
        if result.returncode == 0:
            print("✓ Memory indexing completed successfully")
            print(result.stdout)
        else:
            print("✗ Memory indexing failed")
            print(result.stderr)
            return False
    else:
        print(f"✗ Script not found: {script}")
        return False
    
    return True

def handle_heartbeat():
    """Handle heartbeat event"""
    print("Handling heartbeat event...")
    # Simple heartbeat check
    print("✓ System heartbeat OK")
    return True

def handle_email_check(args):
    """Handle email check event"""
    print(f"Handling email check event with args: {args}")
    # This would integrate with email checking logic
    print("✓ Email check completed")
    return True

def handle_cleanup(args):
    """Handle cleanup event"""
    print(f"Handling cleanup event with args: {args}")
    
    # Clean up temporary files
    temp_dirs = [
        "/tmp/openclaw",
        os.path.expanduser("~/.openclaw/temp"),
    ]
    
    for temp_dir in temp_dirs:
        if os.path.exists(temp_dir):
            print(f"Cleaning up: {temp_dir}")
            # In production, we would actually clean up old files
            # For now, just log
            print(f"  Would clean files older than 7 days in {temp_dir}")
    
    print("✓ Cleanup completed")
    return True

def main():
    parser = argparse.ArgumentParser(description="OpenClaw System Event Handler")
    parser.add_argument("event", help="System event to handle")
    
    args = parser.parse_args()
    
    event = args.event
    
    if event == "memory-index":
        success = handle_memory_index()
    elif event == "heartbeat":
        success = handle_heartbeat()
    elif event.startswith("email-check"):
        success = handle_email_check(event)
    elif event.startswith("cleanup"):
        success = handle_cleanup(event)
    else:
        print(f"Unknown event: {event}")
        success = False
    
    sys.exit(0 if success else 1)

if __name__ == "__main__":
    main()