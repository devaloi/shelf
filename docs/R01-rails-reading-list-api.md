# R01: shelf — Reading List REST API

**Catalog ID:** R01 | **Size:** M | **Language:** Ruby / Rails
**Repo name:** `shelf`
**One-liner:** A clean REST API for managing a personal reading list with tags, search, and JWT authentication — built with Rails API mode.

---

## Why This Stands Out

- **Rails API-mode** — no views, no asset pipeline, pure JSON API
- **JWT authentication** from scratch (not Devise) — shows understanding of auth mechanics
- **Clean ActiveRecord patterns** — scopes, validations, associations, query objects
- **Full-text search** with PostgreSQL or SQLite FTS
- **Pagination** with cursor-based and offset approaches
- **Comprehensive RSpec tests** with FactoryBot — request specs, model specs, unit specs
- **Demonstrates Rails conventions** while avoiding Rails magic where it hides understanding

---

## Architecture

```
shelf/
├── app/
│   ├── controllers/
│   │   ├── application_controller.rb
│   │   ├── auth_controller.rb
│   │   ├── books_controller.rb
│   │   └── tags_controller.rb
│   ├── models/
│   │   ├── user.rb
│   │   ├── book.rb
│   │   ├── tag.rb
│   │   └── book_tag.rb
│   ├── services/
│   │   ├── auth_service.rb
│   │   └── book_search_service.rb
│   └── serializers/
│       ├── book_serializer.rb
│       ├── tag_serializer.rb
│       └── user_serializer.rb
├── config/
│   ├── routes.rb
│   └── database.yml
├── db/
│   ├── migrate/
│   └── seeds.rb
├── spec/
│   ├── models/
│   ├── requests/
│   ├── services/
│   ├── factories/
│   └── support/
├── Gemfile
├── Makefile
├── .gitignore
├── .rubocop.yml
├── LICENSE
└── README.md
```

---

## Data Model

```
users
  id, email, password_digest, created_at, updated_at

books
  id, user_id, title, author, isbn, status (unread/reading/read),
  rating (1-5 nullable), notes (text), url (nullable),
  created_at, updated_at

tags
  id, name, user_id, created_at

book_tags
  book_id, tag_id (composite PK)
```

---

## API Endpoints

| Method | Path | Description |
|--------|------|-------------|
| `POST` | `/auth/register` | Create account |
| `POST` | `/auth/login` | Get JWT token |
| `GET` | `/books` | List books (paginated, filterable) |
| `POST` | `/books` | Create book |
| `GET` | `/books/:id` | Get book with tags |
| `PATCH` | `/books/:id` | Update book |
| `DELETE` | `/books/:id` | Delete book |
| `GET` | `/books/search?q=` | Full-text search |
| `GET` | `/tags` | List user's tags |
| `POST` | `/books/:id/tags` | Add tags to book |
| `DELETE` | `/books/:id/tags/:tag_id` | Remove tag from book |
| `GET` | `/tags/:id/books` | List books by tag |

### Query Parameters for `GET /books`

| Param | Description |
|-------|-------------|
| `status` | Filter by status (unread, reading, read) |
| `tag` | Filter by tag name |
| `sort` | Sort field (title, author, created_at, rating) |
| `order` | asc or desc |
| `page` | Page number |
| `per_page` | Items per page (default 20, max 100) |

---

## Phases

### Phase 1: Scaffold & Models

**1.1 — Project setup**
- `rails new shelf --api --database=sqlite3 --skip-test` (use RSpec instead)
- Add gems: `bcrypt`, `jwt`, `rspec-rails`, `factory_bot_rails`, `rubocop`, `rubocop-rails`, `rubocop-rspec`
- Configure RSpec, FactoryBot, Rubocop
- Create `Makefile` with: `setup`, `test`, `lint`, `server`, `db:reset`, `console`

**1.2 — Database & models**
- Generate migrations for users, books, tags, book_tags
- Add validations: email uniqueness, required fields, rating range, status enum
- Add associations: User has_many books, Book has_many tags through book_tags
- Add scopes: `by_status`, `by_tag`, `recently_added`, `search`
- Use `has_secure_password` for users

**1.3 — Seeds**
- Create sample user with 10-15 books across statuses and tags
- Useful for development and demo

### Phase 2: Authentication

**2.1 — JWT service**
- `AuthService` class: encode/decode JWT tokens, token expiry (24h)
- Use `HS256` with `Rails.application.secret_key_base`
- Handle token expiry, invalid tokens, malformed headers

**2.2 — Auth controller & middleware**
- `POST /auth/register` — create user, return token
- `POST /auth/login` — verify password, return token
- `ApplicationController` — `authenticate_request` before_action
- Extract token from `Authorization: Bearer <token>` header
- Set `current_user` from decoded token
- Return 401 with clear error messages

### Phase 3: Books CRUD & Tags

**3.1 — Books controller**
- Full CRUD with strong parameters
- Scope all queries to `current_user` (never leak other users' books)
- Pagination (offset-based, return total count in response meta)
- Filtering by status, tag, sort/order
- Include tags in book responses

**3.2 — Tags**
- Create tags on the fly when adding to books
- Tags scoped to user
- Delete removes the association, not the tag
- Return tag counts (number of books per tag)

**3.3 — Search**
- Search across title, author, and notes
- Use SQLite `LIKE` with proper escaping (keep it simple, no external search engine)
- Return highlighted matches if practical

### Phase 4: Serialization & Polish

**4.1 — Serializers**
- Use plain Ruby serializer classes (not jbuilder, not active_model_serializers gem)
- Book serializer: include tags, format dates
- Collection serializer: include pagination meta
- Consistent response envelope: `{ data: ..., meta: { page, per_page, total } }`

**4.2 — Error handling**
- Rescue `ActiveRecord::RecordNotFound` → 404
- Rescue `ActiveRecord::RecordInvalid` → 422 with validation errors
- Rescue `JWT::DecodeError` → 401
- Consistent error format: `{ error: "message", details: [...] }`

### Phase 5: Comprehensive Tests

**5.1 — Model specs**
- Validations (presence, uniqueness, inclusion, numericality)
- Associations
- Scopes
- Custom methods

**5.2 — Request specs**
- Every endpoint: happy path + error cases
- Auth: register, login, expired token, missing token, invalid token
- Books: CRUD, pagination, filtering, search, authorization (can't access other user's books)
- Tags: add, remove, list by tag

**5.3 — Service specs**
- AuthService: encode, decode, expired, invalid

### Phase 6: Documentation & Polish

**6.1 — README.md**
- Install, setup, run
- API reference with curl examples for every endpoint
- Authentication flow explanation
- Architecture overview
- Development commands

**6.2 — Final checks**
- `bundle exec rspec` all green
- `bundle exec rubocop` clean
- No hardcoded secrets (use ENV or Rails credentials)
- Seeds work on fresh setup
- `bin/rails db:setup && bin/rails server` works from clean clone

---

## Tech Stack

| Component | Choice |
|-----------|--------|
| Framework | Rails 7+ API mode |
| Database | SQLite3 |
| Auth | bcrypt + JWT (manual) |
| Testing | RSpec + FactoryBot |
| Linting | Rubocop + rubocop-rails |
| Serialization | Plain Ruby classes |

---

## Commit Plan

1. `feat: scaffold Rails API with RSpec and database`
2. `feat: add user model with secure password`
3. `feat: add JWT authentication service and auth endpoints`
4. `feat: add book model with CRUD endpoints`
5. `feat: add tags with many-to-many association`
6. `feat: add pagination, filtering, and search`
7. `feat: add serializers and consistent response format`
8. `test: add comprehensive model and request specs`
9. `refactor: error handling, scoping, cleanup`
10. `docs: add README with API reference`
11. `chore: final rubocop pass and cleanup`
