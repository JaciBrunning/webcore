require 'fileutils'

require_relative 'constants'

namespace :cdn do
    desc "Build CDN resources"
    task :build do
        require 'sass'

        cssroot = "#{CDNConstants::CDN_DIR}/css/webcore_milligram"
        engine = Sass::Engine.for_file("#{cssroot}/milligram.sass", { 
            style: :compressed,
            load_paths: [cssroot]
        })
        FileUtils.mkdir_p "#{CDNConstants::CSS_DIR}"
        File.write("#{CDNConstants::CSS_DIR}/milligram.min.css", engine.render)
    end

    desc "Clean CDN Resources"
    task :clean do
        FileUtils.rm_r CDNConstants::BUILD_DIR
    end
end