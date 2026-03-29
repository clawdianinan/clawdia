#!/usr/bin/env python3
import json
import os
import sys

def remove_ollama_from_file(filepath):
    """Remove ollama provider from a models.json file"""
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
        
        # Check if providers exists and has ollama
        if 'providers' in data and 'ollama' in data['providers']:
            print(f"Removing ollama from {filepath}")
            
            # Remove ollama provider
            del data['providers']['ollama']
            
            # Write back
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=2)
            
            return True
        else:
            print(f"No ollama found in {filepath}")
            return False
            
    except json.JSONDecodeError as e:
        print(f"Error parsing {filepath}: {e}")
        return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def main():
    # Find all models.json files
    agents_dir = "/Users/clawdia/.openclaw/agents"
    updated_count = 0
    
    for root, dirs, files in os.walk(agents_dir):
        if 'models.json' in files:
            filepath = os.path.join(root, 'models.json')
            if remove_ollama_from_file(filepath):
                updated_count += 1
    
    print(f"\nUpdated {updated_count} files")
    
    # Also check main config
    main_config = "/Users/clawdia/.openclaw/openclaw.json"
    if os.path.exists(main_config):
        print(f"\nChecking main config: {main_config}")
        with open(main_config, 'r') as f:
            data = json.load(f)
        
        # Check models.providers
        if 'models' in data and 'providers' in data['models'] and 'ollama' in data['models']['providers']:
            print("WARNING: ollama found in main config models.providers")
        
        # Check agents.defaults.models
        if 'agents' in data and 'defaults' in data['agents']:
            defaults = data['agents']['defaults']
            if 'models' in defaults:
                ollama_models = [k for k in defaults['models'].keys() if k.startswith('ollama/')]
                if ollama_models:
                    print(f"WARNING: ollama models in agents.defaults.models: {ollama_models}")
            
            if 'model' in defaults and 'fallbacks' in defaults['model']:
                ollama_fallbacks = [m for m in defaults['model']['fallbacks'] if m.startswith('ollama/')]
                if ollama_fallbacks:
                    print(f"WARNING: ollama models in agents.defaults.model.fallbacks: {ollama_fallbacks}")

if __name__ == "__main__":
    main()