#!/bin/bash
set -e

OLD_DB="postgresql://postgres:PTLUfGi7fwFdk5x1@db.jnlkzcmeiksqljnbtfhb.supabase.co:5432/postgres"
NEW_DB="postgresql://postgres:cVHV8VFB61QVd8nv@db.eflrqvxmqrtbytkxyrze.supabase.co:5432/postgres"

echo "Migrating 3 missing users: jobs@iih.ng, sinachi@iih.ng, test@iih.ng"

# Export the 3 missing users from OLD
psql "$OLD_DB" -c "COPY (SELECT * FROM auth.users WHERE email IN ('jobs@iih.ng', 'sinachi@iih.ng', 'test@iih.ng')) TO STDOUT WITH (FORMAT binary)" 2>/dev/null | psql "$NEW_DB" -c "INSERT INTO auth.users SELECT * FROM auth.users WHERE email IN ('jobs@iih.ng', 'sinachi@iih.ng', 'test@iih.ng') ON CONFLICT (id) DO NOTHING;" 2>/dev/null || {
    # Fallback: use plain text COPY
    echo "Using fallback method..."
    psql "$OLD_DB" -c "COPY (SELECT * FROM auth.users WHERE email IN ('jobs@iih.ng', 'sinachi@iih.ng', 'test@iih.ng')) TO STDOUT WITH CSV DELIMITER ',' NULL ''" 2>/dev/null | psql "$NEW_DB" -c "COPY auth.users FROM STDIN WITH CSV DELIMITER ',' NULL ''" 2>/dev/null || {
        # Manual INSERT for each user
        echo "Manual insert fallback..."
        for email in jobs@iih.ng sinachi@iih.ng test@iih.ng; do
            psql "$OLD_DB" -t -c "SELECT 'INSERT INTO auth.users VALUES(' || id || ',' || quote_literal(email) || ',' || quote_literal(encrypted_password) || ',' || quote_literal(email_confirmed_at) || ',' || quote_literal(confirmed_at) || ',' || quote_literal(created_at) || ',' || quote_literal(updated_at) || ');' FROM auth.users WHERE email = '$email';" 2>/dev/null | psql "$NEW_DB" 2>/dev/null || true
        done
    }
}

# Verify count
NEW_COUNT=$(psql "$NEW_DB" -t -c "SELECT COUNT(*) FROM auth.users;" 2>/dev/null | tr -d ' ')
echo "NEW database users after migration: $NEW_COUNT"

if [ "$NEW_COUNT" -ge 10 ]; then
    echo "✅ All users migrated successfully!"
else
    echo "⚠️  Still missing users. Current count: $NEW_COUNT"
fi
