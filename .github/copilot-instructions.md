# Copilot Coding Agent Instructions

## 1) Repository purpose and stack
- This is a Rails app for managing RFID tags, authorizations, readers, and tag scan events (including optional camera snapshot capture on scan).
- Project type: monolithic Rails web app with server-rendered views plus JSON endpoints.
- Main languages: Ruby, ERB, JS, SCSS/CSS.
- Framework/runtime: Rails 8.0.2, Ruby 3.3.7, Bundler 2.7.0, Node 20.11.1 (via `mise.toml`).
- Database: SQLite in all environments (`storage/*.sqlite3`).
- Background/jobs/cache/cable: Solid Queue, Solid Cache, Solid Cable.
- Auth: Clearance (`config/initializers/clearance.rb`), sign-up disabled.
- API auth: token-based API keys via `ApiKey` HMAC digest.

## 2) Fast start (validated)
Always run commands from repo root.

1. `bundle install`
2. `npm install`
3. `bin/setup --skip-server`
4. `bin/dev`

Validated behavior:
- `bin/setup --skip-server` succeeds and is idempotent; observed runtime ~2.6s.
- `bin/dev` starts Puma + Tailwind watcher on port 3000.
- If you stop `bin/dev` with timeout/SIGTERM, CSS watcher exits with code 1 during shutdown; this is expected during forced stop.

## 3) Build/test/lint commands and known outcomes

### Bootstrap
- Preferred: `bin/setup --skip-server`
- Internals: bundle check/install, `bin/rails db:prepare`, `bin/rails log:clear tmp:clear`.

### Run (development)
- Preferred: `bin/dev`
- Alternative: `bin/rails server` (without tailwind watch).

### Build (assets)
- Use: `env SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile`
- Observed runtime ~2.4s.
- Warning observed: precompiling in development writes `public/assets/.manifest.json`; changed assets are not served until that manifest is removed.

### Test
- Always run DB prep first: `bin/rails db:prepare RAILS_ENV=test`
- Full suite currently fails in this repository baseline (not caused by your feature) due to pre-existing issues:
  - `test/fixtures/tagscans.yml` references removed columns (`epc`, `pc`) on `tagscans`.
  - Many controller tests expect no auth redirects, but app requires login and redirects to `/sign_in`.
  - `test/controllers/users_controller_test.rb` uses invalid route helpers like `users_index_url`.
- Practical guidance:
  - Run targeted tests for touched files first.
  - If full suite fails, confirm whether failures are pre-existing before changing broad behavior.

### Ruby lint/static checks
- `bundle exec rubocop` runs, but repository currently has existing offenses (observed: 8, mostly autocorrectable).
- `bundle exec erb_lint ...` runs without local `.erb_lint.yml` (default config warning only).
- `bin/brakeman -q` runs; observed only version warning (`7.1.0` not latest).

### JS/CSS lint
- `npm install` is required before `npx --no-install ...` commands.
- ESLint currently fails by configuration: no `eslint.config.js` present for ESLint v9.
- Stylelint currently fails by configuration: no stylelint config present for repository CSS glob.
- Overcommit has ESLint disabled, Stylelint enabled; expect hook friction unless stylelint config is added/updated.

## 4) Pre-commit/CI reality
- No `.github/workflows` directory is present (no GitHub Actions currently configured here).
- Local pre-commit policy is defined in `.overcommit.yml` and includes:
  - `BundleCheck`, `ErbLint`, `RuboCop`, `Stylelint`, `YarnCheck`, `RailsSchemaUpToDate`, whitespace/FIXME checks.
- `overcommit` executable is not currently available via Bundler in this repo (`bundle exec overcommit` fails). Treat `.overcommit.yml` as policy documentation unless your environment has overcommit installed separately.

## 5) Architecture and where to edit

### Primary app areas
- Routes: `config/routes.rb`.
- Controllers: `app/controllers/*`.
  - Core business flows: `tags_controller.rb`, `tagscans_controller.rb`, `api_keys_controller.rb`.
  - API key auth concern: `app/controllers/concerns/api_key_authenticatable.rb`.
- Models: `app/models/*`.
  - RFID/tag logic: `Tag`, `Tagscan`, `TagType`, `Authorization`, `Reader`.
  - API auth: `ApiKey` (token digest/HMAC).
- Jobs: `app/jobs/tagscans_grabphoto_job.rb`.
- Views: ERB + Jbuilder under `app/views`.

### Important non-obvious dependencies
- Camera snapshot integration:
  - URL configured in `config/application.rb` (`config.grabphoto_camera_url`).
  - Credentials expected in Rails credentials under `grab_photo`.
- API key digest secret expected in credentials (`api_key_hmac_secret_key`).
- ActiveStorage is used for scan images (`Tagscan#image`).

### Configuration files to check before risky changes
- Runtime/env: `config/environments/*.rb`, `config/database.yml`, `mise.toml`.
- Ruby lint/style: `.rubocop.yml`.
- Hook policy: `.overcommit.yml`.
- Deploy/container: `config/deploy.yml`, `Dockerfile`.

## 6) Root layout quick map
Top-level: `app/`, `bin/`, `config/`, `db/`, `lib/`, `public/`, `test/`, `vendor/`, plus `Gemfile`, `Gemfile.lock`, `package.json`, `Procfile.dev`, `Dockerfile`, `README.md`, `mise.toml`.

## 7) Agent working rules for this repo
- Always trust this file first to avoid unnecessary searching.
- Only search the repo when:
  - the needed detail is not listed here, or
  - listed guidance is proven incorrect by command output.
- Before broad refactors, run the smallest relevant command set for your touched area (targeted test + relevant linter) and record any baseline failures separately from your change.
