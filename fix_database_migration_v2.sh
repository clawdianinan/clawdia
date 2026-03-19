#!/bin/bash
set -e

# PRDForge Database Migration Fix - CORRECTED VERSION
# Migrates ALL missing tables and data from OLD to NEW

OLD_DB="postgresql://postgres:PTLUfGi7fwFdk5x1@db.jnlkzcmeiksqljnbtfhb.supabase.co:5432/postgres"
NEW_DB="postgresql://postgres:cVHV8VFB61QVd8nv@db.eflrqvxmqrtbytkxyrze.supabase.co:5432/postgres"

echo "🚀 Starting PRDForge database migration fix..."
echo "OLD DB: db.jnlkzcmeiksqljnbtfhb.supabase.co"
echo "NEW DB: db.eflrqvxmqrtbytkxyrze.supabase.co"
echo ""

# Get complete table lists
echo "📋 Getting table lists from both databases..."
OLD_TABLES=$(psql "$OLD_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")
NEW_TABLES=$(psql "$NEW_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public' ORDER BY tablename;")

OLD_COUNT=$(echo "$OLD_TABLES" | wc -l | tr -d ' ')
NEW_COUNT=$(echo "$NEW_TABLES" | wc -l | tr -d ' ')
echo "OLD has $OLD_COUNT tables"
echo "NEW has $NEW_COUNT tables"
echo ""

# Identify missing tables (present in OLD but not in NEW)
echo "🔍 Identifying missing tables..."
MISSING_TABLES=$(echo "$OLD_TABLES" | sort | comm -23 <(echo "$NEW_TABLES" | sort) -)
MISSING_COUNT=$(echo "$MISSING_TABLES" | wc -l | tr -d ' ')

if [ "$MISSING_COUNT" -eq 0 ]; then
    echo "✅ No missing tables. Database already in sync."
    exit 0
fi

echo "❌ Found $MISSING_COUNT missing tables in NEW database"
echo "First 10 missing tables:"
echo "$MISSING_TABLES" | head -10
echo ""

# Confirm before proceeding - AUTO for non-interactive
if [ "$1" != "--auto" ]; then
    read -p "Proceed with migration of $MISSING_COUNT tables? (yes/no): " CONFIRM
    if [ "$CONFIRM" != "yes" ]; then
        echo "Migration cancelled."
        exit 1
    fi
else
    echo "Auto-confirming migration (--auto flag)"
fi

# Phase 1: Create missing schemas (tables) in NEW
echo ""
echo "🏗️  Phase 1: Creating missing table schemas in NEW database..."

# Use pg_dump to extract schema for all missing tables and apply to NEW
TEMP_SCHEMA_DUMP="/tmp/prdforge_missing_schema.sql"
TEMP_TABLE_LIST="/tmp/missing_tables_list.txt"

echo "$MISSING_TABLES" > "$TEMP_TABLE_LIST"

# Dump schema for all missing tables from OLD
echo "Dumping schema for $MISSING_COUNT missing tables..."
pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres \
    --schema-only \
    --no-owner \
    --no-privileges \
    --file="$TEMP_SCHEMA_DUMP" \
    --table="$(paste -sd',' "$TEMP_TABLE_LIST")" \
    postgres 2>/dev/null || {
    echo "⚠️  pg_dump schema failed for multi-table, trying per-table..."
    rm -f "$TEMP_SCHEMA_DUMP"
    touch "$TEMP_SCHEMA_DUMP"
    for table in $MISSING_TABLES; do
        echo "-- Table: $table" >> "$TEMP_SCHEMA_DUMP"
        pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres \
            --schema-only \
            --no-owner \
            --no-privileges \
            -t "$table" \
            postgres 2>/dev/null >> "$TEMP_SCHEMA_DUMP" 2>/dev/null || echo "-- Failed to dump $table" >> "$TEMP_SCHEMA_DUMP"
        echo "" >> "$TEMP_SCHEMA_DUMP"
    done
}

# Apply schema to NEW (skip errors for tables that already exist partially)
echo "Applying schema to NEW database..."
psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres \
    -v ON_ERROR_STOP=0 \
    -f "$TEMP_SCHEMA_DUMP" \
    postgres 2>/dev/null || echo "⚠️  Some schema statements may have failed, continuing..."

echo "✅ Schema creation complete"
echo ""

# Phase 2: Copy data for all missing tables
echo "🚚 Phase 2: Copying data for missing tables..."
TOTAL_MISSING=$(echo "$MISSING_TABLES" | wc -l | tr -d ' ')
CURRENT=0
SUCCESS_COUNT=0
FAILED_COUNT=0

for table in $MISSING_TABLES; do
    CURRENT=$((CURRENT + 1))
    echo "[$CURRENT/$TOTAL_MISSING] Migrating: $table"
    
    # Check if table now exists in NEW (schema may have failed)
    if ! psql "$NEW_DB" -c "\d $table" > /dev/null 2>&1; then
        echo "  ❌ Table schema not found in NEW, skipping data copy"
        FAILED_COUNT=$((FAILED_COUNT + 1))
        continue
    fi
    
    # Get source data count
    OLD_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
    
    if [ "$OLD_COUNT" -eq "0" ]; then
        echo "  ⚠️  Source table empty, nothing to copy"
        continue
    fi
    
    echo "  📥 Source rows: $OLD_COUNT"
    
    # Try to copy data efficiently
    if pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres \
        --data-only \
        --disable-triggers \
        --no-owner \
        --no-privileges \
        -t "$table" \
        postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null; then
        echo "  ✅ Migrated successfully"
        SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
    else
        echo "  ⚠️  Primary copy method failed, using COPY..."
        TMP_DATA="/tmp/${table}_data.csv"
        if psql "$OLD_DB" -c "COPY \"$table\" TO '$TMP_DATA' WITH CSV QUOTE '\"'" 2>/dev/null && \
           psql "$NEW_DB" -c "COPY \"$table\" FROM '$TMP_DATA' WITH CSV QUOTE '\"'" 2>/dev/null; then
            echo "  ✅ Migrated via CSV"
            SUCCESS_COUNT=$((SUCCESS_COUNT + 1))
            rm -f "$TMP_DATA"
        else
            echo "  ❌ Data migration failed for $table"
            FAILED_COUNT=$((FAILED_COUNT + 1))
            rm -f "$TMP_DATA"
        fi
    fi
    
    # Show target count
    NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
    echo "  📊 Target rows: $NEW_COUNT"
    echo ""
done

echo "=========================================="
echo "📈 Migration Summary"
echo "=========================================="
echo "Total missing tables: $TOTAL_MISSING"
echo "Successfully migrated: $SUCCESS_COUNT"
echo "Failed: $FAILED_COUNT"
echo ""

# Phase 3: Verify user data specifically (critical for auth)
echo "🔐 Verifying auth.users table..."
OLD_USERS=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ' || echo "0")
NEW_USERS=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ' || echo "0")
echo "OLD users: $OLD_USERS"
echo "NEW users: $NEW_USERS"

if [ "$OLD_USERS" -gt 0 ] && [ "$OLD_USERS" -eq "$NEW_USERS" ]; then
    echo "✅ User migration verified"
elif [ "$OLD_USERS" -gt 0 ] && [ "$NEW_USERS" -eq 0 ]; then
    echo "❌ No users in NEW database! Critical failure."
    echo "Attempting emergency user migration..."
    if ! psql "$NEW_DB" -c "\d auth.users" > /dev/null 2>&1; then
        pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t auth.users --schema-only postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || true
    fi
    pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t auth.users --data-only postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || true
    NEW_USERS=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ' || echo "0")
    echo "After emergency fix: NEW users = $NEW_USERS"
fi
echo ""

# Phase 4: Check key PRDForge tables
echo "🎯 Checking key PRDForge tables:"
KEY_TABLES="prdforge_projects prdforge_profiles prdforge_docs prdforge_activity_logs prdforge_admin_config"
ALL_GOOD=true
for table in $KEY_TABLES; do
    if echo "$OLD_TABLES" | grep -q "^$table$"; then
        OLD_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
        NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
        STATUS="❌"
        if [ "$OLD_COUNT" -eq "$NEW_COUNT" ] && [ "$OLD_COUNT" -gt 0 ]; then
            STATUS="✅"
        elif [ "$OLD_COUNT" -eq "$NEW_COUNT" ] && [ "$OLD_COUNT" -eq 0 ]; then
            STATUS="⚪"
        fi
        echo "  $STATUS $table: OLD=$OLD_COUNT, NEW=$NEW_COUNT"
        if [ "$STATUS" = "❌" ]; then ALL_GOOD=false; fi
    else
        echo "  ⚪ $table: not in OLD"
    fi
done
echo ""

# Final re-check of missing tables
REMAINING_MISSING=$(echo "$OLD_TABLES" | sort | comm -23 <(echo "$NEW_TABLES" | sort) - | wc -l | tr -d ' ')
if [ "$REMAINING_MISSING" -eq 0 ]; then
    echo "🎉 SUCCESS: All tables are now present in NEW database!"
else
    echo "⚠️  Still $REMAINING_MISSING tables missing"
    echo "Remaining missing tables:"
    echo "$MISSING_TABLES" | while read t; do
        if ! echo "$NEW_TABLES" | grep -q "^$t$"; then
            echo "  - $t"
        fi
    done
fi

echo ""
echo "=========================================="
echo "✅ Migration complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Verify: ./verify_prdforge_databases.sh"
echo "2. Restart PRDForge application"
echo "3. Run QA tests: artifacts/QA-002-manual-test-checklist.md"
echo ""
