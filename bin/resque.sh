#!/bin/bash

RAILS_ENV=development rake resque:start_workers

#RUN_AT_EXIT_HOOKS=true QUEUE=utility RAILS_ENV=development bundle exec rake resque:work
#RUN_AT_EXIT_HOOKS=true QUEUE=import RAILS_ENV=development bundle exec rake resque:work
#ping localhost -i 600
tail -f /dev/stdout
