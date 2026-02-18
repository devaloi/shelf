# shelf

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Ruby](https://img.shields.io/badge/Ruby-3.4-red.svg)](https://www.ruby-lang.org/)
[![Rails](https://img.shields.io/badge/Rails-8.1-red.svg)](https://rubyonrails.org/)

A clean REST API for managing a personal reading list with tags, search, and JWT authentication — built with Rails API mode.

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Rails 8.1 (API mode) |
| Language | Ruby 3.4 |
| Database | SQLite3 |
| Auth | bcrypt + JWT (manual, no Devise) |
| Testing | RSpec + FactoryBot + Shoulda-Matchers |
| Linting | Rubocop + rubocop-rails + rubocop-rspec |
| Serialization | Plain Ruby classes |

## Setup

```bash
git clone https://github.com/devaloi/shelf.git
cd shelf
make setup    # installs gems, creates DB, seeds data
make server   # starts Rails on http://localhost:3000
```

### Prerequisites

- Ruby 3.4+
- Bundler
- SQLite3

### Manual Setup

```bash
bundle install
bin/rails db:setup   # creates, migrates, seeds
bin/rails server
```

### Development Commands

```bash
make setup    # Bundle install + DB setup
make server   # Start Rails server
make test     # Run full test suite
make lint     # Run Rubocop
make console  # Rails console
make db:reset # Drop, create, migrate, seed
```

## Authentication

Shelf uses JWT (JSON Web Tokens) for stateless authentication:

1. **Register** or **Login** to receive a JWT token
2. Include the token in all subsequent requests via the `Authorization` header
3. Tokens expire after 24 hours

```
Authorization: Bearer <your-jwt-token>
```

Tokens are signed with HS256 using the Rails secret key base. No cookies or sessions — pure token-based auth.

## API Reference

Base URL: `http://localhost:3000`

All responses use a consistent envelope:
```json
// Success (single resource)
{ "data": { ... } }

// Success (collection)
{ "data": [ ... ], "meta": { "page": 1, "per_page": 20, "total": 42, "total_pages": 3 } }

// Error
{ "error": "message", "details": ["..."] }
```

---

### Auth

#### Register

```bash
curl -X POST http://localhost:3000/auth/register \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

Response `201 Created`:
```json
{
  "data": {
    "token": "eyJhbGciOi...",
    "user": { "id": 1, "email": "user@example.com", "created_at": "2025-01-01T00:00:00Z" }
  }
}
```

#### Login

```bash
curl -X POST http://localhost:3000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email": "user@example.com", "password": "password123"}'
```

Response `200 OK`:
```json
{
  "data": {
    "token": "eyJhbGciOi...",
    "user": { "id": 1, "email": "user@example.com", "created_at": "2025-01-01T00:00:00Z" }
  }
}
```

**Demo account** (from seeds): `demo@example.com` / `password123`

---

### Books

All book endpoints require authentication.

#### List Books

```bash
curl http://localhost:3000/books \
  -H "Authorization: Bearer $TOKEN"
```

**Query Parameters:**

| Param | Description | Example |
|-------|-------------|---------|
| `status` | Filter by status | `?status=reading` |
| `tag` | Filter by tag name | `?tag=fiction` |
| `sort` | Sort field | `?sort=title` (title, author, created_at, rating) |
| `order` | Sort direction | `?order=asc` (asc, desc) |
| `page` | Page number | `?page=2` |
| `per_page` | Items per page (default 20, max 100) | `?per_page=10` |

Response `200 OK`:
```json
{
  "data": [
    {
      "id": 1,
      "title": "The Pragmatic Programmer",
      "author": "David Thomas",
      "isbn": null,
      "status": "reading",
      "rating": 5,
      "notes": "Essential reading",
      "url": null,
      "tags": [{ "id": 1, "name": "programming" }],
      "created_at": "2025-01-01T00:00:00Z",
      "updated_at": "2025-01-01T00:00:00Z"
    }
  ],
  "meta": { "page": 1, "per_page": 20, "total": 12, "total_pages": 1 }
}
```

#### Get Book

```bash
curl http://localhost:3000/books/1 \
  -H "Authorization: Bearer $TOKEN"
```

Response `200 OK`:
```json
{
  "data": {
    "id": 1,
    "title": "The Pragmatic Programmer",
    "author": "David Thomas",
    "isbn": null,
    "status": "reading",
    "rating": 5,
    "notes": "Essential reading",
    "url": null,
    "tags": [{ "id": 1, "name": "programming" }],
    "created_at": "2025-01-01T00:00:00Z",
    "updated_at": "2025-01-01T00:00:00Z"
  }
}
```

#### Create Book

```bash
curl -X POST http://localhost:3000/books \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Clean Code",
    "author": "Robert C. Martin",
    "status": "unread",
    "rating": 4,
    "notes": "Recommended by team lead"
  }'
```

**Book statuses:** `unread`, `reading`, `read`
**Rating:** 1-5 (optional)

#### Update Book

```bash
curl -X PATCH http://localhost:3000/books/1 \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"status": "read", "rating": 5}'
```

#### Delete Book

```bash
curl -X DELETE http://localhost:3000/books/1 \
  -H "Authorization: Bearer $TOKEN"
```

Response: `204 No Content`

#### Search Books

Searches across title, author, and notes.

```bash
curl "http://localhost:3000/books/search?q=pragmatic" \
  -H "Authorization: Bearer $TOKEN"
```

---

### Tags

#### List Tags

Returns all tags for the current user with book counts.

```bash
curl http://localhost:3000/tags \
  -H "Authorization: Bearer $TOKEN"
```

Response `200 OK`:
```json
{
  "data": [
    { "id": 1, "name": "programming", "books_count": 5, "created_at": "2025-01-01T00:00:00Z" },
    { "id": 2, "name": "fiction", "books_count": 3, "created_at": "2025-01-01T00:00:00Z" }
  ]
}
```

#### List Books by Tag

```bash
curl http://localhost:3000/tags/1/books \
  -H "Authorization: Bearer $TOKEN"
```

#### Add Tags to Book

Tags are created on the fly if they don't exist. Tag names are normalized (lowercased, trimmed).

```bash
curl -X POST http://localhost:3000/books/1/tags \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tags": ["programming", "must-read"]}'
```

#### Remove Tag from Book

Removes the association only — the tag itself is preserved.

```bash
curl -X DELETE http://localhost:3000/books/1/tags/2 \
  -H "Authorization: Bearer $TOKEN"
```

---

### Error Responses

All errors follow a consistent format:

```json
// Validation error (422)
{ "error": "Validation failed", "details": ["Title can't be blank"] }

// Authentication error (401)
{ "error": "Token has expired" }

// Not found (404)
{ "error": "Book not found" }

// Bad request (400)
{ "error": "Search query required" }
```

---

## Architecture

```
app/
├── controllers/
│   ├── application_controller.rb   # Auth, error handling
│   ├── auth_controller.rb          # Register, login
│   ├── books_controller.rb         # CRUD, pagination, filtering
│   ├── tags_controller.rb          # List tags, books by tag
│   └── book_tags_controller.rb     # Add/remove tags on books
├── models/
│   ├── user.rb         # has_secure_password, email normalization
│   ├── book.rb         # Enum status, scopes, validations
│   ├── tag.rb          # Name normalization, uniqueness per user
│   └── book_tag.rb     # Join table
├── services/
│   ├── auth_service.rb              # JWT encode/decode
│   └── book_search_service.rb       # Search query builder
└── serializers/
    ├── book_serializer.rb
    ├── tag_serializer.rb
    └── user_serializer.rb
```

### Key Design Decisions

- **JWT from scratch** — no Devise or authentication gems, demonstrating understanding of token-based auth
- **Plain Ruby serializers** — lightweight, explicit control over JSON output
- **Scoped queries** — all data access scoped to `current_user`, preventing data leakage
- **Centralized error handling** — consistent error responses via `rescue_from` in ApplicationController
- **SQLite LIKE search** — simple and effective for this scale, no external search dependencies

## Data Model

```
users: id, email, password_digest, timestamps
books: id, user_id, title, author, isbn, status, rating, notes, url, timestamps
tags: id, name, user_id, timestamps
book_tags: book_id, tag_id (join table)
```

## Tests

```bash
bundle exec rspec
```

111 examples covering:
- **Model specs** — validations, associations, scopes, custom methods
- **Request specs** — every endpoint with happy path and error cases
- **Service specs** — JWT encoding, decoding, expiration, invalid tokens

## License

[MIT](LICENSE)
