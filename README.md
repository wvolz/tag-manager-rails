# README

This application manages 6c tags and authorizations for an rfid reader.

## Bootstrap first admin user

When the system has no users yet, create the initial admin from the command line:

`bin/rails users:bootstrap_admin`

The task prompts for email, name, and password, and only runs when no users exist.

For non-interactive environments, provide values via env vars:

`EMAIL=admin@example.com PASSWORD=secret PASSWORD_CONFIRMATION=secret FIRST_NAME=Admin LAST_NAME=User bin/rails users:bootstrap_admin`

# Requirements

- bundler version 2.7.0

# INSTALL

## Production

Make sure that bundler is set for 'deployment'

`bundle config set deployment true`

Run the following

`bundle install`

`bundle exec rake db:migrate RAILS_ENV=production`

`bundle exec rake assets:precompile RAILS_ENV=production`

## Docker Compose

Use [docker-compose.yml.example](docker-compose.yml.example) as a starting point for a containerized production-style setup.

The sample splits the Rails web process from the Solid Queue worker process:

- `web` runs the frontend server
- `worker` runs `./bin/jobs`
- `db` runs PostgreSQL for the primary, cache, queue, and cable databases

Both app services share the same `storage` volume so Active Storage files stay available to the web and worker containers.

Start it with a real Rails master key in your environment:

`RAILS_MASTER_KEY=... docker compose -f docker-compose.yml.example up --build`
