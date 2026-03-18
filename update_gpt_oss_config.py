#!/usr/bin/env python3
"""
Update OpenClaw configuration to add GPT-OSS and Qwen 2.5 Coder as Ollama models.
"""

import json
import sys
import os
from datetime import datetime

def backup_config(config_path):
    """Create a backup of the current config."""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    backup_path = f"{config_path}.backup.{timestamp}"
    
    try:
        with open(config_path, 'r') as f:
            config_data = f.read()
        
        with open(backup_path, 'w') as f:
            f.write(config_data)
        
        print(f"✓ Backup created: {backup_path}")
        return True
    except Exception as e:
        print(f"✗ Backup failed: {e}")
        return False

def update_config(config_path):
    """Update the OpenClaw configuration."""
    try:
        with open(config_path, 'r') as f:
            config = json.load(f)
        
        print("✓ Current configuration loaded")
        
        # Add Ollama provider if not exists
        if 'models' not in config:
            config['models'] = {'providers': {}}
        
        if 'providers' not in config['models']:
            config['models']['providers'] = {}
        
        # Add Ollama provider configuration
        ollama_config = {
            'baseUrl': 'http://127.0.0.1:11434/v1',
            'apiKey': 'ollama',
            'api': 'openai-completions',
            'models': [
                {
                    'id': 'gpt-oss:20b',
                    'name': 'gpt-oss-20b'
                },
                {
                    'id': 'qwen2.5-coder:14b',
                    'name': 'qwen2.5-coder-14b'
                }
            ]
        }
        
        config['models']['providers']['ollama'] = ollama_config
        print("✓ Ollama provider added with GPT-OSS:20B and Qwen 2.5 Coder:14B")
        
        # Update fallbacks in agents.defaults.model
        if 'agents' in config and 'defaults' in config['agents']:
            if 'model' in config['agents']['defaults']:
                fallbacks = config['agents']['defaults']['model'].get('fallbacks', [])
                
                # Remove any existing ollama entries to avoid duplicates
                new_fallbacks = [fb for fb in fallbacks if not fb.startswith('ollama/')]
                
                # Add ollama models as last fallbacks
                new_fallbacks.append('ollama/gpt-oss:20b')
                new_fallbacks.append('ollama/qwen2.5-coder:14b')
                
                config['agents']['defaults']['model']['fallbacks'] = new_fallbacks
                print(f"✓ Fallbacks updated: {new_fallbacks}")
            else:
                print("⚠ No model configuration found in agents.defaults")
        else:
            print("⚠ No agents.defaults configuration found")
        
        # Write updated config
        with open(config_path, 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"✓ Configuration updated successfully: {config_path}")
        return True
        
    except Exception as e:
        print(f"✗ Configuration update failed: {e}")
        return False

def main():
    config_path = "/Users/clawdia/.openclaw/openclaw.json"
    
    if not os.path.exists(config_path):
        print(f"✗ Config file not found: {config_path}")
        return False
    
    print(f"Updating OpenClaw configuration at: {config_path}")
    print("-" * 50)
    
    # Create backup
    if not backup_config(config_path):
        print("⚠ Continuing without backup...")
    
    # Update config
    if update_config(config_path):
        print("-" * 50)
        print("✅ Configuration update complete!")
        print("\nNext steps:")
        print("1. Wait for GPT-OSS download to complete")
        print("2. Restart OpenClaw gateway: openclaw gateway restart")
        print("3. Test with: openclaw chat --model ollama/gpt-oss:20b 'Hello'")
        return True
    else:
        return False

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)