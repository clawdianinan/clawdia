# App Project Registry

Date: 2026-04-10
Root: /Users/clawdia/apps

Rule:
- Treat every top-level directory inside `/Users/clawdia/apps` as an active project or project container Temi may refer to by name.
- When Temi mentions one of these names, assume he is referring to that project unless he says otherwise.
- Match both the exact folder name and a compact alias with hyphens/underscores removed.
- Examples: `prdforge` -> `/Users/clawdia/apps/prdforge`, `residentmd` -> `/Users/clawdia/apps/residentmd`, `streamsbilling` -> `/Users/clawdia/apps/streams-billing`.
- If a name is ambiguous with a common English word, prefer the project interpretation only when the surrounding request is clearly software/product/development related. Otherwise ask a short clarifying question.

Projects:
- admin-shared
- apes-of-zamoonda
- build-with-claude-showcase
- iih
- iih-space
- jira-devops-automation
- kwasaa
- kwsgai
- landlink
- prdforge
- prdforge-cli
- quaride
- residentmd
- sabify
- space-platform
- streams-billing
- streams-tax
- subscription-platform
- super-plan-mode
- temikolawolecom
- tracmemo
- trello-automation
- visitdesk
