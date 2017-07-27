#!/bin/bash

rm ./tmp/pids/server.pid
RAILS_ENV=development bundle exec rails s -p 3000 -b 0.0.0.0
