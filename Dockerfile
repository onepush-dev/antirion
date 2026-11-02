# Antirion on Railway: the official release binary (eliasbiondo/antirion:0.1.1, built by upstream CI from
# docker/Dockerfile, pinned by digest) on Debian 12 (same glibc as upstream's distroless cc-debian12 base),
# plus a Caddy edge so the data plane (/v1, /anthropic, /gemini, …) and the admin plane (/ui, /admin, /scim)
# share ONE Railway domain on Railway's PORT.
FROM eliasbiondo/antirion:0.1.1@sha256:d4617950bd053770b93892f733932924f61d56a92acd67012dbeb0d36994db90 AS antirion
FROM caddy:2.11.7-alpine AS caddy

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates libssl3 tini && rm -rf /var/lib/apt/lists/*
COPY --from=antirion /antirion /usr/local/bin/antirion
COPY --from=caddy /usr/bin/caddy /usr/local/bin/caddy
COPY railway/Caddyfile /etc/caddy/Caddyfile
COPY railway/railway-start.sh /usr/local/bin/railway-start.sh
RUN chmod 755 /usr/local/bin/railway-start.sh && mkdir -p /var/lib/antirion/data
# Plain defaults live in the image so the Railway template only carries references and generated secrets.
ENV ANTIRION_DATA_DIR=/var/lib/antirion/data \
    ANTIRION_HOST=127.0.0.1 \
    ANTIRION_DATA_PORT=18080 \
    ANTIRION_ADMIN_PORT=18081 \
    XDG_DATA_HOME=/var/lib/antirion \
    HOME=/var/lib/antirion
WORKDIR /var/lib/antirion
EXPOSE 8080
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/railway-start.sh"]
