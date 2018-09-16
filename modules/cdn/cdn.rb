require 'webcore/cdn/extension'
require_relative 'constants'

class CDNModule < WebcoreApp()
    register ::Webcore::CDNExtension

    get "/:module/:resource/?" do |mod, resource|
        redirect "/cdn/#{mod}/#{resource}"
    end

    get "/:resource/?" do |resource|
        redirect "/cdn/#{resource}"
    end

    fa = RedirectResource.new(:"fontawesome.css", "https://use.fontawesome.com/releases/v5.1.0/css/all.css")
    fa.memcache = true
    services[:cdn].register fa

    mg = FileResource.new(:"milligram.css", "#{CDNConstants::CSS_DIR}/milligram.min.css")
    mg.memcache = true
    services[:cdn].register mg

    not_found do
        "The resource you're looking for could not be located!"
    end
end