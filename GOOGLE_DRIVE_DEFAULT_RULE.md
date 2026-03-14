# Google Drive Default Location Rule

## Rule Statement
**By default, all WORK AND TASK DOCUMENTS created or saved by Clawdia should use Google Drive as the primary storage location.** OpenClaw system files MUST remain local.

## CRITICAL DISTINCTION:
- ✅ **Google Drive:** ONLY for work documents, task outputs, project files, reports, correspondence
- ❌ **NOT for Google Drive:** OpenClaw system files, configuration, agent skills, memory files, scripts
- ✅ **Local workspace:** OpenClaw system files stay in `/Users/clawdia/.openclaw/workspace/`

## Primary Google Account
- **Account:** `clawdianinan@gmail.com`
- **Access Tool:** `gog` CLI (Google Workspace CLI)
- **Status:** ✅ Configured with OAuth for Drive access (authenticated March 14, 2026)

## Google Drive Structure (ACTUAL FOLDER IDs)

### Root Folder: "Clawdia Documents"
- **ID:** `1kTcmKyhwrkcUI0DdwAEcwSlIvlosYGD0`
- **URL:** https://drive.google.com/drive/folders/1kTcmKyhwrkcUI0DdwAEcwSlIvlosYGD0
- **Purpose:** ALL work/task documents go here

### Existing IIH Structure (USE EXISTING - DO NOT CREATE NEW)
- **IIH Folder:** `1PnjclSsciOzQZ-H-XsUNUkD_BZ8KeAQN`
- **Subfolders (use existing):**
  - **Finance:** `166Pq6eSKzb7Ig7fBTgir1aUZE5F_fEs_` (Budgets, financial reports, payments)
  - **Reports:** `1ItUgLtY_MCRN8EoPlGQsFln4bx9ycexR` (Monthly reports, documentation)
  - **HR:** `1qT5NfoZPS9Kzp61OXSwpZplHhyeAzQMt` (Roles, grading, HR documents)
  - **Corporate:** `1WTOJqt-WDhQ_yCx4XKCg7N3uKvsJ2Rbt` (Strategic documents, agreements, proposals)
  - **Organogram:** `1YkddC4r6E1N_ziNzq9hPQh_tjRQfUjzo` (Organization charts, structures)
  - **Roles-and-Grading:** `1bzoChbA6AZeTB28b31wSiJbwoQNCqxfT` (Role definitions, grading)
  - **Governance:** `1W1avHqXzhW8wzm9eKD2TuPgjoDJw-FDs` (Governance documents, policies)
  - **Archive:** `1a5q_WEfZ3WSqyx5esWJn1OQrfQhuoVs4` (Historical files, old versions)
  - **Templates:** `1bKnn7s-uVOFZ1jxE0nSI_NT3vIWbUkxL` (Document templates, forms)

### Other Existing Folders:
- **OpenClaw-Backups:** `1hTSmRfH4Wi-_oqlJDahiFjGUo48u0ayz` (✅ BACKUP FOLDER - System backups, archive copies, exports)
- **Temi-Projects:** `1U9wXq-ajZ7dCug-aTGLIXy5E7DHm0U9O` (Personal projects, non-IIH work)

## Document Classification Guide

### ✅ GO TO GOOGLE DRIVE (Work/Task Documents + Backups):
- Reports, proposals, agreements
- Financial documents, budgets, statements
- Correspondence (emails, letters, responses)
- Project documentation, plans, specifications
- Research materials, analysis, findings
- Meeting notes, minutes, action items
- Client deliverables, presentations
- Operational documents, procedures
- **✅ BACKUPS:** System backups, archive copies, recovery files
- **✅ EXPORTS:** Document exports, data dumps, snapshot copies

### ❌ STAY LOCAL (Active OpenClaw System Files):
- AGENTS.md, SOUL.md, USER.md, IDENTITY.md (active versions)
- HEARTBEAT.md, MEMORY.md, TOOLS.md (active versions)
- Agent skills documentation (active development)
- Configuration files, scripts, automation (active versions)
- Memory system files, logs (active/runtime)
- Workflow definitions, cron jobs (active configurations)
- Development code, prototypes (active development)

### 📁 Backup Strategy:
```
ACTIVE SYSTEM FILES → Local workspace (for daily operation)
↓
REGULAR BACKUPS → Google Drive "OpenClaw-Backups" folder
↓  
ARCHIVE COPIES → Google Drive for long-term storage
↓
EXPORTED DOCUMENTS → Google Drive for sharing/access
```

## Folder Usage Rules
```
CHECK DOCUMENT TYPE FIRST
↓
Work/Task Document? → GOOGLE DRIVE
↓
System/Configuration? → LOCAL WORKSPACE  
↓
CHECK EXISTING STRUCTURE
↓
If folder exists → USE EXISTING FOLDER
↓
If similar content exists → ADD TO EXISTING FOLDER
↓
Only create new folder if NO suitable existing folder
```

## Implementation Rules

### 1. Document Creation
- **New documents:** Create directly in appropriate Google Drive folder
- **File naming:** Use consistent naming: `[Project]_[Description]_[YYYYMMDD].[ext]`
- **Formats (updated default):** Use `.docx` by default for user-requested documents unless the user explicitly asks for another format (`.md`, Google Doc, `.pdf`, etc.)
- **Branding default (when app/product docs):** Include the current product logo in document header/cover area when available

### 2. File Organization
- **Check existing structure first:** Avoid creating new structure if good structure exists
- **Use existing folders:** When similar content exists, add to existing folders
- **Maintain consistency:** Follow established naming and organization patterns

### 3. Local vs Cloud Storage
- **Local workspace:** Use only for temporary files, active editing, or system files
- **Google Drive:** Primary storage for all completed documents, reports, archives
- **Sync process:** Move files from local workspace to Google Drive when complete

### 4. Access and Sharing
- **Default visibility:** Private (only accessible to `clawdianinan@gmail.com`)
- **Sharing:** Only share when explicitly instructed
- **Permissions:** Maintain appropriate access controls

## Current File Migration Plan

### Phase 1: Configuration & Rule Files
Move these workspace files to `OpenClaw_Workspace/Configuration/`:
- AGENTS.md, SOUL.md, USER.md, IDENTITY.md
- HEARTBEAT.md, MEMORY.md, TOOLS.md
- All rule and policy documents

### Phase 2: IIH Documents
Move these to `IIH_Operations/` appropriate subfolders:
- IHS_Logo_Strategic_Independence_Analysis.md
- All organogram update summaries
- Financial and facility reports
- Email correspondence and drafts

### Phase 3: Project Files
Move remaining documents to appropriate project folders based on content.

## Tool Integration

### gog CLI Commands for Common Operations:
```bash
# List files in Drive
gog drive list --max 20

# Search for files
gog drive search "query" --max 10

# Upload a file
gog drive upload /path/to/file --name "Filename" --folder "FolderID"

# Create folder
gog drive mkdir "Folder Name" --parent "ParentFolderID"

# Download file
gog drive download FileID --out /path/to/save
```

### Skill Integration:
- Use `google-drive` skill for API-based operations
- Use `gog` skill for CLI-based operations
- Integrate with `office-document-specialist-suite` for document processing

## Compliance & Validation

### Regular Checks:
1. **Weekly:** Verify all new documents are in Google Drive
2. **Monthly:** Review folder structure and organization
3. **Quarterly:** Archive old files and clean up local workspace

### Success Metrics:
- 100% of new documents created in Google Drive
- 90% of existing documents migrated to Google Drive
- Consistent folder structure and naming conventions
- Reduced local workspace clutter

## Exception Handling

### When to Keep Files Local:
1. **Temporary files:** Files being actively edited
2. **System files:** OpenClaw configuration and runtime files
3. **Sensitive data:** When explicitly instructed to keep local
4. **Large binaries:** When impractical for cloud storage

### Migration Exceptions:
1. **Active projects:** Files in active use can remain local temporarily
2. **System dependencies:** Files required for OpenClaw operation
3. **User instruction:** When explicitly told not to move specific files

## Revision History
- **2026-03-14:** Rule established by Clawdia
- **Next review:** 2026-04-14