# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [Unreleased]

### Added
- JWT authentication (register, login) with 24-hour token expiry
- Book CRUD with pagination, filtering by status/tag, sorting, and search
- Tag management with many-to-many book associations
- Consistent JSON response envelope (`data`, `meta`, `error`)
- BookSearchService for encapsulated search logic
- Plain Ruby serializers (BookSerializer, TagSerializer, UserSerializer)
- Comprehensive RSpec test suite (111 examples)
- Rubocop with rubocop-rails and rubocop-rspec — zero offenses
- Makefile with setup, test, lint, server commands
- Seed data with demo account and sample books
- GitHub Actions CI workflow

### Security
- All queries scoped to `current_user` — no cross-user data access
- JWT tokens signed with HS256 using Rails secret_key_base
- Passwords hashed with bcrypt via `has_secure_password`
- No secrets or credentials in codebase
