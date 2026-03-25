#!/bin/bash
#
# deploy-prdforge.sh — Automate PRDForge production deployment
#
# Typical flow: install deps → build frontend → deploy Supabase Edge Functions → Netlify prod
#
# Usage:
#   ./scripts/deploy-prdforge.sh              # full deploy
#   ./scripts/deploy-prdforge.sh --dry-run    # print steps only
#   ./scripts/deploy-prdforge.sh --functions-only
#   ./scripts/deploy-prdforge.sh --frontend-only
#
# Environment (optional):
#   PRDFORGE_ROOT   — app root (default: /Users/clawdia/apps/prdforge)
#   SKIP_INSTALL    — set to 1 to skip npm ci/install
#   NETLIFY_SITE    — passed to netlify deploy --site if set

set -euo pipefail

PRDFORGE_ROOT="${PRDFORGE_ROOT:-/Users/clawdia/apps/prdforge}"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() { echo -e "${GREEN}✅ $1${NC}"; }
print_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
print_error()   { echo -e "${RED}❌ $1${NC}"; }
print_info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }

DRY_RUN=0
SKIP_BUILD=0
FUNCTIONS_ONLY=0
FRONTEND_ONLY=0

usage() {
    sed -n '1,20p' "$0" | tail -n +2
    exit 0
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --dry-run)       DRY_RUN=1; shift ;;
        --skip-build)    SKIP_BUILD=1; shift ;;
        --functions-only) FUNCTIONS_ONLY=1; shift ;;
        --frontend-only) FRONTEND_ONLY=1; shift ;;
        -h|--help)       usage ;;
        *) print_error "Unknown option: $1"; usage ;;
    esac
done

if [[ "$FUNCTIONS_ONLY" -eq 1 && "$FRONTEND_ONLY" -eq 1 ]]; then
    print_error "Cannot use --functions-only and --frontend-only together"
    exit 1
fi

run() {
    if [[ "$DRY_RUN" -eq 1 ]]; then
        echo "[dry-run] $*"
    else
        "$@"
    fi
}

echo ""
echo "=== PRDForge deployment ==="
print_info "Root: $PRDFORGE_ROOT"
echo ""

if [[ ! -d "$PRDFORGE_ROOT" ]]; then
    print_error "Project directory not found: $PRDFORGE_ROOT"
    echo "Set PRDFORGE_ROOT to your clone path, e.g.:"
    echo "  export PRDFORGE_ROOT=/path/to/prdforge"
    exit 1
fi

cd "$PRDFORGE_ROOT"

if git rev-parse --git-dir &>/dev/null; then
    if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
        print_warning "Git working tree is not clean — deploy anyway? (Ctrl+C to abort)"
        sleep 2
    fi
fi

# --- Dependencies & build (frontend path) ---
if [[ "$FUNCTIONS_ONLY" -eq 0 ]]; then
    if [[ ! -f "package.json" ]]; then
        print_warning "No package.json — skipping npm install/build"
    else
        if [[ "${SKIP_INSTALL:-0}" != "1" ]]; then
            print_info "Installing dependencies..."
            if [[ -f "package-lock.json" ]]; then
                run npm ci
            else
                run npm install
            fi
            print_success "Dependencies ready"
        else
            print_info "Skipping install (SKIP_INSTALL=1)"
        fi

        if [[ "$SKIP_BUILD" -eq 0 ]]; then
            if node -e "process.exit(require('./package.json').scripts?.build ? 0 : 1)" 2>/dev/null; then
                print_info "Building frontend..."
                run npm run build
                print_success "Build finished"
            else
                print_warning "No npm \"build\" script — skipping build"
            fi
        else
            print_info "Skipping build (--skip-build)"
        fi
    fi
fi

# --- Supabase Edge Functions ---
if [[ "$FRONTEND_ONLY" -eq 0 ]]; then
    if ! command -v supabase &>/dev/null; then
        print_warning "Supabase CLI not found — skip functions deploy (install: https://supabase.com/docs/guides/cli)"
    elif [[ ! -d "supabase/functions" ]]; then
        print_warning "No supabase/functions — skipping Edge Function deploy"
    else
        print_info "Deploying Edge Functions..."
        run supabase functions deploy
        print_success "Edge Functions deploy command completed"
    fi
fi

# --- Netlify ---
if [[ "$FUNCTIONS_ONLY" -eq 0 ]]; then
    if ! command -v netlify &>/dev/null; then
        print_warning "Netlify CLI not found — skip Netlify (install: npm i -g netlify-cli)"
    else
        NETLIFY_ARGS=(deploy --prod)
        if [[ -n "${NETLIFY_SITE:-}" ]]; then
            NETLIFY_ARGS+=(--site "$NETLIFY_SITE")
        fi
        print_info "Netlify production deploy..."
        run netlify "${NETLIFY_ARGS[@]}"
        print_success "Netlify deploy command completed"
    fi
fi

echo ""
if [[ "$DRY_RUN" -eq 1 ]]; then
    print_success "Dry run complete — no commands executed"
else
    print_success "Deployment pipeline finished"
    print_info "Verify: https://prdforge-dev.netlify.app (and Supabase dashboard for functions)"
fi
echo ""
