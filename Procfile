web: bundle exec unicorn -p $PORT -c ./config/unicorn-heroku.rb
worker: bundle exec rake jobs:work
slack: bundle exec rake slack:listen
clock: bundle exec clockwork clock.rb