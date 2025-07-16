# README

This application manages 6c tags and authorizations for an rfid reader.

# Requirements

- bundler version 2.7.0

# INSTALL

Run the following before going to production

`bundle install --deployment`

`bundle exec rake db:migrate RAILS_ENV=production`

`yarn install --production --pure-lockfile`

`bundle exec rake assets:precompile RAILS_ENV=production`
