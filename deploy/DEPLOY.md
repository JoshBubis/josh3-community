# josh3-community deploy runbook

The app is a standard Rails 8 (Thruster) container. Deploys follow the
**catamist pattern**: a GitHub Actions workflow runs on a **self-hosted
runner** on the app server — no inbound SSH from GitHub, the runner polls
GitHub over HTTPS. Push to `main` → workflow rebuilds the image, restarts
the container, waits for Postgres, runs migrations, runs seeds.

## Current status

Repo-side prep is done (this PR). What is NOT done — all need Josh:

1. **Server home choice** — where this actually runs. The workflow assumes the
   fleet pattern (self-hosted runner on the host); the `runs-on` label must
   match the runner installed on the chosen host.
2. **Cloudflare Tunnel activation** — config file is prepped at
   `deploy/cloudflared/config.yml` (placeholders only, runs nowhere).
3. **DNS cutover** — josh3.com still serves the old static GitHub Pages site.
   Needs Josh's explicit approval immediately before the cutover.

## Server-side prerequisites (once the home is chosen)

- [ ] GitHub self-hosted Actions runner installed on the host, with a label
      matching `runs-on` in `.github/workflows/deploy.yml`.
- [ ] `$HOME/josh3-community` — git checkout of this repo (the workflow does
      `git fetch` + `git reset --hard origin/main` there).
- [ ] `$HOME/docker-setup` — compose project containing:
  - `josh3-community` service, built from `$HOME/josh3-community/Dockerfile`
    (override `COMPOSE_SERVICE` in the workflow env if named differently).
  - `postgres:16` service with a healthcheck and a named data volume.
  - The app service should `depends_on` the DB's healthcheck so the
    entrypoint's `db:prepare` doesn't race Postgres on first boot.
- [ ] Environment for the app container:
  - `DATABASE_URL` (or `POSTGRES_USER` / `POSTGRES_PASSWORD` /
    `POSTGRES_HOST` / `POSTGRES_DB`) — `config/database.yml` is fully
    env-driven; production DB defaults to `josh3_community_production`.
  - `RAILS_MASTER_KEY` — decrypts `config/credentials.yml.enc`.
    (Do not commit the key anywhere.)
  - `RAILS_HOSTS=josh3.com,www.josh3.com` — production default already
    covers these; override only if serving under a different name first.
- [ ] `cloudflared` installed (tunnel itself is created with Josh).

## How a deploy flows

1. Push to `main` (only `main` triggers it; PRs do not deploy).
2. Runner pulls latest code into `$HOME/josh3-community`.
3. `docker compose build` + `up -d` for the app service.
4. Readiness loop: up to ~80s waiting for
   `rails runner 'ActiveRecord::Base.connection.execute("SELECT 1")'`.
   (The container entrypoint also runs `db:prepare` at boot as a backstop.)
5. `rails db:migrate` with 3 attempts; on failure it prints
   `db:migrate:status` and fails the run.
6. `rails db:seed` — idempotent (`Channel.seed!` uses `find_or_create_by!`).

## Tunnel activation (with Josh)

1. `cloudflared tunnel create josh3` → note the tunnel ID.
2. Fill in `deploy/cloudflared/config.yml` placeholders and install it at
   `/etc/cloudflared/config.yml` (or the host's chosen path).
3. `cloudflared tunnel route dns <TUNNEL_ID> josh3.com`
   (and `www.josh3.com`) — **only with Josh's explicit DNS approval.**
4. Run `cloudflared tunnel --config /etc/cloudflared/config.yml run`.
5. House firewall standard: SSH 22 only inbound; everything else enters
   through the tunnel.

## Post-deploy verification checklist

- [ ] `GET /up` returns 200 (Rails health check).
- [ ] `GET /about` renders (preserved from the static site).
- [ ] `GET /reddit/callback` route exists (Reddit OAuth depends on it).
- [ ] Signup works; posts, comments, voting work.
- [ ] Tokens/API work; moderation tools work.

## Rollback

The workflow is `git reset --hard origin/main` + rebuild, so rolling back is:
push a revert (or reset `main` to the previous SHA), and the next workflow
run rebuilds from that. Nothing else to undo — migrations are the only
stateful part; check `db:migrate:status` before reverting past a migration.
