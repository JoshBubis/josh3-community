# josh3-community on the house laptop

Push to `main` deploys. The app runs next to Hub on the house machine
(`projects-server`, SSH `projects-tailscale`). josh3.com itself still serves
the static GitHub Pages site. Nothing here changes that DNS.

Preview: https://preview.josh3.com

That name is a proxied CNAME to the existing house tunnel
(`hub-home-tunnel`), forwarded to `http://josh3-community:80`. It is not a
new tunnel and not the apex.

## What a push to main does

The workflow `.github/workflows/deploy.yml` runs on the repo's own
self-hosted runner (`~/actions-runners/josh3-community`, label
`projects-server`).

1. `git fetch` and `git reset --hard origin/main` in `~/josh3-community`.
2. `docker compose build josh3-community` and `up -d` for the app and its
   Postgres, from `~/docker-setup`. Other compose services are not restarted.
3. Wait until Rails can talk to Postgres, then `db:migrate` (3 tries) and
   `db:seed`. Seeds only create the four channels and are safe to repeat.

## Containers

| Compose service | Container | Role |
|---|---|---|
| `josh3-community` | `josh3_community` | Rails + Thruster, port 80 inside the network. Host loopback `127.0.0.1:3010`. |
| `josh3-community-db` | `josh3-community-db` | Postgres 16, database `josh3_community_production`. Not the shared Hub database. |

Both sit on the house compose network `app_network`, same as `cloudflared-hub`,
so the tunnel can reach the app by the service name.

Logs: `cd ~/docker-setup && docker compose logs -f josh3-community`.
Rails log files are in the `josh3_community_logs` volume, mounted at
`/rails/log` in the container.

## Secrets

Stored only in `~/docker-setup/.env` (mode 600). Never commit them.

| Env name | Used for |
|---|---|
| `JOSH3_COMMUNITY_RAILS_MASTER_KEY` | Decrypts `config/credentials.yml.enc`. Same key as the repo's gitignored `config/master.key`. |
| `JOSH3_COMMUNITY_DB_PASSWORD` | Postgres role `josh3` and the app's `POSTGRES_PASSWORD`. |

The compose file references those names. It does not contain the values.

## Apex cutover (not done)

Only after Josh says so, in this order:

1. Set `RAILS_HOSTS` to `josh3.com,www.josh3.com,preview.josh3.com` and redeploy.
2. Add tunnel ingress for `josh3.com` and `www.josh3.com` to `hub-home-tunnel`,
   service `http://josh3-community:80`.
3. Then, and only then, point the apex DNS at that tunnel. Today the apex
   CNAME is GitHub Pages. Replacing it is the cutover.

Do not install `deploy/cloudflared/config.yml` from the old prep branch.
That file would create a second tunnel and route the apex. It was not merged.

## Rollback

Push a revert to `main`. The next workflow rebuilds that commit. Migrations
are the stateful part; check `db:migrate:status` before moving backwards
past one.
