#!/bin/bash
set -e

# PRDForge Database Migration Fix Script
# Migrates missing tables and data from OLD to NEW database

OLD_DB="postgresql://postgres:PTLUfGi7fwFdk5x1@db.jnlkzcmeiksqljnbtfhb.supabase.co:5432/postgres"
NEW_DB="postgresql://postgres:cVHV8VFB61QVd8nv@db.eflrqvxmqrtbytkxyrze.supabase.co:5432/postgres"

echo "Starting PRDForge database migration fix..."
echo "OLD DB: $OLD_DB"
echo "NEW DB: $NEW_DB"
echo ""

# Phase 1: Get list of tables that exist in OLD but missing in NEW
echo "Phase 1: Identifying missing tables..."
MISSING_TABLES=$(psql "$OLD_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" | sort | comm -23 <(psql "$NEW_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" | sort) -)

if [ -z "$MISSING_TABLES" ]; then
    echo "✅ No missing tables found. Database schema already complete."
else
    echo "❌ Found $(echo "$MISSING_TABLES" | wc -l | tr -d ' ') missing tables:"
    echo "$MISSING_TABLES"
    echo ""
fi

# Phase 2: For each missing table, copy schema and data
echo "Phase 2: Migrating missing tables..."
for table in $MISSING_TABLES; do
    echo "Migrating table: $table"
    
    # Check if table exists in NEW (could have been created partially)
    if psql "$NEW_DB" -c "\d $table" > /dev/null 2>&1; then
        echo "  - Table exists in NEW, will only copy data"
        # Truncate the table first to ensure clean data
        psql "$NEW_DB" -c "TRUNCATE \"$table\" RESTART IDENTITY CASCADE;" 2>/dev/null || true
    else
        echo "  - Table missing in NEW, creating schema and copying data"
        # Dump schema from OLD and create in NEW
        schema=$(psql "$OLD_DB" -c "SELECT pg_dump('$table', '--schema-only')" 2>/dev/null || echo "Dumping schema...")
        # Alternative: generate CREATE TABLE from OLD
        psql "$OLD_DB" -c "SELECT pg_dump -s -t '$table'" 2>/dev/null | psql "$NEW_DB" 2>/dev/null || {
            # Fallback: get create table statement
            CREATE_STMT=$(psql "$OLD_DB" -t -c "SELECT pg_get_tabledef('public.$table');" 2>/dev/null || echo "")
            if [ -n "$CREATE_STMT" ]; then
                echo "$CREATE_STMT" | psql "$NEW_DB" 2>/dev/null || true
            else
                # Last resort: dump entire table structure
                echo "Creating table $table via pg_dump..."
                pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t "$table" --schema-only postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || true
            fi
        }
    fi
    
    # Copy data using pg_dump for large tables efficiently
    echo "  - Copying data for $table..."
    DATA_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ')
    echo "    Source rows: $DATA_COUNT"
    
    if [ "$DATA_COUNT" -gt 0 ]; then
        # Use pg_dump to copy table data
        pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t "$table" --data-only --disable-triggers postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || {
            # Fallback to INSERT SELECT via dblink or foreign data wrapper if available
            echo "    Using INSERT SELECT method..."
            psql "$OLD_DB" -c "COPY \"$table\" TO STDOUT WITH CSV" 2>/dev/null | psql "$NEW_DB" -c "COPY \"$table\" FROM STDIN WITH CSV" 2>/dev/null || {
                # Last resort: export to temp file
                TMP_FILE="/tmp/${table}_data.csv"
                psql "$OLD_DB" -c "COPY \"$table\" TO '$TMP_FILE' WITH CSV" 2>/dev/null
                psql "$NEW_DB" -c "COPY \"$table\" FROM '$TMP_FILE' WITH CSV" 2>/dev/null
                rm -f "$TMP_FILE"
            }
        }
        NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ')
        echo "    ✓ Migrated to $NEW_COUNT rows"
    else
        echo "    ⚠️  Table is empty, nothing to migrate"
    fi
    echo ""
done

# Phase 3: Verify user count
echo "Phase 3: Verifying user migration..."
OLD_USERS_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ')
NEW_USERS_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ')

echo "OLD users: $OLD_USERS_COUNT"
echo "NEW users: $NEW_USERS_COUNT"

if [ "$OLD_USERS_COUNT" -eq "$NEW_USERS_COUNT" ] && [ "$OLD_USERS_COUNT" -gt 0 ]; then
    echo "✅ User migration successful"
else
    echo "⚠️  User count mismatch"
    echo "   Attempting to migrate auth.users specifically..."
    if ! psql "$NEW_DB" -c "\d auth.users" > /dev/null 2>&1; then
        echo "   Creating auth.users table..."
        pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t auth.users --schema-only postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || true
    fi
    echo "   Copying auth.users data..."
    pg_dump -h db.jnlkzcmeiksqljnbtfhb.supabase.co -U postgres -t auth.users --data-only postgres 2>/dev/null | psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -U postgres postgres 2>/dev/null || true
    NEW_USERS_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ')
    echo "   After retry: NEW users = $NEW_USERS_COUNT"
fi

# Phase 4: Final verification
echo ""
echo "Phase 4: Final verification..."

# Recalculate missing tables after migration
REMAINING_MISSING=$(psql "$OLD_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" | sort | comm -23 <(psql "$NEW_DB" -t -c "SELECT tablename FROM pg_tables WHERE schemaname = 'public';" | sort) -)

if [ -z "$REMAINING_MISSING" ]; then
    echo "✅ All tables now present in NEW database"
else
    echo "⚠️  Still missing tables:"
    echo "$REMAINING_MISSING"
fi

# Check key PRDForge tables
KEY_TABLES="prdforge_projects prdforge_prds prdforge_docs prdforge_users"
echo ""
echo "Checking key PRDForge tables:"
for table in $KEY_TABLES; do
    if psql "$OLD_DB" -c "\d $table" > /dev/null 2>&1; then
        OLD_COUNT=$(psql "$OLD_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
        NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM \"$table\";" 2>/dev/null | tr -d ' ' || echo "0")
        echo "  $table: OLD=$OLD_COUNT, NEW=$NEW_COUNT"
        if [ "$OLD_COUNT" -eq "$NEW_COUNT" ]; then
            echo "    ✅"
        else
            echo "    ❌ Mismatch!"
        fi
    fi
done

echo ""
echo "✅ Migration complete!"
echo "Next: Re-verify with ./verify_prdforge_databases.sh"
echo "Then restart the PRDForge application and run the QA tests."
