require 'whenever/capistrano'

set :application, "yourapp"
set :domain, "yourhost"
set :scm, :git
set :repository,  "yourgitrepo"
set :branch, "master"
set :repository_cache, "git_cache"
set :deploy_via, :remote_cache
set :ssh_options, { :forward_agent => true }
set :user, "username"
default_run_options[:pty] = true
default_run_options[:shell] = false

role :web, domain
role :app, domain
role :db,  domain, :primary => true

set :use_sudo, false

set :deploy_to, "/www/#{application}"

namespace :deploy do
  task :start do ; end
  task :stop do ; end
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end

task :db_setup, :roles => :db do
  run "cd #{release_path}; rake db:setup RAILS_ENV=production"
end

after "deploy:update_code", :bundle_install, :assets_precompile

task :bundle_install, :roles => :app do
  run "cd #{release_path} && bundle install"
end
task :assets_precompile, :roles => :web do
  run "cd #{release_path}; rake assets:precompile"
end
