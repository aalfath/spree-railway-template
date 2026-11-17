# Spree Commerce for Railway: the official image, pinned by version and digest.
# Update: bump the tag and digest below, add a CHANGELOG.md entry, merge to main.
FROM ghcr.io/spree/spree:6.0.5@sha256:ccb50f584a6623a480a7d4d078e8adc53d3e78fec883a4c12d174b1a3d763cb1

# Start as root only to fix the volume's ownership, then drop to the image's
# own `rails` user (uid 1000) before Rails starts (see railway/start.sh).
USER root
COPY --chmod=0755 railway/start.sh /usr/local/bin/railway-start
COPY --chown=1000:1000 railway/railway.rake /rails/lib/tasks/railway.rake

ENV HOME=/home/rails
EXPOSE 3000
ENTRYPOINT ["/usr/local/bin/railway-start"]
