# Contributing to Shelf

Thanks for your interest in contributing! This is a portfolio project, but pull requests and feedback are welcome.

## Getting Started

```bash
git clone https://github.com/devaloi/shelf.git
cd shelf
make setup
```

## Development Workflow

1. Create a feature branch: `git checkout -b feat/your-feature`
2. Write tests first (RSpec)
3. Implement the feature
4. Ensure tests pass: `make test`
5. Ensure linter passes: `make lint`
6. Commit using [Conventional Commits](https://www.conventionalcommits.org/)
7. Open a pull request

## Code Style

- Follow existing patterns in the codebase
- Rubocop must pass clean (`make lint`)
- Comments explain **why**, not **what**
- Use plain Ruby serializers (no gems)
- All database queries must be scoped to `current_user`

## Testing

- Request specs for every endpoint (happy path + error cases)
- Model specs for validations, associations, and scopes
- Service specs for business logic
- Use FactoryBot for test data

```bash
make test       # Run full suite
bundle exec rspec spec/requests/  # Run only request specs
```

## Commit Messages

Follow [Conventional Commits](https://www.conventionalcommits.org/):

- `feat:` — new feature
- `fix:` — bug fix
- `test:` — adding or updating tests
- `docs:` — documentation changes
- `refactor:` — code changes that don't fix bugs or add features
- `chore:` — maintenance, dependency updates
