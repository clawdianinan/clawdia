#!/bin/bash
# Himalaya wrapper script for easy email sending

set -e

# Default account
ACCOUNT="iih_temi"
TO=""
SUBJECT=""
BODY=""
CC=""
ATTACHMENT=""

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --to)
            TO="$2"
            shift 2
            ;;
        --subject)
            SUBJECT="$2"
            shift 2
            ;;
        --body)
            BODY="$2"
            shift 2
            ;;
        --cc)
            CC="$2"
            shift 2
            ;;
        --account)
            ACCOUNT="$2"
            shift 2
            ;;
        --attachment)
            ATTACHMENT="$2"
            echo "Warning: Attachment support not implemented in this wrapper" >&2
            shift 2
            ;;
        *)
            echo "Unknown option: $1" >&2
            exit 1
            ;;
    esac
done

# Validate required arguments
if [[ -z "$TO" ]]; then
    echo "Error: --to is required" >&2
    exit 1
fi

if [[ -z "$SUBJECT" ]]; then
    echo "Error: --subject is required" >&2
    exit 1
fi

if [[ -z "$BODY" ]]; then
    echo "Error: --body is required" >&2
    exit 1
fi

# Build email headers
HEADERS="From: $(himalaya account list | grep "$ACCOUNT" | awk '{print $5" <"$1">"}')"
HEADERS="$HEADERS\nTo: $TO"
HEADERS="$HEADERS\nSubject: $SUBJECT"

if [[ -n "$CC" ]]; then
    HEADERS="$HEADERS\nCc: $CC"
fi

HEADERS="$HEADERS\nDate: $(date -R)"
HEADERS="$HEADERS\nContent-Type: text/plain; charset=utf-8"

# Send email
echo -e "$HEADERS\n\n$BODY" | himalaya message send -a "$ACCOUNT"

echo "Email sent successfully to $TO"
if [[ -n "$CC" ]]; then
    echo "CC: $CC"
fi