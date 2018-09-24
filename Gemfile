source "https://rubygems.org"

# Server
gem "rack", "2.0.1"
gem "sinatra", "2.0.3"
gem "thin", "1.7.2"
gem "puma", "3.12.0"
gem "sinatra-websocket", "0.3.1"
gem "sinatra-contrib", "2.0.3"
gem "dalli", "2.7.8"

# Platform
gem "rake", "12.3.1"

# CDN
gem "sass", "3.4.22"

# Database
gem "pg", "0.21.0"
gem "sequel", "5.0.0"
gem "bcrypt", "3.1.11"
gem "aescrypt", "1.0.0"

# Misc
gem "json", "2.0.4"
gem "wisper", "2.0.0"
gem "tzinfo", "1.2.5"

# TODO: Loader other Gemfiles from here
gem "icalendar", "2.3.0"

# Module deps
$:.unshift File.dirname(__FILE__)
require 'loader/loader'
Webcore::Loader.new.run_configs!.each do |cfg|
    if cfg.gemfile
        puts "Adding Gemfile Dependencies: #{cfg.file} - #{cfg.gemfile}"
        load File.join(cfg.file, cfg.gemfile)
    end
end

# Deployment
group :development do
    gem 'capistrano',         require: false
    gem 'capistrano-rvm',     require: false
    gem 'capistrano-bundler', require: false
end