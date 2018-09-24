require 'rack'
$:.unshift File.dirname(__FILE__)
if ENV['WEBCORE_LOADPATH']
  ENV['WEBCORE_LOADPATH'].split(';').each { |x| $:.unshift(x) }
end
puts "Loading from: #{$:}"

require 'loader/loader'
require 'webcore/services'
require 'webcore/routing/domain_service'
require 'webcore/routing/middleware'

LOADER = Webcore::Loader.new

WEBROOT = File.dirname(__FILE__)
SERVICES = Webcore::DefaultCoreServices.new :core, Webcore::DomainService.new
LOADER.run! SERVICES

puts "[RACKUP] Starting..."
use Webcore::Middleware, SERVICES[:domains]

# Disable Rack::Lint, for websocket use.
module Rack
  class Lint
    def call(env = nil)
      @app.call(env)
    end
  end
end

run Proc.new { |env| [404, {}, ["Not Found"]] }