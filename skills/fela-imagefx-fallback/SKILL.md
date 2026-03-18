---
name: fela-imagefx-fallback
description: ImageFX (Google Imagen) image generation as fallback when Nano Banana quota is exhausted. Use when character generation fails due to Gemini API quota limits. Provides free unlimited image generation via unofficial ImageFX API with Imagen 4 model.
---

# ImageFX Fallback Skill

## Purpose
Fallback image generation system for AOZ character creation when Nano Banana (Gemini 3 Pro Image) API quota is exhausted. Uses Google's ImageFX (Imagen 4) via unofficial API for free unlimited generation.

## Installation & Setup

### 1. Install Package
```bash
npm install -g @rohitaryal/imagefx-api
```

### 2. Get Google Cookie
**Method A: Cookie Editor Extension**
1. Install [Cookie Editor](https://github.com/Moustachauve/cookie-editor) Chrome extension
2. Log into `clawdianinan@gmail.com` in Chrome
3. Navigate to https://labs.google/fx/tools/image-fx
4. Click Cookie Editor icon → Export → Header String
5. Save cookie value as environment variable: `export GOOGLE_COOKIE="your_cookie_here"`

**Method B: Browser Network Tab**
1. Open Chrome DevTools (F12)
2. Go to Network tab
3. Navigate to https://labs.google/fx/tools/image-fx
4. Find `image-fx` request → Copy "Cookie" header from Request Headers
5. Save as environment variable

### 3. Test Installation
```bash
imagefx generate --prompt "test image" --cookie "$GOOGLE_COOKIE"
```

## Usage as Nano Banana Fallback

### Character Generation Workflow
1. **Try Nano Banana first** (primary, higher control)
2. **If 429 quota error**, switch to ImageFX fallback
3. **Generate with ImageFX** using similar prompts
4. **Maintain consistency** with reference images

### Command Examples

#### Basic Generation
```bash
# Single character
imagefx generate --prompt "anthropomorphic ape with intelligent eyes, wearing traditional Nigerian attire, detailed fur texture, cinematic lighting" --model IMAGEN_4 --size PORTRAIT --cookie "$GOOGLE_COOKIE"

# Batch generation (multiple variations)
for i in {1..5}; do
  imagefx generate --prompt "ape character variation $i, different facial expression, same costume style" --model IMAGEN_4 --cookie "$GOOGLE_COOKIE"
done
```

#### AOZ-Specific Prompts
```bash
# Annunaki ape (albino/white)
imagefx generate --prompt "albino anthropomorphic ape with advanced technology, cybernetic implants, futuristic armor, arriving in ancient Africa, dramatic lighting" --model IMAGEN_4 --cookie "$GOOGLE_COOKIE"

# Local village ape
imagefx generate --prompt "wise elder ape with traditional tribal markings, handmade clothing, holding wooden staff, village background, warm sunset lighting" --model IMAGEN_4 --cookie "$GOOGLE_COOKIE"

# Modern diaspora ape
imagefx generate --prompt "young ape in London underground, wearing hoodie and headphones, holding smartphone, urban environment, moody lighting" --model IMAGEN_4 --cookie "$GOOGLE_COOKIE"
```

#### Consistency Controls
```bash
# Same seed for consistency
imagefx generate --prompt "ape character front view" --seed 12345 --cookie "$GOOGLE_COOKIE"
imagefx generate --prompt "ape character side view" --seed 12345 --cookie "$GOOGLE_COOKIE"

# Aspect ratio control
imagefx generate --prompt "full body ape character" --size SQUARE --cookie "$GOOGLE_COOKIE"
imagefx generate --prompt "close-up ape face" --size PORTRAIT --cookie "$GOOGLE_COOKIE"
```

## Integration with Fela Workflow

### Fallback Logic Script
```bash
#!/bin/bash
# generate_character.sh

PROMPT="$1"
OUTPUT_FILE="$2"

# Try Nano Banana first
echo "Attempting Nano Banana generation..."
cd /opt/homebrew/lib/node_modules/openclaw/skills/nano-banana-pro
uv run scripts/generate_image.py --prompt "$PROMPT" --filename "$OUTPUT_FILE" --resolution 2K

if [ $? -ne 0 ]; then
  echo "Nano Banana failed, falling back to ImageFX..."
  # Extract error
  if grep -q "429 RESOURCE_EXHAUSTED" /tmp/generation.log; then
    echo "Quota exhausted, using ImageFX fallback"
    imagefx generate --prompt "$PROMPT" --model IMAGEN_4 --dir "$(dirname "$OUTPUT_FILE")" --cookie "$GOOGLE_COOKIE"
  fi
fi
```

### Quality Comparison
- **Nano Banana (Gemini 3 Pro Image)**: Better prompt adherence, more control, consistent style
- **ImageFX (Imagen 4)**: More realistic, better textures, free unlimited, less control

## Model Specifications

### Available Models
- `IMAGEN_4` (latest, most realistic)
- `IMAGEN_3_5` (balanced quality/speed)
- `IMAGEN_3` (legacy)
- `IMAGEN_2` (basic)

### Aspect Ratios
- `SQUARE` (1:1)
- `PORTRAIT` (2:3) 
- `LANDSCAPE` (3:2)
- `WIDESCREEN` (16:9)
- `ULTRAWIDE` (21:9)

## Limitations & Workarounds

### 1. Cookie Expiration
- Cookies expire periodically (days/weeks)
- **Workaround**: Regular cookie refresh script
- **Detection**: "Authentication failed" errors

### 2. Unofficial API Stability
- No SLA, may break with Google updates
- **Workaround**: Monitor GitHub repo for updates
- **Backup**: Multiple cookie sources

### 3. Rate Limits
- Undocumented limits may apply
- **Workaround**: Implement delays between requests
- **Detection**: "Too many requests" errors

### 4. Regional Restrictions
- ImageFX not available in all countries
- **Workaround**: Use VPN for initial cookie acquisition
- **Note**: Cookie works globally once obtained

## Best Practices for AOZ

### Character Consistency
1. **Seed usage**: Use same seed for character variations
2. **Prompt templates**: Standardized prompt structure
3. **Reference images**: Save first successful generation as reference
4. **Style keywords**: Consistent descriptive terms across generations

### Batch Processing
```bash
# Generate character sheet
CHARACTERS=("annunaki_ape" "elder_ape" "young_ape" "warrior_ape" "scholar_ape")

for char in "${CHARACTERS[@]}"; do
  imagefx generate --prompt "AOZ $char character, consistent style with previous generations" --model IMAGEN_4 --cookie "$GOOGLE_COOKIE" --dir "/path/to/aoz/characters"
done
```

### Quality Assurance
1. **Manual review**: First 5 generations of each character
2. **Style alignment**: Compare with Nano Banana outputs
3. **Consistency check**: Side-by-side comparison of variations
4. **File organization**: Clear naming convention with versioning

## Integration with Production Pipeline

### Fela Agent Configuration
1. **Primary**: Nano Banana skill (`nano-banana-pro`)
2. **Fallback**: ImageFX skill (`fela-imagefx-fallback`)
3. **Decision logic**: Automatic fallback on 429 errors
4. **Output standardization**: Same file formats and locations

### Monitoring & Alerting
- **Quota monitoring**: Track Nano Banana usage
- **Fallback triggers**: Log when ImageFX is used
- **Quality metrics**: Compare outputs between systems
- **Cost tracking**: Zero cost for ImageFX vs API costs

## Troubleshooting

### Common Issues
1. **"Authentication failed"**: Cookie expired, refresh required
2. **"Model not available"**: Check available models with `imagefx --help`
3. **"Network error"**: Check internet connection, retry with delay
4. **"Invalid cookie"**: Ensure cookie includes all required headers

### Debug Mode
```bash
# Verbose output
DEBUG=* imagefx generate --prompt "test" --cookie "$GOOGLE_COOKIE"

# Save logs
imagefx generate --prompt "test" --cookie "$GOOGLE_COOKIE" 2>&1 | tee /tmp/imagefx.log
```

## Performance Notes
- **Generation time**: 10-30 seconds per image
- **Batch capability**: Sequential, not parallel (rate limit risk)
- **Quality**: Comparable to paid services, better than many free alternatives
- **Reliability**: High for personal/non-commercial use

---

*Skill created as fallback for Nano Banana quota issues. Primary: Nano Banana, Fallback: ImageFX.*