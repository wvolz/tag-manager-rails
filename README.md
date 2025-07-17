# README

This application manages 6c tags and authorizations for an rfid reader.

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
