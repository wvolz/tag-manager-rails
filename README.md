# README

This application manages 6c tags and authorizations for an rfid reader.

# INSTALL

Run the following before going to production

`bundle install --deployment`

`bundle exec rake db:migrate RAILS_ENV=production`

`bundle exec rake assets:precompile RAILS_ENV=production`
