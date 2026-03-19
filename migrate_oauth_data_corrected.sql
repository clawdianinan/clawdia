-- Corrected migration script for OAuth user project data
-- OLD: db.jnlkzcmeiksqljnbtfhb.supabase.co
-- NEW: db.eflrqvxmqrtbytkxyrze.supabase.co

-- OAuth User Project IDs
-- d54c154d-a7f1-4850-8904-aea8f7f962a0 (Test)
-- f5a89ec4-931d-4596-9785-2f87d7681c65 (Fitnext)
-- f6bfdca2-e8bd-4516-9a7a-db2781209a6d (Girly girly)
-- ecbc6a41-7dfe-41a9-a12f-a829a689ae85 (Office AI Agent)
-- c28a5249-b3ef-4748-b190-74ea1c715de7 (TracMemo)
-- 47307a19-21d7-4032-8b62-4bf402b8d001 (VoiceDoc AI)
-- 44adaadc-b285-426a-8be6-880eec14aa30 (Decentralized Identity Verification System)

-- Create dblink connection to OLD database
SELECT dblink_connect('old_db', 
    'host=db.jnlkzcmeiksqljnbtfhb.supabase.co 
     port=5432 
     dbname=postgres 
     user=postgres 
     password=PTLUfGi7fwFdk5x1');

-- 1. Migrate prdforge_feature_nodes (72 rows)
INSERT INTO prdforge_feature_nodes (
    id, project_id, name, description, position_x, position_y, 
    dependencies, created_at, updated_at
)
SELECT * FROM dblink('old_db', 
    'SELECT id, project_id, name, description, position_x, position_y, 
            dependencies, created_at, updated_at
     FROM prdforge_feature_nodes 
     WHERE project_id IN (
        ''d54c154d-a7f1-4850-8904-aea8f7f962a0'',
        ''f5a89ec4-931d-4596-9785-2f87d7681c65'',
        ''f6bfdca2-e8bd-4516-9a7a-db2781209a6d'',
        ''ecbc6a41-7dfe-41a9-a12f-a829a689ae85'',
        ''c28a5249-b3ef-4748-b190-74ea1c715de7'',
        ''47307a19-21d7-4032-8b62-4bf402b8d001'',
        ''44adaadc-b285-426a-8be6-880eec14aa30''
     )') AS t(
    id uuid, project_id uuid, name text, description text, 
    position_x double precision, position_y double precision,
    dependencies text[], created_at timestamptz, updated_at timestamptz
)
ON CONFLICT (id) DO NOTHING;

-- 2. Check if any templates are missing (OLD has 8, NEW has 12)
-- We'll insert any templates from OLD that don't exist in NEW
INSERT INTO prdforge_templates (
    id, name, description, category, intake_prefill, 
    created_at, updated_at
)
SELECT * FROM dblink('old_db', 
    'SELECT id, name, description, category, intake_prefill, 
            created_at, updated_at
     FROM prdforge_templates') AS t(
    id uuid, name text, description text, category text,
    intake_prefill jsonb, created_at timestamptz, updated_at timestamptz
)
WHERE NOT EXISTS (
    SELECT 1 FROM prdforge_templates WHERE id = t.id
);

-- Close the connection
SELECT dblink_disconnect('old_db');

-- Verification queries
SELECT 'prdforge_feature_nodes migrated' as table_name, COUNT(*) as row_count FROM prdforge_feature_nodes;

SELECT 'prdforge_templates after migration' as table_name, COUNT(*) as row_count FROM prdforge_templates;