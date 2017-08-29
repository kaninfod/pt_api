#!/bin/bash

rm ./tmp/pids/server.pid
# ping localhost -i 600
RAILS_ENV=development bundle exec rails s -p 3000 -b 0.0.0.0
