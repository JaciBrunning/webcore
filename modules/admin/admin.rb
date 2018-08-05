require 'webcore/cdn/extension'
require 'webcore/db/authextension'

class AdminModule < WebcoreApp()
    register AuthExtension
    register CDNExtension

    set :views, "#{File.dirname(__FILE__)}/views"

    get "/?" do
        https!
        auth_su!
        @title = "Admin Console"
        erb :index
    end

    get "/logout/?" do
        https!
        redirect "/" unless auth?
        logout!
    end
end