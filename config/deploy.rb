# # config valid only for current version of Capistrano
# lock '3.4.0'
#
# set :application, 'hivelife'
# set :repo_url, 'git@github.com:brianzable/Hivelife.git'
#
# # RVM Setup
# set :rvm_ruby_string, :local
# set :rvm_autolibs_flag, 'read-only'
#
# # Default branch is :master
# # ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp
# set :branch, 'polymer_client'
#
# # Default deploy_to directory is /var/www/my_app_name
# # set :deploy_to, '/var/www/hivelife.co'
# set :deploy_to, '/home/bill/hivelife'
#
# # Default value for :scm is :git
# set :scm, :git
#
# # Default value for :format is :pretty
# # set :format, :pretty
#
# # Default value for :log_level is :debug
# # set :log_level, :debug
#
# # Default value for :pty is false
# set :pty, true
#
# # Default value for :linked_files is []
# set :linked_files, fetch(:linked_files, []).push('config/database.yml', 'config/secrets.yml')
#
# # Default value for linked_dirs is []
# set :linked_dirs, fetch(:linked_dirs, []).push('log', 'tmp/pids', 'tmp/cache', 'tmp/sockets', 'vendor/bundle', 'public/system')
#
# # Default value for default_env is {}
# # set :default_env, { path: "/opt/ruby/bin:$PATH" }
#
# # Default value for keep_releases is 5
# set :keep_releases, 5
#
# set(:config_files, [
#   # nginx.conf
#   # 'database.example.yml'
#   # log_rotation
#   # monit
#   # unicorn.rb
#   # unicorn_init.sh
# ])
#
# namespace :deploy do
#   before 'deploy', 'rvm1:install:rvm'
#   before 'deploy', 'rvm1:install:ruby'
#
#   after :restart, :clear_cache do
#     on roles(:web), in: :groups, limit: 3, wait: 10 do
#       # Here we can do anything such as:
#       # within release_path do
#       #   execute :rake, 'cache:clear'
#       # end
#     end
#   end
# end
#

# Change these
server 'hivelife.pem ubuntu@ec2-54-187-36-122.us-west-2.compute.amazonaws.com', port: 22, roles: [:web, :app, :db], primary: true

set :repo_url,        'git@github.com:brianzable/Hivelife.git'
set :branch,          'deploy_tools'
set :application,     'hivelife'
set :user,            'ubuntu'
set :puma_threads,    [4, 16]
set :puma_workers,    0

# Don't change these unless you know what you're doing
set :pty,             true
set :use_sudo,        false
set :stage,           :production
set :ssh_options, {
  forward_agent: true,
  user: fetch(:user),
  auth_methods: ["publickey"],
  keys: ["/path/to/key.pem"]
}
set :deploy_via,      :remote_cache
set :deploy_to,       "/home/#{fetch(:user)}/apps/#{fetch(:application)}"
set :puma_bind,       "unix://#{shared_path}/tmp/sockets/#{fetch(:application)}-puma.sock"
set :puma_state,      "#{shared_path}/tmp/pids/puma.state"
set :puma_pid,        "#{shared_path}/tmp/pids/puma.pid"
set :puma_access_log, "#{release_path}/log/puma.error.log"
set :puma_error_log,  "#{release_path}/log/puma.access.log"
set :puma_preload_app, true
set :puma_worker_timeout, nil
set :puma_init_active_record, true  # Change to false when not using ActiveRecord

## Defaults:
# set :scm,           :git
# set :branch,        :master
# set :format,        :pretty
# set :log_level,     :debug
# set :keep_releases, 5

## Linked Files & Directories (Default None):
set :linked_files, %w{config/database.yml config/secrets.yml}
# set :linked_dirs,  %w{bin log tmp/pids tmp/cache tmp/sockets vendor/bundle public/system}

namespace :puma do
  desc 'Create Directories for Puma Pids and Socket'
  task :make_dirs do
    on roles(:app) do
      execute "mkdir #{shared_path}/tmp/sockets -p"
      execute "mkdir #{shared_path}/tmp/pids -p"
    end
  end

  before :start, :make_dirs
end

namespace :deploy do
  desc "Make sure local git is in sync with remote."
  task :check_revision do
    on roles(:app) do
      unless `git rev-parse HEAD` == `git rev-parse origin/master`
        puts "WARNING: HEAD is not the same as origin/master"
        puts "Run `git push` to sync changes."
        # exit
      end
    end
  end

  desc 'Initial Deploy'
  task :initial do
    on roles(:app) do
      before 'deploy:restart', 'puma:start'
      invoke 'deploy'
    end
  end

  desc 'Build Frontend'
  task :build_client do
    on roles(:app), in: :sequence do
      # within "#{release_path}/client" do
        execute "cd #{release_path}/client; npm install"
        execute "cd #{release_path}/client; bower install"
        # execute "cd #{release_path}/client; gulp"
      # end
    end
  end

  desc 'Restart application'
  task :restart do
    on roles(:app), in: :sequence, wait: 5 do
      invoke 'puma:restart'
    end
  end

  before :starting,     :check_revision
  after  :finishing,    :build_client
  after  :finishing,    :cleanup
  after  :finishing,    :restart
end
