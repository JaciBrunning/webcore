module Webcore
    class ModuleConfiguration
        attr_accessor :id
        attr_accessor :module
        attr_accessor :host
        attr_accessor :priority
        attr_accessor :group

        attr_accessor :apt

        # TODO
        attr_accessor :dependsOn
        attr_accessor :mustLoadAfter
        
        attr_accessor :file
        attr_accessor :gemfile
        attr_accessor :rakefile

        def initialize
            @priority = 50
            @mustLoadAfter = []
            @dependsOn = []
            @apt = []
            @group = nil
        end
    end
end