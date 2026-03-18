---
name: context-manager
description: Intelligent chat history compression and context optimization for OpenClaw sessions. Use when: (1) experiencing context overflow errors, (2) managing long-running sessions with extensive history, (3) optimizing model token usage across different context sizes, (4) preventing silent tool output bloat, or (5) implementing smart summarization of older conversational turns.
---

# Context Manager Skill

Intelligent chat history compression and context optimization for OpenClaw sessions.

## Purpose

Prevent context overflow errors and optimize token usage by intelligently managing session history based on importance scoring, model context limits, and conversation structure.

## Core Principles

### 1. Model-Aware Context Limits
- Different models have different context windows (4K, 8K, 16K, 32K, 128K, etc.)
- Context manager tracks current model and adjusts compression accordingly
- Preserves critical information while pruning low-value content

### 2. Importance-Based Retention
Messages are scored based on:
- **Criticality**: System messages, tool outputs with important results, user instructions
- **Recency**: Recent messages are more important than older ones
- **Relevance**: Messages containing keywords, references, or ongoing task context
- **Structural Value**: Messages that define task boundaries or decision points

### 3. Progressive Compression
- **Level 1**: Remove whitespace and formatting bloat
- **Level 2**: Summarize older tool outputs (keep results, remove intermediate steps)
- **Level 3**: Replace old conversational turns with concise summaries
- **Level 4**: Archive complete older segments to memory files

## When to Use

### Automatic Triggers
1. **Context overflow warnings**: "prompt too large for the model"
2. **Session length > 50 messages**: Proactive compression
3. **Tool output bloat detection**: Large code blocks, file contents, search results
4. **Model switch detection**: When switching to smaller-context model

### Manual Triggers
1. User requests `/compact` command
2. Before starting new major task in long session
3. When session feels "slow" or "bloated"

## Implementation Strategy

### 1. Message Classification
```python
# Message types for scoring
CRITICAL = ["system", "instruction", "decision", "result"]
IMPORTANT = ["tool", "code", "data", "reference"]
NORMAL = ["conversation", "clarification", "confirmation"]
LOW_VALUE = ["greeting", "acknowledgment", "formatting"]
```

### 2. Compression Algorithms
- **Summarization**: Use model to summarize old conversation segments
- **Extraction**: Keep only key information (decisions, results, next steps)
- **Archival**: Move complete history to memory files with references
- **Pruning**: Remove redundant or low-value messages

### 3. Integration Points
- **Session startup**: Check context size, apply compression if needed
- **After tool calls**: Compact large outputs
- **Before model inference**: Ensure prompt fits context window
- **Periodic maintenance**: Every 20 messages or 30 minutes

## Usage Examples

### Basic Compression
```bash
# Compact current session
context-manager compact --strategy balanced

# Compact with aggressive pruning
context-manager compact --strategy aggressive --preserve-critical

# Check context usage
context-manager status --show-breakdown
```

### Model-Specific Optimization
```bash
# Optimize for 4K context model
context-manager optimize --model 4k --target-utilization 80%

# Prepare for model switch
context-manager prepare --target-model gpt-4-32k
```

### Tool Output Management
```bash
# Compact recent tool outputs
context-manager compact-tools --last 10 --keep-results

# Archive complete session to memory
context-manager archive --session-id current --summary-depth detailed
```

## Configuration

### Default Settings
```yaml
compression:
  strategy: "balanced"  # balanced, aggressive, conservative
  target_utilization: 75%
  preserve_critical: true
  summarize_older_than: 20  # messages
  archive_complete_after: 100  # messages

scoring:
  critical_multiplier: 3.0
  important_multiplier: 2.0
  recency_decay: 0.95  # per message
  tool_output_penalty: 0.7  # large outputs get penalty

model_limits:
  default: 8000
  gpt-4: 8000
  gpt-4-32k: 32768
  claude-3-opus: 200000
  llama-2: 4096
```

### Custom Rules
```yaml
preserve_patterns:
  - "DECISION:"
  - "RESULT:"
  - "TODO:"
  - "ERROR:"
  - "@mention"

compress_patterns:
  - "code block"
  - "file content"
  - "search results"
  - "log output"
```

## Integration with OpenClaw

### Session Management
- Hook into session lifecycle events
- Monitor message counts and token usage
- Intercept context overflow errors

### Memory System Integration
- Archive compressed sessions to MEMORY.md
- Create searchable summaries
- Maintain reference links between sessions

### Tool Integration
- Monitor tool output sizes
- Apply compression to large outputs
- Preserve actionable results

## Best Practices

### 1. Always Preserve
- User instructions and constraints
- System decisions and rationale
- Task boundaries and objectives
- Critical errors and resolutions

### 2. Usually Compress
- Long code blocks (keep interface, compress implementation)
- File contents (keep metadata, compress data)
- Search results (keep top N, summarize rest)
- Conversation history (summarize old turns)

### 3. Usually Remove
- Redundant acknowledgments
- Formatting and whitespace bloat
- Failed tool attempts without learning
- Temporary debugging output

### 4. Safety Rules
- Never compress without user confirmation in interactive mode
- Always create backup before aggressive compression
- Preserve ability to reconstruct original if needed
- Log all compression actions for audit

## Troubleshooting

### Common Issues
1. **Over-compression**: Lost critical context
   - Solution: Use conservative strategy, check preserved patterns

2. **Under-compression**: Still hitting limits
   - Solution: Adjust target utilization, use aggressive strategy

3. **Model mismatch**: Wrong context size assumption
   - Solution: Auto-detect model, update configuration

4. **Performance impact**: Compression takes too long
   - Solution: Use incremental compression, cache results

### Recovery Options
```bash
# Restore from backup
context-manager restore --backup-id latest

# View compression history
context-manager history --session-id current

# Adjust settings
context-manager configure --strategy conservative --target-utilization 70%
```

## Advanced Features

### 1. Adaptive Compression
- Learn from user feedback on compression quality
- Adjust scoring weights based on session type
- Custom patterns per user/project

### 2. Cross-Session Optimization
- Share compression patterns across sessions
- Learn from similar tasks
- Build compression profiles

### 3. Quality Metrics
- Compression ratio vs. information loss
- User satisfaction tracking
- Performance impact measurement

## Implementation Notes

This skill should be implemented as a Python module that:
1. Integrates with OpenClaw's session management
2. Provides CLI commands for manual control
3. Offers API for programmatic compression
4. Includes comprehensive logging and monitoring
5. Maintains backward compatibility with existing workflows

The goal is to make context management transparent and automatic while providing manual controls for advanced users.