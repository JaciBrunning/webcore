require 'sinatra/cookies'
require_relative 'auth'

module Webcore
    module AuthExtension
        module Helpers
            def auth_redirect! pagestr, refer
                portstr = ""
                if request.port != 80 && request.port != 443
                    portstr = ":#{request.port}"
                end
                # TODO: Escape
                redirect "http://auth.#{services[:domains].rootdomain}#{portstr}/#{pagestr}?refer=#{refer}"
            end

            def auth?
                !@user.nil?
            end

            def auth!
                auth_redirect! "login", request.url unless auth?
            end

            def auth_su?
                !@user.nil? && @user.superuser
            end

            def auth_su!
                auth_redirect! "login", request.url unless auth_su?
            end

            def logout!
                auth_redirect! "logout", request.url
            end
        end

        def self.registered app
            app.enable :sessions
            app.helpers Sinatra::Cookies
            app.helpers ::Webcore::AuthExtension::Helpers
            app.set :cookie_options, domain: ".#{app.services[:domains].rootdomain}"

            app.before do
                tok = Security.decrypt(cookies[:webcore_token], app.services[:sso].secret)
                @auth_token = Auth.login_token(tok)
                @user = @auth_token.is_a?(Symbol) ? nil : @auth_token.user

                cookies.delete :webcore_token if @user.nil? # Cleanup if the login failed
            end
        end
    end
end