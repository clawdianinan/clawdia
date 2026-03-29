# Session: 2026-03-28 23:09:39 UTC

- **Session Key**: agent:main:telegram:direct:8300162569
- **Session ID**: 54dd240d-16c8-4898-9c7d-c781f45c8339
- **Source**: telegram

## Conversation Summary

assistant: I’m checking provider/model capability docs directly so I can separate what’s truly vision-capable from what only sounds like it.
assistant: I’ve got enough to give you definite answers now.
user: Conversation info (untrusted metadata):
```json
{
  "message_id": "6303",
  "sender_id": "8300162569",
  "sender": "Temi",
  "timestamp": "Sat 2026-03-28 23:06 GMT+1"
}
```

Sender (untrusted metadata):
```json
{
  "label": "Temi (8300162569)",
  "id": "8300162569",
  "name": "Temi"
}
```

Is there any fallback for image model or just one?
assistant: [[reply_to_current]] From what I’ve confirmed in your current OpenClaw config structure: just one configured image model, not an image-model fallback chain like your text models.

So:
1. text models
- support a primary + fallbacks setup

2. image model
- currently appears to be a single slot:
- `agents.defaults.imageModel`

3. image generation model
- also appears to be a single slot:
- `agents.defaults.imageGenerationModel`

I have not seen evidence of a built-in config structure like:
- `imageModel.primary`
- `imageModel.fallbacks`

So the practical answer is:
- native config appears to support one active image model, not a fallback list

That said, fallback behavior can still be built manually at the workflow/script level:
- try image model A
- if it fails, route to image model B
- if that fails, use local OCR

But that would be custom logic, not the same built-in fallback mechanism your text models use.
user: Conversation info (untrusted metadata):
```json
{
  "message_id": "6305",
  "sender_id": "8300162569",
  "sender": "Temi",
  "timestamp": "Sat 2026-03-28 23:06 GMT+1"
}
```

Sender (untrusted metadata):
```json
{
  "label": "Temi (8300162569)",
  "id": "8300162569",
  "name": "Temi"
}
```

So let’s make openai-codex/gpt-5.4-mini our image model then
assistant: I’ll back up the config, set only the image model to `openai-codex/gpt-5.4-mini`, validate, and then commit the config change.
assistant: Validation is still running. I’m waiting for the doctor result before I confirm the change or commit anything.
assistant: [[reply_to_current]] Done — I set `openai-codex/gpt-5.4-mini` as your OpenClaw image model.

What changed:
1. Updated active config:
- `agents.defaults.imageModel = "openai-codex/gpt-5.4-mini"`

2. Created required backup:
- `~/.openclaw/openclaw.json.backup-20260328-230706`

3. Validated config:
- `openclaw doctor` passed

4. Committed the change:
- `config: set image model to gpt-5.4-mini (enable native image analysis)`

Current status:
- Native OpenClaw image-analysis now has an assigned model
- Text default and fallbacks were left untouched

Next recommendation:
- We should run one real image+text test through OpenClaw now to confirm the native path works end-to-end.
user: Conversation info (untrusted metadata):
```json
{
  "message_id": "6309",
  "sender_id": "8300162569",
  "sender": "Temi",
  "timestamp": "Sat 2026-03-28 23:08 GMT+1"
}
```

Sender (untrusted metadata):
```json
{
  "label": "Temi (8300162569)",
  "id": "8300162569",
  "name": "Temi"
}
```

But can we still try to make open claw use a non Llm method as first option?
assistant: [[reply_to_current]] Yes — but not as the built-in default behavior of OpenClaw’s native `image` tool.

Clean distinction:
1. native OpenClaw image analysis
- now uses the configured image model
- that path is LLM/vision-model based

2. local non-LLM first option
- possible, but only as a custom workflow layer
- e.g.:
  - first run local OCR / local image parsing
  - if that is enough, return result
  - if not, fall back to the configured image model

So yes, we can absolutely make your practical workflow “local-first, model-second.”

Best architecture:
- screenshots / text-heavy images → local OCR first
- if low confidence or non-text visual reasoning needed → `gpt-5.4-mini`
- photos/complex visual scenes → go straight to the image model

Important nuance:
- this would be a custom wrapper/workflow around OpenClaw
- not a native config toggle like:
  - `preferLocalImageProcessing = true`

So:
- yes, possible
- yes, sensible
- no, not as a simple built-in OpenClaw image setting from what I’ve seen

If you want, I can build that local-first image analysis workflow next.
user: Conversation info (untrusted metadata):
```json
{
  "message_id": "6311",
  "sender_id": "8300162569",
  "sender": "Temi",
  "timestamp": "Sat 2026-03-28 23:08 GMT+1"
}
```

Sender (untrusted metadata):
```json
{
  "label": "Temi (8300162569)",
  "id": "8300162569",
  "name": "Temi"
}
```

Let’s build the workflow
assistant: I’m going to build a local-first image-analysis workflow in the workspace: a script that tries local OCR first, detects when OCR is sufficient, and only falls back to the configured OpenClaw image model when needed. I’ll also add brief docs and commit it.
assistant: The files wrote successfully, but the script path wasn’t found when executing — likely a path/dir sync issue. I’m checking the directory contents, then I’ll rerun the test and commit the workflow once it passes.
assistant: The workflow files are in place now. I’m running the local-first test and then I’ll commit only the new workflow files, not unrelated workspace changes.
assistant: [[reply_to_current]] Done — I built the local-first image-analysis workflow.

What changed:
1. Added local OCR tool:
- `scripts/image-local/local_ocr.sh`

2. Added local-first wrapper:
- `scripts/image-local/local_first_image_analysis.py`

3. Added usage notes:
- `scripts/image-local/README.md`

How it works:
1. tries local OCR first
2. scores whether OCR is strong enough
3. if strong enough → returns local result
4. if weak → signals that OpenClaw image-model fallback should be used

Test result:
- Ran successfully on your Dispatch screenshot
- Mode returned: `local-ocr`
- So for screenshot/text-heavy images, local processing is now working first

Commit:
- `feat: add local-first image analysis workflow`

Current status:
- Native OpenClaw image model is set to `gpt-5.4-mini`
- Local-first non-LLM image workflow is now available in the workspace
- For screenshots, you now have a practical local-first path

Next recommendation:
- If you want, I can do one more step and wire this into a simple command/shortcut so future screenshot analysis automatically follows:
  - local OCR first
  - OpenClaw image model only if needed
