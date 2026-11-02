# Antirion — single-binary AI/LLM gateway with a built-in console (Apache-2.0). Deploy on Railway with one click.

[![Deploy on Railway](https://railway.com/button.svg)](https://railway.com/deploy/PENDING)

[Antirion](https://github.com/eliasbiondo/antirion) is an AI gateway: one OpenAI-, Anthropic- and Gemini-compatible endpoint in front of your providers, with routing and fallbacks, virtual keys, budgets and spend tracking, guardrails, caching, MCP and a web console. This template runs the official `eliasbiondo/antirion:0.1.1` release binary (pinned by digest) with its embedded store on a Railway volume.

## Services
| Service | Image | Port | Volume |
|---|---|---|---|
| Antirion | `ghcr.io/onepush-dev/antirion:0.1.1` | Railway `PORT` (public HTTPS), health `/healthz` (Caddy → gateway `/-/readyz`) | `/var/lib/antirion` (embedded store, spool, generated encryption key) |

One public domain serves both planes through a small Caddy edge inside the container:
- **Console:** `https://<domain>/ui/` (the bare domain redirects there); Admin API under `/admin`, SCIM under `/scim`
- **Data plane:** `https://<domain>/v1/...` (OpenAI), `/v1/messages` (Anthropic), `/v1beta/...` (Gemini), `/mcp`, …

## Sign in
Zero inputs at deploy time. Open `https://<domain>/ui/` and paste the **admin token** — the `ANTIRION_BOOTSTRAP_TOKEN` variable on the service (generated per deploy). Then add a provider (your LLM API key), a model and a virtual key (`sk-antirion-…`), and call `https://<domain>/v1/chat/completions` with it.

The encryption key for stored provider credentials is generated into the volume on first start; back up the volume. Set `ANTIRION_ENCRYPTION_KEY` (base64 of 32 bytes) yourself only if you manage it outside the volume.

## Notes
- Email (invitations, password resets) is off until you configure SMTP; the admin token works without it. Upstream's compose ships Mailpit for local development only, so it is not part of this template.
- Image defaults: gateway on loopback (`ANTIRION_HOST=127.0.0.1`, data `18080`, admin `18081`), `ANTIRION_DATA_DIR=/var/lib/antirion/data`; `ANTIRION_PUBLIC_ORIGIN` and `ANTIRION_DATA_PLANE_URL` follow the Railway domain.

## License
Antirion is Apache-2.0 licensed by Elias Biondo. This repo only holds Railway packaging.
