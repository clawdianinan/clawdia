#!/usr/bin/env python3
"""
OpenClaw Configuration Script for GPT-OSS:20B
Run this after the model download completes.
"""

import json
import os
import sys
from pathlib import Path

def backup_config(config_path):
    """Create a backup of the current configuration"""
    import time
    backup_path = f"{config_path}.backup.{int(time.time())}"
    print(f"Creating backup: {backup_path}")
    os.system(f"cp '{config_path}' '{backup_path}'")
    return backup_path

def update_openclaw_config():
    """Update OpenClaw configuration to include GPT-OSS"""
    config_path = Path.home() / ".openclaw" / "openclaw.json"
    
    if not config_path.exists():
        print(f"Error: Configuration file not found at {config_path}")
        return False
    
    # Create backup
    backup_path = backup_config(config_path)
    
    # Load configuration
    with open(config_path, 'r') as f:
        config = json.load(f)
    
    # Add Ollama provider if not exists
    if 'ollama' not in config['models']['providers']:
        config['models']['providers']['ollama'] = {
            'baseUrl': 'http://127.0.0.1:11434/v1',
            'apiKey': 'ollama',
            'api': 'openai-completions',
            'models': [
                {
                    'id': 'gpt-oss:20b',
                    'name': 'gpt-oss-20b'
                },
                {
                    'id': 'llama3.2:3b',
                    'name': 'llama3.2-3b'
                }
            ]
        }
        print("✓ Added Ollama provider configuration")
    else:
        print("✓ Ollama provider already exists, updating models...")
        # Ensure GPT-OSS is in the models list
        gpt_oss_exists = any(
            model.get('id') == 'gpt-oss:20b' 
            for model in config['models']['providers']['ollama'].get('models', [])
        )
        if not gpt_oss_exists:
            config['models']['providers']['ollama']['models'].append({
                'id': 'gpt-oss:20b',
                'name': 'gpt-oss-20b'
            })
            print("✓ Added GPT-OSS:20b to Ollama models")
    
    # Update fallbacks in agents.defaults.model.fallbacks
    if 'agents' in config and 'defaults' in config['agents']:
        fallbacks = config['agents']['defaults']['model']['fallbacks']
        
        # Check if GPT-OSS already in fallbacks
        gpt_oss_fallback = 'ollama/gpt-oss:20b'
        if gpt_oss_fallback not in fallbacks:
            # Insert after deepseek/deepseek-chat if it exists
            new_fallbacks = []
            inserted = False
            for fb in fallbacks:
                new_fallbacks.append(fb)
                if fb == 'deepseek/deepseek-chat' and not inserted:
                    new_fallbacks.append(gpt_oss_fallback)
                    inserted = True
                    print(f"✓ Added {gpt_oss_fallback} to fallbacks after deepseek")
            
            # If deepseek not found, add to beginning
            if not inserted:
                new_fallbacks.insert(0, gpt_oss_fallback)
                print(f"✓ Added {gpt_oss_fallback} to beginning of fallbacks")
            
            config['agents']['defaults']['model']['fallbacks'] = new_fallbacks
        else:
            print("✓ GPT-OSS already in fallbacks")
    else:
        print("⚠️ No agents.defaults found in configuration")
    
    # Write updated configuration
    with open(config_path, 'w') as f:
        json.dump(config, f, indent=2)
    
    print(f"\n✅ Configuration updated successfully")
    print(f"📁 Backup saved to: {backup_path}")
    
    return True

def test_ollama_connection():
    """Test if Ollama is running and GPT-OSS is available"""
    import subprocess
    import requests
    
    print("\n🔍 Testing Ollama connection...")
    
    # Check if Ollama is running
    try:
        response = requests.get('http://127.0.0.1:11434/api/tags', timeout=5)
        if response.status_code == 200:
            models = response.json().get('models', [])
            print(f"✓ Ollama is running (found {len(models)} models)")
            
            # Check for GPT-OSS
            gpt_oss_installed = any(
                model.get('name', '').startswith('gpt-oss') 
                for model in models
            )
            if gpt_oss_installed:
                print("✓ GPT-OSS is installed")
                return True
            else:
                print("⚠️ GPT-OSS not found in installed models")
                print("  Run: ollama list")
                return False
        else:
            print(f"⚠️ Ollama API returned status {response.status_code}")
            return False
    except requests.ConnectionError:
        print("❌ Cannot connect to Ollama. Is it running?")
        print("  Start with: ollama serve")
        return False
    except Exception as e:
        print(f"❌ Error testing Ollama: {e}")
        return False

def restart_openclaw():
    """Restart OpenClaw gateway to apply changes"""
    print("\n🔄 Restarting OpenClaw gateway...")
    result = os.system("openclaw gateway restart")
    if result == 0:
        print("✓ OpenClaw gateway restarted")
        return True
    else:
        print("⚠️ Failed to restart OpenClaw gateway")
        print("  You may need to restart it manually:")
        print("  openclaw gateway restart")
        return False

def main():
    print("=" * 60)
    print("OpenClaw GPT-OSS Configuration Script")
    print("=" * 60)
    
    # Step 1: Test Ollama connection
    if not test_ollama_connection():
        print("\n❌ Cannot proceed without Ollama connection")
        print("\nPlease ensure:")
        print("1. Ollama is running: ollama serve")
        print("2. GPT-OSS is downloaded: ollama pull gpt-oss:20b")
        print("3. Check with: ollama list")
        sys.exit(1)
    
    # Step 2: Update configuration
    print("\n📝 Updating OpenClaw configuration...")
    if not update_openclaw_config():
        print("❌ Failed to update configuration")
        sys.exit(1)
    
    # Step 3: Restart OpenClaw
    restart_openclaw()
    
    # Step 4: Final instructions
    print("\n" + "=" * 60)
    print("✅ Configuration Complete!")
    print("=" * 60)
    print("\nNext steps:")
    print("1. Test the configuration:")
    print("   openclaw chat --model ollama/gpt-oss:20b 'Hello, GPT-OSS!'")
    print("\n2. Check model availability:")
    print("   openclaw models list | grep -i gpt")
    print("\n3. Monitor usage in logs:")
    print("   tail -f ~/.openclaw/logs/gateway.log | grep -i ollama")
    print("\n4. The model will be used as a fallback after deepseek")
    print("   Primary: openai-codex/gpt-5.3-codex")
    print("   Fallback 1: deepseek/deepseek-chat")
    print("   Fallback 2: ollama/gpt-oss:20b (local, free)")
    print("\n5. To force use GPT-OSS:")
    print("   /model ollama/gpt-oss:20b")
    print("\nConfiguration file saved to:")
    print(f"   {Path.home() / '.openclaw' / 'workspace' / 'gpt-oss-openclaw-config.json'}")

if __name__ == "__main__":
    main()