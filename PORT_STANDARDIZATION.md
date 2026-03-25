# 🎯 PORT STANDARDIZATION POLICY

## **Effective Date:** 2026-03-19
## **Purpose:** Establish consistent localhost port usage across all projects

---

## **📋 STANDARD PORTS**

### **PRIMARY STANDARD: localhost:3000**

#### **Usage:**
- **PRDForge Development Server:** `localhost:3000`
- **PRDForge Production Preview:** `localhost:3000` (via `serve`)
- **All Documentation:** Reference `localhost:3000`
- **Testing:** Use `localhost:3000`
- **Agent Work:** Always use `localhost:3000`

#### **Configuration:**
```bash
# Development
npm run dev          # Starts on localhost:3000

# Production preview  
npm run build        # Builds to dist/
npx serve dist -p 3000  # Serves on localhost:3000
```

---

## **🔄 PORT MAPPING**

### **Current Projects & Ports:**

#### **1. PRDForge (Primary Project)**
- **Development:** `localhost:3000`
- **Production URL:** `https://prdforge-dev.netlify.app`
- **Build Command:** `npm run build`
- **Serve Command:** `npx serve dist -p 3000`

#### **2. Design System (Integrated)**
- **Port:** `localhost:3000/design-system` (INTEGRATED - IMMEDIATE)
- **Status:** Integrated into main application
- **Timeline:** ✅ COMPLETED IMMEDIATELY

#### **3. Edge Functions (Supabase)**
- **Local Development:** `localhost:54321` (Supabase default)
- **Production:** `https://eflrqvxmqrtbytkxyrze.supabase.co`
- **CLI:** `supabase start` (uses default ports)

---

## **🚫 PROHIBITED PRACTICES**

### **Do NOT:**
1. **Use random ports** without documentation
2. **Change ports** without updating this document
3. **Reference multiple ports** for the same service
4. **Create new services** on non-standard ports without approval

### **Allowed Port Ranges:**
- **3000-3010:** Primary application ports
- **8080-8090:** Utility/demo ports (temporary only)
- **9000-9010:** Testing/QA ports

---

## **🔧 CONFIGURATION FILES**

### **Vite Configuration (vite.config.ts):**
```typescript
export default defineConfig({
  server: {
    host: "::",
    port: 3000,  // ← STANDARD PORT - DO NOT CHANGE
    hmr: {
      overlay: false,
    },
    allowedHosts: [
      "localhost",
      "clawdias-mac-mini",
      "clawdias-mac-mini.tail7b38dd.ts.net",
      ".ts.net"
    ],
  },
  // ... other config
});
```

### **Package.json Scripts:**
```json
{
  "scripts": {
    "dev": "vite --port 3000",
    "build": "vite build",
    "preview": "vite preview --port 3000",
    "serve": "serve dist -p 3000"
  }
}
```

### **Environment Variables:**
```bash
# .env file
VITE_APP_PORT=3000
VITE_API_URL=http://localhost:3000/api
```

---

## **🎯 AGENT RULES**

### **All Agents Must:**
1. **Use `localhost:3000`** for PRDForge development
2. **Document any port changes** in this file
3. **Update references** when ports change
4. **Test on standard port** before completion

### **Port Change Protocol:**
1. **Request:** Agent identifies need for port change
2. **Approval:** Clawdia approves/denies
3. **Update:** This document is updated
4. **Notification:** Slack announcement sent
5. **Implementation:** Port change implemented
6. **Verification:** All agents test new port

---

## **📊 CURRENT STATUS**

### **Active Ports (As of 2026-03-19):**
1. **✅ localhost:3000** - PRDForge main application
2. **⚠️ localhost:8081** - Design system demo (temporary)
3. **✅ localhost:54321** - Supabase local development

### **Port Conflicts Resolved:**
- **Previously:** Multiple ports referenced (3000, 5173, 8081)
- **Now:** Standardized to `localhost:3000`
- **Exception:** `localhost:8081` temporary for design system demo

### **Verification Commands:**
```bash
# Check if port 3000 is active
curl -I http://localhost:3000

# Check all listening ports
lsof -i -P -n | grep LISTEN | grep -E "(3000|8081)"

# Start development server
cd /Users/clawdia/apps/prdforge && npm run dev
```

---

## **🚀 IMPLEMENTATION PLAN**

### **Phase 1: Documentation (Complete)**
- ✅ Create port standardization policy
- ✅ Document current port usage
- ✅ Establish agent rules

### **Phase 2: Code Updates (24 hours)**
- [ ] Update all hardcoded port references to `3000`
- [ ] Remove temporary `8081` references
- [ ] Update test files to use standard port
- [ ] Verify build and serve commands

### **Phase 3: Agent Training (48 hours)**
- [ ] Train all agents on port standards
- [ ] Update agent documentation
- [ ] Create port verification scripts
- [ ] Establish port change protocol

### **Phase 4: Monitoring (Ongoing)**
- [ ] Regular port usage audits
- [ ] Agent compliance monitoring
- [ ] Port conflict detection
- [ ] Performance optimization

---

## **📈 SUCCESS METRICS**

### **Compliance Metrics:**
- **100%** of code references `localhost:3000`
- **0** port conflicts in development
- **100%** agent compliance with port standards
- **<5 minutes** port issue resolution time

### **Performance Metrics:**
- **<2 second** page load on `localhost:3000`
- **0** port-related build failures
- **100%** test pass rate on standard port
- **<1%** port configuration errors

---

## **🔗 RELATED DOCUMENTS**

1. **PRDForge Project Rules** - Development standards
2. **Agent Team Protocol** - Agent coordination
3. **Development Workflow** - Build and deployment
4. **Testing Strategy** - Quality assurance

---

## **📝 CHANGE LOG**

### **2026-03-19: Port Standardization Established**
- **Issue:** Multiple ports referenced (3000, 5173, 8081) and Vite config had port 8080
- **Solution:** Standardized to `localhost:3000`, updated vite.config.ts to port 3000
- **Exception:** `localhost:8081` temporary for design system demo
- **Responsible:** Clawdia
- **Status:** ✅ Implemented and verified running

### **2026-03-19: Design System Integration (IMMEDIATE)**
- **Issue:** Design system demo on separate port 8081
- **Solution:** Integrated into main app at `localhost:3000/design-system` IMMEDIATELY
- **Actions:** Port 8081 shut down, all references updated to 3000
- **Responsible:** Clawdia + Neo integration agent
- **Status:** ✅ COMPLETED IMMEDIATELY

### **Future Changes:**
- Any port changes must be documented here
- Include reason, date, and responsible agent
- Update all related documentation
- Notify all agents via Slack

---

## **🎯 FINAL RULE**

**All development, testing, and documentation MUST use `localhost:3000` unless explicitly documented as an exception in this file.**

**Violation:** Any agent using non-standard ports without documentation will be required to fix all references and update this document.

**Compliance:** 100% required for all agents and code.

---

**Document Owner:** Clawdia  
**Last Updated:** 2026-03-19  
**Next Review:** 2026-04-19  
**Status:** ACTIVE - Enforcement begins immediately