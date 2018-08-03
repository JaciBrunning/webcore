require_relative 'cdn/cdnservice'
require_relative 'cache/memcache_service'
require_relative 'module'

module Webcore
    class Services < Hash
        attr_reader :id

        def initialize id
            super()
            @id = id
        end

        def register id, service
            self[id] = service
        end
    end

    class CoreServices < Services
    end

    class ModuleServices < Services
        def initialize id, coreservices
            super(id)
            register :core, coreservices
        end

        def [] id
            if include?(id)
                fetch id, nil
            elsif fetch(:core, {}).include?(id)
                fetch(:core, nil)[id]
            else
                nil
            end
        end
    end

    class DefaultModuleServices < ModuleServices
        def initialize id, coreservices
            super(id, coreservices)
            register :cdn, CDNService.new
            register :memcache, MemcacheService.new(id)
        end
    end

    class DefaultCoreServices < CoreServices
        def initialize id, domainservice
            super(id)
            register :domains, domainservice
            register :modules, ModulesService.new
        end
    end
end