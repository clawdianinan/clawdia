#!/usr/bin/env python3
"""
Setup script for Context Manager skill
"""

import os
import json
from pathlib import Path

def setup_context_manager():
    """Setup context manager configuration and integration"""
    
    # Create config directory
    config_dir = Path.home() / ".openclaw" / "workspace" / "config"
    config_dir.mkdir(parents=True, exist_ok=True)
    
    # Create default configuration
    config = {
        "context_manager": {
            "enabled": True,
            "auto_compact": True,
            "auto_compact_threshold": 0.8,  # 80% utilization
            "default_strategy": "balanced",
            "archive_old_sessions": True,
            "archive_after_messages": 100,
            "monitor_tool_outputs": True,
            "max_tool_output_size": 5000,  # tokens
        }
    }
    
    config_file = config_dir / "context_manager.json"
    with open(config_file, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"Created configuration at: {config_file}")
    
    # Create integration script
    integration_script = """
#!/usr/bin/env python3
"""
    
    print("Context Manager setup complete!")
    print("\nTo use:")
    print("1. Import context_manager in your scripts")
    print("2. Use ContextManager class to analyze/compact sessions")
    print("3. Call compact_session() when context utilization is high")
    print("\nExample:")
    print("  from scripts.context_manager import ContextManager")
    print("  cm = ContextManager()")
    print("  compressed, stats = cm.compact_session(messages, strategy='balanced')")

if __name__ == "__main__":
    setup_context_manager()