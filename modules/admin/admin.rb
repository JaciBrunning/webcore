require 'webcore/cdn/extension'
require 'webcore/db/authextension'
require 'date'

class AdminModule < WebcoreApp()
    register AuthExtension
    register CDNExtension
    ADMIN_STARTUP = DateTime.now

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

    def uptime
        sec = ((DateTime.now - ADMIN_STARTUP)*24*60*60).to_i

        mm, ss = sec.divmod(60)
        hh, mm = mm.divmod(60)
        dd, hh = hh.divmod(24)
        strbuilder = []
        strbuilder << "#{dd.round(0)}d" if dd > 0
        strbuilder << "#{hh.round(0)}h" if hh > 0
        strbuilder << "#{mm.round(0)}m" if mm > 0
        strbuilder << "#{ss.round(0)}s"

        strbuilder.join(" ")
    end
end