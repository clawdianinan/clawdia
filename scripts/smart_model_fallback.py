#!/usr/bin/env python3
"""
Smart Model Fallback System for OpenClaw

Purpose:
- Detect rate limit/usage limit errors from models
- Cache rate-limited models to prevent retries
- Implement intelligent fallback logic
- Provide model persistence within sessions

Features:
1. Rate limit detection (specific error patterns)
2. Model failure caching with TTL
3. Session-level model persistence
4. Automatic recovery when limits reset
"""

import json
import os
import re
import time
import sqlite3
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Tuple
from pathlib import Path

# Configuration
CACHE_TTL_HOURS = 24  # How long to remember rate-limited models
CACHE_FILE = os.path.expanduser("~/.openclaw/model_fallback_cache.json")
OPENCLAW_CONFIG = os.path.expanduser("~/.openclaw/openclaw.json")
SESSION_DB = os.path.expanduser("~/.openclaw/agents/main/sessions/sessions.json")

# Rate limit error patterns
RATE_LIMIT_PATTERNS = [
    r"insufficient permissions.*model\.request",
    r"rate limit",
    r"usage limit",
    r"quota.*exceeded",
    r"limit.*reached",
    r"too many requests",
    r"429",
    r"403.*limit",
    r"model.*not available",
]

# Model priority (from OpenClaw config)
MODEL_PRIORITY = [
    "openai-codex/gpt-5.3-codex",
    "deepseek/deepseek-chat", 
    "openrouter/stepfun/step-3.5-flash",
    "openrouter/minimax/minimax-m2.5",
    "llama-cpp/llama3.1:8b"
]

class ModelFallbackManager:
    def __init__(self):
        self.cache = self.load_cache()
        self.config = self.load_openclaw_config()
        self.sessions = self.load_sessions()
        
    def load_cache(self) -> Dict:
        """Load rate limit cache from file"""
        if os.path.exists(CACHE_FILE):
            try:
                with open(CACHE_FILE, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def save_cache(self):
        """Save rate limit cache to file"""
        with open(CACHE_FILE, 'w') as f:
            json.dump(self.cache, f, indent=2)
    
    def load_openclaw_config(self) -> Dict:
        """Load OpenClaw configuration"""
        if os.path.exists(OPENCLAW_CONFIG):
            try:
                with open(OPENCLAW_CONFIG, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def load_sessions(self) -> Dict:
        """Load session data"""
        if os.path.exists(SESSION_DB):
            try:
                with open(SESSION_DB, 'r') as f:
                    return json.load(f)
            except:
                return {}
        return {}
    
    def is_rate_limit_error(self, error_message: str) -> bool:
        """Check if error message indicates rate limit"""
        error_lower = error_message.lower()
        for pattern in RATE_LIMIT_PATTERNS:
            if re.search(pattern, error_lower):
                return True
        return False
    
    def record_model_failure(self, model_id: str, error_message: str, custom_retry_time: str = None):
        """Record model failure and check if it's rate limit"""
        if self.is_rate_limit_error(error_message):
            timestamp = datetime.now().isoformat()
            
            # Try to extract reset time from error message
            retry_after = None
            if custom_retry_time:
                try:
                    retry_after = datetime.fromisoformat(custom_retry_time).isoformat()
                except:
                    pass
            
            # If no custom time or parsing failed, use default TTL
            if not retry_after:
                retry_after = (datetime.now() + timedelta(hours=CACHE_TTL_HOURS)).isoformat()
            
            self.cache[model_id] = {
                "failed_at": timestamp,
                "error_type": "rate_limit",
                "error_message": error_message[:500],  # Truncate long messages
                "retry_after": retry_after
            }
            self.save_cache()
            
            # Calculate hours until retry
            retry_dt = datetime.fromisoformat(retry_after)
            hours_until = (retry_dt - datetime.now()).total_seconds() / 3600
            print(f"📛 Rate limit detected for {model_id}. Cached until {retry_dt.strftime('%Y-%m-%d %H:%M')} ({hours_until:.1f} hours).")
            return True
        return False
    
    def is_model_rate_limited(self, model_id: str) -> bool:
        """Check if model is currently rate-limited"""
        if model_id not in self.cache:
            return False
        
        cache_entry = self.cache[model_id]
        if cache_entry.get("error_type") != "rate_limit":
            return False
        
        # Check if retry time has passed
        retry_after_str = cache_entry.get("retry_after")
        if retry_after_str:
            try:
                retry_after = datetime.fromisoformat(retry_after_str)
                if datetime.now() < retry_after:
                    return True
                else:
                    # TTL expired, remove from cache
                    del self.cache[model_id]
                    self.save_cache()
                    return False
            except:
                # If date parsing fails, assume expired
                del self.cache[model_id]
                self.save_cache()
                return False
        
        return False
    
    def get_available_models(self) -> List[str]:
        """Get list of models that are not rate-limited"""
        available = []
        for model in MODEL_PRIORITY:
            if not self.is_model_rate_limited(model):
                available.append(model)
        return available
    
    def get_best_available_model(self) -> str:
        """Get the highest priority model that's not rate-limited"""
        available = self.get_available_models()
        if available:
            return available[0]
        # Fallback to DeepSeek if all else fails
        return "deepseek/deepseek-chat"
    
    def clear_rate_limit(self, model_id: str):
        """Manually clear rate limit for a model"""
        if model_id in self.cache:
            del self.cache[model_id]
            self.save_cache()
            print(f"✅ Cleared rate limit for {model_id}")
            return True
        return False
    
    def get_rate_limit_status(self) -> Dict:
        """Get current rate limit status"""
        status = {
            "timestamp": datetime.now().isoformat(),
            "rate_limited_models": [],
            "available_models": self.get_available_models(),
            "best_model": self.get_best_available_model()
        }
        
        for model_id, info in self.cache.items():
            if info.get("error_type") == "rate_limit":
                status["rate_limited_models"].append({
                    "model": model_id,
                    "failed_at": info.get("failed_at"),
                    "retry_after": info.get("retry_after"),
                    "error": info.get("error_message", "")[:100]
                })
        
        return status
    
    def monitor_session_errors(self, session_id: str):
        """Monitor a specific session for model errors"""
        # This would hook into OpenClaw's session monitoring
        # For now, it's a placeholder for future integration
        pass
    
    def create_fallback_config(self) -> Dict:
        """Create a modified OpenClaw config with smart fallbacks"""
        if not self.config:
            return {}
        
        config = self.config.copy()
        
        # Get available models in priority order
        available = self.get_available_models()
        
        if available:
            # Update model defaults
            if "agents" in config and "defaults" in config["agents"]:
                config["agents"]["defaults"]["model"]["primary"] = available[0]
                config["agents"]["defaults"]["model"]["fallbacks"] = available[1:]
        
        return config

def main():
    import argparse
    
    parser = argparse.ArgumentParser(description="Smart Model Fallback System")
    subparsers = parser.add_subparsers(dest="command", help="Commands")
    
    # Status command
    status_parser = subparsers.add_parser("status", help="Check rate limit status")
    
    # Record failure command
    record_parser = subparsers.add_parser("record", help="Record model failure")
    record_parser.add_argument("model", help="Model ID (e.g., openai-codex/gpt-5.3-codex)")
    record_parser.add_argument("error", help="Error message")
    record_parser.add_argument("--retry-after", help="Custom retry time (ISO format)", default=None)
    
    # Clear command
    clear_parser = subparsers.add_parser("clear", help="Clear rate limit for model")
    clear_parser.add_argument("model", help="Model ID to clear")
    
    # Best model command
    best_parser = subparsers.add_parser("best", help="Get best available model")
    
    # List command
    list_parser = subparsers.add_parser("list", help="List available models")
    
    args = parser.parse_args()
    
    manager = ModelFallbackManager()
    
    if args.command == "status":
        status = manager.get_rate_limit_status()
        print(json.dumps(status, indent=2))
    
    elif args.command == "record":
        is_rate_limit = manager.record_model_failure(args.model, args.error, args.retry_after)
        if is_rate_limit:
            print(f"✅ Recorded rate limit for {args.model}")
        else:
            print(f"⚠️  Recorded failure (not rate limit) for {args.model}")
    
    elif args.command == "clear":
        success = manager.clear_rate_limit(args.model)
        if success:
            print(f"✅ Cleared rate limit for {args.model}")
        else:
            print(f"⚠️  No rate limit found for {args.model}")
    
    elif args.command == "best":
        best = manager.get_best_available_model()
        print(best)
    
    elif args.command == "list":
        available = manager.get_available_models()
        print("Available models (in priority order):")
        for i, model in enumerate(available, 1):
            print(f"{i}. {model}")
    
    else:
        parser.print_help()

if __name__ == "__main__":
    main()