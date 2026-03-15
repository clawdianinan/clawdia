---
name: fela-seedance-video
description: Create fast, consistent Seedance video packages for IIH campaigns. Use when asked to generate event promos, shot lists, continuity plans, style-safe prompts, QA checks, or export handoff specs for editors/social posting.
---

# Fela Seedance Video

Deliver outputs in this order unless the user requests otherwise:
1) Creative brief snapshot
2) Prompt set (master + variants)
3) Shot plan
4) Continuity guardrails
5) QA checklist
6) Export handoff block

## 1) Build a brief snapshot (6 lines max)
Fill:
- Objective:
- Audience:
- Event/date/location:
- Core message (single sentence):
- CTA:
- Platform + duration target:

If key data is missing, make one practical assumption and label it `Assumption:`.

## 2) Generate prompt set
Use this structure for each prompt:
- **Intent**
- **Seedance Prompt**
- **Negative Prompt**
- **Params** (duration, aspect ratio, motion strength, camera style)

Load style rules from `references/iih-brand-style.md` before writing final prompts.

### Event promo master template
Use/adapt:

```text
Intent: [announce / hype / reminder / recap]
Seedance Prompt:
"[Event name] promo for [audience], cinematic but clean, premium education brand tone, confident and warm.
Scene progression: [hook visual] -> [proof/social energy] -> [speaker/value moment] -> [clear CTA frame].
Visual style: [lighting], [palette], [camera movement], realistic motion blur, sharp subject separation, natural skin tones.
Typography moments: short on-screen phrases only: '[Phrase 1]', '[Phrase 2]', '[CTA]'.
Brand consistency: IIH look, restrained transitions, no chaotic overlays, no meme aesthetics.
End card: [date/time/location + registration CTA]."
Negative Prompt:
"low-res, flicker, warped faces/hands, jittery motion, over-saturated neon, cluttered text, inconsistent logos, stretched typography, noisy compression artifacts"
Params: duration=[15s|30s|45s], aspect=[9:16|1:1|16:9], motion=[low|med], camera=[gimbal|locked+push-in|handheld-clean]
```

### Fast variants
Produce 3 variants from the master:
- **A (Emotional):** people-first, reactions, community energy
- **B (Authority):** speaker credibility, outcomes, trust
- **C (Urgency):** deadline, limited seats, countdown framing

## 3) Shot planning (table)
Output a compact table:

| # | Timecode | Shot goal | Visual direction | Overlay text | Transition |
|---|---|---|---|---|---|

Rules:
- Keep 5–9 shots for 30s video.
- First 2 seconds must contain a hook visual + event identifier.
- Each shot must advance one message only.
- Last shot must be explicit CTA.

## 4) Continuity guardrails
For every sequence, lock these:
- Wardrobe/subject identity continuity
- Lighting direction + intensity continuity
- Camera language continuity (do not mix chaotic styles)
- Palette continuity (match IIH style card)
- Text system continuity (same font family/weight behavior)

Add a `Continuity Risks` list with prevention notes.

## 5) Quality checklist (pass/fix)
Score each item `PASS` or `FIX`:
- Hook clarity in first 2 seconds
- Message hierarchy (no competing claims)
- Face/hand integrity in all key frames
- Readable text safe margins for platform
- Brand consistency vs IIH style card
- Audio/beat sync points (if music-driven)
- CTA clarity (what, when, where, how)
- Export readiness (no visible artifacts)

If any `FIX`, provide one-line correction per item.

## 6) Export handoff format
Return this block exactly:

```yaml
handoff:
  campaign: ""
  deliverables:
    - name: ""
      duration_sec:
      aspect_ratio: ""
      platform: ""
      version: "v1"
  source_prompts:
    master: ""
    variants: []
  locked_style:
    palette: "IIH-approved"
    typography: "clean sans, high legibility"
    tone: "confident, warm, premium"
  qc_status:
    overall: "PASS|FIX"
    notes: []
  export_specs:
    codec: "H.264"
    container: "MP4"
    resolution: "1080x1920|1080x1080|1920x1080"
    fps: 30
    bitrate_mbps: "8-16"
    audio: "AAC 48kHz 320kbps"
  filenames:
    pattern: "iih_[campaign]_[aspect]_[duration]_[version].mp4"
  approvals_needed:
    - "Brand"
    - "Content"
```

## Response mode
- Be concise, execution-first.
- Default to practical assumptions instead of long question lists.
- Provide copy-paste-ready prompts and handoff YAML every time.