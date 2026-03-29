#!/usr/bin/env python3
import json
import os
import sys

def replace_ollama_with_llamacpp(filepath):
    """Replace ollama provider with llama-cpp in a models.json file"""
    try:
        with open(filepath, 'r') as f:
            data = json.load(f)
        
        updated = False
        
        # Check if providers exists
        if 'providers' in data:
            # If ollama exists, replace it with llama-cpp
            if 'ollama' in data['providers']:
                print(f"Replacing ollama with llama-cpp in {filepath}")
                
                # Remove ollama
                del data['providers']['ollama']
                
                # Add llama-cpp if not already present
                if 'llama-cpp' not in data['providers']:
                    data['providers']['llama-cpp'] = {
                        "baseUrl": "http://127.0.0.1:31857",
                        "apiKey": "llama-cpp-local",
                        "api": "openai-completions",
                        "models": [
                            {
                                "id": "llama3.1:8b",
                                "name": "llama3.1:8b",
                                "reasoning": True,
                                "input": ["text"],
                                "cost": {
                                    "input": 0,
                                    "output": 0,
                                    "cacheRead": 0,
                                    "cacheWrite": 0
                                },
                                "contextWindow": 2048,
                                "maxTokens": 1024,
                                "api": "openai-completions"
                            }
                        ]
                    }
                    updated = True
                else:
                    print(f"  - llama-cpp already exists in {filepath}")
                    updated = True
            
        if updated:
            # Write back
            with open(filepath, 'w') as f:
                json.dump(data, f, indent=2)
            return True
        else:
            print(f"No ollama found in {filepath}")
            return False
            
    except json.JSONDecodeError as e:
        print(f"Error parsing {filepath}: {e}")
        # Try to fix common JSON issues
        try:
            with open(filepath, 'r') as f:
                content = f.read()
            
            # Fix common issues: trailing commas, missing quotes
            # Remove trailing commas before closing braces/brackets
            import re
            content = re.sub(r',\s*}', '}', content)
            content = re.sub(r',\s*]', ']', content)
            
            # Try to parse again
            data = json.loads(content)
            
            # Now process
            return replace_ollama_with_llamacpp_from_data(filepath, data)
        except:
            print(f"Could not fix {filepath}")
            return False
    except Exception as e:
        print(f"Error processing {filepath}: {e}")
        return False

def replace_ollama_with_llamacpp_from_data(filepath, data):
    """Process data that's already loaded"""
    updated = False
    
    if 'providers' in data:
        if 'ollama' in data['providers']:
            print(f"Replacing ollama with llama-cpp in {filepath} (repaired)")
            
            del data['providers']['ollama']
            
            if 'llama-cpp' not in data['providers']:
                data['providers']['llama-cpp'] = {
                    "baseUrl": "http://127.0.0.1:31857",
                    "apiKey": "llama-cpp-local",
                    "api": "openai-completions",
                    "models": [
                        {
                            "id": "llama3.1:8b",
                            "name": "llama3.1:8b",
                            "reasoning": True,
                            "input": ["text"],
                            "cost": {
                                "input": 0,
                                "output": 0,
                                "cacheRead": 0,
                                "cacheWrite": 0
                            },
                            "contextWindow": 2048,
                            "maxTokens": 1024,
                            "api": "openai-completions"
                        }
                    ]
                }
                updated = True
    
    if updated:
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2)
        return True
    
    return False

def main():
    # Find all models.json files
    agents_dir = "/Users/clawdia/.openclaw/agents"
    updated_count = 0
    error_count = 0
    
    # Process main agent first
    main_file = "/Users/clawdia/.openclaw/agents/main/agent/models.json"
    if os.path.exists(main_file):
        if replace_ollama_with_llamacpp(main_file):
            updated_count += 1
    
    # Process all other agents
    for agent in os.listdir(agents_dir):
        agent_dir = os.path.join(agents_dir, agent)
        if os.path.isdir(agent_dir):
            models_file = os.path.join(agent_dir, "agent", "models.json")
            if os.path.exists(models_file) and models_file != main_file:
                if replace_ollama_with_llamacpp(models_file):
                    updated_count += 1
    
    print(f"\nSummary:")
    print(f"  Updated {updated_count} files")
    print(f"  Errors: {error_count}")
    
    # Verify Trinity has llama-cpp
    print(f"\nVerifying Trinity config...")
    trinity_file = "/Users/clawdia/.openclaw/agents/Trinity/agent/models.json"
    if os.path.exists(trinity_file):
        with open(trinity_file, 'r') as f:
            data = json.load(f)
            if 'providers' in data and 'llama-cpp' in data['providers']:
                print("  ✅ Trinity has llama-cpp")
            else:
                print("  ❌ Trinity missing llama-cpp")
                
                # Add llama-cpp to Trinity
                if 'providers' not in data:
                    data['providers'] = {}
                data['providers']['llama-cpp'] = {
                    "baseUrl": "http://127.0.0.1:31857",
                    "apiKey": "llama-cpp-local",
                    "api": "openai-completions",
                    "models": [
                        {
                            "id": "llama3.1:8b",
                            "name": "llama3.1:8b",
                            "reasoning": True,
                            "input": ["text"],
                            "cost": {
                                "input": 0,
                                "output": 0,
                                "cacheRead": 0,
                                "cacheWrite": 0
                            },
                            "contextWindow": 2048,
                            "maxTokens": 1024,
                            "api": "openai-completions"
                        }
                    ]
                }
                with open(trinity_file, 'w') as f:
                    json.dump(data, f, indent=2)
                print("  ✅ Added llama-cpp to Trinity")

if __name__ == "__main__":
    main()