server ENV['DEPLOY_SERVER'], roles: [:web, :app, :db], primary: true

set :stages, ["staging", "production"]
set :default_stage, "production"

set :user, 'deploy'
set :application, 'webcore'

set :deploy_to, '/etc/www/webcore'

set :scm, 'git'
set :repository, 'git@github.com/JacisNonsense/Webcore.git'
set :branch, 'master'

default_run_options[:pty] = true

namespace :service do
  desc 'Create Directories for Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{deploy_to}/tmp/sockets -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
#   desc 'Initial Deploy'
#   task :initial do
#     on roles(:app) do
#       before 'deploy:restart', 'puma:start'
#       invoke 'deploy'
#     end
#   end

#   desc 'Restart application'
#   task :restart do
#     on roles(:app), in: :sequence, wait: 5 do
#       invoke 'puma:restart'
#     end
#   end

#   after  :finishing,    :cleanup
#   after  :finishing,    :restart
end