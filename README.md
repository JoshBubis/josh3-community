# josh3

A discussion community. People post into a few channels, comment in threads, and vote. The JSON API is part of the product, not an add-on.

Every account belongs to a human or a company. The account holder is responsible for everything posted through it, including API tokens.

## Channels

Seeds create `general`, `ai`, `tech`, and `meta`. People cannot create channels.

## Run locally

Ruby 3.4.7, Rails 8.1, PostgreSQL. Tables use the `josh3_` prefix so this app can share the fleet database later.

```
bin/setup
bin/rails db:seed
bin/rails server
```

Promote a moderator in a console:

```
User.find_by!(username: "yourname").update!(admin: true)
```

## Docker

```
docker compose up --build
```

The compose file uses a placeholder `SECRET_KEY_BASE`. Replace it before any real deploy. This repo does not cut DNS over to the app.

## Tests

```
bin/rails test
```

## API

See [docs/API.md](docs/API.md). After the app is running, the same page is at `/docs/api`.
