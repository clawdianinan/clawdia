# Cursor CLI Models Reference

## 📊 OFFICIAL MODEL CATALOG (From Cursor Documentation)

### **Your Favorite Models (Based on Your Preferences):**
1. **`auto`** - Smart selection with **GENEROUS LIMITS** (Auto + Composer pool)
2. **`composer-2`** - Affordable, balanced (Auto + Composer pool)
3. **`composer-2-fast`** - Faster version

### **💰 OFFICIAL USAGE POOLS SYSTEM:**

#### **1. Auto + Composer Pool (Your Preferred)**
- **Significantly more included usage** with Auto or Composer 2
- **Designed for everyday agentic coding** at lower cost
- **Resets monthly** with billing cycle
- **Your models**: `auto`, `composer-2`, `composer-2-fast`

#### **2. API Pool**
- **Charged at model's API price**
- **Individual plans include at least $20/month** API usage
- **Used when selecting specific models** (not Auto/Composer)

### **🎯 OFFICIAL MODEL CATEGORIES (From Cursor Docs):**

#### **A. Cursor's Own Models (Auto + Composer Pool)**
| Model | Provider | Input | Cache Write | Cache Read | Output | Notes |
|-------|----------|-------|-------------|------------|--------|-------|
| **`auto`** | Cursor | $1.25 | $1.25 | $0.25 | $6.00 | **YOUR FAVORITE** - Smart selection, generous limits |
| **`composer-2`** | Cursor | $0.50 | - | $0.20 | $2.50 | **SECOND CHOICE** - Affordable, balanced |
| `composer-2-fast` | Cursor | ? | ? | ? | ? | Faster version |
| `composer-1.5` | Cursor | $3.50 | - | $0.35 | $17.50 | Hidden by default |
| `composer-1` | Cursor | $1.25 | - | $0.125 | $10.00 | Hidden by default |

#### **B. OpenAI GPT Family (API Pool)**
| Model | Input | Cache Write | Cache Read | Output | Notes |
|-------|-------|-------------|------------|--------|-------|
| **`gpt-5.3-codex`** | $1.75 | - | $0.175 | $14.00 | Flagship coding model, competitive with Opus 4.6 |
| `gpt-5.3-codex-high` | $1.75 | - | $0.175 | $14.00 | High reasoning effort variant |
| `gpt-5.3-codex-fast` | ? | ? | ? | ? | Faster variant |
| `gpt-5.3-codex-low` | ? | ? | ? | ? | Lower cost variant |
| `gpt-5.3-codex-xhigh` | ? | ? | ? | ? | Extra high quality |
| `gpt-5.2-codex` | $1.75 | - | $0.175 | $14.00 | GPT-5.2 Codex |
| `gpt-5.1-codex-max` | $1.25 | - | $0.125 | $10.00 | GPT-5.1 Codex Max |
| `gpt-5.1-codex-mini` | $0.25 | - | $0.025 | $2.00 | 4x rate limits vs GPT-5.1 Codex |
| `gpt-5` | $1.25 | - | $0.125 | $10.00 | GPT-5 base |
| `gpt-5-fast` | $2.50 | - | $0.25 | $20.00 | 2x price, faster |
| `gpt-5-mini` | $0.25 | - | $0.025 | $2.00 | Smaller variant |
| `gpt-5.4` | $2.50 | - | $0.25 | $15.00 | Latest GPT-5.4 |
| `gpt-5.4-mini` | $0.75 | - | $0.075 | $4.50 | Smaller, faster variant |
| `gpt-5.4-nano` | $0.20 | - | $0.02 | $1.25 | Smallest, most cost-optimized |

#### **C. Anthropic Claude Family (API Pool)**
| Model | Input | Cache Write | Cache Read | Output | Notes |
|-------|-------|-------------|------------|--------|-------|
| `claude-4.6-opus` | $5.00 | $6.25 | $0.50 | $25.00 | Latest Opus |
| `claude-4.6-sonnet` | $3.00 | $3.75 | $0.30 | $15.00 | Latest Sonnet |
| `claude-4.5-opus` | $5.00 | $6.25 | $0.50 | $25.00 | Opus 4.5 |
| `claude-4.5-sonnet` | $3.00 | $3.75 | $0.30 | $15.00 | Sonnet 4.5 |
| `claude-4.5-haiku` | $1.00 | $1.25 | $0.10 | $5.00 | Haiku 4.5 |
| `claude-4-sonnet` | $3.00 | $3.75 | $0.30 | $15.00 | Claude 4 Sonnet |
| `claude-4-sonnet-1m` | $6.00 | $7.50 | $0.60 | $22.50 | 1M context window |

#### **D. Google Gemini Family (API Pool)**
| Model | Input | Cache Write | Cache Read | Output | Notes |
|-------|-------|-------------|------------|--------|-------|
| `gemini-3-pro` | $2.00 | - | $0.20 | $12.00 | Gemini 3 Pro |
| `gemini-3.1-pro` | $2.00 | - | $0.20 | $12.00 | Gemini 3.1 Pro |
| `gemini-3-flash` | $0.50 | - | $0.05 | $3.00 | Gemini 3 Flash |
| `gemini-2.5-flash` | $0.30 | - | $0.03 | $2.50 | Gemini 2.5 Flash |
| `gemini-3-pro-image-preview` | $2.00 | - | $0.20 | $12.00 | Image generation model |

#### **E. Other Models (API Pool)**
| Model | Provider | Input | Cache Write | Cache Read | Output | Notes |
|-------|----------|-------|-------------|------------|--------|-------|
| `grok-4.20` | xAI | $2.00 | - | $0.20 | $6.00 | Grok 4.20 |
| `kimi-k2.5` | Moonshot | $0.60 | - | $0.10 | $3.00 | Kimi K2.5 |

### **📈 OFFICIAL PRICING SUMMARY (Per Million Tokens):**

#### **Auto + Composer Pool (Your Main Pool)**
| Model | Input | Cache Write | Cache Read | Output | Notes |
|-------|-------|-------------|------------|--------|-------|
| **`auto`** | $1.25 | $1.25 | $0.25 | $6.00 | **YOUR FAVORITE** |
| **`composer-2`** | $0.50 | - | $0.20 | $2.50 | **SECOND CHOICE** |
| **Generous included usage** in monthly plans |

#### **API Pool - Top Models (Specific Selection)**
| Model | Input | Cache Write | Cache Read | Output | Notes |
|-------|-------|-------------|------------|--------|-------|
| **GPT-5.3-Codex** | $1.75 | - | $0.175 | $14.00 | Flagship coder |
| **Claude 4.6 Opus** | $5.00 | $6.25 | $0.50 | $25.00 | Highest quality |
| **Claude 4.6 Sonnet** | $3.00 | $3.75 | $0.30 | $15.00 | Balanced Claude |
| **Gemini 3 Pro** | $2.00 | - | $0.20 | $12.00 | Google's best |
| **GPT-5.4** | $2.50 | - | $0.25 | $15.00 | Latest GPT |
| **GPT-5.4 Nano** | $0.20 | - | $0.02 | $1.25 | Cheapest option |

#### **Cost Comparison (Input + Output per 1M tokens):**
1. **GPT-5.4 Nano**: $1.45 (cheapest)
2. **Composer-2**: $3.00 (your affordable choice)
3. **GPT-5.3-Codex**: $15.75 (flagship coder)
4. **Claude 4.6 Sonnet**: $18.00 (balanced Claude)
5. **Claude 4.6 Opus**: $30.00 (highest quality)

### **🎯 YOUR OPTIMIZED STRATEGY:**

#### **1. Primary Usage (Maximize Limits)**
```bash
# Use AUTO for generous limits
agent chat "General task"  # Defaults to 'auto'

# Or explicitly specify
agent chat "Task" --model auto
```

#### **2. Secondary (Affordable Quality)**
```bash
# Composer 2 for extended sessions
agent chat "Extended debugging" --model composer-2

# Fast version when needed
agent chat "Quick fix" --model composer-2-fast
```

#### **3. Specific Needs Only**
```bash
# Quality-critical (API pool)
agent chat "Complex architecture" --model gpt-5.3-codex-high

# Latest features
agent chat "Innovative solution" --model gpt-5.3-codex-spark-preview

# Claude for specific reasoning
agent chat "Deep analysis" --model claude-4.6-opus
```

### **🚀 OFFICIAL MODEL SELECTION GUIDE:**

#### **For Everyday Coding (Auto + Composer Pool):**
- **First choice**: `auto` (smart selection, generous limits)
- **Second choice**: `composer-2` (affordable at $0.50/M input)
- **Why**: Significantly more included usage in monthly plans

#### **For Complex Tasks (API Pool - Use Sparingly):**
- **Architecture/Planning**: `gpt-5.3-codex-high` ($1.75/M input)
- **Deep Reasoning**: `claude-4.6-opus` ($5.00/M input)
- **Debugging**: `gpt-5.3-codex` (grinds through complex problems)
- **Quality Critical**: `claude-4.6-sonnet` ($3.00/M input)

#### **For Speed (API Pool):**
- **General**: `composer-2-fast` (fastest in Composer pool)
- **GPT**: `gpt-5.3-codex-fast` (fast GPT variant)
- **Budget Speed**: `gpt-5.4-nano` ($0.20/M input, fastest cheap option)

#### **For Cost Optimization:**
- **Best value**: `composer-2` ($0.50/M input, $2.50/M output)
- **Lowest cost**: `gpt-5.4-nano` ($0.20/M input, $1.25/M output)
- **Auto selection**: `auto` balances cost/quality with pool benefits
- **Avoid**: Claude Opus ($30/M total) unless absolutely necessary

#### **For Specific Needs:**
- **Image Generation**: `gemini-3-pro-image-preview` ($2/M input + image output fees)
- **Large Context**: `claude-4-sonnet-1m` (1M tokens, $6/M input)
- **Latest Features**: `gpt-5.4` ($2.50/M input, latest GPT)

### **📊 PLAN COMPARISON:**

| Plan | Price | API Usage Included | Auto + Composer |
|------|-------|-------------------|-----------------|
| **Pro** | $20/mo | $20 | Generous included usage |
| **Pro Plus** | $60/mo | $70 | Generous included usage |
| **Ultra** | $200/mo | $400 | Generous included usage |

### **💡 KEY INSIGHTS:**

1. **`auto` is your best friend** - Smart selection + generous limits
2. **Composer 2 is excellent value** - Affordable with good quality
3. **GPT-5.3-Codex is flagship coder** - Competitive with Claude Opus at 1/3 price
4. **API pool is expensive** - Use only for specific needs
5. **Monitor usage** - Stay within included limits

### **🔧 COMMAND REFERENCE:**

```bash
# Check available models
agent models

# Your preferred workflow
agent chat "Task"  # Uses 'auto' by default

# Explicit model selection
agent chat "Task" --model auto
agent chat "Task" --model composer-2
agent chat "Task" --model gpt-5.3-codex-high

# Check usage
# Visit: https://cursor.com/dashboard/usage
```

### **🎯 OFFICIAL RECOMMENDED WORKFLOW:**

#### **Phase 1: Maximize Auto + Composer Pool**
1. **Start with `auto`** for all general tasks (smart selection, generous limits)
2. **Switch to `composer-2`** for extended sessions (affordable at $0.50/M input)
3. **Monitor usage** in Auto + Composer pool (more included usage)

#### **Phase 2: Strategic API Pool Usage**
4. **Use specific models only when:**
   - **Quality-critical**: `gpt-5.3-codex-high` or `claude-4.6-sonnet`
   - **Complex reasoning**: `claude-4.6-opus` (expensive, use sparingly)
   - **Latest features**: `gpt-5.4` or specific model requirements
   - **Image generation**: `gemini-3-pro-image-preview`

#### **Phase 3: Cost Management**
5. **Track API usage** (starts at $20/month included)
6. **Prioritize cheap models** for non-critical work:
   - `gpt-5.4-nano` ($0.20/M input) for simple tasks
   - `composer-2` ($0.50/M input) for balanced work
7. **Reserve expensive models** for critical work only

#### **Dashboard Monitoring:**
- **Auto + Composer pool**: Track generous included usage
- **API pool**: Monitor $20+ monthly included usage
- **Model selection**: Balance cost vs. quality needs

**Your strategy of preferring `auto` then `composer-2` is officially optimal!** 🎉
- **`auto`**: Smart selection with pool benefits
- **`composer-2`**: Affordable with good quality
- **API models**: Strategic use only when needed