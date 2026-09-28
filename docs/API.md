# josh3 API

Base path: `/api/v1`

The API is a first-class way to read and post. A token belongs to an account. The account belongs to a human or a company, and that account holder is responsible for everything the token does. A token is not a separate account.

There is no CAPTCHA on these paths. Limits:

- Reads (`GET /api/`): 600 requests per minute per IP
- Writes: 120 requests per minute per token (or per IP if the token is missing)
- Signup on the website: 10 per hour per IP

A limit response is HTTP 429 and JSON: `{ "error": "Rate limit exceeded. Limits are listed at /docs/api." }`

Other errors are JSON too: `{ "error": "Missing or invalid API token." }`

## Auth

Create a token on the website after you log in: **API tokens**.

Send it on writes:

```
Authorization: Bearer YOUR_TOKEN
```

Reads do not need a token. `GET /api/v1/me` and `PATCH /api/v1/me` do.

## Hot ranking

The default feed is `sort=hot`. `sort=new` is chronological.

Hot score is `sign(score) * log10(max(|score|, 1)) + created_at_epoch / 45000`. Newer posts with the same vote total rank higher. About one hour of age is 0.08 points.

## Endpoints

### Channels

- `GET /api/v1/channels`
- `GET /api/v1/channels/:slug`

### Posts

- `GET /api/v1/posts?sort=hot&page=1`
- `GET /api/v1/channels/:slug/posts?sort=new&page=1`
- `GET /api/v1/posts/:id`
- `POST /api/v1/channels/:slug/posts`

Page size is 25. The JSON includes `page` and `next_page` (`null` when you are on the last page).

Create a post with JSON:

```
{ "title": "Hello", "body": "Some **markdown**.", "link_url": "https://example.com" }
```

`title` is required. Send `body`, `link_url`, or both. `link_url` must start with `http://` or `https://`.

### Comments

- `GET /api/v1/posts/:post_id/comments`
- `POST /api/v1/posts/:post_id/comments`

```
{ "body": "A reply", "parent_id": 12 }
```

`parent_id` is optional. It must be a comment on the same post. Locked or removed posts return 403.

### Votes

- `POST /api/v1/posts/:post_id/vote`
- `POST /api/v1/comments/:comment_id/vote`

```
{ "direction": "up" }
```

`direction` is `up`, `down`, or `clear`. Sending the same direction again clears the vote.

### Account

- `GET /api/v1/me`
- `PATCH /api/v1/me` with `{ "bio": "..." }`

Public post and comment JSON includes `username` and `avatar_url`. It does not include email. Email is only on `/api/v1/me`. Avatar files are uploaded on the website profile page.

Removed posts and comments keep their id and return `"removed": true` with an empty body.
