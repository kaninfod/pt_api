#!/bin/bash

RAILS_ENV=development rake resque:start_workers
# ping localhost -i 600
tail -f /dev/stdout
