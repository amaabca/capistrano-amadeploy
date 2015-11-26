module CapistranoDeploy
  module Environment
    def self.load_into(configuration)
      configuration.load do

        set(:environment_file) { ".env" }
        set(:temp_folder) { "./tmp/env_config" }
        set(:environment_branch) { "master" }

        namespace :environment do

          namespace :servers do
            desc "Copy ENV file from remote git repository to your staging/production servers"
            task :fetch_config, :roles => :app, :except => {:no_release => true} do
              if /^y/i =~ Capistrano::CLI.ui.ask("Do you wish to override the existing #{environment_file} file (y/n)? ")
                path_to_new_env = File.join deploy_to, "tmp", "env_config", app_name, ".env.#{current_stage}"
                path_to_old_env = File.join deploy_to, environment_file

                run "rm -rf #{deploy_to}/tmp/env_config && git clone -b #{environment_branch} -n #{environment_repository} --depth 1 #{deploy_to}/tmp/env_config"
                run "cd #{deploy_to}/tmp/env_config && git checkout HEAD #{app_name}/.env.#{current_stage}"
                run "cp #{path_to_new_env}  #{path_to_old_env}"
              else
                puts "Config not changed"
              end
            end

            task :verify do
              run "ssh-keyscan #{environment_host} | tee --append $HOME/.ssh/known_hosts"
            end
          end

          namespace :local do
            desc "Fetch ENV file from remote git repository to your local machine"
            task :fetch_config do
              require 'capistrano-deploy/utilities'
              utilities = ::CapistranoDeploy::Utilities.new(
                environment_file: environment_file,
                temp_folder: temp_folder,
                app_name: app_name,
                environment_repository: environment_repository
              )

              utilities.fetch_config
            end
          end

          before 'multistage:ensure', 'environment:local:fetch_config'
          after 'deploy:setup', 'environment:servers:verify'
          after 'environment:servers:verify', 'environment:servers:fetch_config'

        end

      end
    end
  end
end
