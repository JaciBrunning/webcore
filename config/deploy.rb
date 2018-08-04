set :application, 'webcore'

set :rvm_type, :system
set :rvm_ruby_version, '2.3.3'

set :repo_url, 'https://github.com/JacisNonsense/webcore.git'
set :branch, 'master'

set :user, 'deploy'

# Allows us to access rackup from services
set :bundle_binstubs, -> { shared_path.join('bin') }

namespace :deploy do
    desc 'Install apt packages'
    task :apt do
        on roles(:app) do
            within release_path do
                execute "sudo", "apt-get install -y $(cat Packages)"
            end
        end
    end

    desc "Run rake tasks"
    task :rake_install do
        on roles(:app) do
            within release_path do
                execute "rake", "install"
            end
        end
    end

    before "bundler:install", "deploy:apt"
    after "bundler:install", "deploy:rake_install"
    after :deploy, "service:deploy"
end

namespace :service do
    desc "Deploy Webcore Service"
    task :deploy do
        on roles(:app) do
            service = ERB.new(File.read("#{File.dirname(__FILE__)}/webcore.service.erb")).result(binding)
            upload! StringIO.new(service), "#{shared_path}/webcore.service"

            start = ERB.new(File.read("#{File.dirname(__FILE__)}/webcore.sh.erb")).result(binding)
            upload! StringIO.new(start), "#{shared_path}/webcore.sh"

            execute "chmod 770 #{shared_path}/webcore.sh"
            execute "sudo systemctl link #{shared_path}/webcore.service"
            execute "sudo systemctl daemon-reload"
        end
    end

    desc "Restart Webcore Service"
    task :restart do
        on roles(:app) do
            execute "mkdir -p #{shared_path}/tmp/sockets"
            execute "chown -R :www #{shared_path}/tmp 2> /dev/null || true"
            execute "chmod -R 770 #{shared_path}/tmp 2> /dev/null || true"
            
            execute "sudo systemctl restart webcore.service"
        end
    end
    
    after "service:deploy", "service:restart"
end