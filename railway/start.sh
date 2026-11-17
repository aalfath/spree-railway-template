#!/bin/bash
# Railway start script for Spree Commerce.
# 1. As root: make the Active Storage volume writable for the rails user.
# 2. As rails: prepare the database (create schema + seed on first boot,
#    migrate on updates), print the one-time admin setup link while no admin
#    exists, then run Puma with Solid Queue inside it.
set -euo pipefail

STORAGE_DIR=/rails/storage

if [ "$(id -u)" = "0" ]; then
  mkdir -p "$STORAGE_DIR"
  # Only touch files that aren't already owned by rails (fast on big volumes).
  find "$STORAGE_DIR" -xdev ! -user 1000 -exec chown 1000:1000 {} + 2>/dev/null || true
  exec setpriv --reuid=1000 --regid=1000 --init-groups "$0" "$@"
fi

cd /rails

# Public host for generated URLs (image URLs in API responses, email links,
# the setup link). Railway provides the service's public domain.
export SPREE_HOST="${SPREE_HOST:-${RAILWAY_PUBLIC_DOMAIN:-}}"
# Basic-auth user for the /jobs dashboard (the password is a template secret).
export MISSION_CONTROL_USER="${MISSION_CONTROL_USER:-jobs}"
export PORT="${PORT:-3000}"

if [ -z "${SECRET_KEY_BASE:-}" ]; then
  echo "SECRET_KEY_BASE is not set; refusing to start." >&2
  exit 1
fi

./bin/rails railway:prepare

# Puma serves the web app, the admin dashboard and the APIs, and runs the
# Solid Queue job supervisor in-process (SOLID_QUEUE_IN_PUMA, upstream default).
exec ./bin/rails server -b 0.0.0.0 -p "$PORT"
