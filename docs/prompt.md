# Agent Prompt — shelf

You are building a portfolio project. Your job is to produce clean, professional, senior-engineer-quality code that is ready to post publicly on GitHub.

---

## Docs to Read First

Before writing a single line of code, read all three docs in this folder:

1. `docs/R01-rails-reading-list-api.md` — The project spec. Architecture, phases, data model, API design, commit plan.
2. `docs/github-portfolio.md` — Quality bar and Definition of Done. This sets the standard.
3. `docs/github-portfolio-checklist.md` — Pre-posting checklist. Every box must be checked before you're done.

---

## Rules

### Commit discipline
- One commit per logical unit of work. Follow the commit plan in the spec.
- Conventional commit messages: `feat:`, `fix:`, `test:`, `refactor:`, `docs:`, `chore:`.
- No WIP commits. No "update" commits. No empty commits.
- Write real commit messages: `feat: add JWT authentication service and auth endpoints` not `feat: add stuff`.

### Code quality
- Write the code a senior engineer with 25 years of experience would write.
- Clean Rails conventions. Proper scopes, validations, service objects where appropriate.
- Error handling everywhere — rescue specific exceptions, consistent error response format.
- Tests are real: RSpec request specs + model specs, cover happy path AND error cases. Use FactoryBot.
- Lint clean. `bundle exec rubocop` must pass with zero offenses.

### What NOT to do
- Don't skip phases. Don't combine phases. Work through them in order.
- Don't leave TODO/FIXME/HACK comments in the code.
- Don't commit secrets, personal data, or hardcoded paths.
- Don't write fake tests that just assert `true`. Tests must test real behavior.
- Don't skip the refactoring phase — it's not optional polish, it's core quality.
- Don't commit `.DS_Store` or any generated files.
- Don't use Docker. No Dockerfile, no docker-compose. Just `bundle exec rails server`.

---

## GitHub Username

The GitHub username is **devaloi**. If referencing a GitHub repo URL, use `github.com/devaloi/shelf`. Do not guess or use any other username.

## Start

Read the three docs. Then begin Phase 1 from `docs/R01-rails-reading-list-api.md`.
