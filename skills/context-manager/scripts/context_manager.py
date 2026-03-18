#!/usr/bin/env python3
"""
Context Manager - Intelligent chat history compression for OpenClaw
"""

import json
import re
import sys
import os
from datetime import datetime
from typing import Dict, List, Any, Optional, Tuple
from pathlib import Path

class ContextManager:
    """Main context management class"""
    
    def __init__(self, session_data: Optional[Dict] = None):
        self.session_data = session_data or {}
        self.config = self.load_config()
        
    def load_config(self) -> Dict:
        """Load configuration from file or defaults"""
        config_path = Path.home() / ".openclaw" / "workspace" / "context_manager_config.json"
        
        default_config = {
            "compression": {
                "strategy": "balanced",  # balanced, aggressive, conservative
                "target_utilization": 0.75,  # 75%
                "preserve_critical": True,
                "summarize_older_than": 20,  # messages
                "archive_complete_after": 100,  # messages
                "max_tokens_per_message": 1000,
            },
            "scoring": {
                "critical_multiplier": 3.0,
                "important_multiplier": 2.0,
                "recency_decay": 0.95,  # per message
                "tool_output_penalty": 0.7,
                "code_block_penalty": 0.6,
                "file_content_penalty": 0.5,
            },
            "model_limits": {
                "default": 8000,
                "gpt-4": 8000,
                "gpt-4-32k": 32768,
                "gpt-4-128k": 131072,
                "claude-3-opus": 200000,
                "claude-3-sonnet": 200000,
                "llama-2": 4096,
                "llama-3": 8192,
                "deepseek-chat": 32768,
            },
            "preserve_patterns": [
                r"DECISION:",
                r"RESULT:",
                r"TODO:",
                r"ERROR:",
                r"WARNING:",
                r"CRITICAL:",
                r"@\w+",  # mentions
                r"\[\[reply_to",  # reply tags
            ],
            "compress_patterns": [
                r"```.*?```",  # code blocks
                r"<file.*?>.*?</file>",  # file contents
                r"Search results:.*",  # search results
                r"Tool output:.*",  # tool outputs
                r"Running command:.*",  # command outputs
            ],
            "remove_patterns": [
                r"^\s*$",  # empty lines
                r"^NO_REPLY$",  # silent replies
                r"^HEARTBEAT_OK$",  # heartbeat acks
            ]
        }
        
        if config_path.exists():
            try:
                with open(config_path, 'r') as f:
                    user_config = json.load(f)
                    # Merge with defaults
                    self.merge_configs(default_config, user_config)
            except Exception as e:
                print(f"Warning: Could not load config from {config_path}: {e}")
        
        return default_config
    
    def merge_configs(self, base: Dict, update: Dict) -> None:
        """Recursively merge update into base config"""
        for key, value in update.items():
            if key in base and isinstance(base[key], dict) and isinstance(value, dict):
                self.merge_configs(base[key], value)
            else:
                base[key] = value
    
    def estimate_tokens(self, text: str) -> int:
        """Simple token estimation (4 chars per token approx)"""
        # This is a rough estimate - real tokenization would be better
        return len(text) // 4
    
    def score_message(self, message: Dict, index: int, total_messages: int) -> float:
        """Score a message based on importance factors"""
        score = 1.0
        
        # Apply recency decay
        recency_factor = self.config["scoring"]["recency_decay"] ** (total_messages - index - 1)
        score *= recency_factor
        
        # Check message type
        content = message.get("content", "")
        role = message.get("role", "")
        
        # Critical messages (system, user instructions)
        if role == "system":
            score *= self.config["scoring"]["critical_multiplier"]
        elif role == "user" and any(pattern in content.lower() for pattern in ["please", "need", "should", "must", "important"]):
            score *= self.config["scoring"]["important_multiplier"]
        
        # Check for preserve patterns
        for pattern in self.config["preserve_patterns"]:
            if re.search(pattern, content, re.IGNORECASE | re.DOTALL):
                score *= self.config["scoring"]["critical_multiplier"]
                break
        
        # Penalize large tool outputs and code blocks
        if "tool" in content.lower() or "```" in content:
            # Estimate size penalty
            tokens = self.estimate_tokens(content)
            if tokens > 500:
                penalty = self.config["scoring"]["tool_output_penalty"]
                score *= penalty
        
        # Check for compress patterns
        for pattern in self.config["compress_patterns"]:
            if re.search(pattern, content, re.IGNORECASE | re.DOTALL):
                # These should be compressed, not removed
                score *= 0.8  # Slight penalty to encourage compression
                break
        
        # Check for remove patterns
        for pattern in self.config["remove_patterns"]:
            if re.fullmatch(pattern, content.strip()):
                score = 0.0  # Mark for removal
                break
        
        return score
    
    def compress_message(self, message: Dict, strategy: str = "balanced") -> Dict:
        """Compress a single message based on strategy"""
        content = message.get("content", "")
        role = message.get("role", "")
        
        if strategy == "conservative":
            # Minimal compression
            return message
        
        elif strategy == "balanced":
            # Moderate compression
            compressed = message.copy()
            
            # Compress code blocks (keep first and last few lines)
            if "```" in content:
                lines = content.split('\n')
                in_code_block = False
                code_block_lines = []
                result_lines = []
                
                for line in lines:
                    if line.strip().startswith("```"):
                        in_code_block = not in_code_block
                        result_lines.append(line)
                        if not in_code_block and code_block_lines:
                            # Keep first 10 and last 5 lines of code block
                            if len(code_block_lines) > 20:
                                kept = code_block_lines[:10] + ["...", f"[{len(code_block_lines) - 15} lines compressed]"] + code_block_lines[-5:]
                                result_lines.extend(kept)
                            else:
                                result_lines.extend(code_block_lines)
                            code_block_lines = []
                    elif in_code_block:
                        code_block_lines.append(line)
                    else:
                        result_lines.append(line)
                
                compressed["content"] = '\n'.join(result_lines)
            
            # Truncate very long lines
            lines = compressed["content"].split('\n')
            truncated_lines = []
            for line in lines:
                if len(line) > 200:
                    truncated_lines.append(line[:197] + "...")
                else:
                    truncated_lines.append(line)
            compressed["content"] = '\n'.join(truncated_lines)
            
            return compressed
        
        elif strategy == "aggressive":
            # Aggressive compression
            compressed = message.copy()
            
            # Remove empty lines and excessive whitespace
            lines = [line.strip() for line in content.split('\n') if line.strip()]
            compressed["content"] = ' '.join(lines)
            
            # Truncate if still too long
            if len(compressed["content"]) > 500:
                compressed["content"] = compressed["content"][:497] + "..."
            
            return compressed
        
        return message
    
    def analyze_session(self, messages: List[Dict], model: str = "default") -> Dict:
        """Analyze session for compression opportunities"""
        model_limit = self.config["model_limits"].get(model, self.config["model_limits"]["default"])
        
        total_tokens = 0
        scored_messages = []
        
        for i, msg in enumerate(messages):
            tokens = self.estimate_tokens(msg.get("content", ""))
            score = self.score_message(msg, i, len(messages))
            
            scored_messages.append({
                "index": i,
                "role": msg.get("role", ""),
                "tokens": tokens,
                "score": score,
                "content_preview": msg.get("content", "")[:100] + ("..." if len(msg.get("content", "")) > 100 else "")
            })
            
            total_tokens += tokens
        
        utilization = total_tokens / model_limit
        
        # Sort by score (lowest first for removal)
        scored_messages.sort(key=lambda x: x["score"])
        
        return {
            "total_messages": len(messages),
            "total_tokens": total_tokens,
            "model_limit": model_limit,
            "utilization": utilization,
            "scored_messages": scored_messages,
            "needs_compression": utilization > self.config["compression"]["target_utilization"]
        }
    
    def compact_session(self, messages: List[Dict], strategy: str = None, 
                       target_utilization: float = None) -> Tuple[List[Dict], Dict]:
        """Compact a session based on strategy"""
        if strategy is None:
            strategy = self.config["compression"]["strategy"]
        if target_utilization is None:
            target_utilization = self.config["compression"]["target_utilization"]
        
        analysis = self.analyze_session(messages)
        
        if not analysis["needs_compression"] and strategy != "force":
            return messages, {"action": "none", "reason": "Below target utilization"}
        
        # Score all messages
        scored = []
        for i, msg in enumerate(messages):
            score = self.score_message(msg, i, len(messages))
            scored.append((score, i, msg))
        
        # Sort by score (lowest first)
        scored.sort(key=lambda x: x[0])
        
        compressed_messages = []
        removed_indices = []
        compressed_indices = []
        
        current_tokens = 0
        target_tokens = analysis["model_limit"] * target_utilization
        
        # Keep high-scoring messages, compress/remove low-scoring ones
        for score, idx, msg in scored:
            msg_tokens = self.estimate_tokens(msg.get("content", ""))
            
            if score == 0.0:
                # Marked for removal
                removed_indices.append(idx)
                continue
            
            # Check if we need to compress due to token limit
            if current_tokens + msg_tokens > target_tokens:
                if strategy in ["aggressive", "force"]:
                    # Remove low-scoring messages
                    if score < 0.5:
                        removed_indices.append(idx)
                        continue
                
                # Compress the message
                compressed_msg = self.compress_message(msg, strategy)
                compressed_tokens = self.estimate_tokens(compressed_msg.get("content", ""))
                
                if current_tokens + compressed_tokens <= target_tokens or strategy == "force":
                    compressed_messages.append(compressed_msg)
                    current_tokens += compressed_tokens
                    compressed_indices.append(idx)
                else:
                    removed_indices.append(idx)
            else:
                compressed_messages.append(msg)
                current_tokens += msg_tokens
        
        # Sort compressed messages back to original order
        compressed_messages.sort(key=lambda x: messages.index(x) if x in messages else len(messages))
        
        stats = {
            "action": "compressed",
            "original_messages": len(messages),
            "compressed_messages": len(compressed_messages),
            "removed_count": len(removed_indices),
            "compressed_count": len(compressed_indices),
            "original_tokens": analysis["total_tokens"],
            "compressed_tokens": current_tokens,
            "reduction_percent": ((analysis["total_tokens"] - current_tokens) / analysis["total_tokens"]) * 100 if analysis["total_tokens"] > 0 else 0,
            "removed_indices": removed_indices,
            "compressed_indices": compressed_indices,
            "strategy": strategy,
            "timestamp": datetime.now().isoformat()
        }
        
        return compressed_messages, stats
    
    def create_summary(self, messages: List[Dict], max_length: int = 500) -> str:
        """Create a summary of compressed messages for archival"""
        summary_lines = []
        
        # Extract key information
        for msg in messages[-10:]:  # Last 10 messages
            role = msg.get("role", "")
            content = msg.get("content", "")[:200]
            
            if role == "user":
                summary_lines.append(f"User: {content}")
            elif role == "assistant":
                # Look for actions/results
                if any(keyword in content.lower() for keyword in ["created", "updated", "result", "error", "decision"]):
                    summary_lines.append(f"Assistant: {content[:150]}")
        
        summary = "\n".join(summary_lines)
        
        if len(summary) > max_length:
            summary = summary[:max_length-3] + "..."
        
        return summary
    
    def archive_session(self, messages: List[Dict], session_id: str, summary: str = None) -> str:
        """Archive session to memory file"""
        if summary is None:
            summary = self.create_summary(messages)
        
        timestamp = datetime.now().strftime("%Y-%m-%d-%H%M")
        archive_dir = Path.home() / ".openclaw" / "workspace" / "memory" / "archived_sessions"
        archive_dir.mkdir(parents=True, exist_ok=True)
        
        archive_file = archive_dir / f"session_{session_id}_{timestamp}.json"
        
        archive_data = {
            "session_id": session_id,
            "timestamp": timestamp,
            "summary": summary,
            "message_count": len(messages),
            "messages": messages[-50:],  # Keep last 50 messages
            "full_archive_path": str(archive_file)
        }
        
        with open(archive_file, 'w') as f:
            json.dump(archive_data, f, indent=2)
        
        # Create reference in MEMORY.md
        memory_file = Path.home() / ".openclaw" / "workspace" / "MEMORY.md"
        if memory_file.exists():
            with open(memory_file, 'a') as f:
                f.write(f"\n## Archived Session {timestamp}\n")
                f.write(f"- Session: {session_id}\n")
                f.write(f"- Summary: {summary}\n")
                f.write(f"- Archive: {archive_file}\n")
        
        return str(archive_file)


def main():
    """Command-line interface"""
    import argparse
    
    parser = argparse.ArgumentParser(description="Context Manager for OpenClaw")
    parser.add_argument("action", choices=["analyze", "compact", "archive", "status", "config"])
    parser.add_argument("--session-file", help="Path to session JSON file")
    parser.add_argument("--strategy", choices=["conservative", "balanced", "aggressive", "force"], 
                       default="balanced")
    parser.add_argument("--target-utilization", type=float, default=0.75,
                       help="Target token utilization (0.0-1.0)")
    parser.add_argument("--model", default="default", help="Model name for context limits")
    parser.add_argument("--output", help="Output file for compressed session")
    parser.add_argument("--summary", help="Custom summary for archiving")
    
    args = parser.parse_args()
    
    cm = ContextManager()
    
    if args.action == "config":
        print(json.dumps(cm.config, indent=2))
        return
    
    if args.action == "status":
        print("Context Manager Status:")
        print(f"Default model limit: {cm.config['model_limits']['default']} tokens")
        print(f"Compression strategy: {cm.config['compression']['strategy']}")
        print(f"Target utilization: {cm.config['compression']['target_utilization']*100}%")
        return
    
    # Load session data
    if args.session_file and os.path.exists(args.session_file):
        with open(args.session_file, 'r') as f:
            session_data = json.load(f)
        messages = session_data.get("messages", [])
    else:
        # For demo purposes, create sample data
        messages = [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Please help me with this task."},
            {"role": "assistant", "content": "I'll help you. Let me analyze the situation."},
        ]
    
    if args.action == "analyze":
        analysis = cm.analyze_session(messages, args.model)
        print("Session Analysis:")
        print(f"Total messages: {analysis['total_messages']}")
        print(f"Estimated tokens: {analysis['total_tokens']}")
        print(f"Model limit: {analysis['model_limit']}")
        print(f"Utilization: {analysis['utilization']*100:.1f}%")
        print(f"Needs compression: {analysis['needs_compression']}")
        
        print("\nLowest scoring messages (candidates for compression/removal):")
        for msg in analysis["scored_messages"][:5]:
            print(f"  [{msg['index']}] Score: {msg['score']:.2f}, Tokens: {msg['tokens']}, "
                  f"Role: {msg['role']}, Preview: {msg['content_preview']}")
    
    elif args.action == "compact":
        compressed, stats = cm.compact_session(
            messages, 
            strategy=args.strategy,
            target_utilization=args.target_utilization
        )
        
