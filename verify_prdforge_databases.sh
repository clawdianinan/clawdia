#!/bin/bash

# PRDForge Database Verification Script
# Compares OLD vs NEW Supabase databases after migration

set -e

# Database connection strings
OLD_DB="postgresql://postgres:PTLUfGi7fwFdk5x1@db.jnlkzcmeiksqljnbtfhb.supabase.co:5432/postgres"
NEW_DB="postgresql://postgres:cVHV8VFB61QVd8nv@db.eflrqvxmqrtbytkxyrze.supabase.co:5432/postgres"

# Output file
REPORT_FILE="database_comparison_report_$(date +%Y%m%d_%H%M%S).md"

echo "# PRDForge Database Migration Verification Report" > $REPORT_FILE
echo "Generated: $(date)" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "## Phase 1: Database Connection Test" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Test connections
echo "Testing OLD database connection..." | tee -a $REPORT_FILE
if psql "$OLD_DB" -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ OLD database connection successful" >> $REPORT_FILE
else
    echo "❌ OLD database connection failed" >> $REPORT_FILE
    exit 1
fi

echo "Testing NEW database connection..." | tee -a $REPORT_FILE
if psql "$NEW_DB" -c "SELECT version();" > /dev/null 2>&1; then
    echo "✅ NEW database connection successful" >> $REPORT_FILE
else
    echo "❌ NEW database connection failed" >> $REPORT_FILE
    exit 1
fi

echo "" >> $REPORT_FILE
echo "## Phase 2: Table Structure Comparison" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Get list of tables from both databases
OLD_TABLES=$(psql "$OLD_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")
NEW_TABLES=$(psql "$NEW_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")

echo "### Tables in OLD database:" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
echo "$OLD_TABLES" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
echo "" >> $REPORT_FILE

echo "### Tables in NEW database:" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
echo "$NEW_TABLES" >> $REPORT_FILE
echo "\`\`\`" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Compare table lists
echo "### Table Comparison Results:" >> $REPORT_FILE
MISSING_IN_NEW=$(comm -23 <(echo "$OLD_TABLES" | sort) <(echo "$NEW_TABLES" | sort))
MISSING_IN_OLD=$(comm -13 <(echo "$OLD_TABLES" | sort) <(echo "$NEW_TABLES" | sort))

if [ -z "$MISSING_IN_NEW" ]; then
    echo "✅ All tables from OLD database are present in NEW database" >> $REPORT_FILE
else
    echo "❌ Tables missing in NEW database:" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
    echo "$MISSING_IN_NEW" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
fi

if [ -n "$MISSING_IN_OLD" ]; then
    echo "⚠️  Extra tables in NEW database (not in OLD):" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
    echo "$MISSING_IN_OLD" >> $REPORT_FILE
    echo "\`\`\`" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "## Phase 3: User Data Verification" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Check auth.users table
echo "### auth.users table comparison:" >> $REPORT_FILE

OLD_USERS_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM auth.users;" | tr -d ' ')
NEW_USERS_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" | tr -d ' ')

echo "OLD database users: $OLD_USERS_COUNT" >> $REPORT_FILE
echo "NEW database users: $NEW_USERS_COUNT" >> $REPORT_FILE

if [ "$OLD_USERS_COUNT" -eq "$NEW_USERS_COUNT" ]; then
    echo "✅ User count matches" >> $REPORT_FILE
else
    echo "❌ User count mismatch!" >> $REPORT_FILE
    echo "Difference: $((OLD_USERS_COUNT - NEW_USERS_COUNT))" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "### User email list comparison:" >> $REPORT_FILE

OLD_USER_EMAILS=$(psql "$OLD_DB" -t -c "SELECT email FROM auth.users ORDER BY email;" | tr '\n' ',' | sed 's/,$//')
NEW_USER_EMAILS=$(psql "$NEW_DB" -t -c "SELECT email FROM auth.users ORDER BY email;" | tr '\n' ',' | sed 's/,$//')

echo "OLD user emails: $OLD_USER_EMAILS" >> $REPORT_FILE
echo "NEW user emails: $NEW_USER_EMAILS" >> $REPORT_FILE

echo "" >> $REPORT_FILE
echo "## Phase 4: PRDForge Tables Data Counts" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Check all prdforge_* tables
PRDFORGE_TABLES=$(echo "$OLD_TABLES" | grep -i "prdforge")

for table in $PRDFORGE_TABLES; do
    echo "### Table: $table" >> $REPORT_FILE
    
    OLD_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
    NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
    
    echo "OLD count: $OLD_COUNT" >> $REPORT_FILE
    echo "NEW count: $NEW_COUNT" >> $REPORT_FILE
    
    if [ "$OLD_COUNT" -eq "$NEW_COUNT" ]; then
        echo "✅ Count matches" >> $REPORT_FILE
    else
        echo "❌ Count mismatch!" >> $REPORT_FILE
        echo "Difference: $((OLD_COUNT - NEW_COUNT))" >> $REPORT_FILE
    fi
    echo "" >> $REPORT_FILE
done

echo "" >> $REPORT_FILE
echo "## Phase 5: Sample Data Verification" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Sample check for first 5 rows in key tables
KEY_TABLES="auth.users prdforge_projects prdforge_prds"

for table in $KEY_TABLES; do
    if echo "$OLD_TABLES" | grep -q "^$table$"; then
        echo "### Sample data from $table (first 3 rows):" >> $REPORT_FILE
        echo "\`\`\`sql" >> $REPORT_FILE
        psql "$OLD_DB" -c "SELECT * FROM \"$table\" LIMIT 3;" 2>/dev/null | head -20 >> $REPORT_FILE
        echo "\`\`\`" >> $REPORT_FILE
        echo "" >> $REPORT_FILE
    fi
done

echo "" >> $REPORT_FILE
echo "## Phase 6: Summary" >> $REPORT_FILE
echo "" >> $REPORT_FILE

# Calculate overall status
TOTAL_TABLES=$(echo "$OLD_TABLES" | wc -l)
MISSING_COUNT=$(echo "$MISSING_IN_NEW" | wc -l)

if [ "$MISSING_COUNT" -eq 0 ] && [ "$OLD_USERS_COUNT" -eq "$NEW_USERS_COUNT" ]; then
    echo "✅ **MIGRATION SUCCESSFUL**" >> $REPORT_FILE
    echo "All $TOTAL_TABLES tables and $OLD_USERS_COUNT users migrated successfully." >> $REPORT_FILE
else
    echo "⚠️  **MIGRATION ISSUES DETECTED**" >> $REPORT_FILE
    echo "- Missing tables: $MISSING_COUNT" >> $REPORT_FILE
    echo "- User count mismatch: OLD=$OLD_USERS_COUNT, NEW=$NEW_USERS_COUNT" >> $REPORT_FILE
    echo "" >> $REPORT_FILE
    echo "**Recommended actions:**" >> $REPORT_FILE
    echo "1. Check missing tables: $MISSING_IN_NEW" >> $REPORT_FILE
    echo "2. Verify user migration" >> $REPORT_FILE
    echo "3. Run targeted data transfer for missing tables" >> $REPORT_FILE
fi

echo "" >> $REPORT_FILE
echo "---" >> $REPORT_FILE
echo "Report generated by PRDForge Database Verification Script" >> $REPORT_FILE

echo ""
echo "✅ Database verification complete!"
echo "📊 Report saved to: $REPORT_FILE"
echo ""
echo "To view the report:"
echo "  cat $REPORT_FILE"
echo ""
echo "Next steps:"
echo "  1. Review the report above"
echo "  2. If issues found, run targeted migration scripts"
echo "  3. Test the application with migrated data"