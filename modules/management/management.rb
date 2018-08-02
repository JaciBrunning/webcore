require 'webcore/cdn/extension'
require 'webcore/db/authextension'

class TestModule < WebcoreApp()
    register AuthExtension
    register CDNExtension

    set :views, "#{File.dirname(__FILE__)}/views"

    get "/?" do
        auth_su!
        @title = "Management Console"
        erb :index
    end

    get "/logout/?" do
        redirect "/" unless auth?
        logout!
    end
end