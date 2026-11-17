# Spree Commerce on Railway

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/new/template/spree-commerce?utm_medium=integration&utm_source=button&utm_campaign=spree)

Railway template for [Spree Commerce](https://spreecommerce.org), the open-source (BSD-3-Clause) headless commerce platform: REST Store and Admin APIs, a React admin dashboard, TypeScript SDKs, webhooks and a built-in marketplace mode.

## What it deploys

- **spree**, built from this repo's `Dockerfile`: Spree **6.0.5**, the official image pinned by version and digest, `ghcr.io/spree/spree:6.0.5@sha256:ccb50f584a6623a480a7d4d078e8adc53d3e78fec883a4c12d174b1a3d763cb1`. Puma serves the admin dashboard (`/dashboard`), the APIs (`/api/v3`) and the job dashboard (`/jobs`), and runs the Solid Queue background jobs in the same process, as upstream recommends for a single node. A Railway volume at `/rails/storage` keeps uploaded product images and files. Health check: `/up`.
- **Postgres** (Railway's database) for everything else: catalogue, customers, orders, and, through Rails' Solid stack, the job queue, the cache and Action Cable. No Redis is needed.

`railway/start.sh` makes the volume writable, drops to the image's `rails` user, runs `db:prepare` (creates and seeds the database on the first boot, runs migrations after an update), prints the one-time admin setup link while no admin exists, and starts Puma.

## After deploy

1. Open the service's **Deploy Logs** and find the line `Spree has no admin account yet. Open this link to create it`.
2. Open that link (`https://YOUR-DOMAIN/dashboard/setup?token=…`) and create the first admin: email, password, store name and the country you sell from. The link stops working as soon as an admin exists. No default account or password is ever created.
3. Sign in at `https://YOUR-DOMAIN/dashboard`. Add more admins from Settings → Users.

The `/jobs` dashboard uses HTTP basic auth: user `jobs`, password in the service's `MISSION_CONTROL_PASSWORD` variable.

## Variables

| Variable | Template default | Purpose |
|---|---|---|
| `DATABASE_URL` | `${{Postgres.DATABASE_URL}}` | Postgres connection over the private network |
| `SECRET_KEY_BASE` | generated | Rails key for sessions and signed cookies |
| `ACTIVE_RECORD_ENCRYPTION_PRIMARY_KEY`, `…_DETERMINISTIC_KEY`, `…_KEY_DERIVATION_SALT` | generated | Encrypt secrets at rest (webhook signing keys, gateway customer ids, OAuth tokens). Never change them once data exists |
| `SPREE_JWT_SECRET_KEY` | generated | Signs API tokens (separate from `SECRET_KEY_BASE`) |
| `MISSION_CONTROL_PASSWORD` | generated | Password for the `/jobs` dashboard |
| `PORT` | `3000` | Port Puma listens on |

Optional, add them in the service's variables when you need them (see Spree's [environment variables](https://spreecommerce.org/docs/developer/deployment/environment_variables)):

- **Email:** `SMTP_HOST`, `SMTP_PORT`, `SMTP_USERNAME`, `SMTP_PASSWORD`, `SMTP_FROM_ADDRESS`. Without `SMTP_HOST`, emails are only written to the logs.
- **Custom domain:** `SPREE_HOST=shop.example.com` (defaults to the Railway domain) for links in emails and image URLs.
- **Object storage instead of the volume:** `S3_ENDPOINT`, `S3_ACCESS_KEY_ID`, `S3_SECRET_ACCESS_KEY`, `S3_BUCKET` (or the `AWS_*`, `CLOUDFLARE_*` sets). Existing files on the volume are not moved for you.
- **Search:** `MEILISEARCH_URL`, `MEILISEARCH_API_KEY`, then run `bin/rails spree:search:reindex`. Without them, search runs on Postgres.

## Updates

Projects deployed from the template build from this repo's `main` branch. When a new Spree version is merged to `main`, Railway shows those projects an "update available" notice, and each owner chooses when to apply it. Migrations run on the next boot. Read [CHANGELOG.md](CHANGELOG.md) first: breaking changes are listed at the top of each entry, and Spree's own [upgrade guides](https://spreecommerce.org/docs/developer/upgrades) cover major versions.

Spree Commerce is BSD-3-Clause licensed, by Spree Commerce Inc. and contributors. This repo only wraps the official image.
