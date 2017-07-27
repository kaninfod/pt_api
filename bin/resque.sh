#!/bin/bash

RAILS_ENV=development rake resque:start_workers
tail -f /dev/stdout
