$:.unshift(File.expand_path('./lib', ENV['rvm_path'])) # Add RVM's lib directory to the load path.
require "rvm/capistrano"                  # Load RVM's capistrano plugin.
set :rvm_ruby_string, 'ree'

require 'bundler/capistrano'

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :application, "TryRuby"

default_run_options[:pty] = true  # Must be set for the password prompt from git to work
set :repository, "git@github.com:RabbitZ/TryRuby.git"  # Your clone URL
set :branch, "master"
set :scm, "git"
set :user, "tryruby"  # The server's user for deploys
set :deploy_to, "/var/rails/tryruby"
set :deploy_via, :remote_cache
set :use_sudo, false

ssh_options[:forward_agent] = true

set :git_shallow_clone, 1
set :git_enable_submodules, 1

role :web, "106.187.37.16"                          # Your HTTP server, Apache/etc
role :app, "106.187.37.16"                          # This may be the same as your `Web` server
role :db,  "106.187.37.16", :primary => true # This is where Rails migrations will run

# tasks
namespace :deploy do
  task :start, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end

  desc "Compile assets"
  task :assets do
    run "cd #{current_path}; chmod -R 0777 public/"
    #run "cd #{current_path}; RAILS_ENV=production rake assets:precompile"
  end

  task :stop, :roles => :app do
    # Do nothing.
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
    run "mkdir -p #{current_path}/tmp/cache"
    run "cd #{current_path}; chmod -R 0777 log/"
    run "cd #{current_path}; chmod -R 0777 tmp/"
  end

  desc "Symlink shared resources on each release"
  task :symlink_shared, :roles => :app do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{shared_path}/temp #{release_path}/public/temp"
    # run "ln -nfs #{shared_path}/config/newrelic.yml #{release_path}/config/newrelic.yml"
  end
end

after 'deploy:update_code', 'deploy:symlink_shared'
#after "deploy:symlink_shared", "deploy:assets"