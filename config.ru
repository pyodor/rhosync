require 'rubygems'
require 'sinatra'

disable :run, :clean_trace
set :environment, :production
enable :raise_errors
set :secret, '<changeme>'

require 'rhosync.rb'

configure :development,:production do 
  RhosyncStore.bootstrap(File.join('apps'))
end

# FileUtils.mkdir_p 'log' unless File.exists?('log')
# log = File.new("log/sinatra.log", "a+")
# $stdout.reopen(log)
# $stderr.reopen(log)

run Sinatra::Application
