require_relative 'config_context'

module Webcore
    class Loader
        attr_accessor :search_paths

        DEFAULT_SEARCHPATHS = [ "#{File.dirname(__FILE__)}/../../modules", ".", "~/webcore/modules"] + (ENV["WEBCORE_MODULE_PATH"] || "").split(";")

        def initialize search_paths=DEFAULT_SEARCHPATHS
            @search_paths = search_paths.map { |path| File.expand_path(path) }
        end

        def discover
            configs = @search_paths.map do |path|
                Dir[File.join(path.gsub("\\", "/"), '**/*.webcore.rb')]
            end.flatten
            configs.each do |c|
                puts "[LOADER] Found module configuration: #{c}"
            end
            configs
        end

        def configure config_files
            ids = []
            config_files.map do |cfile|
                ctx = ConfigContext.new cfile
                config = ctx.load
                id = config.id
                unless ids.include? id
                    puts "[LOADER] Loaded Module Config: #{id} -> #{cfile}"
                    ids << id
                    config
                else
                    puts "[LOADER] * Duplicate Module ID Found: #{id}, ignoring..."
                    nil
                end
            end.reject(&:nil?)
        end

        def load_modules config_objs, coreservices
            require_relative '../webcore/module'
            require_relative '../webcore/services'

            config_objs.map do |c|
                services = DefaultModuleServices.new c.id, coreservices
                mod = Module.new c, services
                coreservices[:modules][c.id] = mod
                mod.load
                puts "[LOADER] Loaded Module: #{mod.id}"
            end
        end

        def run_configs!
            configure(discover)
        end

        def run! coreservices
            configs = run_configs!
            load_modules configs, coreservices
        end
    end
end