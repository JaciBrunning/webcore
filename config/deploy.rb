set :application, 'webcore'

set :rvm_type, :system
set :rvm_ruby_version, '2.3.3'

set :repo_url, 'https://github.com/JacisNonsense/webcore.git'
set :branch, 'master'

set :user, 'deploy'

# namespace :service do
#   desc 'Create Directories for Socket'
#   task :make_dirs do
#     on roles(:app) do
#       execute "mkdir #{deploy_to}/tmp/sockets -p"
#     end
#   end

#   before :start, :make_dirs
# end

# namespace :deploy do
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
# end