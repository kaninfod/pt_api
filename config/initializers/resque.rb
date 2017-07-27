require 'resque/server'
require 'resque/scheduler/server'
require 'active_scheduler'

config = YAML.load(File.open("#{Rails.root}/config/resque.yml"))[Rails.env]
Resque.redis = Redis.new(host: config['host'], port: config['port'], db: config['db'])

# require 'syslogger'
require 'logger'

Resque.logger = Logger.new(STDOUT)
Resque.logger.level = Logger::DEBUG


# Resque.logger.info "logger initialized"
