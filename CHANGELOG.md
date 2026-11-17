# Changelog

Each entry is one version of this Railway template. Breaking changes are listed first.
Deployers get Railway's "update available" notice when a change lands on `main`.

## 6.0.5-1 (2026-11-17)

- First release: Spree Commerce [v6.0.5](https://github.com/spree/spree/releases/tag/v6.0.5),
  official image `ghcr.io/spree/spree:6.0.5@sha256:ccb50f584a6623a480a7d4d078e8adc53d3e78fec883a4c12d174b1a3d763cb1`.
- One `spree` service (Puma with Solid Queue jobs in-process) with a volume at `/rails/storage`
  for uploaded images and files, plus Railway Postgres for everything else (catalogue, orders,
  job queue, cache and Action Cable, through Rails' Solid stack).
- Secrets (`SECRET_KEY_BASE`, Active Record encryption keys, JWT key, `/jobs` password) are
  generated at deploy. No default admin: the first admin is created through Spree's one-time
  setup link, printed in the deploy logs.
