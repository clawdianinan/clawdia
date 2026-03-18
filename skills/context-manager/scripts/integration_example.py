#!/usr/bin/env python3
"""
Example integration of Context Manager with OpenClaw session handling
"""

import json
import sys
from pathlib import Path

# Add the scripts directory to path
sys.path.insert(0, str(Path(__file__).parent))

from context_manager import ContextManager

def integrate_with_openclaw_session(session_data: dict) -> dict:
    """
    Integrate context manager with OpenClaw session data
    
    Args:
        session_data: OpenClaw session data with messages
        
    Returns:
        Updated session data with compression applied if needed
    """
    cm = ContextManager(session_data)
    
    # Get messages from session
    messages = session_data.get("messages", [])
    
    if not messages:
        return session_data
    
    # Analyze session
    analysis = cm.analyze_session(messages)
    
    print(f"Session analysis: {analysis['total_messages']} messages, "
          f"{analysis['total_tokens']} tokens, "
          f"{analysis['utilization']*100:.1f}% utilization")
    
    # Check if compression is needed
    if analysis["needs_compression"]:
        print("Session needs compression, applying...")
        
        # Compact session
        compressed_messages, stats = cm.compact_session(messages)
        
        print(f"Compression stats: {stats['removed_count']} removed, "
              f"{stats['compressed_count']} compressed, "
              f"{stats['reduction_percent']:.1f}% reduction")
        
        # Update session data
        session_data["messages"] = compressed_messages
        session_data["compression_stats"] = stats
        
        # Archive if we removed many messages
        if stats["removed_count"] > 10:
            summary = cm.create_summary(messages)
            archive_path = cm.archive_session(
                messages, 
                session_data.get("session_id", "unknown"),
                summary
            )
            print(f"Archived original session to: {archive_path}")
            session_data["archive_path"] = archive_path
    
    return session_data


def monitor_tool_output(tool_name: str, output: str, max_size: int = 5000) -> str:
    """
    Monitor and compress tool outputs
    
    Args:
        tool_name: Name of the tool
        output: Tool output content
        max_size: Maximum size in tokens before compression
        
    Returns:
        Compressed output if needed
    """
    cm = ContextManager()
    
    # Estimate tokens
    tokens = cm.estimate_tokens(output)
    
    if tokens <= max_size:
        return output
    
    print(f"Tool '{tool_name}' output is large: {tokens} tokens, compressing...")
    
    # Create a message object for compression
    message = {
        "role": "tool",
        "content": f"Tool {tool_name} output: {output}"
    }
    
    # Compress with aggressive strategy
    compressed = cm.compress_message(message, strategy="aggressive")
    
    # Extract compressed content
    compressed_content = compressed["content"]
    
    # Add compression note
    if len(compressed_content) < len(output):
        compressed_content += f"\n\n[Note: Tool output compressed from {tokens} to {cm.estimate_tokens(compressed_content)} tokens]"
    
    return compressed_content


def check_context_overflow(session_data: dict, model: str = "default") -> bool:
    """
    Check if session is at risk of context overflow
    
    Args:
        session_data: Session data
        model: Model name for context limits
        
    Returns:
        True if at risk, False otherwise
    """
    cm = ContextManager(session_data)
    messages = session_data.get("messages", [])
    
    if not messages:
        return False
    
    analysis = cm.analyze_session(messages, model)
    
    # Consider at risk if > 90% utilization
    return analysis["utilization"] > 0.9


def proactive_compression(session_data: dict, threshold: float = 0.75) -> dict:
    """
    Apply proactive compression before hitting limits
    
    Args:
        session_data: Session data
        threshold: Utilization threshold for proactive compression
        
    Returns:
        Updated session data
    """
    cm = ContextManager(session_data)
    messages = session_data.get("messages", [])
    
    if not messages:
        return session_data
    
    analysis = cm.analyze_session(messages)
    
    if analysis["utilization"] > threshold:
        print(f"Proactive compression triggered at {analysis['utilization']*100:.1f}% utilization")
        compressed_messages, stats = cm.compact_session(messages, strategy="balanced")
        session_data["messages"] = compressed_messages
        session_data["proactive_compression"] = stats
    
    return session_data


# Example usage
if __name__ == "__main__":
    # Example session data
    example_session = {
        "session_id": "test_session_123",
        "model": "gpt-4",
        "messages": [
            {"role": "system", "content": "You are a helpful assistant."},
            {"role": "user", "content": "Please analyze this large dataset and provide insights."},
            {"role": "assistant", "content": "I'll analyze the dataset. Let me load it first."},
            # ... many more messages ...
        ]
    }
    
    # Add some large tool output
    large_output = "Tool output: " + "x" * 10000
    example_session["messages"].append({
        "role": "tool",
        "content": large_output
    })
    
    print("=== Context Manager Integration Example ===")
    
    # 1. Monitor tool output
    print("\n1. Monitoring tool output:")
    compressed_output = monitor_tool_output("data_loader", large_output)
    print(f"   Original size: {len(large_output)} chars")
    print(f"   Compressed size: {len(compressed_output)} chars")
    
    # 2. Check context overflow risk
    print("\n2. Checking context overflow risk:")
    at_risk = check_context_overflow(example_session)
    print(f"   At risk of overflow: {at_risk}")
    
    # 3. Apply proactive compression
    print("\n3. Applying proactive compression:")
    updated_session = proactive_compression(example_session)
    print(f"   Session updated: {'proactive_compression' in updated_session}")
    
    # 4. Full integration
    print("\n4. Full session integration:")
    final_session = integrate_with_openclaw_session(example_session)
    print(f"   Final message count: {len(final_session.get('messages', []))}")
    
    print("\n=== Integration Complete ===")