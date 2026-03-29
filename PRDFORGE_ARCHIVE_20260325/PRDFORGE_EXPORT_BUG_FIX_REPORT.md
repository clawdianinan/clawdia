# PRDForge Export Bug Fix Report - [object] Tags Issue
**Date:** March 25, 2026  
**Time:** 23:15 WAT  
**Criticality:** 🚨 HIGH - Export functionality broken

## 🚨 **IDENTIFIED BUG: [object] Tags in Export Output**

### **Problem:**
Users get `[object Object]` tags instead of proper content when copying/exporting PRDs.

### **Root Cause:**
Database fields contain **JSON objects** instead of **strings**, and export functions don't handle this correctly.

## 🔍 **Technical Analysis**

### **1. Database Schema Issues:**
- **`prdforge_modules.dependencies`**: `TEXT[]` but might contain objects
- **`prdforge_feature_nodes.dependencies`**: `TEXT[]` but might contain objects  
- **`prdforge_prd_sections.content`**: `TEXT` but might store JSON objects
- **`prdforge_guardrails.description`**: `TEXT` but might store JSON objects
- **`prdforge_tasks.description`**: `TEXT` but might store JSON objects

### **2. Code Issues in `ExportView.tsx`:**
```typescript
// PROBLEM: Assumes dependencies are strings, but they might be objects
if (m.dependencies?.length) lines.push(`**Dependencies:** ${m.dependencies.join(", ")}\n`);

// PROBLEM: Assumes description is string, but might be object
if (g.description) lines.push(`${g.description}\n`);

// PROBLEM: Assumes content is string, but might be object
lines.push((s.content || "") + "\n");
```

### **3. Data Flow Problem:**
```
AI Generation → Stores objects in text fields → Export assumes strings → [object] tags
```

## 🧪 **Reproduction Steps**

1. Generate a PRD with AI
2. Go to Export view
3. Click "Copy to clipboard" or any export option
4. **Result:** Output contains `[object Object]` tags

## 🔧 **Fix Strategy**

### **Immediate Fix (Export Functions):**
Add type guards to all export functions:

```typescript
// FIXED: Handle both strings and objects
const content = typeof s.content === 'string' ? s.content : JSON.stringify(s.content, null, 2);

// FIXED: Handle array of strings or objects
const depNames = m.dependencies.map(d => 
  typeof d === 'string' ? d : d?.name || JSON.stringify(d)
);

// FIXED: Handle object descriptions
const desc = typeof g.description === 'string' ? g.description : JSON.stringify(g.description, null, 2);
```

### **Long-term Fix (Data Source):**
1. Fix AI generation to store strings, not objects
2. Add database validation
3. Add data migration for existing bad data

## 📋 **Files to Fix**

### **1. `src/components/workspace/views/ExportView.tsx`**
- `buildMarkdown()` function
- `buildJSON()` function  
- `buildCSV()` function
- `buildPrintHTML()` function
- `buildClaudeMd()` function
- `buildAgentsMd()` function

### **2. Edge Functions that generate data:**
- `supabase/functions/prdforge-ai/index.ts`
- Check all AI generation functions

### **3. Database Migrations:**
Consider changing `TEXT` to `JSONB` for fields that store structured data

## 🧪 **Test Cases to Verify Fix**

### **Test 1: String Data**
```typescript
const goodData = {
  content: "This is a string",
  dependencies: ["auth", "database"],
  description: "Simple description"
};
// Should work without changes
```

### **Test 2: Object Data**  
```typescript
const badData = {
  content: { summary: "Object content" },
  dependencies: [{id: 1, name: "auth"}],
  description: { requirements: ["HTTPS"] }
};
// Should be converted to readable strings
```

### **Test 3: Mixed Data**
```typescript
const mixedData = {
  content: "String content",
  dependencies: ["auth", {id: 2, name: "database"}],
  description: "String description"
};
// Should handle both types gracefully
```

## 🚀 **Implementation Plan**

### **Phase 1: Emergency Export Fix (Immediate)**
1. Fix `buildMarkdown()` with type guards
2. Fix `buildJSON()`, `buildCSV()`, `buildPrintHTML()`
3. Test all export formats
4. Deploy fix

### **Phase 2: Data Source Fix (Short-term)**
1. Audit AI generation functions
2. Ensure string storage in database
3. Add validation to prevent object storage
4. Data migration for existing bad data

### **Phase 3: Prevention (Long-term)**
1. Database schema improvements
2. Comprehensive export tests
3. TypeScript strict typing
4. Data validation middleware

## 📊 **Impact Assessment**

### **Affected Users:**
- **All users** trying to export PRDs
- **Free tier users** (can't use paid features without export)
- **Paid users** (export is a key feature)

### **Business Impact:**
- **High:** Makes core functionality unusable
- **High:** Negative user experience
- **Medium:** Potential churn risk
- **High:** Damages product credibility

### **Technical Debt:**
- **High:** Data type inconsistencies
- **Medium:** Lack of validation
- **Low:** Easy to fix with type guards

## 🎯 **Success Criteria**

### **Fixed When:**
1. No `[object]` tags in any export format
2. All data is readable and properly formatted
3. All export functions work correctly
4. Edge cases handled (null, undefined, objects, arrays)

### **Testing Requirements:**
- [ ] Markdown export works
- [ ] JSON export works  
- [ ] CSV export works
- [ ] HTML/print export works
- [ ] Claude format export works
- [ ] Agents format export works
- [ ] Copy to clipboard works
- [ ] External exports work (Google Docs/Sheets)
- [ ] All data types handled correctly

## 🔧 **Code Changes Required**

### **1. Type Guard Utility:**
```typescript
export function safeToString(value: any): string {
  if (value === null || value === undefined) return '';
  if (typeof value === 'string') return value;
  if (Array.isArray(value)) {
    return value.map(v => safeToString(v)).join(', ');
  }
  return JSON.stringify(value, null, 2);
}

export function safeExtractName(value: any): string {
  if (typeof value === 'string') return value;
  if (value?.name) return value.name;
  return safeToString(value);
}
```

### **2. Fixed buildMarkdown():**
```typescript
const buildMarkdown = () => {
  // Use safeToString() for all content
  lines.push(safeToString(s.content) + "\n");
  
  // Use safeExtractName() for dependencies
  const depNames = m.dependencies?.map(safeExtractName) || [];
  lines.push(`**Dependencies:** ${depNames.join(", ")}\n`);
};
```

## 📈 **Priority: 🚨 CRITICAL**

### **Timeline:**
- **Immediate:** Fix export functions (1-2 hours)
- **Today:** Test and deploy fix
- **This week:** Fix data source issues
- **Next week:** Add comprehensive tests

### **Risk if Not Fixed:**
- Users cannot use exported PRDs
- Negative reviews and churn
- Damaged reputation
- Wasted development on broken feature

## 🏁 **Conclusion**

The export functionality is **critically broken** due to data type mismatches. Users get `[object]` tags instead of usable content. 

**Immediate action required:** Fix export functions with proper type guards.

**Long-term solution:** Fix data at source and improve database schema.

**Status:** 🚨 **EXPORT FUNCTIONALITY BROKEN - REQUIRES IMMEDIATE FIX**

**Report Prepared By:** Morpheus (QA & API Testing Lead) via Clawdia  
**Date:** March 25, 2026, 23:15 WAT