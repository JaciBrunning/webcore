require 'rack'
$:.unshift File.dirname(__FILE__)

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

run Proc.new { |env| [404, {}, ['Not Found']] }