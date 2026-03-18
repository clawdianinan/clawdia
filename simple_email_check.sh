#!/bin/bash

echo "Enhanced Email Processor Summary - $(date)"
echo "=========================================="
echo ""

# Check for emails from Temi
echo "1. Checking for emails from Temi (instructions):"
echo "-------------------------------------------------"
himalaya envelope list --page-size 20 | grep -i "temi\|kolawole" | while read line; do
    echo "   Found: $line"
done
echo ""

# Check for IIH emails
echo "2. Checking for IIH emails (@iih.ng domain):"
echo "--------------------------------------------"
himalaya envelope list --page-size 20 | grep -i "@iih.ng" | while read line; do
    echo "   Found: $line"
done
echo ""

# Check for IHS Towers emails (highest priority)
echo "3. Checking for IHS Towers emails (highest priority):"
echo "-----------------------------------------------------"
himalaya envelope list --page-size 20 | grep -i "ihstowers" | while read line; do
    echo "   ⚠️  HIGH PRIORITY: $line"
done
echo ""

# Check for monthly report emails
echo "4. Checking for monthly report emails:"
echo "--------------------------------------"
himalaya envelope list --page-size 20 | grep -i "monthly.*report\|report.*monthly" | while read line; do
    echo "   Found monthly report email: $line"
done
echo ""

# Check for external emails about IIH
echo "5. Checking for external emails about IIH:"
echo "------------------------------------------"
himalaya envelope list --page-size 20 | grep -i "IIH\|Ilorin Innovation Hub" | grep -v "@iih.ng" | while read line; do
    echo "   External email about IIH: $line"
    echo "   → Should be handled with IIH email addresses only"
done
echo ""

echo "Processing complete."
echo ""
echo "Key actions needed:"
echo "1. Process any instructions from Temi's emails automatically"
echo "2. Keep IIH matters strictly with IIH emails (@iih.ng domain)"
echo "3. Use IIH address book to recognize staff by name"
echo "4. Special handling for monthly report emails"
echo "5. External emails about IIH should be handled with IIH email addresses only"
echo "6. Non-IIH external emails refer to Temi for review"