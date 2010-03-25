require 'rake'
require 'net/ssh'

desc 'Push local version onto production server'
task :deploy => [:sync, 'app:restart']

desc 'Use rsync to update the production server'
task :sync do
  sh "rsync --exclude 'shorten.js' --exclude '.git' --exclude '.gitignore' -rltvz -e ssh . avdgaag@avdgaag.webfactional.com:/home/avdgaag/webapps/shortener/shortener"
end

namespace :app do
  def ssh_sh(cmd)
    Net::SSH.start('avdgaag.webfactional.com', 'avdgaag', :verbose => :info) do |ssh|
      ssh.exec! cmd
    end
  end

  desc 'Start the app server'
  task :start do
    ssh_sh '/home/avdgaag/webapps/shortener/bin/start'
  end

  desc 'Stop the app server'
  task :stop do
    ssh_sh '/home/avdgaag/webapps/shortener/bin/stop'
  end

  desc 'Restart the application on the production server'
  task :restart do
    ssh_sh '/home/avdgaag/webapps/shortener/bin/restart'
  end
end

desc 'Run the app unit tests'
task :test do
  sh "ruby #{FileList['test_*.rb'].join(' ')}"
end

task :default => :test