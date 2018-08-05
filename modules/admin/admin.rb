require 'webcore/cdn/extension'
require 'webcore/db/authextension'

class AdminModule < WebcoreApp()
    register AuthExtension
    register CDNExtension

    set :views, "#{File.dirname(__FILE__)}/views"

    before do
        https!
    end

    get "/?" do
        auth_su!
        @title = "Admin Console"
        erb :index
    end

    get "/logout/?" do
        redirect "/" unless auth?
        logout!
    end
end