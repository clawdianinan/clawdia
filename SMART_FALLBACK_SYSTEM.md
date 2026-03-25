# Smart Fallback System for OpenClaw

## Purpose
Prevent OpenClaw from retrying rate-limited models on each message. When GPT-5.3-Codex hits usage limits, the system automatically switches to DeepSeek and remembers not to retry GPT-5.3-Codex for 24 hours.

## Problem Solved
- **Before**: OpenClaw tries GPT-5.3-Codex → fails (rate limit) → falls back to DeepSeek → next message: tries GPT-5.3-Codex again → fails again → annoying cycle
- **After**: OpenClaw tries GPT-5.3-Codex → fails (rate limit) → system records rate limit → switches to DeepSeek → next message: uses DeepSeek (skips rate-limited GPT) → continues with DeepSeek until rate limit resets

## Components

### 1. `smart_model_fallback.py`
Core Python script that:
- Detects rate limit errors (specific patterns)
- Caches rate-limited models with 24-hour TTL
- Provides intelligent model selection
- Manages rate limit status

### 2. `integrate_smart_fallback.sh`
Bash wrapper that:
- Integrates with OpenClaw configuration
- Updates model priorities automatically
- Provides easy-to-use commands
- Sets up monitoring hooks

### 3. Cache File
`~/.openclaw/model_fallback_cache.json`
Stores rate limit information with timestamps.

## Usage

### Basic Commands

```bash
# Check current status
cd ~/.openclaw/workspace/scripts
./integrate_smart_fallback.sh status

# Record a model failure (interactive)
./integrate_smart_fallback.sh record

# Clear rate limit for a model (interactive)
./integrate_smart_fallback.sh clear

# Update OpenClaw config with best available model
./integrate_smart_fallback.sh update

# Set up automatic error monitoring
./integrate_smart_fallback.sh monitor

# Full setup (update + monitor)
./integrate_smart_fallback.sh full-setup
```

### Manual Python Commands

```bash
# Check status
python3 smart_model_fallback.py status

# Record rate limit
python3 smart_model_fallback.py record "openai-codex/gpt-5.3-codex" "Error message here"

# Clear rate limit
python3 smart_model_fallback.py clear "openai-codex/gpt-5.3-codex"

# Get best available model
python3 smart_model_fallback.py best

# List available models
python3 smart_model_fallback.py list
```

## How It Works

### Rate Limit Detection
The system looks for these error patterns:
- "insufficient permissions.*model\.request"
- "rate limit"
- "usage limit" 
- "quota.*exceeded"
- "limit.*reached"
- "too many requests"
- "429" (HTTP status)
- "403.*limit"
- "model.*not available"

### Model Priority
Default priority order (configurable):
1. `openai-codex/gpt-5.3-codex`
2. `deepseek/deepseek-chat`
3. `openrouter/stepfun/step-3.5-flash`
4. `openrouter/minimax/minimax-m2.5`
5. `llama-cpp/llama3.1:8b`

### Cache Behavior
- Rate-limited models are cached for **24 hours**
- After 24 hours, they're automatically removed from cache
- Manual clearing available via `clear` command

## Integration with OpenClaw

### Automatic Configuration Update
When you run `./integrate_smart_fallback.sh update`:
1. Checks which models are rate-limited
2. Selects best available model as primary
3. Updates OpenClaw configuration (`~/.openclaw/openclaw.json`)
4. Restarts OpenClaw gateway

### Example Configuration Change
**Before (GPT rate-limited):**
```json
"model": {
  "primary": "openai-codex/gpt-5.3-codex",
  "fallbacks": ["deepseek/deepseek-chat", "..."]
}
```

**After (automatically updated):**
```json
"model": {
  "primary": "deepseek/deepseek-chat",
  "fallbacks": ["openrouter/stepfun/step-3.5-flash", "...", "openai-codex/gpt-5.3-codex"]
}
```

Note: GPT-5.3-Codex moves to the end of fallbacks when rate-limited.

## Monitoring Setup

The monitoring hook watches OpenClaw logs for error patterns and automatically records rate limits. To enable:

```bash
./integrate_smart_fallback.sh monitor
# Then run the monitoring script:
./monitor_openclaw_errors.sh
```

## Recovery Process

When GPT-5.3-Codex rate limit resets (e.g., Mar 21, 2026 11:33 PM):

1. **Automatic**: The cache auto-expires at the specified retry time
2. **Manual**: Clear the rate limit anytime:
   ```bash
   ./integrate_smart_fallback.sh clear
   # Enter: openai-codex/gpt-5.3-codex
   ```
3. **Update configuration** to switch back to GPT:
   ```bash
   ./integrate_smart_fallback.sh update
   ```

### For Current Situation (Codex limit until Mar 21, 2026 11:33 PM):
```bash
# One-time setup already done:
./setup_gpt_limit_fix.sh

# After limit resets tomorrow night:
./integrate_smart_fallback.sh clear
./integrate_smart_fallback.sh update
```

## Benefits

1. **No more annoying model switching** - Stays with working model
2. **Automatic rate limit detection** - Recognizes specific error patterns
3. **Configurable TTL** - 24-hour cache (adjustable in script)
4. **Easy management** - Simple commands for status/clear/update
5. **Preserves OAuth configuration** - Doesn't change authentication mode
6. **Reversible** - Easy to switch back when limits reset

## Files Created

- `~/.openclaw/workspace/scripts/smart_model_fallback.py`
- `~/.openclaw/workspace/scripts/integrate_smart_fallback.sh`
- `~/.openclaw/workspace/scripts/monitor_openclaw_errors.sh` (after monitoring setup)
- `~/.openclaw/model_fallback_cache.json`
- `~/.openclaw/openclaw.json.backup.*` (config backups)

## Next Steps

1. **Initial setup**: Run `./integrate_smart_fallback.sh full-setup`
2. **Monitor status**: Use `./integrate_smart_fallback.sh status` regularly
3. **When GPT works again**: Clear rate limit and update config

This system solves the immediate problem while keeping your OAuth configuration intact and providing a clean path back to GPT-5.3-Codex when your usage limit resets.