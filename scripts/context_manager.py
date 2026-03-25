#!/usr/bin/env python3
"""
Context Manager for AI Tools
Prevents context overflow by maintaining buffers and managing token usage.
"""

import os
import json
import re
from typing import Dict, List, Optional, Tuple

class ContextManager:
    """Manages context buffers to prevent overflow."""
    
    def __init__(self, max_context_fraction: float = 0.7):
        """
        Args:
            max_context_fraction: Maximum fraction of context to use (0.7 = 70%)
        """
        self.max_context_fraction = max_context_fraction
        self.context_usage = {}
        
    def estimate_tokens(self, text: str) -> int:
        """Rough token estimation (4 chars ≈ 1 token for English)."""
        return len(text) // 4
    
    def get_available_context(self, model: str, total_context: int) -> int:
        """Calculate available context based on model limits."""
        available = int(total_context * self.max_context_fraction)
        
        # Model-specific adjustments
        model_limits = {
            'gpt-5.3-codex': 128000,
            'claude-4.6-opus': 200000,
            'claude-4.6-sonnet': 200000,
            'gemini-3-pro': 1000000,
            'composer-2': 128000,
            'auto': 128000,  # Default for auto selection
        }
        
        if model in model_limits:
            total_context = model_limits[model]
            available = int(total_context * self.max_context_fraction)
        
        return available
    
    def trim_context(self, text: str, max_tokens: int, keep_important: bool = True) -> str:
        """Trim text to fit within token limit, preserving important parts."""
        tokens = self.estimate_tokens(text)
        
        if tokens <= max_tokens:
            return text
        
        if keep_important:
            # Keep important sections (code, errors, recent content)
            lines = text.split('\n')
            
            # Prioritize recent content (last 30%)
            keep_lines = int(len(lines) * 0.3)
            important = lines[-keep_lines:]
            
            # Add critical markers
            critical_sections = []
            for line in lines:
                if any(marker in line.lower() for marker in ['error:', 'fatal:', 'critical:', 'todo:', 'fix:', 'bug:']):
                    critical_sections.append(line)
            
            trimmed = important + critical_sections
            trimmed_text = '\n'.join(trimmed)
            
            # If still too long, truncate
            if self.estimate_tokens(trimmed_text) > max_tokens:
                return self.simple_truncate(trimmed_text, max_tokens)
            
            return trimmed_text
        else:
            return self.simple_truncate(text, max_tokens)
    
    def simple_truncate(self, text: str, max_tokens: int) -> str:
        """Simple truncation to token limit."""
        max_chars = max_tokens * 4
        if len(text) <= max_chars:
            return text
        
        # Try to cut at sentence/paragraph boundary
        truncated = text[:max_chars]
        
        # Find last reasonable break point
        last_period = truncated.rfind('. ')
        last_newline = truncated.rfind('\n\n')
        
        if last_newline > max_chars * 0.8:  # If we have a recent paragraph break
            return truncated[:last_newline] + "\n\n[CONTEXT TRIMMED...]"
        elif last_period > max_chars * 0.8:  # If we have a recent sentence break
            return truncated[:last_period + 1] + " [CONTEXT TRIMMED...]"
        else:
            return truncated + "... [CONTEXT TRIMMED]"
    
    def prepare_prompt(self, task: str, context: str, model: str = "auto") -> str:
        """Prepare a prompt with proper context management."""
        # Get available context
        available_tokens = self.get_available_context(model, 128000)  # Default 128K
        
        # Estimate task tokens
        task_tokens = self.estimate_tokens(task)
        
        # Calculate available for context
        context_budget = available_tokens - task_tokens - 1000  # Reserve for response
        
        if context_budget <= 0:
            # Task itself is too large
            return f"Task too large for context. Please simplify.\n\nTask: {task[:500]}..."
        
        # Trim context if needed
        if context:
            trimmed_context = self.trim_context(context, context_budget)
            
            # Check if we had to trim significantly
            original_tokens = self.estimate_tokens(context)
            trimmed_tokens = self.estimate_tokens(trimmed_context)
            
            if trimmed_tokens < original_tokens * 0.5:  # If we trimmed more than 50%
                warning = f"[WARNING: Context trimmed from {original_tokens} to {trimmed_tokens} tokens]\n\n"
                trimmed_context = warning + trimmed_context
            
            prompt = f"Context:\n{trimmed_context}\n\nTask: {task}"
        else:
            prompt = f"Task: {task}"
        
        return prompt
    
    def log_usage(self, model: str, prompt_tokens: int, total_context: int):
        """Log context usage for monitoring."""
        usage_percent = (prompt_tokens / total_context) * 100
        
        self.context_usage[model] = {
            'prompt_tokens': prompt_tokens,
            'total_context': total_context,
            'usage_percent': usage_percent,
            'safe_buffer': 100 - usage_percent
        }
        
        # Warn if approaching limit
        if usage_percent > (self.max_context_fraction * 100 * 0.9):  # 90% of our buffer
            print(f"⚠️  WARNING: {model} context usage at {usage_percent:.1f}% of buffer")
        
        return self.context_usage[model]

def main():
    """Test the context manager."""
    import sys
    
    if len(sys.argv) < 2:
        print("Usage: python context_manager.py <task> [context_file] [model]")
        print("Example: python context_manager.py 'Fix bug' context.txt gpt-5.3-codex")
        return
    
    task = sys.argv[1]
    context = ""
    model = "auto"
    
    if len(sys.argv) > 2:
        context_file = sys.argv[2]
        if os.path.exists(context_file):
            with open(context_file, 'r') as f:
                context = f.read()
    
    if len(sys.argv) > 3:
        model = sys.argv[3]
    
    manager = ContextManager(max_context_fraction=0.7)
    prompt = manager.prepare_prompt(task, context, model)
    
    print("=" * 80)
    print("PREPARED PROMPT (with context management):")
    print("=" * 80)
    print(prompt)
    print("=" * 80)
    
    # Show stats
    prompt_tokens = manager.estimate_tokens(prompt)
    available = manager.get_available_context(model, 128000)
    usage = manager.log_usage(model, prompt_tokens, 128000)
    
    print(f"\n📊 CONTEXT USAGE STATS:")
    print(f"  Model: {model}")
    print(f"  Prompt tokens: {prompt_tokens:,}")
    print(f"  Available buffer: {available:,} (70% of total)")
    print(f"  Usage: {usage['usage_percent']:.1f}% of buffer")
    print(f"  Safe buffer remaining: {usage['safe_buffer']:.1f}%")

if __name__ == "__main__":
    main()