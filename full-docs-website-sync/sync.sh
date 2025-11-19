#!/usr/bin/env bash
set -euo pipefail

# Full Docs Website Sync - Scrape documentation websites
# Usage: ./sync.sh <website-url> [--scraper=httrack|crawl4ai|both] [--force]

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
KNOWLEDGE_ROOT="$(cd "$SCRIPT_DIR/../../.knowledge" && pwd)"
FULL_DOCS_DIR="$KNOWLEDGE_ROOT/full-docs-website"
MANIFEST_FILE="$FULL_DOCS_DIR/MANIFEST.yaml"
STALENESS_DAYS=30

# Parse arguments
WEBSITE_URL=""
SCRAPER="both"  # default
FORCE=false

for arg in "$@"; do
  case $arg in
    --scraper=*)
      SCRAPER="${arg#*=}"
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    *)
      if [ -z "$WEBSITE_URL" ]; then
        WEBSITE_URL="$arg"
      fi
      ;;
  esac
done

if [ -z "$WEBSITE_URL" ]; then
  echo "Usage: $0 <website-url> [--scraper=httrack|crawl4ai|both] [--force]" >&2
  echo "" >&2
  echo "Examples:" >&2
  echo "  $0 https://nextjs.org/docs" >&2
  echo "  $0 https://react.dev --scraper=httrack" >&2
  echo "  $0 https://nextjs.org/docs --scraper=both --force" >&2
  exit 1
fi

# Validate scraper option
if [[ ! "$SCRAPER" =~ ^(httrack|crawl4ai|playwright|both)$ ]]; then
  echo "ERROR: Invalid scraper option: $SCRAPER" >&2
  echo "       Must be one of: httrack, crawl4ai, playwright, both" >&2
  exit 1
fi

# Parse domain from URL
DOMAIN=$(printf "%s" "$WEBSITE_URL" | sed -E 's#^https?://([^/]+).*#\1#')

if [ -z "$DOMAIN" ]; then
  echo "ERROR: Could not parse domain from URL: $WEBSITE_URL" >&2
  exit 1
fi

SITE_DIR="$FULL_DOCS_DIR/$DOMAIN"

echo "==> Scraping: $DOMAIN"
echo "    URL: $WEBSITE_URL"
echo "    Target: $SITE_DIR"
echo "    Scraper(s): $SCRAPER"

# Create full-docs-website directory if needed
mkdir -p "$FULL_DOCS_DIR"

# Initialize MANIFEST.yaml if it doesn't exist
if [ ! -f "$MANIFEST_FILE" ]; then
  echo "websites: []" > "$MANIFEST_FILE"
  echo "    Created MANIFEST.yaml"
fi

# Check staleness
check_staleness() {
  if ! command -v yq &> /dev/null; then
    echo "    WARNING: yq not found, skipping staleness check (install with: brew install yq)" >&2
    return 1  # Treat as stale
  fi

  local last_synced
  last_synced=$(yq eval ".websites[] | select(.name == \"$DOMAIN\") | .last_synced" "$MANIFEST_FILE" 2>/dev/null || echo "null")

  if [ "$last_synced" = "null" ] || [ -z "$last_synced" ]; then
    echo "    Not in manifest (first scrape)"
    return 1  # Stale
  fi

  # Calculate age in days
  if command -v gdate &> /dev/null; then
    DATE_CMD=gdate
  else
    DATE_CMD=date
  fi

  local last_epoch
  local now_epoch
  last_epoch=$($DATE_CMD -d "$last_synced" +%s 2>/dev/null || $DATE_CMD -j -f "%Y-%m-%dT%H:%M:%SZ" "$last_synced" +%s 2>/dev/null || echo "0")
  now_epoch=$($DATE_CMD +%s)
  local age_days=$(( (now_epoch - last_epoch) / 86400 ))

  echo "    Last scraped: $last_synced ($age_days days ago)"

  if [ "$age_days" -gt "$STALENESS_DAYS" ]; then
    echo "    Status: STALE (>$STALENESS_DAYS days)"
    return 1  # Stale
  else
    echo "    Status: FRESH (<$STALENESS_DAYS days)"
    return 0  # Fresh
  fi
}

# Determine if we should scrape
SHOULD_SCRAPE=false

if [ "$FORCE" = true ]; then
  echo "    Force flag set, will scrape"
  SHOULD_SCRAPE=true
elif [ ! -d "$SITE_DIR" ]; then
  echo "    Directory doesn't exist, will scrape"
  SHOULD_SCRAPE=true
elif ! check_staleness; then
  SHOULD_SCRAPE=true
fi

if [ "$SHOULD_SCRAPE" = false ]; then
  echo "    Skipping scrape (fresh and not forced)"
  exit 0
fi

# Create site directory
mkdir -p "$SITE_DIR"

# Function to scrape with httrack
scrape_httrack() {
  echo "==> Scraping with httrack..."

  if ! command -v httrack &> /dev/null; then
    echo "ERROR: httrack not found" >&2
    echo "       Install with: brew install httrack" >&2
    return 1
  fi

  local httrack_dir="$SITE_DIR/httrack"
  mkdir -p "$httrack_dir"

  # Run httrack
  # Options:
  #   -O: output directory
  #   -v: verbose
  #   -s0: no robots.txt restrictions
  #   -%P: priority for links from same domain
  #   -N0: save all files
  httrack "$WEBSITE_URL" \
    -O "$httrack_dir" \
    -v \
    -s0 \
    -%P \
    -N0 \
    || {
      echo "ERROR: httrack failed" >&2
      return 1
    }

  echo "    httrack complete: $httrack_dir"
}

# Function to scrape with crawl4ai
scrape_crawl4ai() {
  echo "==> Scraping with crawl4ai (SPA-compatible)..."

  # Use Python script with proper SPA parameters
  local python_scraper="$SCRIPT_DIR/crawl4ai_scraper.py"

  if [ ! -f "$python_scraper" ]; then
    echo "ERROR: crawl4ai_scraper.py not found at $python_scraper" >&2
    return 1
  fi

  # Use web-context-builder's venv Python which has crawl4ai installed
  local venv_python="$HOME/GITHUB/.web-context-builder/venv/bin/python3"

  if [ ! -f "$venv_python" ]; then
    echo "ERROR: web-context-builder venv not found at $venv_python" >&2
    echo "       Run: cd $HOME/GITHUB/.web-context-builder && python3 -m venv venv && venv/bin/pip install crawl4ai" >&2
    return 1
  fi

  # Run Python scraper with SPA support
  # This uses wait_for="networkidle" and delay_before_return_html=3.0
  # which are critical for single-page apps with hash routing
  if "$venv_python" "$python_scraper" "$WEBSITE_URL" "$SITE_DIR"; then
    echo "    crawl4ai complete: $SITE_DIR/crawl4ai"
    return 0
  else
    echo "ERROR: crawl4ai scraper failed" >&2
    return 1
  fi
}

# Function to scrape with playwright (SPA fallback with directory tree)
scrape_playwright() {
  echo "==> Scraping with playwright (directory tree structure)..."

  # Use Python script for Playwright scraping
  local python_scraper="$SCRIPT_DIR/playwright_scraper.py"

  if [ ! -f "$python_scraper" ]; then
    echo "ERROR: playwright_scraper.py not found at $python_scraper" >&2
    return 1
  fi

  # Use web-context-builder's venv Python which has playwright installed
  local venv_python="$HOME/GITHUB/.web-context-builder/venv/bin/python3"

  if [ ! -f "$venv_python" ]; then
    echo "ERROR: web-context-builder venv not found at $venv_python" >&2
    echo "       Run: cd $HOME/GITHUB/.web-context-builder && python3 -m venv venv && venv/bin/pip install playwright && venv/bin/playwright install chromium" >&2
    return 1
  fi

  # Run Playwright scraper (outputs directory tree structure)
  if "$venv_python" "$python_scraper" "$WEBSITE_URL" "$SITE_DIR"; then
    echo "    playwright complete: $SITE_DIR/playwright"
    return 0
  else
    echo "ERROR: playwright scraper failed" >&2
    return 1
  fi
}

# Run selected scraper(s)
SCRAPERS_USED=""

case "$SCRAPER" in
  httrack)
    scrape_httrack
    SCRAPERS_USED="httrack"
    ;;
  crawl4ai)
    scrape_crawl4ai
    SCRAPERS_USED="crawl4ai"
    ;;
  playwright)
    scrape_playwright
    SCRAPERS_USED="playwright"
    ;;
  both)
    # Run ALL THREE scrapers for cross-validation
    scrape_httrack
    scrape_crawl4ai
    scrape_playwright
    SCRAPERS_USED="httrack,crawl4ai,playwright"
    ;;
esac

# Cross-validate scraper outputs (if multiple scrapers ran)
if [[ "$SCRAPERS_USED" == *","* ]]; then
  echo "==> Cross-validating scraper outputs..."

  validation_script="$SCRIPT_DIR/validate_scrapers.py"

  if [ -f "$validation_script" ]; then
    if python3 "$validation_script" "$SITE_DIR"; then
      echo "    ✅ Validation complete - see validation-report.json"
    else
      echo "    ⚠️  Validation detected issues - see report above" >&2
    fi
  else
    echo "    WARNING: validate_scrapers.py not found, skipping validation" >&2
  fi
fi

# Update MANIFEST.yaml
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v yq &> /dev/null; then
  # Remove existing entry (if any)
  yq eval -i "del(.websites[] | select(.name == \"$DOMAIN\"))" "$MANIFEST_FILE"

  # Add new entry
  yq eval -i ".websites += [{
    \"name\": \"$DOMAIN\",
    \"url\": \"$WEBSITE_URL\",
    \"last_synced\": \"$TIMESTAMP\",
    \"scraper\": \"$SCRAPERS_USED\"
  }]" "$MANIFEST_FILE"

  echo "==> Updated MANIFEST.yaml"
else
  echo "WARNING: yq not found, cannot update MANIFEST.yaml (install with: brew install yq)" >&2
  echo "         Manual entry needed:" >&2
  echo "         - name: $DOMAIN" >&2
  echo "           url: $WEBSITE_URL" >&2
  echo "           last_synced: $TIMESTAMP" >&2
  echo "           scraper: $SCRAPERS_USED" >&2
fi

echo "==> Scrape complete: $DOMAIN"
