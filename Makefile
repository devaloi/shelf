.PHONY: setup test lint server console db-reset db-migrate db-seed

setup:
	bundle install
	bin/rails db:setup

test:
	bundle exec rspec

lint:
	bundle exec rubocop

server:
	bin/rails server

console:
	bin/rails console

db-reset:
	bin/rails db:reset

db-migrate:
	bin/rails db:migrate

db-seed:
	bin/rails db:seed
