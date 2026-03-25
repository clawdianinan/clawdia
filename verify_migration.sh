#!/bin/bash

# Verification script for PRDForge OAuth data migration
# Run this to verify all data is present in the NEW database

echo "🔍 Verifying PRDForge OAuth Data Migration..."
echo "=============================================="

# Check feature nodes
echo "Checking feature nodes..."
FEATURE_NODES_COUNT=$(psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -p 5432 -U postgres -d postgres -t -c "SELECT COUNT(*) FROM prdforge_feature_nodes WHERE project_id IN (
    'd54c154d-a7f1-4850-8904-aea8f7f962a0',
    'f5a89ec4-931d-4596-9785-2f87d7681c65',
    'f6bfdca2-e8bd-4516-9a7a-db2781209a6d',
    'ecbc6a41-7dfe-41a9-a12f-a829a689ae85',
    'c28a5249-b3ef-4748-b190-74ea1c715de7',
    '47307a19-21d7-4032-8b62-4bf402b8d001',
    '44adaadc-b285-426a-8be6-880eec14aa30'
);" 2>/dev/null)

if [ "$FEATURE_NODES_COUNT" -eq 72 ]; then
    echo "✅ Feature Nodes: $FEATURE_NODES_COUNT/72"
else
    echo "❌ Feature Nodes: $FEATURE_NODES_COUNT/72 (MISMATCH)"
fi

# Check total counts
echo ""
echo "Total Counts in NEW Database:"
echo "-----------------------------"

psql -h db.eflrqvxmqrtbytkxyrze.supabase.co -p 5432 -U postgres -d postgres -c "SELECT 
    'Projects' as entity, COUNT(*) as count FROM prdforge_projects WHERE id IN (
        'd54c154d-a7f1-4850-8904-aea8f7f962a0',
        'f5a89ec4-931d-4596-9785-2f87d7681c65',
        'f6bfdca2-e8bd-4516-9a7a-db2781209a6d',
        'ecbc6a41-7dfe-41a9-a12f-a829a689ae85',
        'c28a5249-b3ef-4748-b190-74ea1c715de7',
        '47307a19-21d7-4032-8b62-4bf402b8d001',
        '44adaadc-b285-426a-8be6-880eec14aa30'
    )
UNION ALL
SELECT 
    'PRD Sections' as entity, COUNT(*) as count FROM prdforge_prd_sections WHERE project_id IN (
        'd54c154d-a7f1-4850-8904-aea8f7f962a0',
        'f5a89ec4-931d-4596-9785-2f87d7681c65',
        'f6bfdca2-e8bd-4516-9a7a-db2781209a6d',
        'ecbc6a41-7dfe-41a9-a12f-a829a689ae85',
        'c28a5249-b3ef-4748-b190-74ea1c715de7',
        '47307a19-21d7-4032-8b62-4bf402b8d001',
        '44adaadc-b285-426a-8be6-880eec14aa30'
    )
UNION ALL
SELECT 
    'Modules' as entity, COUNT(*) as count FROM prdforge_modules WHERE project_id IN (
        'd54c154d-a7f1-4850-8904-aea8f7f962a0',
        'f5a89ec4-931d-4596-9785-2f87d7681c65',
        'f6bfdca2-e8bd-4516-9a7a-db2781209a6d',
        'ecbc6a41-7dfe-41a9-a12f-a829a689ae85',
        'c28a5249-b3ef-4748-b190-74ea1c715de7',
        '47307a19-21d7-4032-8b62-4bf402b8d001',
        '44adaadc-b285-426a-8be6-880eec14aa30'
    )
UNION ALL
SELECT 
    'Feature Nodes' as entity, COUNT(*) as count FROM prdforge_feature_nodes WHERE project_id IN (
        'd54c154d-a7f1-4850-8904-aea8f7f962a0',
        'f5a89ec4-931d-4596-9785-2f87d7681c65',
        'f6bfdca2-e8bd-4516-9a7a-db2781209a6d',
        'ecbc6a41-7dfe-41a9-a12f-a829a689ae85',
        'c28a5249-b3ef-4748-b190-74ea1c715de7',
        '47307a19-21d7-4032-8b62-4bf402b8d001',
        '44adaadc-b285-426a-8be6-880eec14aa30'
    )
UNION ALL
SELECT 
    'Templates' as entity, COUNT(*) as count FROM prdforge_templates;" 2>/dev/null

echo ""
echo "✅ Verification complete!"