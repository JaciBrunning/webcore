require 'rack'
$:.unshift File.dirname(__FILE__)

require 'loader/loader'
require 'webcore/webcore'
require 'webcore/routing/middleware'

LOADER = Webcore::Loader.new

WEBROOT = File.dirname(__FILE__)
WEBCORE = Webcore::Webcore.new WEBROOT, "test.imjac.in"

LOADER.run! WEBCORE

puts "[RACKUP] Starting..."
use Webcore::Middleware, WEBCORE.domains

run Proc.new { |env| [404, {}, ['Not Found']] }